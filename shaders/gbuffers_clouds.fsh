/*
    GravityShade for the IRIS Shaders mod.
    Made by Gravity10, Code base by Sildur.
*/

#version 120
/* DRAWBUFFERS:02 */ //0=gcolor, 2=gnormal for normals

#define gbuffers_clouds
#include "shaders.settings"

varying vec2 texcoord;
varying vec4 color;
uniform sampler2D texture;

#ifdef Fog
const int GL_LINEAR = 9729;
const int GL_EXP = 2048;
uniform int fogMode;
#endif

void main() {

	gl_FragData[0] = texture2D(texture, texcoord.xy)*color;
	gl_FragData[1] = vec4(0.0); //fill normal buffer with 0.0, improves performance

#ifdef Fog
	if (fogMode == GL_EXP) {
		gl_FragData[0].rgb = mix(gl_FragData[0].rgb, gl_Fog.color.rgb, 1.0 - clamp(exp(-gl_Fog.density * gl_FogFragCoord), 0.0, 1.0));
	} else if (fogMode == GL_LINEAR) {
		gl_FragData[0].rgb = mix(gl_FragData[0].rgb, gl_Fog.color.rgb, clamp((gl_FogFragCoord - gl_Fog.start) * gl_Fog.scale, 0.0, 1.0));
	}
#endif	
}
