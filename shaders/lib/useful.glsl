bool isOverworld() {
	#ifdef NOSKYLIGHT
		return false;
	#endif
    return true;
}

float sqrtFast(float x) {
	x = clamp(x, 0.0, 1.0);
    return (2.0-x)*x;
}

float getFogCover(float renderDist, float dist, float isBlind) {
	return sqrtFast(smoothstep(FogOcclusionStart * (1.0 - isBlind) * renderDist, mix(FogOcclusionRadius * renderDist, 16.0, isBlind), dist));
}