/*
    GravityShade for the IRIS Shaders mod.
    Made by Gravity10, Code base by Sildur.
*/

#version 120
/* DRAWBUFFERS:02 */ //0=gcolor, 2=gnormal for normals

#define composite0
#include "shaders.settings"

varying vec2 texcoord;
varying vec4 color;
uniform vec3 shadowLightPosition;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D texture;
uniform sampler2D gnormal; //used by reflections and celshading
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform float viewWidth;
uniform float viewHeight;
uniform float near;
uniform float far;
uniform int isEyeInWater;

vec3 decode (vec2 enc){
    vec2 fenc = enc*4-2;
    float f = dot(fenc,fenc);
    float g = sqrt(1-f/4.0);
    vec3 n;
    n.xy = fenc*g;
    n.z = 1-f/2;
    return n;
}

float cdist(vec2 coord) {
	return clamp(1.0 - max(abs(coord.s-0.5),abs(coord.t-0.5))*2.0, 0.0, 1.0);
}

vec3 screenSpace(vec2 coord, float depth){
	vec4 pos = gbufferProjectionInverse * (vec4(coord, depth, 1.0) * 2.0 - 1.0);
	return pos.xyz/pos.w;
}

#ifdef Reflections
uniform mat4 gbufferProjection;
uniform ivec2 eyeBrightnessSmooth;

vec3 nvec3(vec4 pos) {
    return pos.xyz/pos.w;
}

vec4 raytrace(vec4 color, vec3 normal) {
	vec3 fragpos0 = screenSpace(texcoord.xy, texture2D(depthtex0, texcoord.xy).x);
	vec3 rvector = reflect(fragpos0.xyz, normal.xyz);
		 rvector = normalize(rvector);
	
	vec3 start = fragpos0 + rvector;
	vec3 tvector = rvector;
    int sr = 0;
	const int maxf = 3;				//number of refinements
	const float ref = 0.2;			//refinement multiplier
	const int rsteps = 15;
	const float inc = 2.2;			//increasement factor at each step	
    for(int i=0;i<rsteps;i++){
        vec3 pos = nvec3(gbufferProjection * vec4(start, 1.0)) * 0.5 + 0.5;
        if(pos.x < 0 || pos.x > 1 || pos.y < 0 || pos.y > 1 || pos.z < 0 || pos.z > 1.0) break;
        vec3 fragpos1 = screenSpace(pos.xy, texture2D(depthtex1, pos.st).x);
        float err = distance(start, fragpos1);
		if(err < pow(length(rvector),1.35)){
                sr++;
                if(sr >= maxf){
                    color = texture2D(texture, pos.st);
					color.a = cdist(pos.st);
					break;
                }
				tvector -= rvector;
                rvector *= ref;

}
        rvector *= inc;
        tvector += rvector;
		start = fragpos0 + tvector;
	}

    return color;
}/*--------------------------------------*/
#endif

#ifdef Refractions
uniform sampler2D noisetex;
uniform float frameTimeCounter;
uniform vec3 cameraPosition;
uniform mat4 gbufferModelViewInverse;

mat2 rmatrix(float rad){
	return mat2(vec2(cos(rad), -sin(rad)), vec2(sin(rad), cos(rad)));
}

float calcWaves(vec2 coord){
	vec2 movement = abs(vec2(0.0, -frameTimeCounter * 0.31365))*0.90;

	coord *= 0.262144;
	vec2 coord0 = coord * rmatrix(1.0) - movement * 4.0;
		 coord0.y *= 3.0;
	vec2 coord1 = coord * rmatrix(0.5) - movement * 1.5;
		 coord1.y *= 3.0;		 
	vec2 coord2 = coord + movement * 0.5;
		 coord2.y *= 3.0;
	
	float wave = 1.0 - texture2D(noisetex,coord0 * 0.005).x * 10.0;		//big waves
		  wave += texture2D(noisetex,coord1 * 0.010416).x * 7.0;		//small waves
		  wave += sqrt(texture2D(noisetex,coord2 * 0.045).x * 6.5) * 1.33;//noise texture
		  wave *= 0.0157;
	
	return wave;
}

vec2 calcBump(vec2 coord){
	const vec2 deltaPos = vec2(0.25, 0.0);

	float h0 = calcWaves(coord);
	float h1 = calcWaves(coord + deltaPos.xy);
	float h2 = calcWaves(coord - deltaPos.xy);
	float h3 = calcWaves(coord + deltaPos.yx);
	float h4 = calcWaves(coord - deltaPos.yx);

	float xDelta = ((h1-h0)+(h0-h2));
	float yDelta = 2.0 * ((h3-h0)+(h0-h4));

	return vec2(xDelta,yDelta)*0.04;
}
#endif

#ifdef Godrays
varying vec2 lightPos;
float land = 1.0-near/far/far;
float getnoise(vec2 pos) {
	return fract(sin(dot(pos ,vec2(18.9898f,28.633f))) * 4378.5453f);
}
vec3 calcRays(vec3 color){
	vec2 deltatexcoord = vec2(lightPos - texcoord) * 0.04;
#if grays_quality == 1
	vec2 noisetc = texcoord; //fast unfiltered
#elif grays_quality == 2
	vec2 noisetc = texcoord + deltatexcoord*getnoise(texcoord); //slow filtered
#endif

	float gr = 1.0;
	for (int i = 0; i < 20; i++) {
		float depth0 = texture2D(depthtex0, noisetc).x;
		noisetc += deltatexcoord;
		gr += dot(step(land, depth0), 1.0)*cdist(noisetc);
	}
	gr /= 20.0;

	vec3 gfragpos0 = screenSpace(texcoord.xy, texture2D(depthtex0, texcoord.xy).x);
	float lightpos = clamp(dot(normalize(gfragpos0.xyz), normalize(shadowLightPosition.xyz)), 0.0, 1.0)*gr*grays_intensity;
	return color *= 1.0+lightpos*color * (1.0 - isEyeInWater);
}
#endif

#ifdef skyReflection
uniform vec3 skyColor;
#endif

void main() {

	vec4 tex = texture2D(texture, texcoord.xy)*color;
	vec3 normal = texture2D(gnormal, texcoord.xy).xyz; //vec2 for normals, z=mat
	vec3 newnormal = decode(normal.xy);

	float getmat = normal.z*2.0;
	bool iswater = getmat > 0.9 && getmat < 1.1;
	bool isreflective = getmat > 0.9 && getmat < 3.1;
	bool isice = getmat > 1.9 && getmat < 2.1;

#ifdef Reflections
if(isreflective && isEyeInWater < 0.9){
	vec4 reflection = raytrace(tex, newnormal.xyz);

 	vec3 normfrag1 = normalize(screenSpace(texcoord.xy, texture2D(depthtex1, texcoord.xy).x));

	vec3 rVector = reflect(normfrag1, normalize(newnormal.xyz));
	vec3 hV= normalize(rVector - normfrag1);
	
	float normalDotEye = dot(hV, normfrag1);
	float F0 = 0.09;
	float fresnel = pow(clamp(1.0 + normalDotEye,0.0,1.0), 4.0) ;
		  fresnel = fresnel+F0*(1.0-fresnel);
		
#ifdef Refractions
	vec4 fragpos0 = gbufferProjectionInverse * (vec4(texcoord, texture2D(depthtex0, texcoord).x, 1.0) * 2.0 - 1.0);
		 fragpos0 /= fragpos0.w;
	vec2 wpos = (gbufferModelViewInverse*fragpos0).xz+cameraPosition.xz;
		 if(!isice)tex.rgb = texture2D(texture, (texcoord.xy+calcBump(wpos))).rgb*color.rgb;
#endif

		 reflection.rgb = mix(tex.rgb, reflection.rgb, reflection.a); //maybe change tex with skycolor
		 tex.rgb = mix(tex.rgb, reflection.rgb, fresnel*1.25);
}
#endif

#ifdef Godrays
	tex.rgb = calcRays(tex.rgb);
#endif

	gl_FragData[0] = tex;
	gl_FragData[1] = vec4(0.0); //improves performance
}
