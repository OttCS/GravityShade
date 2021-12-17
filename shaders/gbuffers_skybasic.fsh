/*
    GravityShade for the IRIS Shaders mod.
    Made by Gravity10, Code base by Sildur.
*/

#version 120
/* DRAWBUFFERS:02 */ //0=gcolor, 2=gnormal for normals

varying vec4 color;

uniform ivec2 eyeBrightnessSmooth;
uniform float rainStrength;
uniform int worldTime;

#include "lib/color.glsl"
#include "lib/useful.glsl"

void main() {
    
	bool overworld = isOverworld();

    vec3 fCol = getFogColor();
	if (overworld) {
		fCol = mix(fCol, currentSkyLight() * 0.7, eyeBrightnessSmooth.y / 256.0);
	}
    if (overworld) {
        // gl_FragData[0] = vec4(mix(color.rgb, fCol, clamp((gl_FogFragCoord + 0.0) * 0.03, 0.0, 1.0)),color.a);
        gl_FragData[0] = vec4(fCol, color.a);
    } else {
        gl_FragData[0] = vec4(fCol, 1.0);
    }

    gl_FragData[1] = vec4(0.0); //fills normal buffer with 0.0, improves overall performance
}
