Shader "GPUXX/TexturedSpecmapVertexLit" { Properties {
_BaseTex ("Base (RGB) Gloss (A)", 2D) = "white" {} _SpecColor ("Spec Color", Color) = (1,1,1,1) _Shininess ("Shininess", Range(0.01,1)) = 0.7
}
SubShader {
// Directional light colors aren't exposed in "ForwardBase" mode, so we try "Vertex
" mode,
// which really should be called "Simple" mode, as we can still do custom per-
pixel lighting
Tags { "LightMode" = "Vertex" }
Pass { ZWrite Off
//ZTest Always
CGPROGRAM
#include "UnityCG.cginc"
#pragma target 2.0
#pragma vertex vert_specmapvertexlit #pragma fragment frag_specmapvertexlit
uniform sampler2D _BaseTex; uniform float4 _BaseTex_ST;
uniform float4 _SpecColor; uniform float _Shininess;
struct a2v {
float4 v: POSITION; float3 n: NORMAL; float2 tc: TEXCOORD0;
};
struct v2f {
float4 sv: SV_POSITION;
float2 tc: TEXCOORD0;
float3 diff_almost: TEXCOORD1; float3 spec_almost: TEXCOORD2;
};
v2f vert_specmapvertexlit(a2v input) { v2f output;
output.sv = mul (UNITY_MATRIX_MVP, input.v);
float3 vWorldPos = mul (_Object2World, input.v).xyz;
// To transform normals, we want to use the inverse transpose of upper left 3x3 // Putting input.n in first argument is like doing trans((float3x3)_World2Object)
* input.n;
float3 nWorld = normalize(mul(input.n, (float3x3) _World2Object));
// Unity light position convention is:
// w = 0, directional light, with x y z pointing in opposite of light direction // w = 1, point light, with x y z indicating position coordinates
float3 lightDir = normalize(_WorldSpaceLightPos0.xyz -
vWorldPos * _WorldSpaceLightPos0.w);
float3 eyeDir = normalize(_WorldSpaceCameraPos.xyz - vWorldPos);
float3 h = normalize(lightDir + eyeDir);
output.diff_almost = 2*unity_LightColor0.rgb * max(0, dot(nWorld, lightDir)); float ndoth = max(0, dot(nWorld, h));
float count=0;
for(int i=0;i<800;i++)
{count++;
output.spec_almost += 2*unity_LightColor0.rgb * _SpecColor.rgb * pow(ndot h, _Shininess*128.0);
output.spec_almost +=float3(count,20,80)/100000;
}
//output.spec_almost = 2*unity_LightColor0.rgb * _SpecColor.rgb * pow(ndot
h, _Shininess*128.0);
output.tc = TRANSFORM_TEX(input.tc, _BaseTex);
return output; }
float4 frag_specmapvertexlit(v2f input) : COLOR {
float4 base = tex2D(_BaseTex, input.tc);
float3 output = (input.diff_almost + 2*UNITY_LIGHTMODEL_AMBIENT.r
gb) * base.rgb +input.sec_almost.rgb*base.a;
return(float4(output,1));
}
ENDCG
} }
}