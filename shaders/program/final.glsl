/*
    GravityShade for the IRIS Shaders mod.
    Made by Gravity10, Code base by Sildur.
*/

varying vec2 texcoord;
varying vec3 color;

#ifdef FSH

/* Should be colortex3 when TAA is implemented */
uniform sampler2D colortex0;

uniform int isEyeInWater;

#include "/lib/common.glsl"
#include "/lib/math.glsl"

vec3 FilmicLum(vec3 x) {
    // Credit for true Luminance goes to Darel Finley, https://alienryderflex.com/hsp.html
    float l = getLum(x); // True luminance
    float c = 0.48; // Curve strength
    return (c * (1.0 - l)+ 1.0) * mix(vec3(x), vec3(l), c * 0.12);
}

/* VOID MAIN */

void main()
{
	vec3 tex = texture2D(colortex0, texcoord.xy).rgb*color;
	tex.rgb = FilmicLum(tex);
    if (isEyeInWater == 1) { // In water
        tex.rgb *= (waterColor);
    } else if (isEyeInWater == 2) { // In lava
        tex.rgb *= (lavaColor);
    } else if (isEyeInWater == 3) { // In powder snow
        tex.rgb *= (powderColor);
    }
	gl_FragData[0] = vec4(tex, 1.0);
}

#endif

#ifdef VSH

/* VOID MAIN */

void main() {
	gl_Position = ftransform();
	texcoord = (gl_MultiTexCoord0).xy;
	color = gl_Color.rgb;
}

#endif