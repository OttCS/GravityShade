/*
	GravityShade by Gravity10
	Code is licensed under GNU Lesser General Public License v2.1
	Thanks for using GravityShade!
*/

#define Blocklight_Falloff 2.5 //[2.0 2.5 3.0 3.5 4.0]
#define Skylight_Falloff 2.0 //[2.0 2.5 3.0 3.5 4.0]
#define Soft_Shadows 0.0 //[0.0 1.0 2.0]

uniform float rainStrength;
uniform int worldTime;

vec3 inWaterColor(int x) {
	vec3 color = vec3(1.0f);

	if (x == 1) {
		color *= vec3(0.3f, 0.9f, 0.7f);
	} else if (x == 2) {
		color *= vec3(0.9f, 0.7f, 0.3f);
	}

	return color;
}

vec3 dColor(int d) {
	vec3 trueLight = vec3(0.5f, 0.4f, 0.6f); // Default as End lighting

	if (d == 0) { // Overworld Lighting
		trueLight = mix(vec3(0.2f, 0.3f, 0.6f), vec3(1.1f, 1.0f, 1.0f), clamp(-(worldTime - 13000.0f) * (23000.0f - worldTime) / 11000000.0f, 0.0f, 1.0f)); //Night vs Day coloring
		trueLight *=  vec3(1.0f) - vec3(0.3f, 0.2f, 0.2f) * rainStrength; //Adjust coloring for rain
	} else if (d == 1) { // Nether Lighting
		trueLight = vec3(0.3f, 0.2f, 0.1f);
	}

	return trueLight;
}

vec3 trueLight(vec2 lmcoord, int d) {
	vec3 trueLight = dColor(d);

	if (d == 0) // Overworld Lighting
		trueLight *= 0.5f * smoothstep(0.879f - 0.01f * Soft_Shadows, 0.88f, lmcoord.g) + 0.5f * pow(lmcoord.g, Skylight_Falloff + rainStrength * lmcoord.g);
    
	return max(trueLight, vec3(1.9f, 1.4f, 1.1f) * pow(lmcoord.r, Blocklight_Falloff + rainStrength * lmcoord.g)) + 0.1f; // Mix with blocklight
}

