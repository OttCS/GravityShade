#version 120
/* DRAWBUFFERS:02 */ //0=gcolor, 2=gnormal for normals
/*
    GravityShade for the IRIS Shaders mod.
    Made by Gravity10, Code base by Sildur.
*/

#define gbuffers_textured
#include "shaders.settings"

//Setup constants
const int noiseTextureResolution = 64;
//----------------------------------------------------------------

/* Don't remove me
const int gcolorFormat = RGBA8;
const int gnormalFormat = RGB10_A2;
const int compositeFormat = RGBA8;
-----------------------------------------*/

varying vec4 color;
varying vec3 position;
varying vec3 vworldpos;
varying mat3 tbnMatrix;
varying vec2 texcoord;
varying vec2 lmcoord;
varying float mcID;
varying float mat;

uniform sampler2D noisetex;
uniform sampler2D texture;

uniform vec4 entityColor;
uniform vec3 shadowLightPosition;
uniform ivec2 eyeBrightnessSmooth;
uniform float far;
uniform float rainStrength;
uniform int heldBlockLightValue;
uniform int heldBlockLightValue2;
uniform int isEyeInWater;
uniform int entityId;
uniform int worldTime;

#ifdef Reflections

uniform float frameTimeCounter;

float calcBump(vec2 coord, bool iswater) {
	vec2 mDir = vec2(0.0);
	if (iswater) mDir.x = frameTimeCounter * animationSpeed * 0.025;
	float h0 = 0.0;
	h0 += texture2D(noisetex, coord * vec2(0.023, 0.019) - mDir.xx).x; // Default low res normalBump
	if (gl_FogFragCoord < 96.0) { // 6 Chunks medium res normalBump
		h0 += texture2D(noisetex, coord * vec2(0.113, 0.117) + mDir.yx).x * 0.6;
		if (gl_FogFragCoord < 32.0) { // 2 Chunks ULTRA high res normalBump
			h0 += texture2D(noisetex, coord * vec2(0.527, 0.371) + mDir.xy).x * 0.4;
			h0 -= 0.2;
		}
		h0 -= 0.3;
	}
	h0 -= 0.5;
	return h0;
}

#endif

vec3 blockLightMap(float val) {
	return vec3(emissive_R * pow(val, emissive_R * 0.5),emissive_G * pow(val, emissive_G * 0.5),emissive_B * pow(val, emissive_B * 0.5))*val;
}

#ifdef Shadows
varying float NdotL;
varying vec3 getShadowpos;
uniform sampler2DShadow shadowtex0;	//normal shadows
uniform sampler2DShadow shadowtex1; //colored shadows
uniform sampler2D shadowcolor0;

float shadowfilter(sampler2DShadow shadowtexture){
	return shadow2D(shadowtexture,vec3(getShadowpos.xy, getShadowpos.z)).x * NdotL;
}

float grayShade() {
	float shading = 1.0;
	if (rainStrength < 0.9) shading = min(1.0, 2.0 * shadowfilter(shadowtex0));
	shading *= smoothstep(0.0, 0.04, eyeBrightnessSmooth.y / 255.0);
	shading *= 1.0 - rainStrength;
	return shading;
}

vec4 encode (vec3 n){
    return vec4(n.xy*inversesqrt(n.z*8.0+8.0) + 0.5, mat/4.0, 1.0);
}

vec3 emissiveOreLightComp(vec3 lightComp, vec3 color) {
	float maxCol = max(color.r, max(color.g, color.b));
	if (maxCol > 0.40) {
		if (color.b + 0.1 < min(color.r, color.g)) return vec3(emissionStrength);
		float minCol = min(color.r, min(color.g, color.b));
		if (minCol + 0.18 < maxCol) return vec3(emissionStrength);
		if (minCol > 0.7) return vec3(emissionStrength);
	}
	return lightComp;
}

vec3 emissiveToneMap(vec3 color) {
	return color * (color + 0.5);
}

#include "lib/color.glsl"
#include "lib/useful.glsl"

void main() {
	bool overworld = isOverworld();

	vec4 tex = vec4(0.0);
	vec4 normal = vec4(0.0);

	vec3 skyLight = vec3(ambientLevel);
	vec3 ambLight = vec3(ambientLevel);
	if (isEyeInWater == 1) ambLight = waterCol;

	float rID = round(mcID); // Stupid varying floats are't precise enough

	if (overworld) {
		skyLight = currentSkyLight(worldTime, rainStrength); // Overworld
	} else {
		#ifdef END
			ambLight = vec3(0.60, 0.48, 0.60); // End
		#else
			ambLight = fogColor * 0.48 + vec3(0.28, 0.2, 0.24); // Nether
		#endif
	}

	float fogCover = 0.0;
	#ifdef Fog
		fogCover = smoothstep(FogOcclusionStart, FogOcclusionRadius, gl_FogFragCoord / far * (isEyeInWater * 2.0 + 1.0));
	#endif

	if (fogCover < 1.0) {
		tex = texture2D(texture, texcoord.st); // Get tex
		tex.rgb = mix(tex.rgb,entityColor.rgb,entityColor.a); // Fix for hurt

		float shade = smoothstep(0.88, 0.92, lmcoord.y) * (NdotL + 0.05);
		if (gl_FogFragCoord < shadowDistance * 1.125) {
			shade = mix(grayShade(), shade, smoothstep(1.0, 1.125, gl_FogFragCoord / shadowDistance));
		}
		shade = shade * slight + (1.0 - slight);

		vec3 lightComp = max(mix(ambLight, skyLight, lmcoord.y * shade), blockLightMap(lmcoord.x));

		// EMISSIVE BLOCKS WORK //
		if (rID == 10089.0 || rID == 10090.0 || rID == 10169.0) {
			tex.rgb = emissiveToneMap(tex.rgb);
			lightComp = vec3(lmcoord.x * emissionStrength * 0.8 + 0.2);
		} else if (rID == 10566.0) { // Emissive ores
			lightComp = emissiveOreLightComp(lightComp, tex.rgb);
		} else if(rID == 10998.0) { // Warped/Crimson Plants
			if (tex.g > 0.2 || tex.r > 0.34) {
				// tex.rgb = emissiveToneMap(tex.rgb);
				tex.rgb *= emissionStrength;
				lightComp = vec3(emissionStrength);
			}
		}

		// // ENTITY FIXES //
		// if (entityId == 11001) { // Fix Spiders
		// 	if (tex.r > tex.g + tex.b) lightComp = vec3(emissionStrength);
		// } else if (entityId == 11002) { // Fix Endermen
		// 	if (tex.r == 1.0) {
		// 		// tex.g *= 0.3;
		// 		lightComp = vec3(emissionStrength);
		// 	}
		// } else if (entityId == 11000) { // Fix Lightning
		// 	lightComp = vec3(emissionStrength);
		// }

		// Dynamic Handlight
		if (gl_FogFragCoord < 8.0 && (heldBlockLightValue > 0 || heldBlockLightValue2 > 0)) lightComp = max(lightComp, blockLightMap(max(heldBlockLightValue, heldBlockLightValue2) / 14.0 - gl_FogFragCoord / 8.0));

		// Normal Bumping
		vec2 coord = vworldpos.xz - vworldpos.y;
		if(mat > 0.9 && mat < 3.1) { // Standard reflections
			float bump = calcBump(coord.xy, mat < 1.1);
			normal = vec4(normalize(vec3(vec2(bump) * 0.03, 0.55) * tbnMatrix), 1.0);
			if (rID == 10008.0) {
				tex.a = 0.7;
				tex.rgb *= color.rgb * lightComp * 0.27 + waterCol;
			}
		} else if (mat > 3.9 && tex.r == tex.g && tex.r == tex.b) { // Metallic Accent Reflections
			float bump = calcBump(coord.xy, mat < 1.1);
			normal = vec4(normalize(vec3(vec2(bump) * 0.03, 0.55) * tbnMatrix), 1.0);
		}

		tex.rgb *= lightComp;

		if (rID != 10008.0) tex.rgb *= mix(vec3(1.0), color.rgb, color.a); // Avoid recoloring water
	} // Done with rendered effects

	vec3 fCol;
	#ifdef Fog
		if (overworld) {
			fCol = getOverworldFogColor(skyLight, eyeBrightnessSmooth.y);
		} else {
			fCol = getFogColor();
		}
		if (isEyeInWater == 1) fCol *= waterCol;
	#endif

	if (fogCover < 1.0) { // Visible
		gl_FragData[0] = vec4(mix(tex.rgb, fCol, fogCover), tex.a);
		if (rID == 10008.0) gl_FragData[0].a = mix(tex.a, 1.0, fogCover); // blendFogWithAlpha water
		gl_FragData[1] = encode(normal.xyz);
	} else { // Completely covered by fog, just render as fog color
		gl_FragData[0] = vec4(fCol, 1.0);
		#ifdef showFogOcclusion // Debug option
			gl_FragData[0] = vec4(1.0, 0.0, 0.0, 1.0);
		#endif
		gl_FragData[1] = vec4(0.0);
	}
}