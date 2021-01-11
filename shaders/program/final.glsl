/*
	GravityShade by Gravity10
	Code is licensed under GNU Lesser General Public License v2.1
	Thanks for using GravityShade!
*/

#ifdef FSH

uniform sampler2D colortex0;

varying vec2 coord;

#ifdef OVERWORLD
const float sunPathRotation = -27.0;
#endif

void main() {

	vec3 color = texture2D(colortex0, coord).rgb;
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