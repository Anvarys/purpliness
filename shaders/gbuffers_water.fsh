#version 330 compatibility

uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform sampler2D depthtex0;
uniform vec2 viewSize;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

float linearizeDepth(float depth) {

    float near = 0.1;

    float far = 100.0;

    return (2.0 * near) / (far + near - depth * (far - near));

}

void main() {
	vec2 uv0 = gl_FragCoord.xy / viewSize;
	float sceneDepth = linearizeDepth(texture(depthtex0, uv0).r);
	float waterDepth = linearizeDepth(gl_FragCoord.z);
	float depthDifference = abs(sceneDepth - waterDepth);

	float depthFactor = smoothstep(0.0, 0.02, depthDifference);

	vec3 normal = vec3(0.5, 0.2, 0.7);
	vec3 deep = vec3(0.1, 0.0, 0.2);

	vec2 uv = gl_FragCoord.xy / viewSize;
	
	color = texture(gtexture, texcoord);
	color.rgb = mix(color.rgb, mix(normal, deep, depthFactor), 0.7);
	color *= texture(lightmap, lmcoord);
	if (color.a < alphaTestRef) {
		discard;
	}
}