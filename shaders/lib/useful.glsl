bool isOverworld() {
	#ifdef END
		return false;
	#endif
	#ifdef NETHER
		return false;
	#endif
    return true;
}

vec3 MildACES(vec3 x) {
	return 2.2 * x * x / (x * (1.9 * x) + 0.3);
}