#version 120

#include "shaders.settings"

varying vec4 color;

uniform ivec2 eyeBrightnessSmooth;
uniform float rainStrength;
uniform int worldTime;
uniform int isEyeInWater;

#include "lib/color.glsl"
#include "lib/useful.glsl"

void main() {
	bool overworld = isOverworld();
	vec3 skyLight = currentSkyLight(worldTime, rainStrength) * 0.7;
	vec3 fCol;
	if (overworld) {
		fCol = getOverworldFogColor(skyLight, eyeBrightnessSmooth.y);
	} else {
		fCol = getFogColor();
	}
	if (isEyeInWater == 1) fCol *= waterCol * (skyLight + 1.8);
	gl_FragData[0] = vec4(mix(color.rgb, fCol, clamp((gl_FogFragCoord) * 0.04, 0.0, 1.0)), 1.0);
    gl_FragData[1] = vec4(0.0);

}
