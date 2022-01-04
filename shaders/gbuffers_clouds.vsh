#version 120
/*
    GravityShade for the IRIS Shaders mod.
    Made by Gravity10, Code base by Sildur.
*/

#define composite1
#include "shaders.settings"

varying vec2 texcoord;
varying vec4 color;

void main() {
	gl_Position = ftransform();
	gl_FogFragCoord = length(gl_Position.xyz);
	texcoord = (gl_MultiTexCoord0).xy;
	color = gl_Color;
}
