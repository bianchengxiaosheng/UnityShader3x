Shader "GWL/LightingBaseDiffuseGuess" {
  Properties {
    _EmissiveColor ("Emissive Color", Color) = (1,1,1,1)  
    _AmbientColor  ("Ambient Color", Color) = (1,1,1,1)  
    _MySliderValue ("This is a Slider", Range(0,10)) = 2.5 
  }
  SubShader {
    Tags { "RenderType" = "Opaque" }
    LOD 200
    Pass {
      Tags { "LightMode"="ForwardBase" }
      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag
      #pragma multi_compile_fwdbase nodirlightmap;
      #include "UnityCG.cginc" 
      #include "Lighting.cginc" 
      #include "AutoLight.cginc" 

      float4 _EmissiveColor;  
      float4 _AmbientColor;  
      float _MySliderValue;
      struct Input{
        float4 vertex:POSITION;
        float3 normal:NORMAL;
      };
      struct Output{  
        float4 pos:SV_POSITION;
        float3 worldNormal:TEXCOORD0;
        //float3 worldLightDir:TEXCOORD1;
        float3 vertexLight : TEXCOORD3;
        LIGHTING_COORDS(2,3)
        
      };
      Output vert(Input v)
      {
        Output o;
        o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
        o.worldNormal = mul((float3x3)_Object2World,SCALED_NORMAL);
        o.vertexLight  = ShadeSH9(float4 (o.worldNormal, 1.0));
        TRANSFER_VERTEX_TO_FRAGMENT(o);
        return o;
      }
      inline float4 LightingBasicDiffuse (SurfaceOutput s, fixed3 lightDir, fixed atten)
      {
          float difLight = max(0, dot (s.Normal, lightDir));
          
          float4 col;
          col.rgb = s.Albedo * _LightColor0.rgb * (difLight * atten * 2);
          col.a = s.Alpha;
          return col;
      }
        struct Input2 
        {
          float2 uv_MainTex;
        };

      void surf3 (Input2 IN, inout SurfaceOutput o) 
      {
        float4 c;
        c =  pow((_EmissiveColor + _AmbientColor), _MySliderValue);
        
        o.Albedo = c.rgb;
        o.Alpha = c.a;
      }

      fixed4 frag(Output i):COLOR
      {
        SurfaceOutput o;
        o.Albedo = 0.0;
        o.Emission = 0.0;
        o.Specular = 0.0;
        o.Alpha = 0.0;
        o.Gloss = 0.0;
        o.Normal = i.worldNormal ;
        Input2 In;
        surf3(In,o);//unity3.5.7必须使用这个函数才能达到预期效果，很奇怪，直接分解相关函数达不到预期 unity4.5.5却可以达到
        //float4  finalcolor2 = pow((_EmissiveColor + _AmbientColor), _MySliderValue);
        //o.Albedo = finalcolor2.rgb;
        //o.Alpha = 1;
        fixed atten = LIGHT_ATTENUATION(i);
        fixed4 c = 0;
        c = LightingBasicDiffuse(o,_WorldSpaceLightPos0.xyz,atten);
        c.rgb += o.Albedo * i.vertexLight;
        return c ;
      }
      ENDCG
    }
  }
   
  FallBack "Diffuse"
}
