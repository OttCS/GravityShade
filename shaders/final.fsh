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
vec3 MildACES(vec3 x) {
	return 1.8*x*x/(x*(1.5*x)+0.3);
}
#endif

void main() {

	vec3 tex = texture2D(colortex3, texcoord.xy).rgb*color;
	#ifdef Tonemap
		tex.rgb = MildACES(tex);
	#endif
	gl_FragData[0] = vec4(tex, 1.0);
}
