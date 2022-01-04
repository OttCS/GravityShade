#version 120
/*
    GravityShade for the IRIS Shaders mod.
    Made by Gravity10, Code base by Sildur.
*/

#include "shaders.settings"
#include "lib/color.glsl"
#include "lib/useful.glsl"

varying vec4 color;

uniform ivec2 eyeBrightnessSmooth;
uniform float rainStrength;
uniform int worldTime;
uniform int isEyeInWater;

void main() {
	bool overworld = isOverworld();
	vec3 fCol;
	if (overworld) {
		vec3 skyLight = currentSkyLight(worldTime, rainStrength);
		fCol = getOverworldFogColor(skyLight, eyeBrightnessSmooth.y);
		if (isEyeInWater == 1) fCol *= waterCol * (skyLight + 1.8);
		fCol = mix(color.rgb, fCol, clamp((gl_FogFragCoord) * 0.04, 0.0, 1.0));
	} else {
		fCol = getFogColor();
	}
	gl_FragData[0] = vec4(fCol, 1.0);
    gl_FragData[1] = vec4(0.0);

}