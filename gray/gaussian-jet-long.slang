#version 450

/*
   Gaussian blur - dynamic range, resizable
   
   Copyright (C) 2020 guest(r) - guest.r@gmail.com

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License
   as published by the Free Software Foundation; either version 2
   of the License, or (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
   
*/ 

#pragma format R32G32B32A32_UINT

layout(push_constant) uniform Push
{
	vec4 SourceSize;
	vec4 OriginalSize;
	vec4 OutputSize;
	uint FrameCount;
	float SIZEH;
	float SIGMA_H;
	float SIZEV;
	float SIGMA_V;
} params;

#pragma parameter SIZEH "Horizontal Blur Radius" 6.0 0.0 25.0 1.0 
#define SIZEH params.SIZEH

#pragma parameter SIGMA_H "Horizontal Blur Sigma" 1.50 0.1 12.0 0.05
#define SIGMA_H params.SIGMA_H

#pragma parameter SIZEV "Vertical Blur Radius" 6.0 0.0 25.0 1.0 
#define SIZEV params.SIZEV

#pragma parameter SIGMA_V "Vertical Blur Sigma" 1.50 0.1 12.0 0.05
#define SIGMA_V params.SIGMA_V

layout(std140, set = 0, binding = 0) uniform UBO
{
	mat4 MVP;
} global;

#pragma stage vertex
layout(location = 0) in vec4 Position;
layout(location = 1) in vec2 TexCoord;
layout(location = 0) out vec2 vTexCoord;

void main()
{
   gl_Position = global.MVP * Position;
   vTexCoord = TexCoord;
}

#pragma stage fragment
layout(location = 0) in vec2 vTexCoord;
layout(location = 0) out uvec4 FragColor;
layout(set = 0, binding = 2) uniform usampler2D Source;

#define COMPAT_TEXTURE(c,d) texture(c,d)
#define SourceSize params.SourceSize

float invsqrsigma_h = 1.0/(2.0*SIGMA_H*SIGMA_H);
float invsqrsigma_v = 1.0/(2.0*SIGMA_V*SIGMA_V);

float gaussian_h(float x)
{
	return exp(-x*x*invsqrsigma_h);
}

float gaussian_v(float x)
{
	return exp(-x*x*invsqrsigma_v);
}

uvec4 jet_texture(usampler2D text, vec2 uv){
	uvec4 pack = texture(text, uv);

	if(uv.x < 0.0){
		return pack.grab;
	}
	if(uv.x > 1.0){
		return pack.grab;
	}
	if(uv.y < 0.0){
		return pack.barg;
	}
	if(uv.y > 1.0){
		return pack.barg;
	}

	return pack;
}

void main()
{
	vec2 f = fract(SourceSize.xy * vTexCoord.xy);
	f = 0.5 - f;
	vec2 tex = floor(SourceSize.xy * vTexCoord)*SourceSize.zw + 0.5*SourceSize.zw;
	vec2 dx  = vec2(SourceSize.z, 0.0);	
	vec2 dy  = vec2(0.0, SourceSize.w);

	vec4 colorx0 = 0.0.xxxx; // this
	vec4 colorx1 = 0.0.xxxx;
	vec4 colorx2 = 0.0.xxxx;
	vec4 colorx3 = 0.0.xxxx;
	vec4 colory0 = 0.0.xxxx;
	vec4 colory1 = 0.0.xxxx;
	vec4 colory2 = 0.0.xxxx;
	vec4 colory3 = 0.0.xxxx;

	float wx, wy;
	float wsumx;
	float wsumy = 0.0;
	uvec4 pack;   // this
	vec4 pixel0;
	vec4 pixel1;
	vec4 pixel2;
	vec4 pixel3;
	float x;
	float y = -SIZEV;

	do
	{
		wsumx  = 0.0;
		colorx0 = 0.0.xxxx; // this
		colorx1 = 0.0.xxxx;
		colorx2 = 0.0.xxxx;
		colorx3 = 0.0.xxxx;
		x = -SIZEH;
		
		do
		{
			pack  = jet_texture(Source, tex + x*dx + y*dy); // this
			pixel0  = unpackUnorm4x8(pack.r);
			pixel1  = unpackUnorm4x8(pack.g);
			pixel2  = unpackUnorm4x8(pack.b);
			pixel3  = unpackUnorm4x8(pack.a);
			wx      = gaussian_h(x+f.x);
			colorx0 = colorx0 + wx * pixel0;  // this
			colorx1 = colorx1 + wx * pixel1;
			colorx2 = colorx2 + wx * pixel2;
			colorx3 = colorx3 + wx * pixel3;
			wsumx   = wsumx+ wx;
			x = x + 1.0;
			
		} while (x <= SIZEH);
		
		colorx0  = colorx0 / wsumx;  // this
		colorx1  = colorx1 / wsumx;
		colorx2  = colorx2 / wsumx;
		colorx3  = colorx3 / wsumx;
		wy      = gaussian_v(y+f.y);
		colory0  = colory0 + wy * colorx0;  // this
		colory1  = colory1 + wy * colorx1;
		colory2  = colory2 + wy * colorx2;
		colory3  = colory3 + wy * colorx3;
		wsumy   = wsumy + wy;
		y = y + 1.0;
		
	} while (y <= SIZEV);

	colory0= colory0/wsumy; // this
	colory1= colory1/wsumy;
	colory2= colory2/wsumy;
	colory3= colory3/wsumy;

	FragColor = uvec4(packUnorm4x8(colory0), packUnorm4x8(colory1), packUnorm4x8(colory2), packUnorm4x8(colory3)); // this
}
