/*
	GravityShade by Gravity10
	Code is licensed under GNU Lesser General Public License v2.1
	Thanks for using GravityShade!
*/

uniform float rainStrength;
uniform int worldTime;

#define Blocklight_Falloff 1.5 //[1.0 1.5 2.0 2.5 3.0]
#define Skylight_Falloff 1.0 //[1.0 1.5 2.0 2.5 3.0]

vec3 trueLight(vec2 lmcoord) {
    vec3 trueLight = mix(vec3(0.0f, 0.1f, 0.4f), vec3(1.1f, 1.0f, 1.0f), clamp(-(worldTime - 13000.0f) * (23000.0f - worldTime) / 11000000.0f, 0.0f, 1.0f)); //Night vs Day coloring
	trueLight *=  vec3(1.0f) - vec3(0.3f, 0.2f, 0.2f) * rainStrength; //Adjust coloring for rain
	return max(trueLight * pow(lmcoord.g, Skylight_Falloff + rainStrength * lmcoord.g), vec3(1.7f, 1.3f, 1.0f) * pow(lmcoord.r, Blocklight_Falloff + rainStrength * lmcoord.g)) + 0.2f; // Mix with blocklight
}

// NOTES //

// Don't use "lightmap" sampler: slow and lmcoord.rg can be exploited for the same result with more customisation