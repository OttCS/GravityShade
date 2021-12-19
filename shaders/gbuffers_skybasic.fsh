#version 120

#include "shaders.settings"

varying vec4 color;

uniform float rainStrength;
uniform int worldTime;
uniform int isEyeInWater;

#include "lib/color.glsl"

void main() {
	vec3 fCol = currentSkyLight(worldTime, rainStrength) * 0.72;
	if (isEyeInWater == 1) fCol *= waterCol;
	gl_FragData[0] = vec4(mix(color.rgb, fCol, clamp((gl_FogFragCoord) * 0.04, 0.0, 1.0)), 1.0);
    gl_FragData[1] = vec4(0.0);

}
