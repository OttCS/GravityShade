/*
    GravityShade for the IRIS Shaders mod.
    Made by Gravity10, Code base by Sildur.
*/

varying float mcID;
varying vec2 lmcoord;
varying vec2 texcoord;
varying vec3 position;
varying vec4 color;
varying float isWater;

#ifdef FSH

uniform sampler2D texture;

uniform vec3 cameraPosition;

#include "/lib/common.glsl"
#define FogWork
#include "/lib/math.glsl"
#include "/lib/light.glsl"
#include "/lib/bumps.glsl"
#include "/lib/colorsToFrag.glsl"

void main() {
    vec4 tex = vec4(0.0);
    vec4 normal = vec4(0.0);

    vec3 ambLight = vec3(ambientLevel);
    vec3 skyLight = skyLM();

    float fogCover = getFogCover(gl_FogFragCoord);

    if (fogCover < 1.0) {
		tex = texture2D(texture, texcoord.st); // Get tex

        vec3 lightComp = max(mix(ambLight, skyLight, slCurve(lmcoord.y)), blockLMwHand(lmcoord.x));

        if (comp(mcID, 10008.0)) {
            tex.rgb *= waterColor;
            vec2 coord = position.xz + cameraPosition.xz;
            coord *= 10.0;
            vec2 p = coord;
            tex.rgb -= qDist(coord , p);
            tex.a = 0.6;
        } else if (comp(mcID, 10089.0)) {
			lightComp = vec3(lmcoord.x * emissionStrength * 0.8 + 0.2);
        }
        tex.rgb *= lightComp;
	} // Done with rendered effects

    gl_FragData[0] = rgbaWrite(tex, skyLight, fogCover);
    gl_FragData[1] = normal;
}

#endif

#ifdef VSH

attribute vec4 mc_Entity;

uniform vec3 cameraPosition;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

// VOID MAIN //

void main() {
    mcID = mc_Entity.x;

    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	position = mat3(gbufferModelViewInverse) * (gl_ModelViewMatrix * gl_Vertex).xyz + gbufferModelViewInverse[3].xyz;

    gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(position, 1.0);
    gl_FogFragCoord = length(position.xyz);
    color = gl_Color;
}

#endif