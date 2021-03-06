Shader "Stencil/Paper" {
Properties {
    _Color ("Main Color", Color) = (1,1,1,1)
    _MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
    _StencilTex ("Stencil", 2D) = "white" {}
}

SubShader {
    Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
    LOD 100

    Cull Off
    Lighting Off
    ZWrite Off
    Blend One OneMinusSrcAlpha

    Pass {
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"

            struct appdata_t {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float2 texcoord : TEXCOORD0;
            };

            sampler2D _MainTex;
            sampler2D _StencilTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed3 _GlobalColorCorrection;

            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 paintCol = tex2D(_MainTex, i.texcoord);
                fixed4 stencilCol = tex2D(_StencilTex, i.texcoord);
                stencilCol.rgb = _Color * stencilCol.a;
                fixed4 col = paintCol*stencilCol.a + stencilCol*(1-paintCol.a); 
                //col.rgb *= _GlobalColorCorrection;
                return col;
            }
        ENDCG
    }
}

}
