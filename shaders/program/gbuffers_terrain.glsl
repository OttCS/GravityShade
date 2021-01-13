/*
	GravityShade by Gravity10
	Code is licensed under GNU Lesser General Public License v2.1
	Thanks for using GravityShade!
*/

#ifdef FSH

uniform sampler2D texture;

varying vec3 color;
varying vec2 lmcoord;
varying vec2 texcoord;

#include "/lib/g10tm.glsl"
#include "/lib/light.glsl"

void main() {

	vec3 texColor = g10tm(texture2D(texture, texcoord).rgb * color.rgb);

	int dimension = 0;
	#ifdef NETHER
	dimension = 1;
	#endif
	#ifdef END
	dimension = 2;
	#endif

	gl_FragData[0] = vec4(texColor * trueLight(lmcoord, dimension), texture2D(texture, texcoord).a);
}

#endif

// FSH above, VSH below //

#ifdef VSH

attribute vec4 mc_Entity;

varying vec2 lmcoord;
varying vec3 binormal;
varying vec3 normal;
varying vec3 tangent;
varying vec3 color;
varying vec2 texcoord;

#include "/lib/waving.glsl"

void main() {

	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).rg;
	
	texcoord = gl_MultiTexCoord0.xy;
	
	vec4 coordPos = gl_Vertex;

	color = gl_Color.rgb;

	if (mc_Entity.x >= 10100 && mc_Entity.x <= 10300) {

		if (mc_Entity.x <= 10107) {

			if (mc_Entity.x <= 10102) { // Ground plants and crops
				plantWave(coordPos.xyz);
			} else if (mc_Entity.x <= 10104) { // Tall plants
				tallPlantWave(coordPos.xyz);
			} else if (mc_Entity.x <= 10106) { // Leaves and vines
				leafWave(coordPos.xzy);
			} else { // Lily Pad
				lilyWave(coordPos.xyz);
			}

		} else {

			if (mc_Entity.x <= 10109) { // Hardy Plants
				hardyWave(coordPos.xyz);
			} else if (mc_Entity.x == 10251) {// Soul Lantern and Normal Lantern
				lanternWave(coordPos.xyz);
			} else if (mc_Entity.x == 10300) { // Water
				waterWave(coordPos.xyz);
			}
		}
		
	}
	
	gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * coordPos);

	normal = normalize(gl_NormalMatrix * gl_Normal);

	mat3 tbnMatrix = mat3(tangent.x, binormal.x, normal.x,
                          tangent.y, binormal.y, normal.y,
                          tangent.z, binormal.z, normal.z);
}

#endif