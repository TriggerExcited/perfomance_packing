#version 450

#pragma format R32G32B32A32_UINT

layout(push_constant) uniform Push{
	vec4 SourceSize;
	vec4 OriginalSize;
	vec4 OutputSize;
	uint FrameCount;
} params;

layout(std140, set = 0, binding = 0) uniform UBO
{
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
layout(location = 0) out uvec4 FragColor;
layout(set = 0, binding = 2) uniform sampler2D Source;

void main(){
    vec4 q0 = texture(Source, vTexCoord * 0.50);
	vec4 q1 = texture(Source, vTexCoord * 0.50 + vec2(0.50, 0.00));
	vec4 q2 = texture(Source, vTexCoord * 0.50 + vec2(0.00, 0.50));
	vec4 q3 = texture(Source, vTexCoord * 0.50 + vec2(0.50, 0.50));

	FragColor = uvec4(packUnorm4x8(q0), packUnorm4x8(q1), packUnorm4x8(q2), packUnorm4x8(q3));
}
