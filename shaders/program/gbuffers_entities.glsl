/*
	GravityShade by Gravity10
	Code is licensed under GNU Lesser General Public License v2.1
	Thanks for using GravityShade!
*/

#ifdef FSH

uniform sampler2D texture;

varying vec2 lmcoord;
varying vec2 texcoord;

#include "/lib/light.glsl"

void main() {

	// Texture Adjustments
	vec3 texColor = 0.75 * texture2D(texture, texcoord).rgb; // Multiply by 0.75f for some crazy reason
	texColor *= -0.5f * texColor + 1.5f; // Gravity10 Tonemap

	int dimension = 0;
	#ifdef NETHER
	dimension = 1;
	#endif
	#ifdef END
	dimension = 2;
	#endif

	gl_FragData[0] = vec4(texColor * trueLight(lmcoord, dimension), texture2D(texture, texcoord).a);
}

#endif

// FSH above, VSH below //

#ifdef VSH

varying vec2 lmcoord;
varying vec2 texcoord;

void main() {

	gl_Position = ftransform();

	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).rg;
	texcoord = gl_MultiTexCoord0.xy;
	
}

#endif