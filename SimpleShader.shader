Shader "GPUXX/GeomColor" {
SubShader { Pass {
ZWrite Off //ZTest Always
CGPROGRAM #pragma target 3.0
#pragma vertex vert_geomcolor #pragma fragment frag_geomcolor
void vert_geomcolor(float4 v:POSITION, out float4 c:COLOR0, out float4 sv:SV _POSITION) {
sv = mul(UNITY_MATRIX_MVP, v);
c = float4(v.x, v.y, v.z, 1); }
float4 frag_geomcolor(float4 c:COLOR0) : COLOR { return float4(c); // red
}
ENDCG
} }
}