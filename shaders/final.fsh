#version 120
/*
    GravityShade for the IRIS Shaders mod.
    Made by Gravity10, Code base by Sildur.
*/

#define final
#include "shaders.settings"

varying vec2 texcoord;
varying vec3 color;

uniform sampler2D colortex3;	//taa mixed with everything

#ifdef Tonemap
vec3 ACESFilm(vec3 x)
{
    float a = 2.51;
    float b = 0.03;
    float c = 2.43;
    float d = 0.59;
    float e = 0.14;
    return (x*(a*x+b))/(x*(c*x+d)+e);
}

vec3 MildACES(vec3 x) {
	return 1.08*x*x/(x*(1.5*x)+0.3)+0.4*x;
}
#endif

void main() {

	vec3 tex = texture2D(colortex3, texcoord.xy).rgb*color;
	#ifdef Tonemap
        #ifdef CustomACES
		    tex.rgb = MildACES(tex);
        #endif
	#endif
	gl_FragData[0] = vec4(tex, 1.0);
}
