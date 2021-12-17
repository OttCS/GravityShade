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

void main() {

	gl_FragData[0] = texture2D(texture, texcoord.xy)*color;
	gl_FragData[1] = vec4(0.0); //fill normal buffer with 0.0, improves performance

}
