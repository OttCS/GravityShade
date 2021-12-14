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

vec3 Uncharted2Tonemap(vec3 x) {
	float A = 0.28;
	float B = 0.29;		
	float C = 0.08;
	float D = 0.2;
	float E = 0.025;
	float F = 0.35;
	return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
}

void main() {

	vec3 tex = texture2D(colortex0, texcoord).rgb * color.rgb;
	gl_FragData[0] = vec4(Uncharted2Tonemap(tex)*2.2, 1.0);

}
