#version 120

/*
	GravityShade by Gravity10
	Code is licensed under GNU Lesser General Public License v2.1
	Thanks for using GravityShade!
*/

uniform sampler2D texture;

varying vec3 color;
varying vec2 lmcoord;
varying vec2 texcoord;

#include "lib/light.glsl"

void main() {

	// Texture Adjustments
	vec3 texColor = texture2D(texture, texcoord).rgb * color.rgb;
	texColor *= -0.5f * texColor + 1.5f; // Gravity10 Tonemap

	gl_FragData[0] = vec4(texColor * trueLight(lmcoord), texture2D(texture, texcoord).a);
}

// NOTES //

// Don't use "lightmap" sampler: slow and lmcoord.rg can be exploited for the same result with more customisation