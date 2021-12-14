/*
    GravityShade for the IRIS Shaders mod.
    Made by Gravity10, Code base by Sildur.
*/

#version 120

#define shadowprogram
#include "shaders.settings"

varying vec3 texcoord;
attribute vec4 mc_Entity;

#ifdef Shadows
vec2 calcShadowDistortion(in vec2 shadowpos) {
	float distortion = ((1.0 - SHADOW_MAP_BIAS) + length(shadowpos.xy * 1.25) * SHADOW_MAP_BIAS) * 0.85;
	return shadowpos.xy / distortion;
}
#endif

void main() {

vec4 position = gl_ModelViewProjectionMatrix * gl_Vertex;
#ifdef Shadows
	 position.xy = calcShadowDistortion(position.xy);
#endif

	gl_Position = position;

	texcoord.xy = (gl_MultiTexCoord0).xy;
	texcoord.z = 1.0;

	if(mc_Entity.x == 10008.0) texcoord.z = 0.0;
#ifndef grass_shadows
	if(mc_Entity.x == 10031.0 || mc_Entity.x == 10175.0 || mc_Entity.x == 10176.0) texcoord.z = 0.0;	
#endif
}
