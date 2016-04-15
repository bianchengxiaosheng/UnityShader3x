Shader "GWL/LambertDiffuseGeneratedCodeDelete" 
{
	Properties 	
	{
		_EmissiveColor ("Emissive Color", Color) = (1,1,1,1)
		_AmbientColor  ("Ambient Color", Color) = (1,1,1,1)
		_MySliderValue ("This is a Slider", Range(0,10)) = 2.5

	}	
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200

	// ---- forward rendering base pass:
	Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardBase" }

    CGPROGRAM
    // compile directives
    #pragma vertex vert_surf
    #pragma fragment frag_surf
    #pragma multi_compile_fwdbase nodirlightmap
    //#include "HLSLSupport.cginc"
    //#include "UnityShaderVariables.cginc"
    //#define UNITY_PASS_FORWARDBASE
    #include "UnityCG.cginc"
    #include "Lighting.cginc"
    #include "AutoLight.cginc"


    		//#pragma surface surf BasicDiffuse

    		float4 _EmissiveColor;
    		float4 _AmbientColor;
    		float _MySliderValue;
    		
    		inline float4 LightingBasicDiffuse (SurfaceOutput s, fixed3 lightDir, fixed atten)
    		{
    			float difLight = max(0, dot (s.Normal, lightDir));
    			
    			float4 col;
    			col.rgb = s.Albedo * _LightColor0.rgb * (difLight * atten * 2);
    			col.a = s.Alpha;
    			return col;
    		}

    		struct Input 
    		{
    			//float2 uv_MainTex;
    			float2 uv;
    		};

    		void surf (inout SurfaceOutput o) 
    		{
    			float4 c;
    			c =  pow((_EmissiveColor + _AmbientColor), _MySliderValue);
    			
    			o.Albedo = c.rgb;
    			o.Alpha = c.a;
    		}
    // vertex-to-fragment interpolation data
    struct v2f_surf {
      float4 pos : SV_POSITION;
      fixed3 normal : TEXCOORD0;
      fixed3 vlight : TEXCOORD1;
      LIGHTING_COORDS(2,3)
    };
    // vertex shader
    v2f_surf vert_surf (appdata_full v) {
      v2f_surf o;
      o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
      float3 worldN = mul((float3x3)_Object2World, SCALED_NORMAL);
      o.normal = worldN;
      // SH/ambient and vertex lights
      float3 shlight = ShadeSH9 (float4(worldN,1.0));
      o.vlight = shlight;

      // pass lighting information to pixel shader
      //TRANSFER_VERTEX_TO_FRAGMENT(o);
      return o;
    }
    // fragment shader
    fixed4 frag_surf (v2f_surf IN) : COLOR {

      Input surfIN;
      SurfaceOutput o;
      o.Albedo = 0.0;
      o.Emission = 0.0;
      o.Specular = 0.0;
      o.Alpha = 0.0;
      o.Gloss = 0.0;
      o.Normal = IN.normal;
      float2 v;
      // call surface function
      surf (o);

      // compute lighting & shadowing factor
      fixed atten = LIGHT_ATTENUATION(IN);
      fixed4 c = 0;

      // realtime lighting: call lighting function
      c = LightingBasicDiffuse (o, _WorldSpaceLightPos0.xyz, atten);
      c.rgb += o.Albedo * IN.vlight;

      return c;
    }

    ENDCG

    }

	

	} 
	
	FallBack "Diffuse"
}
