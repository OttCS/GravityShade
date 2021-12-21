/*
    GravityShade for the IRIS Shaders mod.
    Made by Gravity10, Code base by Sildur.
*/

#version 120
/* DRAWBUFFERS:02 */ //0=gcolor, 2=gnormal for normals

#define gbuffers_textured
#include "shaders.settings"

//Setup constants
const int	noiseTextureResolution = 128;
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
varying float iswater;
varying float mcID;
varying float mat;

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

uniform sampler2D noisetex;

uniform float frameTimeCounter;

mat2 rmatrix(float rad){
	return mat2(vec2(cos(rad), -sin(rad)), vec2(sin(rad), cos(rad)));
}

float calcWaves(vec2 coord){
	vec2 movement = abs(vec2(0.0, -frameTimeCounter * 0.31365*iswater)) * animationSpeed;
		 
	coord *= 0.262144;
	vec2 coord0 = coord * rmatrix(1.0) - movement * 4.0;
		 coord0.y *= 3.0;
	vec2 coord1 = coord * rmatrix(0.5) - movement * 1.5;
		 coord1.y *= 3.0;		 
	vec2 coord2 = coord + movement * 0.5;
		 coord2.y *= 3.0;
	
	float wave = 1.0 - texture2D(noisetex,coord0 * 0.005).x * 10.0;		//big waves
		  wave += texture2D(noisetex,coord1 * 0.010416).x * 7.0;		//small waves
		  wave += sqrt(texture2D(noisetex,coord2 * 0.045).x * 6.5) * 1.33;//noise texture
		  wave *= 0.0157;
	
	return wave;
}

vec3 calcBump(vec2 coord){
	if (mat > 2.1) return vec3(0.0, 0.0, 0.55);
	float xDelta = 0.0;
	float yDelta = 0.0;
	if (mat < 2.1) {
		const vec2 deltaPos = vec2(0.25, 0.0);
		float h0 = calcWaves(coord);
		xDelta = ((calcWaves(coord + deltaPos.xy)-h0)+(h0-calcWaves(coord - deltaPos.xy)));
		yDelta = (1.0 + iswater) * ((calcWaves(coord + deltaPos.yx)-h0)+(h0-calcWaves(coord - deltaPos.yx)));
	}
	return vec3(vec2(xDelta,yDelta)*0.45, 0.55);
}

#endif

// vec3 emissiveLight = vec3(emissive_R * pow(lmcoord.x, emissive_R * 0.5),emissive_G * pow(lmcoord.x, emissive_G * 0.5),emissive_B * pow(lmcoord.x, emissive_B * 0.5))*lmcoord.x;
vec3 emissiveLight = vec3(emissive_R,emissive_G,emissive_B)*pow(lmcoord.x, 1.6);

#ifdef Shadows
varying float NdotL;
varying vec3 getShadowpos;
uniform sampler2DShadow shadowtex0;	//normal shadows
uniform sampler2DShadow shadowtex1; //colored shadows
uniform sampler2D shadowcolor0;

float shadowfilter(sampler2DShadow shadowtexture){
	vec2 offset = vec2(0.25, -0.25) / shadowMapResolution;	
	return clamp(dot(vec4(shadow2D(shadowtexture,vec3(getShadowpos.xy + offset.xx, getShadowpos.z)).x,
						  shadow2D(shadowtexture,vec3(getShadowpos.xy + offset.yx, getShadowpos.z)).x,
						  shadow2D(shadowtexture,vec3(getShadowpos.xy + offset.xy, getShadowpos.z)).x,
						  shadow2D(shadowtexture,vec3(getShadowpos.xy + offset.yy, getShadowpos.z)).x),vec4(0.25))*NdotL,0.0,1.0);
}

vec3 calcShadows(vec3 c){
	vec3 finalShading = vec3(0.0);

if(NdotL > 0.0 && rainStrength < 0.9){ //optimization, disable shadows during rain for performance boost
	float shading = shadowfilter(shadowtex0);
	float cshading = shadowfilter(shadowtex1);
	finalShading = texture2D(shadowcolor0, getShadowpos.xy).rgb*(cshading-shading) + shading;
	//avoid light leaking underground
	finalShading *= mix(max(lmcoord.t-2.0/16.0,0.0)*1.14285714286,1.0,clamp((eyeBrightnessSmooth.y/255.0-2.0/16.)*4.0,0.0,1.0));
	finalShading *= (1.0 - rainStrength) * (1.0 - iswater);
}
	
return c * (1.0+finalShading+emissiveLight) * slight;
}
#endif

vec4 encode (vec3 n){
    return vec4(n.xy*inversesqrt(n.z*8.0+8.0) + 0.5, mat/4.0, 1.0);
}

vec3 emissiveLightComp(vec3 lightComp, vec3 color) {
	return max(lightComp, vec3(emissionStrength) * smoothstep(0.12, 0.24, max(color.r, max(color.g, color.b)) - min(color.r, min(color.g, color.b))));
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
	vec3 skyLight = vec3(0.3);
	vec3 ambLight = vec3(0.3);

	float rID = round(mcID); // Stupid varying floats are't precise enough

	if (overworld) {
		skyLight = currentSkyLight(worldTime, rainStrength); // Overworld
	} else {
		#ifdef END
			ambLight = vec3(0.7, 0.6, 0.7); // End
		#else
			ambLight = fogColor * 0.6 + 0.4; // Nether
		#endif
	}
	vec3 lightComp = max(mix(ambLight, skyLight, lmcoord.y), emissiveLight);

	float fogCover = 0.0;
	#ifdef Fog
		fogCover = smoothstep(0.2, 0.997, gl_FogFragCoord / far * (isEyeInWater * 2.0 + 1.0));
	#endif

	if (fogCover < 1.0) {
		tex = texture2D(texture, texcoord.st); // Get tex
		tex.rgb = mix(tex.rgb,entityColor.rgb,entityColor.a); // Fix for hurt
	
		// EMISSIVE BLOCKS WORK //
		if (rID == 10089.0 || rID == 10090.0) {
			tex.rgb = emissiveToneMap(tex.rgb);
			lightComp = vec3(lmcoord.x * 0.8 + 0.2);
		} else if (rID == 10566.0) { // Emissive ores
			lightComp = emissiveLightComp(lightComp, tex.rgb);
		} else if(rID == 10998.0) { // Warped/Crimson Plants
			if (tex.g > 0.2 || tex.r > 0.34) {
				tex.rgb = emissiveToneMap(tex.rgb);
				lightComp = emissiveLightComp(lightComp, tex.rgb);
			}
		}
		if (gl_FogFragCoord < 17.0) lightComp = max(lightComp, mix(vec3(0.0), vec3(emissive_R,emissive_G,emissive_B), smoothstep(4.0, 16.0, max(heldBlockLightValue, heldBlockLightValue2) - gl_FogFragCoord)));
		tex.rgb *= mix(vec3(1.0), color.rgb, color.a) * lightComp;
		// heldBlockLightValue
	
		#ifdef Shadows
			if (overworld) tex.rgb = calcShadows(tex.rgb);
		#endif

		// WACKY FIXES //
		if (rID == 10008.0){ // Fix water
			tex.a = 0.8;
			tex.rgb = waterCol * (lightComp + 0.16);
		}  else if (entityId == 11000) { // Fix Lightning
			tex = vec4(0.9, 0.8, 1.0, 0.5);
		}

		#ifdef Reflections	
			vec2 waterpos = (vworldpos.xz - vworldpos.y);
			if(mat > 0.9) normal = vec4(normalize(calcBump(waterpos) * tbnMatrix), 1.0);
		#endif
	} // Done with rendered effects

	vec3 fCol;
	#ifdef Fog
		if (overworld) {
			fCol = getOverworldFogColor(skyLight * 0.7, eyeBrightnessSmooth.y);
		} else {
			fCol = getFogColor();
		}
		if (isEyeInWater == 1) fCol *= waterCol * (lightComp + 1.8);
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