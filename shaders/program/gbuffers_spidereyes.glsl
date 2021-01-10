/*
	GravityShade by Gravity10
	Code is licensed under GNU Lesser General Public License v2.1
	Thanks for using GravityShade!
*/

#ifdef FSH

uniform sampler2D texture;

varying vec2 texcoord;

#include "/lib/g10tm.glsl"

void main() {

	// vec3 texColor = g10tm(texture2D(texture, texcoord).rgb);
	gl_FragData[0] = vec4(g10tm(texture2D(texture, texcoord).rgb), texture2D(texture, texcoord).a);
	
}

#endif

// FSH above, VSH below //

#ifdef VSH

varying vec2 texcoord;

void main() {

	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
	
}

#endif