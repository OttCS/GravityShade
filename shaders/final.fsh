#version 120

/*
	GravityShade by Gravity10
	Code is licensed under GNU Lesser General Public License v2.1
	Thanks for using GravityShade!
*/

uniform sampler2D gcolor;
varying vec2 coord;

void main() {
	vec3 color = texture2D(gcolor, coord).rgb;

	gl_FragData[0] = vec4(color, 1.0f);

}