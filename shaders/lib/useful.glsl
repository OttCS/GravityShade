bool isOverworld() {
	#ifdef NOSKYLIGHT
		return false;
	#endif
    return true;
}

#include "math.glsl"

float getFogCover(float renderDist, float dist, float isBlind) {
	return sqrtFast(smoothstep(FogOcclusionStart * (1.0 - isBlind) * renderDist, mix(FogOcclusionRadius * renderDist, 16.0, isBlind), dist));
}