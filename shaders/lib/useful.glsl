bool isOverworld() {
	#ifdef END
		return false;
	#endif
	#ifdef NETHER
		return false;
	#endif
    return true;
}

float getFogCover(float renderDist, float dist, float isBlind) {
	return smoothstep(FogOcclusionStart * (1.0 - isBlind) * renderDist, mix(FogOcclusionRadius * renderDist, 16.0, isBlind), dist);
}