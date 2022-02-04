// Functions that are commonly required by nearly every gbuffer, regarding lighting

const float ambientLevel = 0.1;

const float emissionStrength = 1.2;

const float emissive_R = 2.2;
const float emissive_G = 1.4;
const float emissive_B = 1.0;

vec3 blockLM(float bl) {
    return vec3(emissive_R * pow(bl, emissive_R * 0.5),emissive_G * pow(bl, emissive_G * 0.5),emissive_B * pow(bl, emissive_B * 0.5)) * bl;
}

uniform int worldTime;

const vec3 noonLight = vec3(1.08, 1.08, 1.08);
const vec3 riseLight = vec3(1.08, 0.96, 0.84);
const vec3 setLight = vec3(1.08, 0.60, 0.72);
const vec3 nightLight = vec3(0.12, 0.24, 0.36);

vec3 skyLM() {
    vec3 res;
    int tick = (worldTime + 1450) % 24000;
    if (tick < 9148) {
        if (tick < 1900) {
		    res = mix3(nightLight, riseLight, noonLight, smoothstep(0.0, 1900.0, tick));
	    } else {
            res = noonLight;
        }
    } else {
        if (tick < 15255) {
		    res = mix3(noonLight, setLight, nightLight, smoothstep(13065.0, 15255.0, tick));
	    } else {
            res = nightLight;
        }
    }
    return res;
}

float slCurve(float sl) {
	return smoothstep(0.90, 0.94, sl) * 0.55 + 0.45 * sl;
}

#ifdef blockEmission

vec3 emissiveOreLightComp(vec3 lightComp, vec3 color) {
	float maxCol = max(color.r, max(color.g, color.b));
	if (maxCol > 0.40) {
		if (color.b + 0.1 < min(color.r, color.g)) return vec3(emissionStrength);
		float minCol = min(color.r, min(color.g, color.b));
		if (minCol + 0.18 < maxCol) return vec3(emissionStrength);
		if (minCol > 0.7) return vec3(emissionStrength);
	}
	return lightComp;
}

vec3 emissiveNetherOreLightComp(vec3 lightComp, vec3 color) {
	if (color.g > 0.5) return vec3(emissionStrength);
	return lightComp;
}

vec3 emissiveToneMap(vec3 color) {
	return color * (color + 0.5);
}

#endif
