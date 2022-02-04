/*
    GravityShade for the IRIS Shaders mod.
    Made by Gravity10, Code base by Sildur.
*/

// varying vec3 position;
varying vec4 color;

#ifdef FSH

uniform vec3 cameraPosition;

#define FogWork
#include "/lib/math.glsl"
#include "/lib/light.glsl"
#include "/lib/colorsToFrag.glsl"

void main() { 
    vec3 ambLight = vec3(ambientLevel);
    vec3 skyLight = skyLM();

    gl_FragData[0].rgb = mix(fColAdj(vec3(skyLight)), vec3(0.65, 0.75, 0.8) * fColAdj(vec3(skyLight)), gl_FogFragCoord);
    gl_FragData[0].a = 0.0;
    gl_FragData[1] = vec4(0.0);
}

#endif

#ifdef VSH

uniform vec3 cameraPosition;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

// VOID MAIN //

void main() {
    gl_Position = ftransform();
    vec3 position = mat3(gbufferModelViewInverse) * (gl_ModelViewMatrix * gl_Vertex).xyz + gbufferModelViewInverse[3].xyz;
    // gl_FogFragCoord = length(position.xyz);
    gl_FogFragCoord = clamp(position.y, 0.0, 1.0);
    color = gl_Color;
}

#endif