#version 120
/* DRAWBUFFERS:02 */ //0=gcolor, 2=gnormal for normals
/*
    GravityShade for the IRIS Shaders mod.
    Made by Gravity10, Code base by Sildur.
*/

#define gbuffers_textured
#include "shaders.settings"

/* Don't remove me
const int gcolorFormat = RGBA8;
const int gnormalFormat = RGB10_A2;
const int compositeFormat = RGBA8;
-----------------------------------------*/

varying vec4 color;
varying vec2 texcoord;

uniform sampler2D texture;

uniform vec4 entityColor;
uniform ivec2 eyeBrightnessSmooth;
uniform float blindness;
uniform float far;
uniform float rainStrength;
uniform int isEyeInWater;
uniform int worldTime;

#include "lib/color.glsl"
#include "lib/useful.glsl"

void main() {
	bool overworld = isOverworld();

	vec4 tex = vec4(0.0);
	vec4 normal = vec4(0.0);

	vec3 skyLight = vec3(ambientLevel);
	vec3 ambLight = vec3(ambientLevel);
	if (isEyeInWater == 1) ambLight = waterCol;

	if (overworld) {
		skyLight = currentSkyLight(worldTime, rainStrength); // Overworld
	} else {
		#ifdef END
			ambLight = vec3(0.72, 0.60, 0.72); // End
		#else
			ambLight = fogColor * 0.48 + vec3(0.28, 0.2, 0.24); // Nether
		#endif
	}

	float fogCover = 0.0;
	#ifdef Fog
		fogCover = getFogCover(far, gl_FogFragCoord, blindness);
	#endif

	if (fogCover < 1.0) {
		tex = texture2D(texture, texcoord.st); // Get tex
		tex.rgb = mix(tex.rgb,entityColor.rgb,entityColor.a)*emissionStrength*vec3(1.0, 0.4, 0.8); // Fix for hurt, emissive, and fix coloration
	} // Done with rendered effects

	vec3 fCol;
	#ifdef Fog
		if (overworld) {
			fCol = getOverworldFogColor(skyLight, eyeBrightnessSmooth.y);
		} else {
			fCol = getFogColor();
		}
		if (isEyeInWater == 1) fCol *= waterCol;
	#endif

	if (fogCover < 1.0) { // Visible
		gl_FragData[0] = vec4(mix(tex.rgb, fCol, fogCover), tex.a);
	} else { // Completely covered by fog, just render as fog color
		gl_FragData[0] = vec4(fCol, 1.0);
		#ifdef showFogOcclusion // Debug option
			gl_FragData[0] = vec4(1.0, 0.0, 0.0, 1.0);
		#endif
	}
	gl_FragData[1] = vec4(0.0);
}