#extension GL_EXT_gpu_shader4 : enable

float smoothstep(float edge0, float edge1, float x) {
	float t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
	return t * t * (3.0 - 2.0 * t);
}

vec3 mix3(vec3 a, vec3 b, vec3 c, float param) {

	if (param < 0.5) {
		return mix(a, b, param * 2.0);
	}

	return mix(b, c, param * 2.0 - 1.0);

	return vec3(0.0);

}

vec3 getOverworldSkyLighting(int tick, float rainStrength) {

	vec3 noon = vec3(1.44 - 0.48 * rainStrength);

	vec3 rise = noon * vec3(1.0, 0.72, 0.60);
	vec3 set = noon * vec3(0.84, 0.48, 0.84);
	vec3 night = noon * vec3(0.12, 0.24, 0.36);

	vec3 res = night;

	if (tick < 1900) {
		res = mix3(night, rise, noon, smoothstep(0.0, 1900.0, tick));
	} else if (tick < 9148) {
		res = noon;
	} else if (tick < 15255) {
		res = mix3(noon, set, night, smoothstep(13065.0, 15255.0, tick));
	}

	return res;
}

vec3 currentSkyLight(int x, float rain) {
	return getOverworldSkyLighting((x + 1450) % 24000, rain);
}

uniform vec3 fogColor;

vec3 getFogColor() {
	#ifdef END
		return vec3(0.12, 0.00, 0.24);
	#endif
	#ifdef NETHER
		return fogColor;
	#endif
	return vec3(ambientLevel); // Default Ambient Light
}

vec3 getOverworldFogColor(vec3 dimLight, float playerSkyExposure) {
	return mix(vec3(ambientLevel), dimLight * (vec3(0.48, 0.48, 0.60) * fogColor + 0.24), min(1.0, playerSkyExposure));
}