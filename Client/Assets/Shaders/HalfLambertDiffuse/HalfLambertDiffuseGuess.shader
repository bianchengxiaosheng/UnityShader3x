Shader "GWL/HalfLambertDiffuseGuess" {//Half Lambert最初是由Valve（游戏半条命2使用的引擎即是其开发的）提出来，用于提高物体在一些光线无法照射到的区域的亮度的。简单说来，它提高了漫反射光照的亮度，使得漫反射光线可以看起来照射到一个物体的各个表面
  Properties {
    _EmissiveColor ("Emissive Color", Color) = (1,1,1,1)
    _AmbientColor  ("Ambient Color", Color) = (1,1,1,1)
    _MySliderValue ("This is a Slider", Range(0,10)) = 2.5
  }
  SubShader {
    Tags { "RenderType"="Opaque" }
    LOD 200
    Pass {
      Tags { "LightMode" = "ForwardBase" }
      CGPROGRAM
      #pragma vertex vert
        #pragma fragment frag
        #include "UnityCG.cginc"
        #include "Lighting.cginc"
        #include "AutoLight.cginc"
        float4 _EmissiveColor;
        float4 _AmbientColor;
        float _MySliderValue;
        //基本漫反射模型
        inline float4 LightingBasicDiffuse (fixed3 rbg,fixed3 normal, fixed3 lightDir, fixed atten)
        {
          fixed  difLight = dot (normal, lightDir);
          fixed hLambert = difLight * 0.5 + 0.5; 
          
          fixed4  col;
          col.rgb = rbg * _LightColor0.rgb * (hLambert * atten * 2);
          col.a = 1;
          return col;
        }

        struct Input{
          float4 vertex:POSITION;
          float3 normal:NORMAL;

        }; 
        struct Output{
          float4 pos:SV_POSITION;
          fixed3 worldN:TEXCOORD0;
          fixed3 vertexLight:TEXCOORD1;
          float3 worldlightDir:TEXCOORD2;
          float4 worldPos:TEXCOORD3;
        };

      Output vert(Input v)
      {
        Output o;
        o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
        o.worldN = mul((float3x3)_Object2World,SCALED_NORMAL);
        o.vertexLight = ShadeSH9(float4(o.worldN,1.0));
        o.worldlightDir = WorldSpaceLightDir(v.vertex );
        o.worldPos = mul(_Object2World,v.vertex);
        return o;
      }


      fixed4 frag(Output i):COLOR
      {
        fixed4   col = pow((_EmissiveColor + _AmbientColor),_MySliderValue);
        fixed4 Col2;
        float  atten = 1;//LIGHT_ATTENUATION(i);
        float3 lightDirection;
        if(0.0 == _WorldSpaceLightPos0.w)//直线光
        {
          atten = 1.0;
          lightDirection = normalize(_WorldSpaceLightPos0.xyz);

        }else//点光源或聚光灯
        {
          float3 vertexToLightSource = _WorldSpaceLightPos0.xyz - i.worldPos.xyz;
          float distance = length(vertexToLightSource);
          atten = 1.0 /distance;//线性的光照强度
          lightDirection = normalize(vertexToLightSource);
        }
        Col2 =  LightingBasicDiffuse(col.rgb,i.worldN,lightDirection,atten);
        Col2.rbg += col.rgb * i.vertexLight;
        return Col2;
      }
      ENDCG
    }
    
  } 
  FallBack "Diffuse"
}
