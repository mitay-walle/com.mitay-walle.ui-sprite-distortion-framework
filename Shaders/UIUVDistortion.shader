Shader "UI/UV Distortion HDR"
{
    Properties
    {
        [PerRendererData] _MainTex ("Main Texture", 2D) = "white" {}
        _DistortionTex ("Distortion Texture", 2D) = "black" {}

        [HDR] _TextureHDRMultiplier ("Texture HDR Multiplier", Color) = (1,1,1,1)
        [HDR] _VertexColorHDRMultiplier ("Vertex Color HDR Multiplier", Color) = (1,1,1,1)

        [Toggle]_InvertAlpha ("Invert Alpha", Float) = 0
        [HideInInspector]_StencilComp ("Stencil Comparison", Float) = 8
        [HideInInspector]_Stencil ("Stencil ID", Float) = 0
        [HideInInspector]_StencilOp ("Stencil Operation", Float) = 0
        [HideInInspector]_StencilWriteMask ("Stencil Write Mask", Float) = 255
        [HideInInspector]_StencilReadMask ("Stencil Read Mask", Float) = 255

        [HideInInspector]_ColorMask ("Color Mask", Float) = 15

        // RectMask2D values are supplied per CanvasRenderer.
        // Wide default keeps the shader visible when no RectMask2D is present.
        [PerRendererData][HideInInspector] _ClipRect ("Clip Rect", Vector) = (-32767,-32767,32767,32767)
        [PerRendererData][HideInInspector] _UIMaskSoftnessX ("Mask Softness X", Float) = 0
        [PerRendererData][HideInInspector] _UIMaskSoftnessY ("Mask Softness Y", Float) = 0

        [HideInInspector][Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0

        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendRGB ("Src RGB", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendRGB ("Dst RGB", Float) = 10
        [Enum(UnityEngine.Rendering.BlendOp)] _BlendOpRGB ("Op RGB", Float) = 0

        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendA ("Src A", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendA ("Dst A", Float) = 1
        [Enum(UnityEngine.Rendering.BlendOp)] _BlendOpA ("Op A", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        BlendOp [_BlendOpRGB], [_BlendOpA]
        Blend [_SrcBlendRGB] [_DstBlendRGB], [_SrcBlendA] [_DstBlendA]

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        ColorMask [_ColorMask]

        Pass
        {
            Name "Default"

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            struct appdata_t
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 texcoord : TEXCOORD0;
                float4 texcoord1 : TEXCOORD1;
                float4 texcoord2 : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                half4 color : COLOR;
                float2 texcoord : TEXCOORD0;
                float2 distortionUV : TEXCOORD1;
                float4 worldPosition : TEXCOORD2;
                float4 params : TEXCOORD3;
                half4 mask : TEXCOORD4;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            sampler2D _DistortionTex;

            float4 _ClipRect;
            float4 _MainTex_ST;
            float4 _DistortionTex_ST;
            float4 _TextureHDRMultiplier;
            float4 _VertexColorHDRMultiplier;
            float _InvertAlpha;
            float _UIMaskSoftnessX;
            float _UIMaskSoftnessY;

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

                float4 clampedRect = clamp(_ClipRect, -2e10, 2e10);
                float2 pixelSize = OUT.vertex.w;
                pixelSize /= abs(mul((float2x2)UNITY_MATRIX_P, _ScreenParams.xy));
                OUT.mask = half4(
                    v.vertex.xy * 2.0 - clampedRect.xy - clampedRect.zw,
                    0.25 / (0.25 * half2(_UIMaskSoftnessX, _UIMaskSoftnessY) + abs(pixelSize.xy))
                );

                OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                OUT.params = v.texcoord1;

                float2 distortionUV = v.texcoord * (1.0 + OUT.params.w);
                float2 scrollOffset = float2(OUT.params.y, OUT.params.z) * _Time.y + v.texcoord2.xy;
                OUT.distortionUV = TRANSFORM_TEX(distortionUV + scrollOffset, _DistortionTex);

                half4 vertexColor = v.color;
                vertexColor *= _VertexColorHDRMultiplier;

                if (_InvertAlpha > 0.5)
                {
                    OUT.color.rgb = vertexColor.rgb;
                    OUT.color.a = 1.0 - v.color.a;
                }
                else
                {
                    OUT.color = vertexColor;
                }

                return OUT;
            }

            fixed4 frag(v2f v) : SV_Target
            {
                float4 distortionSample = tex2D(_DistortionTex, v.distortionUV);
                float2 distortion = (distortionSample.rg - 0.5) * 2.0 * v.params.x;
                float2 distortedUV = v.texcoord + distortion;

                half4 color = tex2D(_MainTex, distortedUV);
                color *= _TextureHDRMultiplier;

                if (_InvertAlpha > 0.5)
                {
                    color.rgb *= v.color.rgb;
                    color.rgb = lerp(color.rgb, half3(1, 1, 1), v.color.a);
                }
                else
                {
                    color *= v.color;
                }

                // RectMask2D + Softness.
                // Deliberately NOT wrapped in UNITY_UI_CLIP_RECT: some custom UI
                // material paths do not enable that keyword, while CanvasRenderer
                // still supplies _ClipRect and _UIMaskSoftnessX/Y.
                half2 uiMask = saturate((_ClipRect.zw - _ClipRect.xy - abs(v.mask.xy)) * v.mask.zw);
                half clipFactor = uiMask.x * uiMask.y;

                // Fade both RGB and alpha so clipping is visible with additive blending too.
                color *= clipFactor;

                #ifdef UNITY_UI_ALPHACLIP
                clip(color.a - 0.001);
                #endif

//color.a*=_TextureHDRMultiplier;
				color = saturate(color);



                return color;
            }
            ENDCG
        }
    }
}
