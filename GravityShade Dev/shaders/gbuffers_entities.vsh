#version 120

/*
	GravityShade by Gravity10
	Code is licensed under GNU Lesser General Public License v2.1
	Thanks for using GravityShade!
*/

varying vec2 lmcoord;
varying vec2 texcoord;

void main() {

	gl_Position = ftransform();

	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).rg;
	texcoord = gl_MultiTexCoord0.xy;
	
}
