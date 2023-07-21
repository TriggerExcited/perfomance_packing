#version 450

#pragma parameter MODE "Mode:" 0.0 0.0 3.0 1.0

layout(push_constant) uniform Push{
	vec4 SourceSize;
	vec4 OriginalSize;
	vec4 OutputSize;
	uint FrameCount;
	float MODE;
} params;

#define MODE params.MODE

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
layout(set = 0, binding = 3) uniform sampler2D context_pass;

vec3 luminance = vec3(0.2989, 0.5870, 0.1140);

vec3 RGBtoYIQ(vec3 RGB){
    const mat3x3 m = mat3x3(
        0.2989, 0.5870, 0.1140,
        0.5959, -0.2744, -0.3216,
        0.2115, -0.5229, 0.3114);
    return RGB * m;
}

vec3 YIQtoRGB(vec3 YIQ)
{
    const mat3x3 m = mat3x3(
        1.0, 0.956, 0.6210,
        1.0, -0.2720, -0.6474,
        1.0, -1.1060, 1.7046);
    return YIQ * m;
}

void main(){
	float luminance;

	if(vTexCoord.x < 0.5){
		if(vTexCoord.y < 0.5){
			luminance = texture(Source, vTexCoord * 2.0).r;
		}else{
			luminance = texture(Source, vTexCoord * 2.0 - vec2(0.0, 1.0)).b;
		}
	}else{
		if(vTexCoord.y < 0.5){
			luminance = texture(Source, vTexCoord * 2.0 - vec2(1.0, 0.0)).g;
		}else{
			luminance = texture(Source, vTexCoord * 2.0 - 1.0.xx).a;
		}
	}
	FragColor = luminance.xxxx;
}
