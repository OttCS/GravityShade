#version 120
/*
    GravityShade for the IRIS Shaders mod.
    Made by Gravity10, Code base by Sildur.
*/

#define gbuffers_textured
#define shadowprogram
#include "shaders.settings"

//Moving entities IDs
//See block.properties for mapped ids
#define ENTITY_SMALLGRASS   10031.0	//
#define ENTITY_LOWERGRASS   10175.0	//lower half only in 1.13+
#define ENTITY_UPPERGRASS	10176.0 //upper half only used in 1.13+
#define ENTITY_SMALLENTS    10059.0	//sapplings(6), dandelion(37), rose(38), carrots(141), potatoes(142), beetroot(207)

#define ENTITY_LEAVES       10018.0	//161 new leaves
#define ENTITY_VINES        10106.0

#define ENTITY_WATER		10008.0	//9
#define ENTITY_LILYPAD      10111.0	//
#define ENTITY_ICE			10079.0	//transparent reflections, stained glass(95, 160), slimeblock(165)

#define ENTITY_FIRE         10051.0	//
#define ENTITY_LAVA   		10010.0	//11
#define ENTITY_EMISSIVE		10089.0 //emissive blocks defined in block.properties
#define ENTITY_WAVING_LANTERN 10090.0
#define ENTITY_INVERTED_LOWER 10177.0	//hanging_roots

varying vec4 color;
varying vec3 vworldpos;
varying mat3 tbnMatrix;
varying vec2 texcoord;
varying vec2 lmcoord;
varying float iswater;
varying float mcID;
varying float mat;

attribute vec4 mc_Entity;
attribute vec4 mc_midTexCoord;
attribute vec4 at_tangent;                      //xyz = tangent vector, w = handedness, added in 1.7.10

uniform vec3 cameraPosition;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

//moving stuff
uniform float frameTimeCounter;
uniform float far;
const float PI = 3.14;
float pi2wt = (150.79*frameTimeCounter) * animationSpeed;

vec3 calcWave(in vec3 pos, in float fm, in float mm, in float ma, in float f0, in float f1, in float f2, in float f3, in float f4, in float f5) {
	float magnitude = sin(pi2wt*fm + dot(pos, vec3(0.5))) * mm + ma;
	vec3 d012 = sin(vec3(f0, f1, f2)*pi2wt);
	
    vec3 ret;
		 ret.x = pi2wt*f3 + d012.x + d012.y - pos.x + pos.z + pos.y;
		 ret.z = pi2wt*f4 + d012.y + d012.z + pos.x - pos.z + pos.y;
		 ret.y = pi2wt*f5 + d012.z + d012.x + pos.z + pos.y - pos.y;
		 ret = sin(ret)*magnitude;
	
    return ret;
}

vec3 calcMove(in vec3 pos, in float f0, in float f1, in float f2, in float f3, in float f4, in float f5, in vec3 amp1, in vec3 amp2) {
    vec3 move1 = calcWave(pos      , 0.0027, 0.0400, 0.0400, 0.0127, 0.0089, 0.0114, 0.0063, 0.0224, 0.0015) * amp1;
	vec3 move2 = calcWave(pos+move1, 0.0348, 0.0400, 0.0400, f0, f1, f2, f3, f4, f5) * amp2;
    return move1+move2;
}/*---*/

#ifdef Shadows
varying float NdotL;
uniform vec3 shadowLightPosition;
#endif

#ifdef TAA
uniform float viewWidth;
uniform float viewHeight;
vec2 texelSize = vec2(0.97 / viewWidth, 0.97 / viewHeight);
uniform int framemod8;
const vec2[8] offsets = vec2[8](vec2(1./8.,-3./8.),
								vec2(-1.,3.)/8.,
								vec2(5.0,1.)/8.,
								vec2(-3,-5.)/8.,
								vec2(-5.,5.)/8.,
								vec2(-7.,-1.)/8.,
								vec2(3,7.)/8.,
								vec2(7.,-7.)/8.);
#endif

#include "lib/useful.glsl"

void main() {

	mcID = mc_Entity.x;

	//Positioning
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	vec3 position = mat3(gbufferModelViewInverse) * (gl_ModelViewMatrix * gl_Vertex).xyz + gbufferModelViewInverse[3].xyz;

	vworldpos = position.xyz + cameraPosition;
	bool istopv = gl_MultiTexCoord0.t < mc_midTexCoord.t;

#ifdef Waving_Tallgrass
if (mcID == ENTITY_LOWERGRASS && istopv || mcID == ENTITY_UPPERGRASS)
			position.xyz += calcMove(vworldpos.xyz,
			0.0041,
			0.0070,
			0.0044,
			0.0038,
			0.0240,
			0.0000,
			vec3(0.8,0.0,0.8),
			vec3(0.4,0.0,0.4));

#endif
if (istopv) {
#ifdef Waving_Grass
	if ( mcID == ENTITY_SMALLGRASS) {
		position.xyz += calcMove(vworldpos.xyz, 0.0041, 0.0070, 0.0044, 0.0038, 0.0063, 0.0000, vec3(3.0,1.6,3.0), vec3(0.0,0.0,0.0));
	}
#endif
#ifdef Waving_Entities
	if (mcID == ENTITY_SMALLENTS)
			position.xyz += calcMove(vworldpos.xyz,
			0.0041,
			0.0070,
			0.0044,
			0.0038,
			0.0240,
			0.0000,
			vec3(0.8,0.0,0.8),
			vec3(0.4,0.0,0.4));
#endif
}

#ifdef Waving_Leaves
	if ( mcID == ENTITY_LEAVES)
			position.xyz += calcMove(vworldpos.xyz,
			0.0040,
			0.0064,
			0.0043,
			0.0035,
			0.0037,
			0.0041,
			vec3(1.0,0.2,1.0),
			vec3(0.5,0.1,0.5));
#endif
#ifdef Waving_Vines
	if ( mcID == ENTITY_VINES)
			position.xyz += calcMove(vworldpos.xyz,
			0.0040,
			0.0064,
			0.0043,
			0.0035,
			0.0037,
			0.0041,
			vec3(0.5,1.0,0.5),
			vec3(0.25,0.5,0.25));

	if (mcID == ENTITY_INVERTED_LOWER && gl_MultiTexCoord0.t > mc_midTexCoord.t)
			position.xyz += calcMove(vworldpos.xyz,
			0.0041,
			0.0070,
			0.0044,
			0.0038,
			0.0240,
			0.0000,
			vec3(0.8,0.0,0.8),
			vec3(0.4,0.0,0.4));				
#endif
	iswater = 0.0;
	if(mcID == ENTITY_WATER) iswater = 0.95;	//don't fully remove shadows on water plane
#ifdef Waving_Water
	if(mcID == ENTITY_WATER || mcID == ENTITY_LILYPAD) { //water, lilypads
		float fy = fract(vworldpos.y + 0.001);
		float wave = 0.05 * sin(2 * PI * (frameTimeCounter*0.8 + vworldpos.x /  2.5 + vworldpos.z / 5.0))
				   + 0.05 * sin(2 * PI * (frameTimeCounter*0.6 + vworldpos.x / 6.0 + vworldpos.z /  12.0));
		position.y += clamp(wave, -fy, 1.0-fy)*waves_amplitude;
	}
#endif

#ifdef Waving_Lanterns
	if(mcID == ENTITY_WAVING_LANTERN){
		vec3 fxyz = fract(vworldpos.xyz + 0.001);
		float wave = 0.025 * sin(2.0 * PI * (frameTimeCounter*0.4 + vworldpos.x * 0.5 + vworldpos.z * 0.5));
		float waveY = 0.05 * cos(frameTimeCounter*2.0 + vworldpos.y);
		position.x -= clamp(wave, -fxyz.x, 1.0-fxyz.x);
		position.y += clamp(waveY*0.25, -fxyz.y, 1.0-fxyz.y)+0.015;		
		position.z += clamp(wave*0.45, -fxyz.z, 1.0-fxyz.z);
	}
#endif

	mat = 0.0;
	if(mcID == ENTITY_WATER) {
		mat = 1.0;
	} else if(mcID == ENTITY_ICE) {
		mat = 2.0;
	} else if(mcID == 10042.0 || mcID == 10169.0) { // POLISHED BLOCKS
		mat = 3.0;
	} else if(mcID == 10001.0) { // METALLIC ACCENTS
		mat = 4.0;
	}
	gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(position, 1.0);

	//Fog
	gl_FogFragCoord = length(position.xyz);

	#ifdef TAA
		gl_Position.xy += offsets[framemod8] * gl_Position.w * texelSize;
	#endif

	color = gl_Color;

	//Fix colors on emissive blocks
	if(mcID == 10089.0 ||  mcID == 10090.0) color = vec4(1.0);

	//Bump & Parallax mapping
	vec3 normal = normalize(gl_NormalMatrix * gl_Normal);	
	vec3 tangent = normalize(gl_NormalMatrix * at_tangent.xyz);
	vec3 binormal = normalize(gl_NormalMatrix * cross(at_tangent.xyz, gl_Normal.xyz) * at_tangent.w);
	tbnMatrix = mat3(tangent.x, binormal.x, normal.x,
					 tangent.y, binormal.y, normal.y,
					 tangent.z, binormal.z, normal.z);					 
	

	#ifdef Shadows
		#ifndef NOSKYLIGHT // Handle Skylit dimensions
			if (mcID == ENTITY_SMALLGRASS
			|| mcID == ENTITY_LOWERGRASS
			|| mcID == ENTITY_UPPERGRASS
			|| mcID == ENTITY_SMALLENTS
			|| mcID == ENTITY_LEAVES
			|| mcID == ENTITY_VINES
			|| mcID == ENTITY_LILYPAD
			|| mcID == ENTITY_FIRE
			|| mcID == ENTITY_WAVING_LANTERN	
			|| mcID == ENTITY_EMISSIVE	
			|| mcID == 10030.0	//cobweb	
			|| mcID == 10115.0 //nether wart
			|| mcID == 10576.0 //spore blossom	
			|| mcID == 10006.0) {
				NdotL = 0.7;
			} else {
				NdotL = clamp(dot(normal, normalize(shadowLightPosition))*1.01-0.01,0.0,1.0);
			}
		#endif
	#endif
}