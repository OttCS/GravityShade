/*
    GravityShade for the IRIS Shaders mod.
    Made by Gravity10, Code base by Sildur.
*/

#version 120

#define final
#include "shaders.settings"

varying vec2 texcoord;
varying vec4 color;

uniform sampler2D colortex0;	//taa mixed with everything

#ifdef Tonemap
vec3 Uncharted2Tonemap(vec3 x) {
	float A = 0.28;
	float B = 0.29;		
	float C = 0.08;	//default 0.010
	float D = 0.2;
	float E = 0.025;
	float F = 0.35;
	return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
}
#endif

void main() {

	vec3 tex = texture2D(colortex0, texcoord).rgb * color.rgb;

	tex = Uncharted2Tonemap(tex)*gamma;

	gl_FragData[0] = vec4(tex, 1.0);
}
