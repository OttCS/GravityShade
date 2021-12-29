/*
    GravityShade for the IRIS Shaders mod.
    Made by Gravity10, Code base by Sildur.
*/

#version 120

#define final
#include "shaders.settings"


varying vec2 texcoord;
varying vec4 color;

uniform sampler2D colortex0;

vec3 gravityTone(vec3 x, float adj) {
	return x / ((0.5 + adj) * x + (0.5 - adj)) / (1.0 + adj) - adj;
}

void main() {

	vec3 tex = texture2D(colortex0, texcoord).rgb * color.rgb;
	// gl_FragData[0] = vec4(gravityTone(tex, 0.0), 1.0);
	gl_FragData[0] = vec4(tex, 1.0);

}
