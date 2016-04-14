Shader "GWL/BaseDiffuse" {
	Properties {
		_DiffuseTex("DiffuseTex (RGB)", 2D) = "white" {}
	}
	SubShader {
		Pass {
			Tags { "RenderType"="Opaque" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			uniform sampler2D _DiffuseTex;

			
			struct Input{
				float4 vertex:POSITION;
				float4 texcoord:TEXCOORD0; 
			};
			struct Output{	
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0; 
			};
			Output vert(Input v)
			{
				Output o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				o.uv = v.texcoord.xy;
				return o;
			}
			fixed4 frag(Output i):COLOR
			{
				fixed4 finalcolor = tex2D(_DiffuseTex,i.uv);
				return finalcolor ;
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
