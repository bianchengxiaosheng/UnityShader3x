Shader "GWL/LightingBaseDiffuse" {
	Properties {
		_EmissiveColor ("Emissive Color", Color) = (1,1,1,1)  
        _AmbientColor  ("Ambient Color", Color) = (1,1,1,1)  
        _MySliderValue ("This is a Slider", Range(0,2.5)) = 2.5 
	}
	SubShader {
		Tags { "RenderType" = "Opaque" }
		LOD 200
		Pass {
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase;
			//#define UNITY_PASS_FORWARDBASE
			#include "UnityCG.cginc" 
			#include "Lighting.cginc" 
			#include "AutoLight.cginc" 
			//#define INTERNAL_DATA
			//#define WorldReflectionVector(data,normal) data.worldRefl
			//#define WorldNormalVector(data,normal) normal
			fixed4 _EmissiveColor;  
        	fixed4 _AmbientColor;  
        	float _MySliderValue;

			
			struct Input{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};
			struct Output{	
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldLightDir:TEXCOORD1;
				float3 shLight : TEXCOORD2;
				float3 vertexLight : TEXCOORD3;
				LIGHTING_COORDS(2,3)
				
			};
			Output vert(Input v)
			{
				Output o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				o.worldNormal = normalize(mul((float3x3)_Object2World,SCALED_NORMAL));//因为模型的矩阵式正交矩阵，所以用这个否则用这个mul(v.normal,(float3x3) _World2Object)
				//计算光照方向
				o.worldLightDir = normalize(WorldSpaceLightDir(v.vertex));
				o.shLight = ShadeSH9(float4 (o.worldNormal, 1.0));
				//o.vertexLight = ShadeVertexLights(v.vertex, v.normal);
				o.vertexLight = o.shLight;
				float3  worldPos = mul(_Object2World,v.vertex).xyz;
				o.vertexLight +=  Shade4PointLights (
				    unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
				    unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
				    unity_4LightAtten0, worldPos, o.worldNormal);
				
				TRANSFER_VERTEX_TO_FRAGMENT(o); 
				return o;
			}
			float4 LightBasicDiffuse(float3 normal,fixed3 lightDir,float3 albedo,fixed atten)
			{
				float difLight = max(0,dot(normal,lightDir));
				float4 col;
				col.rgb = albedo * _LightColor0.rgb * (difLight * atten * 2);
				col.a = 1;
				return col;
			}	
			fixed4 frag(Output i):COLOR
			{
				float4  finalcolor ;//= pow((_EmissiveColor + _AmbientColor), _MySliderValue);
				finalcolor.rgb += finalcolor.rbg * i.vertexLight;

				fixed atten = LIGHT_ATTENUATION(i);
				return finalcolor;
			}
			ENDCG
		}
		Pass {
			Name "FORWARD"
			Tags { "LightMode" = "ForwardAdd" }
			ZWrite Off Blend One One Fog { Color (0,0,0,0) }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase;
			#include "UnityCG.cginc" 
			#include "Lighting.cginc" 
			#include "AutoLight.cginc" 
			fixed4 _EmissiveColor;  
        	fixed4 _AmbientColor;  
        	float _MySliderValue;
        	struct Input{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};
			struct Output{	
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldLightDir:TEXCOORD1;
				
				LIGHTING_COORDS(2,3)
				
			};
			Output vert(Input v)
			{
				Output o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex );
				o.worldNormal = mul((float3x3)_Object2World, SCALED_NORMAL);
				o.worldLightDir = WorldSpaceLightDir(v.vertex);
				return o; 
			}
			fixed4 frag(Output i):COLOR
			{
				float4  finalcolor = pow((_EmissiveColor + _AmbientColor), _MySliderValue);
				float difLight = max(0,dot(i.worldNormal ,i.worldLightDir));
				float4 col;
				fixed atten = LIGHT_ATTENUATION(i);
				col.rgb = finalcolor.rgb * _LightColor0.rgb * (difLight * 1 * atten);
				col.a =1;
				return col;
			}


			ENDCG
		}

	} 
	FallBack "Diffuse"
}
