#version 450

layout(push_constant) uniform Push{
	vec4 SourceSize;
	vec4 OriginalSize;
	vec4 OutputSize;
	uint FrameCount;
} params;


layout(std140, set = 0, binding = 0) uniform UBO{
	mat4 MVP;
} global;

#pragma stage vertex
layout(location = 0) in vec4 Position;
layout(location = 1) in vec2 TexCoord;
layout(location = 0) out vec2 vTexCoord;

void main(){
   gl_Position = global.MVP * Position;
   vTexCoord = TexCoord;
}

#pragma stage fragment
layout(location = 0) in vec2 vTexCoord;
layout(location = 0) out vec4 FragColor;
layout(set = 0, binding = 2) uniform sampler2D Source;

vec3 luminance = vec3(0.2989, 0.5870, 0.1140);

void main(){
	float q0 = dot(texture(Source, vTexCoord * 0.50).rgb, luminance);
	float q1 = dot(texture(Source, vTexCoord * 0.50 + vec2(0.50, 0.00)).rgb, luminance);
	float q2 = dot(texture(Source, vTexCoord * 0.50 + vec2(0.00, 0.50)).rgb, luminance);
	float q3 = dot(texture(Source, vTexCoord * 0.50 + vec2(0.50, 0.50)).rgb, luminance);

	FragColor = vec4(q0, q1, q2, q3);
}
