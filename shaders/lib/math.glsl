// Optimized math functions that are widely useful

bool comp(float a, float b) {
	return abs(a - b) < 0.1;
}

float strengthCurve(float x, float c) {
    return (c * (1.0 - x) + 1.0) * x;
}

float sqrtFast(float x) {
    return (2.0-x)*x;
}

float getLum(vec3 v) {
	return sqrtFast(0.299 * v.r * v.r + 0.587 * v.g * v.g + 0.144 * v.b * v.b); // True luminance
}

vec3 sqrtFast(vec3 x) {
    return vec3(sqrtFast(x.r), sqrtFast(x.g), sqrtFast(x.b));
}

float smoothstep(float edge0, float edge1, float x) {
	float t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
	return t * t * (3.0 - 2.0 * t);
}

float qDist(vec2 a, vec2 b) {
	return sqrtFast(pow(b.x - a.x, 2.0) + pow(b.y - a.y, 2.0));
}

vec3 mix3(vec3 a, vec3 b, vec3 c, float param) {
	if (param < 0.5) {
		return mix(a, b, param * 2.0);
	}
	return mix(b, c, param * 2.0 - 1.0);
}

// Fog stuff
#ifdef FogWork
uniform float far;

const float FogOcclusionStart = 0.375;
const float FogOcclusionRadius = 0.997;

float getFogCover(float dist) {
	return pow(smoothstep(far * FogOcclusionStart, far * FogOcclusionRadius, dist), 2.0);
}

vec3 fColAdj(vec3 v) {
	return v * v;
}

#endif