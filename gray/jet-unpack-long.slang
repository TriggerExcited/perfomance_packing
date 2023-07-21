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
layout(set = 0, binding = 2) uniform usampler2D Source;

void main(){
	vec4 upack;
	
	if(vTexCoord.x < 0.5){
		if(vTexCoord.y < 0.5){
			upack = unpackUnorm4x8(texture(Source, vTexCoord * 2.0).r);
		}else{
			upack = unpackUnorm4x8(texture(Source, vTexCoord * 2.0 - vec2(0.0, 1.0)).b);
		}
	}else{
		if(vTexCoord.y < 0.5){
			upack = unpackUnorm4x8(texture(Source, vTexCoord * 2.0 - vec2(1.0, 0.0)).g);
		}else{
			upack = unpackUnorm4x8(texture(Source, vTexCoord * 2.0 - 1.0.xx).a);
		}
	}
	FragColor = upack;
}
