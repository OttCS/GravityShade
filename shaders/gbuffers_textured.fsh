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
varying float mcID;
varying float iswater;
varying float mat;

uniform sampler2D normals;
uniform sampler2D texture;
uniform sampler2D lightmap;
uniform float rainStrength;
uniform vec4 entityColor;
uniform int isEyeInWater;
uniform int entityId;
uniform ivec2 eyeBrightnessSmooth;
uniform vec3 shadowLightPosition;
uniform int worldTime;

uniform vec3 fogColor;

#ifdef Fog
const int GL_LINEAR = 9729;
const int GL_EXP = 2048;
uniform int fogMode;
#endif

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
	if (mat > 2.0) { // Smoother blocks
		return vec3(0.0, 0.0, 0.55);
	}
	const vec2 deltaPos = vec2(0.25, 0.0);

	float h0 = calcWaves(coord);
	float h1 = calcWaves(coord + deltaPos.xy);
	float h2 = calcWaves(coord - deltaPos.xy);
	float h3 = calcWaves(coord + deltaPos.yx);
	float h4 = calcWaves(coord - deltaPos.yx);

	float xDelta = ((h1-h0)+(h0-h2));
	float yDelta = (1.0 + iswater) * ((h3-h0)+(h0-h4));

	return vec3(vec2(xDelta,yDelta)*0.45, 0.55); //z = 1.0-0.5
}

#endif

#ifdef Shadows
varying float NdotL;
varying vec3 getShadowpos;
uniform sampler2DShadow shadowtex0;	//normal shadows
uniform sampler2DShadow shadowtex1; //colored shadows
uniform sampler2D shadowcolor0;

//Hacky lightmap setup for emissive blocks, todo
float modlmap = 13.0-lmcoord.s*12.35; 
float torch_lightmap = max(1.5/(modlmap*modlmap)-0.00945,0.0);
vec3 emissiveLight = clamp(vec3(1.25)*torch_lightmap, 0.0, 1.0); //emissive lightmap

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
    return vec4(n.xy*inversesqrt(n.z*8.0+8.0) + 0.5, mat/2.0, 1.0);
}

float smoothstep(float edge0, float edge1, float x) {
	float t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
	return t * t * (3.0 - 2.0 * t);
}

vec3 mix3(vec3 a, vec3 b, vec3 c, float param) {

	if (param < 0.5) {
		return mix(a, b, param * 2.0);
	}

	return mix(b, c, param * 2.0 - 1.0);

	return vec3(0.0);

}

vec3 getOverworldSkyLighting (int tick) {

	vec3 rise = vec3(1.0, 0.7, 0.4);
	vec3 noon = vec3(1.2, 1.1, 1.0);
	vec3 set = vec3(1.0, 0.4, 0.7);
	vec3 night = vec3(0.2, 0.3, 0.4);

	vec3 res = night;

	if (tick < 1900) {
		res = mix3(night, rise, noon, smoothstep(0.0, 1900.0, tick));
	} else if (tick < 13065) {
		res = noon;
	} else if (tick < 15255) {
		res = mix3(noon, set, night, smoothstep(13065.0, 15255.0, tick));
	}

	return res * mix(vec3(1.0), vec3(0.6, 0.8, 0.7), rainStrength);
}

bool isOverworld () {
	#ifdef END
		return false;
	#endif
	#ifdef NETHER
		return false;
	#endif
	return true;
}

void main() {

	//Mix default MC skylight with custom emissive light
	vec4 tex = texture2D(texture, texcoord.st) * color;

	vec3 skyLight = vec3(1.0);
	vec3 ambLight = vec3(0.2);

	if (isOverworld()) {
		skyLight = getOverworldSkyLighting((worldTime + 1450) % 24000); // Overworld
	} else {
		#ifdef END
			ambLight = vec3(0.8, 0.7, 0.8); // End
		#else
			ambLight = fogColor * 0.4 + 0.6; // Nether
		#endif
	}
	
	vec3 lightComp = max(mix(ambLight, skyLight, lmcoord.y), vec3(emissive_R * pow(lmcoord.x, emissive_R),emissive_G * pow(lmcoord.x, emissive_G),emissive_B * pow(lmcoord.x, emissive_B))*lmcoord.x-0.5/16.0);
	tex.rgb *= lightComp;


	vec4 normal = vec4(0.0); //fill the buffer with 0.0 if not needed, improves performance

#ifdef Shadows
	tex.rgb = calcShadows(tex.rgb);
#endif

// Fix Red Entities
tex.rgb = mix(tex.rgb,entityColor.rgb,entityColor.a);

#ifdef Reflections	
	vec2 waterpos = (vworldpos.xz - vworldpos.y);
	if(mat > 0.9)normal = vec4(normalize(calcBump(waterpos) * tbnMatrix), 1.0); //mat > 0.9 so that only reflective blocks alter normals, boosts performance by about 30%. mat=reflective
#endif

if(iswater > 0.1){
	if(isEyeInWater > 0) {
		tex.a = 0.4;
	}
	tex.rgb = vec3(0.08, 0.16, 0.32) * lightComp + 0.2;
}

	//Fix lightning bolts
	if(entityId == 11000) tex = vec4(vec3(1.0), 0.5);
	
#ifdef Fog
	tex.rgb = mix(tex.rgb, gl_Fog.color.rgb, pow(clamp((gl_FogFragCoord - gl_Fog.start) * gl_Fog.scale, 0.0, 1.0), 4.0));
#endif

	gl_FragData[0] = tex;
	gl_FragData[1] = encode(normal.xyz);
}