#version 120

/*
	GravityShade by Gravity10
	Code is licensed under GNU Lesser General Public License v2.1
	Thanks for using GravityShade!
*/

varying vec2 coord;

void main() {

	gl_Position = ftransform();
	coord = gl_MultiTexCoord0.xy;
	
}
