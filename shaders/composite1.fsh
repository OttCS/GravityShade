/*
    GravityShade for the IRIS Shaders mod.
    Made by Gravity10, Code base by Sildur.
*/

#version 120
/* DRAWBUFFERS:3 */

#define composite1
#include "shaders.settings"

varying vec2 texcoord;
uniform sampler2D colortex0;		//everything

void main() {

	gl_FragData[0] = texture2D(colortex0, texcoord);	//if TAA is disabled just passthrough data from composite0, previous buffer.

}
