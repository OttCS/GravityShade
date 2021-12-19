#version 120

#include "shaders.settings"

varying vec4 color;

void main() {
	gl_Position = ftransform();
	gl_FogFragCoord = gl_Position.z;
	color = gl_Color;
}
