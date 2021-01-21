/*
	GravityShade by Gravity10
	Code is licensed under GNU Lesser General Public License v2.1
	Thanks for using GravityShade!
*/

uniform float frameTimeCounter;
uniform float rainStrength;

const float wFlex = 2.2f; // Water flexing frequency
const float lFlex = 1.4f; // Leaves flexing frequency
const float pFlex = 1.8f; // Plants flexing frequency
const float hFlex = 1.2f; // Hardy plants flexing frequency
const float m = 0.03f; // Magnitude

float tick = 2.0f * frameTimeCounter;

float wSin(float x, float frequency) {
	x = mod(x, 32.0f);
	return (32.0f - x) * x / 256.0f * sin(x * x * frequency / 48.0f);
}

void hardyWave(inout vec3 coordPos) {
    coordPos.xz += step(-0.01f, -mod((texcoord.t) * 16.0f, 1.0f / 16.0f)) * wSin(coordPos.y + coordPos.x + tick, hFlex + rainStrength) * m;
}

void lanternWave(inout vec3 coordPos) {
    coordPos.x += (1.0f - fract(coordPos.y - 0.001f)) * wSin(3.0f * floor(coordPos.z) + tick, hFlex) * m * 2.0f;
	coordPos.z += (1.0f - fract(coordPos.y - 0.001f)) * wSin(3.0f * floor(coordPos.x) + tick, hFlex * 0.73f) * m * 2.0f;
	coordPos.y += (0.982f - cos(fract(coordPos.z) - 0.5f)) + (0.982f - cos(fract(coordPos.x) - 0.5f)) * 1.3f;
}

void leafWave(inout vec3 coordPos) {
	vec3 ret = vec3(0.0f);
	float tSwerve = wSin(tick + coordPos.x + coordPos.y, lFlex);
	ret.x = sin(tSwerve + tick + coordPos.z + coordPos.y) + tSwerve;
	ret.y = sin(tSwerve + tick + coordPos.z + coordPos.x) + tSwerve;
	ret.z = sin(tSwerve + tick + coordPos.x + coordPos.y) + tSwerve;
	coordPos += ret * m;
}

void lilyWave(inout vec3 coordPos) {
    float sum = wSin(1.0f * tick + 2.0f * coordPos.x + 8.0f * coordPos.z, wFlex + rainStrength);
	sum += wSin(1.5f * tick + 4.0f * coordPos.x + 2.0f * coordPos.z, wFlex + rainStrength);
	sum += wSin(2.0f * tick + 8.0f * coordPos.x + 2.0f * coordPos.z, wFlex + rainStrength);
	coordPos.xyz += sum * 0.333f * m;
}

void plantWave(inout vec3 coordPos) {
    coordPos.xyz += step(-0.01f, -mod((texcoord.t) * 16.0f, 1.0f / 16.0f)) * wSin(coordPos.x + coordPos.z + tick, 0.5f * pFlex + rainStrength) * m;
}

void tallPlantWave(inout vec3 coordPos) {
    coordPos.xz += max(step(-0.01f, -mod((texcoord.t) * 16.0f, 1.0f / 16.0f)), 10104 - mc_Entity.x) * wSin(coordPos.x + coordPos.z + tick, 0.5f * pFlex + rainStrength) * m;
}

void waterWave(inout vec3 coordPos) {
    float sum = wSin(1.0f * tick + 2.0f * coordPos.x + 8.0f * coordPos.z, wFlex + rainStrength);
	sum += wSin(1.5f * tick + 4.0f * coordPos.x + 2.0f * coordPos.z, wFlex + rainStrength);
	sum += wSin(2.0f * tick + 8.0f * coordPos.x + 2.0f * coordPos.z, wFlex + rainStrength);
	coordPos.y += sum * 0.333f * m;
}