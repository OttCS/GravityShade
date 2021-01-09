#version 120

/*
	GravityShade by Gravity10
	Code is licensed under GNU Lesser General Public License v2.1
	Thanks for using GravityShade!
*/

uniform sampler2D colortex0;

varying vec2 coord;

const float sunPathRotation = -27.0;

void main() {
	vec3 color = texture2D(colortex0, coord).rgb;
	gl_FragData[0] = vec4(color, 1.0f);
}