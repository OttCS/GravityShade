/*
    GravityShade for the IRIS Shaders mod.
    Made by Gravity10, Code base by Sildur.
*/

#version 120
/* DRAWBUFFERS:02 */ //0=gcolor, 2=gnormal for normals

#define gbuffers_clouds
#include "shaders.settings"

varying vec2 texcoord;
varying vec4 color;

uniform sampler2D texture;

uniform float rainStrength;
uniform int worldTime;

#include "lib/color.glsl"

void main() {

	gl_FragData[0] = texture2D(texture, texcoord.xy * (1.0 + rainStrength))*vec4(currentSkyLight(worldTime, rainStrength), 1.0);
	gl_FragData[1] = vec4(0.0);

}
