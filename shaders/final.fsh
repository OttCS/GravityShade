/*
    GravityShade for the IRIS Shaders mod.
    Made by Gravity10, Code base by Sildur.
*/

#version 120

#define final
#include "shaders.settings"
#include "lib/useful.glsl"


varying vec2 texcoord;
varying vec4 color;

uniform sampler2D colortex0;

void main() {

	vec3 tex = texture2D(colortex0, texcoord).rgb * color.rgb;
	#ifdef Tonemap
		#ifdef CustomACES
			tex.rgb = MildACES(tex.rgb);
		#endif
	#endif
	gl_FragData[0] = vec4(tex, 1.0);
	// gl_FragData[0] = vec4(tex, 1.0);

}
