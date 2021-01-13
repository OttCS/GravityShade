/*
	GravityShade by Gravity10
	Code is licensed under GNU Lesser General Public License v2.1
	Thanks for using GravityShade!
*/

#define GravityShade_Version Developer //[Developer]

#ifdef FSH

#define Fog
#define Fog_Start 1.0 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]

uniform sampler2D colortex0;

#ifdef Fog
uniform sampler2D depthtex0;
uniform vec3 fogColor;
#endif

varying vec2 coord;

#ifdef OVERWORLD
const float sunPathRotation = -27.0;
#endif

#ifdef Fog
#include "/lib/functions.glsl"
#include "/lib/light.glsl"
#endif

void main() {

	vec3 color = texture2D(colortex0, coord).rgb;

	#ifdef Fog
	float depth = betterPow(texture2D(depthtex0, coord).r, 1000 * Fog_Start * (-0.5f * rainStrength + 1.0f));

	int dimension = 0;
	#ifdef NETHER
	dimension = 1;
	#endif
	#ifdef END
	dimension = 2;
	#endif

	if (depth != 1.0f)
		color = mix(color, mix(dColor(dimension), fogColor, depth), depth);
	#endif

	gl_FragData[0] = vec4(color, 1.0f);
}

#endif

// FSH above, VSH below //

#ifdef VSH

varying vec2 coord;

void main() {
	gl_Position = ftransform();
	coord = gl_MultiTexCoord0.xy;
}

#endif