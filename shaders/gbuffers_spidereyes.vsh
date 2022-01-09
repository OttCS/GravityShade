#version 120
/*
    GravityShade for the IRIS Shaders mod.
    Made by Gravity10, Code base by Sildur.
*/

#define gbuffers_textured
#include "shaders.settings"

varying vec4 color;
varying vec2 texcoord;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

#ifdef TAA
uniform float viewWidth;
uniform float viewHeight;
vec2 texelSize = vec2(0.97 / viewWidth, 0.97 / viewHeight);
uniform int framemod8;
const vec2[8] offsets = vec2[8](vec2(1./8.,-3./8.),
								vec2(-1.,3.)/8.,
								vec2(5.0,1.)/8.,
								vec2(-3,-5.)/8.,
								vec2(-5.,5.)/8.,
								vec2(-7.,-1.)/8.,
								vec2(3,7.)/8.,
								vec2(7.,-7.)/8.);
#endif

void main() {

	//Positioning
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	vec3 position = mat3(gbufferModelViewInverse) * (gl_ModelViewMatrix * gl_Vertex).xyz + gbufferModelViewInverse[3].xyz;
	gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(position, 1.0);

	//Fog
	gl_FogFragCoord = length(position.xyz);

	#ifdef TAA
		gl_Position.xy += offsets[framemod8] * gl_Position.w * texelSize;
	#endif

	color = gl_Color;
}