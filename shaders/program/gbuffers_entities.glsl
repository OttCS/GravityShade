/*
	GravityShade by Gravity10
	Code is licensed under GNU Lesser General Public License v2.1
	Thanks for using GravityShade!
*/

#ifdef FSH

uniform sampler2D texture;
uniform vec4 entityColor;

varying vec3 color;
varying vec2 lmcoord;
varying vec2 texcoord;

#include "/lib/light.glsl"
#include "/lib/g10tm.glsl"

void main() {

	vec3 texColor = g10tm(0.75f * texture2D(texture, texcoord).rgb * color.rgb + entityColor.rgb);

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

varying vec3 color;
varying vec2 lmcoord;
varying vec2 texcoord;

void main() {

	gl_Position = ftransform();

	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).rg;
	texcoord = gl_MultiTexCoord0.xy;
	color = gl_Color.rgb;
	
}

#endif