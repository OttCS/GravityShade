/*
    GravityShade for the IRIS Shaders mod.
    Made by Gravity10, Code base by Sildur.
*/

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec3 position;
varying vec4 color;

#ifdef FSH

uniform sampler2D texture;

uniform int entityId;
uniform vec3 cameraPosition;

#define FogWork
#include "/lib/math.glsl"
#include "/lib/light.glsl"
#include "/lib/colorsToFrag.glsl"

void main() {
    vec4 tex = vec4(0.0);
    
    vec3 skyLight = skyLM();

    float fogCover = getFogCover(gl_FogFragCoord);

    if (fogCover < 1.0) {
		tex = texture2D(texture, texcoord.st) * emissionStrength * vec4(1.0, 0.4, 0.8, 1.0); // Get tex
    } // Done with rendered effects

    gl_FragData[0] = rgbaWrite(tex, skyLight, fogCover);
    gl_FragData[1] = vec4(0.0);
}

#endif

#ifdef VSH

uniform vec3 cameraPosition;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

// VOID MAIN //

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	vec3 position = mat3(gbufferModelViewInverse) * (gl_ModelViewMatrix * gl_Vertex).xyz + gbufferModelViewInverse[3].xyz;

    gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(position, 1.0);
    gl_FogFragCoord = length(position.xyz);
    color = gl_Color;
}

#endif