const int noiseTextureResolution = 256;

uniform float frameTimeCounter;
uniform sampler2D noisetex;

float calcBump(vec2 coord, bool iswater) {
	coord = floor(coord.xy * 16.0) * 0.0625;
	vec2 mDir = vec2(0.0);
	if (iswater) mDir.x = frameTimeCounter * 0.002;
	float h0 = 0.0;
	float blend = 1.0;
	if (gl_FogFragCoord < 32.0) { // 4 Chunks ULTRA high res normalBump
		blend = 1.0 - smoothstep(48.0, 64.0, gl_FogFragCoord);
		h0 += (texture2D(noisetex, coord * vec2(0.527, 0.371) + mDir.xy).x * 0.2 - 0.1) * blend;
	}
	h0 += texture2D(noisetex, coord * vec2(0.113, 0.117) + mDir.yx).x * 0.6 - 0.3;
	h0 += texture2D(noisetex, coord * vec2(0.023, 0.019) - mDir.xx).x - 0.5; // Default low res normalBump
	return h0;
}