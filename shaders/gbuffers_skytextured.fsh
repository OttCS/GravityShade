#version 120
/* DRAWBUFFERS:02 */ //0=gcolor, 2=gnormal for normals
/*
    GravityShade for the IRIS Shaders mod.
    Made by Gravity10, Code base by Sildur.
*/

varying vec2 texcoord;
varying vec4 color;
uniform sampler2D texture;

#include "lib/math.glsl"

void main() {
	gl_FragData[0] = texture2D(texture, texcoord.xy);
    gl_FragData[1] = vec4(0.0); //fills normal buffer with 0.0, improves overall performance
}
