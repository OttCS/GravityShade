#version 120

/*
	GravityShade by Gravity10
	Code is licensed under GNU Lesser General Public License v2.1
	Thanks for using GravityShade!
*/

uniform sampler2D texture;

uniform float rainStrength;
uniform int worldTime;
uniform int moonPhase;

varying vec3 color;
varying vec2 texcoord;
varying vec4 lmcoord;

const float sunPathRotation = -27.0;

#define Blocklight_Falloff 1.5 //[1.0 1.5 2.0 2.5 3.0]
#define Skylight_Falloff 1.0 //[1.0 1.5 2.0 2.5 3.0]

float dayVal(int worldTime) {

    return clamp(-(worldTime - 13000.0f) * (23000.0f - worldTime) / 11000000.0f, 0.0f, 1.0f);

}

void main() {

	// Texture Adjustments
	vec3 texColor = texture2D(texture, texcoord.xy).rgb * color.rgb;
	texColor *= -0.5f * texColor + 1.5f; // Gravity10 Tonemap

	// Lighting Adjustments
	vec3 trueLight = mix(vec3(0.0f, 0.1f, 0.4f), vec3(1.1f, 1.0f, 1.0f), dayVal(worldTime)); //Night vs Day coloring
	trueLight *= -0.5f * rainStrength + 1.0f; //Adjust coloring for rain
	trueLight = 0.2f + max(trueLight * pow(lmcoord.g, Skylight_Falloff + rainStrength), vec3(1.7f, 1.3f, 1.0f) * pow(lmcoord.r, Blocklight_Falloff + rainStrength)); // Mix with blocklight

	gl_FragData[0] = vec4(texColor * trueLight, texture2D(texture, texcoord.xy).a);

}

// NOTES //

// Don't use "lightmap" sampler: slow and lmcoord.rg can be exploited for the same result with more customisation