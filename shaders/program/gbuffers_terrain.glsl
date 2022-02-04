/*
    GravityShade for the IRIS Shaders mod.
    Made by Gravity10, Code base by Sildur.
*/

varying float mat;
varying float mcID;
varying vec2 lmcoord;
varying vec2 texcoord;
varying vec3 position;
varying vec4 color;

#ifdef FSH

uniform sampler2D texture;
uniform vec3 cameraPosition;

#define FogWork
#include "/lib/math.glsl"
#define blockEmission
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

        vec3 lightComp = max(mix(ambLight, skyLight, slCurve(lmcoord.y)), blockLM(lmcoord.x));

        if (comp(mcID, 10089.0) || comp(mcID, 10090.0) || comp(mcID, 10169.0)) {
            tex.rgb = emissiveToneMap(tex.rgb);
			lightComp = vec3(lmcoord.x * emissionStrength * 0.8 + 0.2);
        } else if (comp(mcID, 10566.0)) {
            lightComp = emissiveOreLightComp(lightComp, tex.rgb);
        } else if (comp(mcID, 10153.0)) {
            lightComp = emissiveNetherOreLightComp(lightComp, tex.rgb);
        }

        tex.rgb *= lightComp;
        tex.rgb *= mix(vec3(1.0), color.rgb, color.a);
        tex.a *= color.a;
	} // Done with rendered effects

    gl_FragData[0] = rgbaWrite(tex, skyLight, fogCover);
    gl_FragData[1] = normal;
}

#endif

#ifdef VSH

attribute vec4 mc_Entity;

uniform float frameTimeCounter;
uniform vec3 cameraPosition;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

const float PI = 3.14;
float pi2wt = (150.79*frameTimeCounter);

vec3 calcWave(in vec3 pos, in float fm, in float mm, in float ma, in float f0, in float f1, in float f2, in float f3, in float f4, in float f5) {
	float magnitude = sin(pi2wt*fm + dot(pos, vec3(0.5))) * mm + ma;
	vec3 d012 = sin(vec3(f0, f1, f2)*pi2wt);
	
    vec3 ret;
		 ret.x = pi2wt*f3 + d012.x + d012.y - pos.x + pos.z + pos.y;
		 ret.z = pi2wt*f4 + d012.y + d012.z + pos.x - pos.z + pos.y;
		 ret.y = pi2wt*f5 + d012.z + d012.x + pos.z + pos.y - pos.y;
		 ret = sin(ret)*magnitude;
	
    return ret;
}

vec3 calcMove(in vec3 pos, in float f0, in float f1, in float f2, in float f3, in float f4, in float f5, in vec3 amp1, in vec3 amp2) {
    vec3 move1 = calcWave(pos      , 0.0027, 0.0400, 0.0400, 0.0127, 0.0089, 0.0114, 0.0063, 0.0224, 0.0015) * amp1;
	vec3 move2 = calcWave(pos+move1, 0.0348, 0.0400, 0.0400, f0, f1, f2, f3, f4, f5) * amp2;
    return move1+move2;
}

// VOID MAIN //

void main() {
    mcID = mc_Entity.x;

    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	vec3 position = mat3(gbufferModelViewInverse) * (gl_ModelViewMatrix * gl_Vertex).xyz + gbufferModelViewInverse[3].xyz;
    vec3 vworldpos = position.xyz + cameraPosition.xyz;

    mat = 0.0;
    if (mcID == 10031.0) {
        position.xz += calcMove(vworldpos.xyz, 0.0041, 0.0070, 0.0044, 0.0038, 0.0063, 0.0000, vec3(3.0,1.6,3.0), vec3(0.0));
    }
    if(mcID == 10079.0) {
		mat = 2.0;
	} else if(mcID == 10042.0 || mcID == 10169.0) { // POLISHED BLOCKS
		mat = 3.0;
	} else if(mcID == 10001.0) { // METALLIC ACCENTS
		mat = 4.0;
	}

    gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(position, 1.0);
    gl_FogFragCoord = length(position.xyz);
    color = gl_Color;
}

#endif