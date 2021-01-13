/*
	GravityShade by Gravity10
	Code is licensed under GNU Lesser General Public License v2.1
	Thanks for using GravityShade!
*/

float betterPow(float x, float p) {
	return max(pow((0.265f * p + 0.2f) * (x - 1.0f) + 1.0f, 3), 0.0f);
}

vec3 g10tm(vec3 v3) {
	return (-0.5f * v3 + 1.5f) * v3;
}