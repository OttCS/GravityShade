#version 120

/*
	GravityShade by Gravity10
	Code is licensed under GNU Lesser General Public License v2.1
	Thanks for using GravityShade!
*/

attribute vec4 mc_Entity;

uniform float frameTimeCounter;
uniform float rainStrength;

varying vec2 lmcoord;
varying vec3 binormal;
varying vec3 normal;
varying vec3 tangent;
varying vec3 color;
varying vec2 texcoord;

const float wFlex = 2.2f; // Water flexing frequency
const float lFlex = 1.4f; // Leaves flexing frequency
const float pFlex = 1.8f; // Plants flexing frequency
const float hFlex = 1.2f; // Hardy plants flexing frequency
const float m = 0.05f; // Magnitude

float wSin(float x, float frequency) {
	x = mod(x, 32.0f);
	return (32.0f - x) * x / 256.0f * sin(x * x * frequency / 48.0f);
}

void main() {

	float tick = frameTimeCounter;

	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).rg;
	
	texcoord = gl_MultiTexCoord0.xy;
	
	vec4 coordPos = gl_Vertex;

	color = gl_Color.rgb;
	if (mc_Entity.x >= 10100 && mc_Entity.x <= 10300) {

		if (mc_Entity.x == 10300) {
		// Water
		float sum = 0.6f * wSin(tick + coordPos.x * 0.5f, wFlex + rainStrength) * m + 0.4f * wSin(2.0 * tick + coordPos.x + coordPos.z * 0.5f, wFlex + rainStrength) * m;
		coordPos.y += sum;
		color += sum * 1.8f;
		} else if (mc_Entity.x <= 10102) {
			// Ground plants and crops
			coordPos.xz += step(-0.01f, -mod((texcoord.t) * 16.0f, 1.0f / 16.0f)) * wSin(coordPos.x + coordPos.z + tick, 0.5f * pFlex + rainStrength) * m;
		} else if (mc_Entity.x <= 10104) {
			// Tall plants
			coordPos.xz += max(step(-0.01f, -mod((texcoord.t) * 16.0f, 1.0f / 16.0f)), 10104 - mc_Entity.x) * wSin(coordPos.x + coordPos.z + tick, 0.5f * pFlex + rainStrength) * m;
		} else if (mc_Entity.x <= 10106) {
			// Leaves and vines
			coordPos.xzy += wSin(coordPos.z + coordPos.x + tick, lFlex + rainStrength) * m;
		} else if (mc_Entity.x == 10107) {
			// Lily Pad
			coordPos.xyz += 0.6f * wSin(tick + coordPos.x * 0.5f, wFlex + rainStrength) * m + 0.4f * wSin(2.0 * tick + coordPos.x + coordPos.z * 0.5f, wFlex + rainStrength) * m;
		} else if (mc_Entity.x <= 10109) {
			// Hardy Plants
			coordPos.xz += step(-0.01f, -mod((texcoord.t) * 16.0f, 1.0f / 16.0f)) * wSin(coordPos.y + coordPos.x + tick, hFlex + rainStrength) * m;
		} else if (mc_Entity.x == 10251) {
			// Soul Lantern and Normal Lantern
			coordPos.x += (1.0f - fract(coordPos.y - 0.001f)) * wSin(3.0f * floor(coordPos.z) + tick, hFlex) * m * 2.0f;
			coordPos.z += (1.0f - fract(coordPos.y - 0.001f)) * wSin(3.0f * floor(coordPos.x) + tick, hFlex * 0.73f) * m * 2.0f;
			coordPos.y += (0.982f - cos(fract(coordPos.z) - 0.5f)) + (0.982f - cos(fract(coordPos.x) - 0.5f)) * 1.3f;
		}
		
	}
	
	gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * coordPos);

	normal = normalize(gl_NormalMatrix * gl_Normal);

	mat3 tbnMatrix = mat3(tangent.x, binormal.x, normal.x,
                          tangent.y, binormal.y, normal.y,
                          tangent.z, binormal.z, normal.z);
}

// NOTES //

// Unused samplers and *stuff* for some reason slow Optifine WAY down? Idk, just check if things are used or not
// Using optimized if-else trees are super valuable to bring the average # of comparisons down
// Took inspiration from BSL for lanterns, fract(x - 0.001) is gENIUS for finding the top of the block