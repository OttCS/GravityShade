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

#ifdef SSAO
uniform float aspectRatio;
const vec2 check_offsets[25] = vec2[25](vec2(-0.4894566f,-0.3586783f),
									vec2(-0.1717194f,0.6272162f),
									vec2(-0.4709477f,-0.01774091f),
									vec2(-0.9910634f,0.03831699f),
									vec2(-0.2101292f,0.2034733f),
									vec2(-0.7889516f,-0.5671548f),
									vec2(-0.1037751f,-0.1583221f),
									vec2(-0.5728408f,0.3416965f),
									vec2(-0.1863332f,0.5697952f),
									vec2(0.3561834f,0.007138769f),
									vec2(0.2868255f,-0.5463203f),
									vec2(-0.4640967f,-0.8804076f),
									vec2(0.1969438f,0.6236954f),
									vec2(0.6999109f,0.6357007f),
									vec2(-0.3462536f,0.8966291f),
									vec2(0.172607f,0.2832828f),
									vec2(0.4149241f,0.8816f),
									vec2(0.136898f,-0.9716249f),
									vec2(-0.6272043f,0.6721309f),
									vec2(-0.8974028f,0.4271871f),
									vec2(0.5551881f,0.324069f),
									vec2(0.9487136f,0.2605085f),
									vec2(0.7140148f,-0.312601f),
									vec2(0.0440252f,0.9363738f),
									vec2(0.620311f,-0.6673451f)
									);

vec3 toScreenSpace(vec3 pos) {
	vec4 iProjDiag = vec4(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y, gbufferProjectionInverse[2].zw);
	vec3 p3 = pos * 2.0 - 1.0;
    vec4 fragposition = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
    return fragposition.xyz / fragposition.w;
}

//modified version of Yuriy O'Donnell's SSDO (License MIT -> https://github.com/kayru/dssdo)
float calcSSDO(vec3 fragpos, vec3 normal){
	float finalAO = 0.0;
	float radius = 0.05 / (fragpos.z);
	const float attenuation_angle_threshold = 0.1;
	const int num_samples = 16;	
	const float ao_weight = 1.0;

	for( int i=0; i<num_samples; ++i ){
	    vec2 texOffset = pow(length(check_offsets[i].xy),0.5)*radius*vec2(1.0,aspectRatio)*normalize(check_offsets[i].xy);
		vec2 newTC = texcoord+texOffset;

		vec3 t0 = toScreenSpace(vec3(newTC, texture2D(depthtex1, newTC).x));

		vec3 center_to_sample = t0.xyz - fragpos.xyz;

		float dist = length(center_to_sample);

		vec3 center_to_sample_normalized = center_to_sample / dist;
		float attenuation = 1.0-clamp(dist/6.0,0.0,1.0);
		float dp = dot(normal, center_to_sample_normalized);

		attenuation = sqrt(max(dp,0.0))*attenuation*attenuation * step(attenuation_angle_threshold, dp);
		finalAO += attenuation * (ao_weight / num_samples);
	}
	return finalAO;
}
#endif

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

#ifdef Celshading
float pw = 1.0/ viewWidth;
float ph = 1.0/ viewHeight;
float getdepth(vec2 coord) {
	return texture2D(depthtex1,coord).x;
}
vec3 celshade(vec3 c) {
	//edge detect
	float dtresh = 1/(far-near)* 0.0005;
	vec4 dc = vec4(getdepth(texcoord.xy));

	vec4 sa = vec4(getdepth(texcoord.xy + vec2(-pw,-ph)),
				   getdepth(texcoord.xy + vec2(pw,-ph)),
				   getdepth(texcoord.xy + vec2(-pw,0.0)),
				   getdepth(texcoord.xy + vec2(0.0,ph)));
	
	//opposite side samples
	vec4 sb = vec4(getdepth(texcoord.xy + vec2(pw,ph)),
				   getdepth(texcoord.xy + vec2(-pw,ph)),
				   getdepth(texcoord.xy + vec2(pw,0.0)),
				   getdepth(texcoord.xy + vec2(0.0,-ph)));

	vec4 dd = abs(2.0* dc - sa - sb) - dtresh;
		 dd = step(dd.xyzw, vec4(0.0));

	float e = clamp(dot(dd,vec4(0.25f)),0.0,1.0);
	return c*e;
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
