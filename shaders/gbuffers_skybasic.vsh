#version 120
/*
    GravityShade for the IRIS Shaders mod.
    Made by Gravity10, Code base by Sildur.
*/

#include "shaders.settings"

varying vec4 color;

void main() {
	gl_Position = ftransform();
	gl_FogFragCoord = gl_Position.z;
	color = gl_Color;
}
