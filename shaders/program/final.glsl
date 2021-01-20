/*
	GravityShade by Gravity10
	Code is licensed under GNU Lesser General Public License v2.1
	Thanks for using GravityShade!
*/

#define GravityShade_Version Developer //[Developer]

#ifdef FSH

#define Fog
#define Fog_Start 1.0 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define Water_Fog_Start 0.2 //[0.05 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]

uniform sampler2D colortex0;

uniform int isEyeInWater;

#ifdef Fog
uniform sampler2D depthtex0;
uniform vec3 fogColor;
#endif

varying vec2 coord;

#ifdef OVERWORLD
const float sunPathRotation = -40.0;
#endif

#include "/lib/functions.glsl"
#include "/lib/light.glsl"

void main() {

	vec3 color = texture2D(colortex0, coord).rgb * inWaterColor(isEyeInWater);

	#ifdef Fog
	float depth = betterPow(texture2D(depthtex0, coord).r, 1200.0f * mix(Fog_Start, Water_Fog_Start, step(1.0f, isEyeInWater)));

	int dimension = 0;
	#ifdef NETHER
	dimension = 1;
	#endif
	#ifdef END
	dimension = 2;
	#endif

	if (depth != 1.0f) // Do not include sky
		color = mix(color, fColor(dimension) * (0.5f + 0.5f * fogColor), depth);
		
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