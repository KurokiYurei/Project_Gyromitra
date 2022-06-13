Shader "Clouds"
{
    Properties
    {
        Vector4_7857debdf41d401bba91a8ee4589797d("Rotate Projection", Vector) = (1, 0, 0, 0)
        Vector1_3e90a01d954242c19dfed08766b90e95("Noise Scale", Float) = 10
        Vector1_7dd17304f68b476ea7aca908377acaa8("Noise Speed", Float) = 0.1
        Vector1_08428239c85e48588fbdefbbdba657d0("Noise Height", Float) = 1
        Vector4_d7175560f1a3463cb3aa8bf951d8481c("Noise Remap", Vector) = (0, 1, -1, 1)
        Color_6339afdcca124ffdacbdb2d95c288d1f("Color Valley", Color) = (0, 0, 0, 0)
        Color_4c92777dd71a44c28f40a8b89797d9cf("Color Peak", Color) = (1, 1, 1, 0)
        Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f("Noise Edge 1", Float) = 0
        Vector1_8607474205e846fd9baba5fc496fc1a4("Noise Edge 2", Float) = 1
        Vector1_e4c7de79ca074dc6acf544fa08058f61("Noise Power", Float) = 2
        Vector1_2b90fecba49247d69fea4250dd6f2b05("Base Scale", Float) = 5
        Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b("Base Speed", Float) = 0.2
        Vector1_85705dce160b423095b83fec18834b94("Base Strength", Float) = 2
        Vector1_2d8f347bfae0495495a1901da88f5503("Emission Strength", Float) = 2
        Vector1_abdcc9bf2c3e4b2784bd5b3cd35ee51c("Curvature Radius", Float) = 1
        Vector1_e422a47f8df24c3db74aea0d635974ab("Fresnel Power", Float) = 1
        Vector1_a692e6f11a4a48ce952d8c7a0c61c1aa("Fresnel Opacity", Float) = 1
        Vector1_554b3b77df094a20ae20fb7a09a219e7("Fade Depth", Float) = 100
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        //ZWrite Off
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 TangentSpaceNormal;
            float3 WorldSpaceViewDirection;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float3 interp3 : TEXCOORD3;
            #if defined(LIGHTMAP_ON)
            float2 interp4 : TEXCOORD4;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp5 : TEXCOORD5;
            #endif
            float4 interp6 : TEXCOORD6;
            float4 interp7 : TEXCOORD7;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp5.xyz =  input.sh;
            #endif
            output.interp6.xyzw =  input.fogFactorAndVertexLight;
            output.interp7.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp4.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp5.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp6.xyzw;
            output.shadowCoord = input.interp7.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_7857debdf41d401bba91a8ee4589797d;
        float Vector1_3e90a01d954242c19dfed08766b90e95;
        float Vector1_7dd17304f68b476ea7aca908377acaa8;
        float Vector1_08428239c85e48588fbdefbbdba657d0;
        float4 Vector4_d7175560f1a3463cb3aa8bf951d8481c;
        float4 Color_6339afdcca124ffdacbdb2d95c288d1f;
        float4 Color_4c92777dd71a44c28f40a8b89797d9cf;
        float Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
        float Vector1_8607474205e846fd9baba5fc496fc1a4;
        float Vector1_e4c7de79ca074dc6acf544fa08058f61;
        float Vector1_2b90fecba49247d69fea4250dd6f2b05;
        float Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
        float Vector1_85705dce160b423095b83fec18834b94;
        float Vector1_2d8f347bfae0495495a1901da88f5503;
        float Vector1_abdcc9bf2c3e4b2784bd5b3cd35ee51c;
        float Vector1_e422a47f8df24c3db74aea0d635974ab;
        float Vector1_a692e6f11a4a48ce952d8c7a0c61c1aa;
        float Vector1_554b3b77df094a20ae20fb7a09a219e7;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2);
            float _Property_854cff9e0336411abc3494adb5949df2_Out_0 = Vector1_abdcc9bf2c3e4b2784bd5b3cd35ee51c;
            float _Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2;
            Unity_Divide_float(_Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2, _Property_854cff9e0336411abc3494adb5949df2_Out_0, _Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2);
            float _Power_b076041ae9da49808786f2e74199f99b_Out_2;
            Unity_Power_float(_Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2, 3, _Power_b076041ae9da49808786f2e74199f99b_Out_2);
            float3 _Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2;
            Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_b076041ae9da49808786f2e74199f99b_Out_2.xxx), _Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2);
            float _Property_053ddb8da804443e8b374d1f1e46439d_Out_0 = Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
            float _Property_049c2369ee52402da7e76747fd5d4b19_Out_0 = Vector1_8607474205e846fd9baba5fc496fc1a4;
            float4 _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0 = Vector4_7857debdf41d401bba91a8ee4589797d;
            float _Split_812593ea1f7b4cd48228a008310391e8_R_1 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[0];
            float _Split_812593ea1f7b4cd48228a008310391e8_G_2 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[1];
            float _Split_812593ea1f7b4cd48228a008310391e8_B_3 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[2];
            float _Split_812593ea1f7b4cd48228a008310391e8_A_4 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[3];
            float3 _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0.xyz), _Split_812593ea1f7b4cd48228a008310391e8_A_4, _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3);
            float _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0 = Vector1_7dd17304f68b476ea7aca908377acaa8;
            float _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0, _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2);
            float2 _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2.xx), _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3);
            float _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0 = Vector1_3e90a01d954242c19dfed08766b90e95;
            float _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2);
            float2 _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3);
            float _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2);
            float _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2;
            Unity_Add_float(_GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2, _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2);
            float _Divide_ced9f1a8c241466e91792e08856155c5_Out_2;
            Unity_Divide_float(_Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2, 2, _Divide_ced9f1a8c241466e91792e08856155c5_Out_2);
            float _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1;
            Unity_Saturate_float(_Divide_ced9f1a8c241466e91792e08856155c5_Out_2, _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1);
            float _Property_def7d18ce006439b83bdf0435d5dae87_Out_0 = Vector1_e4c7de79ca074dc6acf544fa08058f61;
            float _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2;
            Unity_Power_float(_Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1, _Property_def7d18ce006439b83bdf0435d5dae87_Out_0, _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2);
            float4 _Property_acbb4ec64c894666aed93d6c17bab669_Out_0 = Vector4_d7175560f1a3463cb3aa8bf951d8481c;
            float _Split_7d4cb659812b4aba82359b9cd5676286_R_1 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[0];
            float _Split_7d4cb659812b4aba82359b9cd5676286_G_2 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[1];
            float _Split_7d4cb659812b4aba82359b9cd5676286_B_3 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[2];
            float _Split_7d4cb659812b4aba82359b9cd5676286_A_4 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[3];
            float4 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4;
            float3 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5;
            float2 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_R_1, _Split_7d4cb659812b4aba82359b9cd5676286_G_2, 0, 0, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6);
            float4 _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4;
            float3 _Combine_97b350e15af444549b08b7cccad8507b_RGB_5;
            float2 _Combine_97b350e15af444549b08b7cccad8507b_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_B_3, _Split_7d4cb659812b4aba82359b9cd5676286_A_4, 0, 0, _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4, _Combine_97b350e15af444549b08b7cccad8507b_RGB_5, _Combine_97b350e15af444549b08b7cccad8507b_RG_6);
            float _Remap_7e4aea3511c044c096a39756751a8edf_Out_3;
            Unity_Remap_float(_Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6, _Combine_97b350e15af444549b08b7cccad8507b_RG_6, _Remap_7e4aea3511c044c096a39756751a8edf_Out_3);
            float _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1;
            Unity_Absolute_float(_Remap_7e4aea3511c044c096a39756751a8edf_Out_3, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1);
            float _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3;
            Unity_Smoothstep_float(_Property_053ddb8da804443e8b374d1f1e46439d_Out_0, _Property_049c2369ee52402da7e76747fd5d4b19_Out_0, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1, _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3);
            float _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0 = Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
            float _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0, _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2);
            float2 _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2.xx), _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3);
            float _Property_5e4cf85948674accba829baa1128f457_Out_0 = Vector1_2b90fecba49247d69fea4250dd6f2b05;
            float _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3, _Property_5e4cf85948674accba829baa1128f457_Out_0, _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2);
            float _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0 = Vector1_85705dce160b423095b83fec18834b94;
            float _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2;
            Unity_Multiply_float(_GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2);
            float _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2;
            Unity_Add_float(_Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2, _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2);
            float _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2;
            Unity_Add_float(1, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2);
            float _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2;
            Unity_Divide_float(_Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2, _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2);
            float3 _Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_8d035f5a1dd247c991949a2468e485ed_Out_2.xxx), _Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2);
            float _Property_a31cd2828e384b93a347c401039dc22f_Out_0 = Vector1_08428239c85e48588fbdefbbdba657d0;
            float3 _Multiply_a450069c754545c0a818930e08827565_Out_2;
            Unity_Multiply_float(_Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2, (_Property_a31cd2828e384b93a347c401039dc22f_Out_0.xxx), _Multiply_a450069c754545c0a818930e08827565_Out_2);
            float3 _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a450069c754545c0a818930e08827565_Out_2, _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2);
            float3 _Add_d021335a91474d7e933acf61f6e5b302_Out_2;
            Unity_Add_float3(_Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2, _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2, _Add_d021335a91474d7e933acf61f6e5b302_Out_2);
            description.Position = _Add_d021335a91474d7e933acf61f6e5b302_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_ba0f647605054add9ecb748acfab7189_Out_0 = Color_6339afdcca124ffdacbdb2d95c288d1f;
            float4 _Property_0f6a99dfadb1482ebb8abc5826059d6d_Out_0 = Color_4c92777dd71a44c28f40a8b89797d9cf;
            float _Property_053ddb8da804443e8b374d1f1e46439d_Out_0 = Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
            float _Property_049c2369ee52402da7e76747fd5d4b19_Out_0 = Vector1_8607474205e846fd9baba5fc496fc1a4;
            float4 _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0 = Vector4_7857debdf41d401bba91a8ee4589797d;
            float _Split_812593ea1f7b4cd48228a008310391e8_R_1 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[0];
            float _Split_812593ea1f7b4cd48228a008310391e8_G_2 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[1];
            float _Split_812593ea1f7b4cd48228a008310391e8_B_3 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[2];
            float _Split_812593ea1f7b4cd48228a008310391e8_A_4 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[3];
            float3 _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0.xyz), _Split_812593ea1f7b4cd48228a008310391e8_A_4, _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3);
            float _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0 = Vector1_7dd17304f68b476ea7aca908377acaa8;
            float _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0, _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2);
            float2 _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2.xx), _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3);
            float _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0 = Vector1_3e90a01d954242c19dfed08766b90e95;
            float _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2);
            float2 _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3);
            float _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2);
            float _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2;
            Unity_Add_float(_GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2, _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2);
            float _Divide_ced9f1a8c241466e91792e08856155c5_Out_2;
            Unity_Divide_float(_Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2, 2, _Divide_ced9f1a8c241466e91792e08856155c5_Out_2);
            float _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1;
            Unity_Saturate_float(_Divide_ced9f1a8c241466e91792e08856155c5_Out_2, _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1);
            float _Property_def7d18ce006439b83bdf0435d5dae87_Out_0 = Vector1_e4c7de79ca074dc6acf544fa08058f61;
            float _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2;
            Unity_Power_float(_Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1, _Property_def7d18ce006439b83bdf0435d5dae87_Out_0, _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2);
            float4 _Property_acbb4ec64c894666aed93d6c17bab669_Out_0 = Vector4_d7175560f1a3463cb3aa8bf951d8481c;
            float _Split_7d4cb659812b4aba82359b9cd5676286_R_1 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[0];
            float _Split_7d4cb659812b4aba82359b9cd5676286_G_2 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[1];
            float _Split_7d4cb659812b4aba82359b9cd5676286_B_3 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[2];
            float _Split_7d4cb659812b4aba82359b9cd5676286_A_4 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[3];
            float4 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4;
            float3 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5;
            float2 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_R_1, _Split_7d4cb659812b4aba82359b9cd5676286_G_2, 0, 0, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6);
            float4 _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4;
            float3 _Combine_97b350e15af444549b08b7cccad8507b_RGB_5;
            float2 _Combine_97b350e15af444549b08b7cccad8507b_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_B_3, _Split_7d4cb659812b4aba82359b9cd5676286_A_4, 0, 0, _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4, _Combine_97b350e15af444549b08b7cccad8507b_RGB_5, _Combine_97b350e15af444549b08b7cccad8507b_RG_6);
            float _Remap_7e4aea3511c044c096a39756751a8edf_Out_3;
            Unity_Remap_float(_Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6, _Combine_97b350e15af444549b08b7cccad8507b_RG_6, _Remap_7e4aea3511c044c096a39756751a8edf_Out_3);
            float _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1;
            Unity_Absolute_float(_Remap_7e4aea3511c044c096a39756751a8edf_Out_3, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1);
            float _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3;
            Unity_Smoothstep_float(_Property_053ddb8da804443e8b374d1f1e46439d_Out_0, _Property_049c2369ee52402da7e76747fd5d4b19_Out_0, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1, _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3);
            float _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0 = Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
            float _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0, _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2);
            float2 _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2.xx), _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3);
            float _Property_5e4cf85948674accba829baa1128f457_Out_0 = Vector1_2b90fecba49247d69fea4250dd6f2b05;
            float _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3, _Property_5e4cf85948674accba829baa1128f457_Out_0, _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2);
            float _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0 = Vector1_85705dce160b423095b83fec18834b94;
            float _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2;
            Unity_Multiply_float(_GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2);
            float _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2;
            Unity_Add_float(_Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2, _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2);
            float _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2;
            Unity_Add_float(1, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2);
            float _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2;
            Unity_Divide_float(_Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2, _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2);
            float4 _Lerp_1d146db540d144cea0c82b0d31afe7fb_Out_3;
            Unity_Lerp_float4(_Property_ba0f647605054add9ecb748acfab7189_Out_0, _Property_0f6a99dfadb1482ebb8abc5826059d6d_Out_0, (_Divide_8d035f5a1dd247c991949a2468e485ed_Out_2.xxxx), _Lerp_1d146db540d144cea0c82b0d31afe7fb_Out_3);
            float _Property_db3130cfd93f4e20a2eea366d3e7c3cb_Out_0 = Vector1_e422a47f8df24c3db74aea0d635974ab;
            float _FresnelEffect_f1ecbfd78ca54d9a82c60183643a368d_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_db3130cfd93f4e20a2eea366d3e7c3cb_Out_0, _FresnelEffect_f1ecbfd78ca54d9a82c60183643a368d_Out_3);
            float _Multiply_67c2514ffb7f47e2b62c67ff73747b76_Out_2;
            Unity_Multiply_float(_Divide_8d035f5a1dd247c991949a2468e485ed_Out_2, _FresnelEffect_f1ecbfd78ca54d9a82c60183643a368d_Out_3, _Multiply_67c2514ffb7f47e2b62c67ff73747b76_Out_2);
            float _Property_1e995a1735c045988eba42a23c39c906_Out_0 = Vector1_a692e6f11a4a48ce952d8c7a0c61c1aa;
            float _Multiply_60b7ea1e156f4b5099f325cddb89a068_Out_2;
            Unity_Multiply_float(_Multiply_67c2514ffb7f47e2b62c67ff73747b76_Out_2, _Property_1e995a1735c045988eba42a23c39c906_Out_0, _Multiply_60b7ea1e156f4b5099f325cddb89a068_Out_2);
            float4 _Add_3d1174b8fb2346af8156df38795e2a28_Out_2;
            Unity_Add_float4(_Lerp_1d146db540d144cea0c82b0d31afe7fb_Out_3, (_Multiply_60b7ea1e156f4b5099f325cddb89a068_Out_2.xxxx), _Add_3d1174b8fb2346af8156df38795e2a28_Out_2);
            float _Property_d2746846112f46188c604caf72994dd9_Out_0 = Vector1_2d8f347bfae0495495a1901da88f5503;
            float4 _Multiply_6a7e610df71a42cbbc5238f078bc0fbd_Out_2;
            Unity_Multiply_float(_Add_3d1174b8fb2346af8156df38795e2a28_Out_2, (_Property_d2746846112f46188c604caf72994dd9_Out_0.xxxx), _Multiply_6a7e610df71a42cbbc5238f078bc0fbd_Out_2);
            float _SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1);
            float4 _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0 = IN.ScreenPosition;
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_R_1 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[0];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_G_2 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[1];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_B_3 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[2];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_A_4 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[3];
            float _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2;
            Unity_Subtract_float(_Split_88bd4eaad1bc473bafd9769e43fc6eae_A_4, 1, _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2);
            float _Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2;
            Unity_Subtract_float(_SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1, _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2, _Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2);
            float _Property_eec2c1a9e98a4156b7ae81ef6fd2adfa_Out_0 = Vector1_554b3b77df094a20ae20fb7a09a219e7;
            float _Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2;
            Unity_Divide_float(_Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2, _Property_eec2c1a9e98a4156b7ae81ef6fd2adfa_Out_0, _Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2);
            float _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1;
            Unity_Saturate_float(_Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2, _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1);
            surface.BaseColor = (_Add_3d1174b8fb2346af8156df38795e2a28_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_6a7e610df71a42cbbc5238f078bc0fbd_Out_2.xyz);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile _ _GBUFFER_NORMALS_OCT
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_GBUFFER
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 TangentSpaceNormal;
            float3 WorldSpaceViewDirection;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float3 interp3 : TEXCOORD3;
            #if defined(LIGHTMAP_ON)
            float2 interp4 : TEXCOORD4;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp5 : TEXCOORD5;
            #endif
            float4 interp6 : TEXCOORD6;
            float4 interp7 : TEXCOORD7;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp5.xyz =  input.sh;
            #endif
            output.interp6.xyzw =  input.fogFactorAndVertexLight;
            output.interp7.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp4.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp5.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp6.xyzw;
            output.shadowCoord = input.interp7.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_7857debdf41d401bba91a8ee4589797d;
        float Vector1_3e90a01d954242c19dfed08766b90e95;
        float Vector1_7dd17304f68b476ea7aca908377acaa8;
        float Vector1_08428239c85e48588fbdefbbdba657d0;
        float4 Vector4_d7175560f1a3463cb3aa8bf951d8481c;
        float4 Color_6339afdcca124ffdacbdb2d95c288d1f;
        float4 Color_4c92777dd71a44c28f40a8b89797d9cf;
        float Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
        float Vector1_8607474205e846fd9baba5fc496fc1a4;
        float Vector1_e4c7de79ca074dc6acf544fa08058f61;
        float Vector1_2b90fecba49247d69fea4250dd6f2b05;
        float Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
        float Vector1_85705dce160b423095b83fec18834b94;
        float Vector1_2d8f347bfae0495495a1901da88f5503;
        float Vector1_abdcc9bf2c3e4b2784bd5b3cd35ee51c;
        float Vector1_e422a47f8df24c3db74aea0d635974ab;
        float Vector1_a692e6f11a4a48ce952d8c7a0c61c1aa;
        float Vector1_554b3b77df094a20ae20fb7a09a219e7;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2);
            float _Property_854cff9e0336411abc3494adb5949df2_Out_0 = Vector1_abdcc9bf2c3e4b2784bd5b3cd35ee51c;
            float _Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2;
            Unity_Divide_float(_Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2, _Property_854cff9e0336411abc3494adb5949df2_Out_0, _Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2);
            float _Power_b076041ae9da49808786f2e74199f99b_Out_2;
            Unity_Power_float(_Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2, 3, _Power_b076041ae9da49808786f2e74199f99b_Out_2);
            float3 _Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2;
            Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_b076041ae9da49808786f2e74199f99b_Out_2.xxx), _Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2);
            float _Property_053ddb8da804443e8b374d1f1e46439d_Out_0 = Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
            float _Property_049c2369ee52402da7e76747fd5d4b19_Out_0 = Vector1_8607474205e846fd9baba5fc496fc1a4;
            float4 _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0 = Vector4_7857debdf41d401bba91a8ee4589797d;
            float _Split_812593ea1f7b4cd48228a008310391e8_R_1 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[0];
            float _Split_812593ea1f7b4cd48228a008310391e8_G_2 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[1];
            float _Split_812593ea1f7b4cd48228a008310391e8_B_3 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[2];
            float _Split_812593ea1f7b4cd48228a008310391e8_A_4 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[3];
            float3 _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0.xyz), _Split_812593ea1f7b4cd48228a008310391e8_A_4, _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3);
            float _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0 = Vector1_7dd17304f68b476ea7aca908377acaa8;
            float _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0, _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2);
            float2 _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2.xx), _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3);
            float _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0 = Vector1_3e90a01d954242c19dfed08766b90e95;
            float _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2);
            float2 _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3);
            float _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2);
            float _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2;
            Unity_Add_float(_GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2, _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2);
            float _Divide_ced9f1a8c241466e91792e08856155c5_Out_2;
            Unity_Divide_float(_Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2, 2, _Divide_ced9f1a8c241466e91792e08856155c5_Out_2);
            float _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1;
            Unity_Saturate_float(_Divide_ced9f1a8c241466e91792e08856155c5_Out_2, _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1);
            float _Property_def7d18ce006439b83bdf0435d5dae87_Out_0 = Vector1_e4c7de79ca074dc6acf544fa08058f61;
            float _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2;
            Unity_Power_float(_Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1, _Property_def7d18ce006439b83bdf0435d5dae87_Out_0, _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2);
            float4 _Property_acbb4ec64c894666aed93d6c17bab669_Out_0 = Vector4_d7175560f1a3463cb3aa8bf951d8481c;
            float _Split_7d4cb659812b4aba82359b9cd5676286_R_1 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[0];
            float _Split_7d4cb659812b4aba82359b9cd5676286_G_2 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[1];
            float _Split_7d4cb659812b4aba82359b9cd5676286_B_3 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[2];
            float _Split_7d4cb659812b4aba82359b9cd5676286_A_4 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[3];
            float4 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4;
            float3 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5;
            float2 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_R_1, _Split_7d4cb659812b4aba82359b9cd5676286_G_2, 0, 0, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6);
            float4 _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4;
            float3 _Combine_97b350e15af444549b08b7cccad8507b_RGB_5;
            float2 _Combine_97b350e15af444549b08b7cccad8507b_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_B_3, _Split_7d4cb659812b4aba82359b9cd5676286_A_4, 0, 0, _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4, _Combine_97b350e15af444549b08b7cccad8507b_RGB_5, _Combine_97b350e15af444549b08b7cccad8507b_RG_6);
            float _Remap_7e4aea3511c044c096a39756751a8edf_Out_3;
            Unity_Remap_float(_Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6, _Combine_97b350e15af444549b08b7cccad8507b_RG_6, _Remap_7e4aea3511c044c096a39756751a8edf_Out_3);
            float _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1;
            Unity_Absolute_float(_Remap_7e4aea3511c044c096a39756751a8edf_Out_3, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1);
            float _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3;
            Unity_Smoothstep_float(_Property_053ddb8da804443e8b374d1f1e46439d_Out_0, _Property_049c2369ee52402da7e76747fd5d4b19_Out_0, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1, _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3);
            float _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0 = Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
            float _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0, _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2);
            float2 _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2.xx), _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3);
            float _Property_5e4cf85948674accba829baa1128f457_Out_0 = Vector1_2b90fecba49247d69fea4250dd6f2b05;
            float _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3, _Property_5e4cf85948674accba829baa1128f457_Out_0, _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2);
            float _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0 = Vector1_85705dce160b423095b83fec18834b94;
            float _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2;
            Unity_Multiply_float(_GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2);
            float _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2;
            Unity_Add_float(_Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2, _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2);
            float _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2;
            Unity_Add_float(1, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2);
            float _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2;
            Unity_Divide_float(_Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2, _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2);
            float3 _Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_8d035f5a1dd247c991949a2468e485ed_Out_2.xxx), _Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2);
            float _Property_a31cd2828e384b93a347c401039dc22f_Out_0 = Vector1_08428239c85e48588fbdefbbdba657d0;
            float3 _Multiply_a450069c754545c0a818930e08827565_Out_2;
            Unity_Multiply_float(_Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2, (_Property_a31cd2828e384b93a347c401039dc22f_Out_0.xxx), _Multiply_a450069c754545c0a818930e08827565_Out_2);
            float3 _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a450069c754545c0a818930e08827565_Out_2, _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2);
            float3 _Add_d021335a91474d7e933acf61f6e5b302_Out_2;
            Unity_Add_float3(_Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2, _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2, _Add_d021335a91474d7e933acf61f6e5b302_Out_2);
            description.Position = _Add_d021335a91474d7e933acf61f6e5b302_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_ba0f647605054add9ecb748acfab7189_Out_0 = Color_6339afdcca124ffdacbdb2d95c288d1f;
            float4 _Property_0f6a99dfadb1482ebb8abc5826059d6d_Out_0 = Color_4c92777dd71a44c28f40a8b89797d9cf;
            float _Property_053ddb8da804443e8b374d1f1e46439d_Out_0 = Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
            float _Property_049c2369ee52402da7e76747fd5d4b19_Out_0 = Vector1_8607474205e846fd9baba5fc496fc1a4;
            float4 _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0 = Vector4_7857debdf41d401bba91a8ee4589797d;
            float _Split_812593ea1f7b4cd48228a008310391e8_R_1 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[0];
            float _Split_812593ea1f7b4cd48228a008310391e8_G_2 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[1];
            float _Split_812593ea1f7b4cd48228a008310391e8_B_3 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[2];
            float _Split_812593ea1f7b4cd48228a008310391e8_A_4 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[3];
            float3 _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0.xyz), _Split_812593ea1f7b4cd48228a008310391e8_A_4, _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3);
            float _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0 = Vector1_7dd17304f68b476ea7aca908377acaa8;
            float _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0, _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2);
            float2 _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2.xx), _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3);
            float _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0 = Vector1_3e90a01d954242c19dfed08766b90e95;
            float _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2);
            float2 _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3);
            float _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2);
            float _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2;
            Unity_Add_float(_GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2, _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2);
            float _Divide_ced9f1a8c241466e91792e08856155c5_Out_2;
            Unity_Divide_float(_Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2, 2, _Divide_ced9f1a8c241466e91792e08856155c5_Out_2);
            float _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1;
            Unity_Saturate_float(_Divide_ced9f1a8c241466e91792e08856155c5_Out_2, _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1);
            float _Property_def7d18ce006439b83bdf0435d5dae87_Out_0 = Vector1_e4c7de79ca074dc6acf544fa08058f61;
            float _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2;
            Unity_Power_float(_Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1, _Property_def7d18ce006439b83bdf0435d5dae87_Out_0, _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2);
            float4 _Property_acbb4ec64c894666aed93d6c17bab669_Out_0 = Vector4_d7175560f1a3463cb3aa8bf951d8481c;
            float _Split_7d4cb659812b4aba82359b9cd5676286_R_1 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[0];
            float _Split_7d4cb659812b4aba82359b9cd5676286_G_2 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[1];
            float _Split_7d4cb659812b4aba82359b9cd5676286_B_3 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[2];
            float _Split_7d4cb659812b4aba82359b9cd5676286_A_4 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[3];
            float4 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4;
            float3 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5;
            float2 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_R_1, _Split_7d4cb659812b4aba82359b9cd5676286_G_2, 0, 0, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6);
            float4 _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4;
            float3 _Combine_97b350e15af444549b08b7cccad8507b_RGB_5;
            float2 _Combine_97b350e15af444549b08b7cccad8507b_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_B_3, _Split_7d4cb659812b4aba82359b9cd5676286_A_4, 0, 0, _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4, _Combine_97b350e15af444549b08b7cccad8507b_RGB_5, _Combine_97b350e15af444549b08b7cccad8507b_RG_6);
            float _Remap_7e4aea3511c044c096a39756751a8edf_Out_3;
            Unity_Remap_float(_Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6, _Combine_97b350e15af444549b08b7cccad8507b_RG_6, _Remap_7e4aea3511c044c096a39756751a8edf_Out_3);
            float _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1;
            Unity_Absolute_float(_Remap_7e4aea3511c044c096a39756751a8edf_Out_3, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1);
            float _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3;
            Unity_Smoothstep_float(_Property_053ddb8da804443e8b374d1f1e46439d_Out_0, _Property_049c2369ee52402da7e76747fd5d4b19_Out_0, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1, _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3);
            float _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0 = Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
            float _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0, _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2);
            float2 _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2.xx), _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3);
            float _Property_5e4cf85948674accba829baa1128f457_Out_0 = Vector1_2b90fecba49247d69fea4250dd6f2b05;
            float _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3, _Property_5e4cf85948674accba829baa1128f457_Out_0, _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2);
            float _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0 = Vector1_85705dce160b423095b83fec18834b94;
            float _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2;
            Unity_Multiply_float(_GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2);
            float _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2;
            Unity_Add_float(_Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2, _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2);
            float _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2;
            Unity_Add_float(1, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2);
            float _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2;
            Unity_Divide_float(_Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2, _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2);
            float4 _Lerp_1d146db540d144cea0c82b0d31afe7fb_Out_3;
            Unity_Lerp_float4(_Property_ba0f647605054add9ecb748acfab7189_Out_0, _Property_0f6a99dfadb1482ebb8abc5826059d6d_Out_0, (_Divide_8d035f5a1dd247c991949a2468e485ed_Out_2.xxxx), _Lerp_1d146db540d144cea0c82b0d31afe7fb_Out_3);
            float _Property_db3130cfd93f4e20a2eea366d3e7c3cb_Out_0 = Vector1_e422a47f8df24c3db74aea0d635974ab;
            float _FresnelEffect_f1ecbfd78ca54d9a82c60183643a368d_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_db3130cfd93f4e20a2eea366d3e7c3cb_Out_0, _FresnelEffect_f1ecbfd78ca54d9a82c60183643a368d_Out_3);
            float _Multiply_67c2514ffb7f47e2b62c67ff73747b76_Out_2;
            Unity_Multiply_float(_Divide_8d035f5a1dd247c991949a2468e485ed_Out_2, _FresnelEffect_f1ecbfd78ca54d9a82c60183643a368d_Out_3, _Multiply_67c2514ffb7f47e2b62c67ff73747b76_Out_2);
            float _Property_1e995a1735c045988eba42a23c39c906_Out_0 = Vector1_a692e6f11a4a48ce952d8c7a0c61c1aa;
            float _Multiply_60b7ea1e156f4b5099f325cddb89a068_Out_2;
            Unity_Multiply_float(_Multiply_67c2514ffb7f47e2b62c67ff73747b76_Out_2, _Property_1e995a1735c045988eba42a23c39c906_Out_0, _Multiply_60b7ea1e156f4b5099f325cddb89a068_Out_2);
            float4 _Add_3d1174b8fb2346af8156df38795e2a28_Out_2;
            Unity_Add_float4(_Lerp_1d146db540d144cea0c82b0d31afe7fb_Out_3, (_Multiply_60b7ea1e156f4b5099f325cddb89a068_Out_2.xxxx), _Add_3d1174b8fb2346af8156df38795e2a28_Out_2);
            float _Property_d2746846112f46188c604caf72994dd9_Out_0 = Vector1_2d8f347bfae0495495a1901da88f5503;
            float4 _Multiply_6a7e610df71a42cbbc5238f078bc0fbd_Out_2;
            Unity_Multiply_float(_Add_3d1174b8fb2346af8156df38795e2a28_Out_2, (_Property_d2746846112f46188c604caf72994dd9_Out_0.xxxx), _Multiply_6a7e610df71a42cbbc5238f078bc0fbd_Out_2);
            float _SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1);
            float4 _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0 = IN.ScreenPosition;
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_R_1 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[0];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_G_2 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[1];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_B_3 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[2];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_A_4 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[3];
            float _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2;
            Unity_Subtract_float(_Split_88bd4eaad1bc473bafd9769e43fc6eae_A_4, 1, _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2);
            float _Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2;
            Unity_Subtract_float(_SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1, _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2, _Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2);
            float _Property_eec2c1a9e98a4156b7ae81ef6fd2adfa_Out_0 = Vector1_554b3b77df094a20ae20fb7a09a219e7;
            float _Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2;
            Unity_Divide_float(_Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2, _Property_eec2c1a9e98a4156b7ae81ef6fd2adfa_Out_0, _Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2);
            float _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1;
            Unity_Saturate_float(_Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2, _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1);
            surface.BaseColor = (_Add_3d1174b8fb2346af8156df38795e2a28_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_6a7e610df71a42cbbc5238f078bc0fbd_Out_2.xyz);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_7857debdf41d401bba91a8ee4589797d;
        float Vector1_3e90a01d954242c19dfed08766b90e95;
        float Vector1_7dd17304f68b476ea7aca908377acaa8;
        float Vector1_08428239c85e48588fbdefbbdba657d0;
        float4 Vector4_d7175560f1a3463cb3aa8bf951d8481c;
        float4 Color_6339afdcca124ffdacbdb2d95c288d1f;
        float4 Color_4c92777dd71a44c28f40a8b89797d9cf;
        float Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
        float Vector1_8607474205e846fd9baba5fc496fc1a4;
        float Vector1_e4c7de79ca074dc6acf544fa08058f61;
        float Vector1_2b90fecba49247d69fea4250dd6f2b05;
        float Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
        float Vector1_85705dce160b423095b83fec18834b94;
        float Vector1_2d8f347bfae0495495a1901da88f5503;
        float Vector1_abdcc9bf2c3e4b2784bd5b3cd35ee51c;
        float Vector1_e422a47f8df24c3db74aea0d635974ab;
        float Vector1_a692e6f11a4a48ce952d8c7a0c61c1aa;
        float Vector1_554b3b77df094a20ae20fb7a09a219e7;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2);
            float _Property_854cff9e0336411abc3494adb5949df2_Out_0 = Vector1_abdcc9bf2c3e4b2784bd5b3cd35ee51c;
            float _Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2;
            Unity_Divide_float(_Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2, _Property_854cff9e0336411abc3494adb5949df2_Out_0, _Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2);
            float _Power_b076041ae9da49808786f2e74199f99b_Out_2;
            Unity_Power_float(_Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2, 3, _Power_b076041ae9da49808786f2e74199f99b_Out_2);
            float3 _Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2;
            Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_b076041ae9da49808786f2e74199f99b_Out_2.xxx), _Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2);
            float _Property_053ddb8da804443e8b374d1f1e46439d_Out_0 = Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
            float _Property_049c2369ee52402da7e76747fd5d4b19_Out_0 = Vector1_8607474205e846fd9baba5fc496fc1a4;
            float4 _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0 = Vector4_7857debdf41d401bba91a8ee4589797d;
            float _Split_812593ea1f7b4cd48228a008310391e8_R_1 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[0];
            float _Split_812593ea1f7b4cd48228a008310391e8_G_2 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[1];
            float _Split_812593ea1f7b4cd48228a008310391e8_B_3 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[2];
            float _Split_812593ea1f7b4cd48228a008310391e8_A_4 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[3];
            float3 _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0.xyz), _Split_812593ea1f7b4cd48228a008310391e8_A_4, _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3);
            float _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0 = Vector1_7dd17304f68b476ea7aca908377acaa8;
            float _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0, _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2);
            float2 _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2.xx), _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3);
            float _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0 = Vector1_3e90a01d954242c19dfed08766b90e95;
            float _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2);
            float2 _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3);
            float _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2);
            float _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2;
            Unity_Add_float(_GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2, _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2);
            float _Divide_ced9f1a8c241466e91792e08856155c5_Out_2;
            Unity_Divide_float(_Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2, 2, _Divide_ced9f1a8c241466e91792e08856155c5_Out_2);
            float _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1;
            Unity_Saturate_float(_Divide_ced9f1a8c241466e91792e08856155c5_Out_2, _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1);
            float _Property_def7d18ce006439b83bdf0435d5dae87_Out_0 = Vector1_e4c7de79ca074dc6acf544fa08058f61;
            float _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2;
            Unity_Power_float(_Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1, _Property_def7d18ce006439b83bdf0435d5dae87_Out_0, _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2);
            float4 _Property_acbb4ec64c894666aed93d6c17bab669_Out_0 = Vector4_d7175560f1a3463cb3aa8bf951d8481c;
            float _Split_7d4cb659812b4aba82359b9cd5676286_R_1 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[0];
            float _Split_7d4cb659812b4aba82359b9cd5676286_G_2 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[1];
            float _Split_7d4cb659812b4aba82359b9cd5676286_B_3 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[2];
            float _Split_7d4cb659812b4aba82359b9cd5676286_A_4 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[3];
            float4 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4;
            float3 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5;
            float2 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_R_1, _Split_7d4cb659812b4aba82359b9cd5676286_G_2, 0, 0, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6);
            float4 _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4;
            float3 _Combine_97b350e15af444549b08b7cccad8507b_RGB_5;
            float2 _Combine_97b350e15af444549b08b7cccad8507b_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_B_3, _Split_7d4cb659812b4aba82359b9cd5676286_A_4, 0, 0, _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4, _Combine_97b350e15af444549b08b7cccad8507b_RGB_5, _Combine_97b350e15af444549b08b7cccad8507b_RG_6);
            float _Remap_7e4aea3511c044c096a39756751a8edf_Out_3;
            Unity_Remap_float(_Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6, _Combine_97b350e15af444549b08b7cccad8507b_RG_6, _Remap_7e4aea3511c044c096a39756751a8edf_Out_3);
            float _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1;
            Unity_Absolute_float(_Remap_7e4aea3511c044c096a39756751a8edf_Out_3, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1);
            float _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3;
            Unity_Smoothstep_float(_Property_053ddb8da804443e8b374d1f1e46439d_Out_0, _Property_049c2369ee52402da7e76747fd5d4b19_Out_0, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1, _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3);
            float _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0 = Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
            float _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0, _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2);
            float2 _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2.xx), _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3);
            float _Property_5e4cf85948674accba829baa1128f457_Out_0 = Vector1_2b90fecba49247d69fea4250dd6f2b05;
            float _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3, _Property_5e4cf85948674accba829baa1128f457_Out_0, _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2);
            float _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0 = Vector1_85705dce160b423095b83fec18834b94;
            float _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2;
            Unity_Multiply_float(_GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2);
            float _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2;
            Unity_Add_float(_Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2, _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2);
            float _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2;
            Unity_Add_float(1, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2);
            float _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2;
            Unity_Divide_float(_Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2, _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2);
            float3 _Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_8d035f5a1dd247c991949a2468e485ed_Out_2.xxx), _Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2);
            float _Property_a31cd2828e384b93a347c401039dc22f_Out_0 = Vector1_08428239c85e48588fbdefbbdba657d0;
            float3 _Multiply_a450069c754545c0a818930e08827565_Out_2;
            Unity_Multiply_float(_Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2, (_Property_a31cd2828e384b93a347c401039dc22f_Out_0.xxx), _Multiply_a450069c754545c0a818930e08827565_Out_2);
            float3 _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a450069c754545c0a818930e08827565_Out_2, _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2);
            float3 _Add_d021335a91474d7e933acf61f6e5b302_Out_2;
            Unity_Add_float3(_Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2, _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2, _Add_d021335a91474d7e933acf61f6e5b302_Out_2);
            description.Position = _Add_d021335a91474d7e933acf61f6e5b302_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1);
            float4 _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0 = IN.ScreenPosition;
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_R_1 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[0];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_G_2 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[1];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_B_3 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[2];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_A_4 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[3];
            float _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2;
            Unity_Subtract_float(_Split_88bd4eaad1bc473bafd9769e43fc6eae_A_4, 1, _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2);
            float _Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2;
            Unity_Subtract_float(_SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1, _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2, _Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2);
            float _Property_eec2c1a9e98a4156b7ae81ef6fd2adfa_Out_0 = Vector1_554b3b77df094a20ae20fb7a09a219e7;
            float _Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2;
            Unity_Divide_float(_Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2, _Property_eec2c1a9e98a4156b7ae81ef6fd2adfa_Out_0, _Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2);
            float _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1;
            Unity_Saturate_float(_Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2, _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1);
            surface.Alpha = _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_7857debdf41d401bba91a8ee4589797d;
        float Vector1_3e90a01d954242c19dfed08766b90e95;
        float Vector1_7dd17304f68b476ea7aca908377acaa8;
        float Vector1_08428239c85e48588fbdefbbdba657d0;
        float4 Vector4_d7175560f1a3463cb3aa8bf951d8481c;
        float4 Color_6339afdcca124ffdacbdb2d95c288d1f;
        float4 Color_4c92777dd71a44c28f40a8b89797d9cf;
        float Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
        float Vector1_8607474205e846fd9baba5fc496fc1a4;
        float Vector1_e4c7de79ca074dc6acf544fa08058f61;
        float Vector1_2b90fecba49247d69fea4250dd6f2b05;
        float Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
        float Vector1_85705dce160b423095b83fec18834b94;
        float Vector1_2d8f347bfae0495495a1901da88f5503;
        float Vector1_abdcc9bf2c3e4b2784bd5b3cd35ee51c;
        float Vector1_e422a47f8df24c3db74aea0d635974ab;
        float Vector1_a692e6f11a4a48ce952d8c7a0c61c1aa;
        float Vector1_554b3b77df094a20ae20fb7a09a219e7;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2);
            float _Property_854cff9e0336411abc3494adb5949df2_Out_0 = Vector1_abdcc9bf2c3e4b2784bd5b3cd35ee51c;
            float _Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2;
            Unity_Divide_float(_Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2, _Property_854cff9e0336411abc3494adb5949df2_Out_0, _Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2);
            float _Power_b076041ae9da49808786f2e74199f99b_Out_2;
            Unity_Power_float(_Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2, 3, _Power_b076041ae9da49808786f2e74199f99b_Out_2);
            float3 _Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2;
            Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_b076041ae9da49808786f2e74199f99b_Out_2.xxx), _Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2);
            float _Property_053ddb8da804443e8b374d1f1e46439d_Out_0 = Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
            float _Property_049c2369ee52402da7e76747fd5d4b19_Out_0 = Vector1_8607474205e846fd9baba5fc496fc1a4;
            float4 _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0 = Vector4_7857debdf41d401bba91a8ee4589797d;
            float _Split_812593ea1f7b4cd48228a008310391e8_R_1 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[0];
            float _Split_812593ea1f7b4cd48228a008310391e8_G_2 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[1];
            float _Split_812593ea1f7b4cd48228a008310391e8_B_3 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[2];
            float _Split_812593ea1f7b4cd48228a008310391e8_A_4 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[3];
            float3 _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0.xyz), _Split_812593ea1f7b4cd48228a008310391e8_A_4, _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3);
            float _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0 = Vector1_7dd17304f68b476ea7aca908377acaa8;
            float _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0, _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2);
            float2 _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2.xx), _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3);
            float _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0 = Vector1_3e90a01d954242c19dfed08766b90e95;
            float _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2);
            float2 _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3);
            float _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2);
            float _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2;
            Unity_Add_float(_GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2, _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2);
            float _Divide_ced9f1a8c241466e91792e08856155c5_Out_2;
            Unity_Divide_float(_Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2, 2, _Divide_ced9f1a8c241466e91792e08856155c5_Out_2);
            float _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1;
            Unity_Saturate_float(_Divide_ced9f1a8c241466e91792e08856155c5_Out_2, _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1);
            float _Property_def7d18ce006439b83bdf0435d5dae87_Out_0 = Vector1_e4c7de79ca074dc6acf544fa08058f61;
            float _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2;
            Unity_Power_float(_Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1, _Property_def7d18ce006439b83bdf0435d5dae87_Out_0, _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2);
            float4 _Property_acbb4ec64c894666aed93d6c17bab669_Out_0 = Vector4_d7175560f1a3463cb3aa8bf951d8481c;
            float _Split_7d4cb659812b4aba82359b9cd5676286_R_1 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[0];
            float _Split_7d4cb659812b4aba82359b9cd5676286_G_2 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[1];
            float _Split_7d4cb659812b4aba82359b9cd5676286_B_3 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[2];
            float _Split_7d4cb659812b4aba82359b9cd5676286_A_4 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[3];
            float4 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4;
            float3 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5;
            float2 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_R_1, _Split_7d4cb659812b4aba82359b9cd5676286_G_2, 0, 0, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6);
            float4 _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4;
            float3 _Combine_97b350e15af444549b08b7cccad8507b_RGB_5;
            float2 _Combine_97b350e15af444549b08b7cccad8507b_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_B_3, _Split_7d4cb659812b4aba82359b9cd5676286_A_4, 0, 0, _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4, _Combine_97b350e15af444549b08b7cccad8507b_RGB_5, _Combine_97b350e15af444549b08b7cccad8507b_RG_6);
            float _Remap_7e4aea3511c044c096a39756751a8edf_Out_3;
            Unity_Remap_float(_Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6, _Combine_97b350e15af444549b08b7cccad8507b_RG_6, _Remap_7e4aea3511c044c096a39756751a8edf_Out_3);
            float _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1;
            Unity_Absolute_float(_Remap_7e4aea3511c044c096a39756751a8edf_Out_3, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1);
            float _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3;
            Unity_Smoothstep_float(_Property_053ddb8da804443e8b374d1f1e46439d_Out_0, _Property_049c2369ee52402da7e76747fd5d4b19_Out_0, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1, _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3);
            float _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0 = Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
            float _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0, _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2);
            float2 _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2.xx), _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3);
            float _Property_5e4cf85948674accba829baa1128f457_Out_0 = Vector1_2b90fecba49247d69fea4250dd6f2b05;
            float _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3, _Property_5e4cf85948674accba829baa1128f457_Out_0, _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2);
            float _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0 = Vector1_85705dce160b423095b83fec18834b94;
            float _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2;
            Unity_Multiply_float(_GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2);
            float _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2;
            Unity_Add_float(_Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2, _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2);
            float _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2;
            Unity_Add_float(1, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2);
            float _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2;
            Unity_Divide_float(_Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2, _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2);
            float3 _Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_8d035f5a1dd247c991949a2468e485ed_Out_2.xxx), _Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2);
            float _Property_a31cd2828e384b93a347c401039dc22f_Out_0 = Vector1_08428239c85e48588fbdefbbdba657d0;
            float3 _Multiply_a450069c754545c0a818930e08827565_Out_2;
            Unity_Multiply_float(_Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2, (_Property_a31cd2828e384b93a347c401039dc22f_Out_0.xxx), _Multiply_a450069c754545c0a818930e08827565_Out_2);
            float3 _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a450069c754545c0a818930e08827565_Out_2, _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2);
            float3 _Add_d021335a91474d7e933acf61f6e5b302_Out_2;
            Unity_Add_float3(_Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2, _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2, _Add_d021335a91474d7e933acf61f6e5b302_Out_2);
            description.Position = _Add_d021335a91474d7e933acf61f6e5b302_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1);
            float4 _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0 = IN.ScreenPosition;
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_R_1 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[0];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_G_2 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[1];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_B_3 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[2];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_A_4 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[3];
            float _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2;
            Unity_Subtract_float(_Split_88bd4eaad1bc473bafd9769e43fc6eae_A_4, 1, _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2);
            float _Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2;
            Unity_Subtract_float(_SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1, _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2, _Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2);
            float _Property_eec2c1a9e98a4156b7ae81ef6fd2adfa_Out_0 = Vector1_554b3b77df094a20ae20fb7a09a219e7;
            float _Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2;
            Unity_Divide_float(_Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2, _Property_eec2c1a9e98a4156b7ae81ef6fd2adfa_Out_0, _Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2);
            float _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1;
            Unity_Saturate_float(_Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2, _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1);
            surface.Alpha = _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_7857debdf41d401bba91a8ee4589797d;
        float Vector1_3e90a01d954242c19dfed08766b90e95;
        float Vector1_7dd17304f68b476ea7aca908377acaa8;
        float Vector1_08428239c85e48588fbdefbbdba657d0;
        float4 Vector4_d7175560f1a3463cb3aa8bf951d8481c;
        float4 Color_6339afdcca124ffdacbdb2d95c288d1f;
        float4 Color_4c92777dd71a44c28f40a8b89797d9cf;
        float Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
        float Vector1_8607474205e846fd9baba5fc496fc1a4;
        float Vector1_e4c7de79ca074dc6acf544fa08058f61;
        float Vector1_2b90fecba49247d69fea4250dd6f2b05;
        float Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
        float Vector1_85705dce160b423095b83fec18834b94;
        float Vector1_2d8f347bfae0495495a1901da88f5503;
        float Vector1_abdcc9bf2c3e4b2784bd5b3cd35ee51c;
        float Vector1_e422a47f8df24c3db74aea0d635974ab;
        float Vector1_a692e6f11a4a48ce952d8c7a0c61c1aa;
        float Vector1_554b3b77df094a20ae20fb7a09a219e7;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2);
            float _Property_854cff9e0336411abc3494adb5949df2_Out_0 = Vector1_abdcc9bf2c3e4b2784bd5b3cd35ee51c;
            float _Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2;
            Unity_Divide_float(_Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2, _Property_854cff9e0336411abc3494adb5949df2_Out_0, _Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2);
            float _Power_b076041ae9da49808786f2e74199f99b_Out_2;
            Unity_Power_float(_Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2, 3, _Power_b076041ae9da49808786f2e74199f99b_Out_2);
            float3 _Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2;
            Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_b076041ae9da49808786f2e74199f99b_Out_2.xxx), _Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2);
            float _Property_053ddb8da804443e8b374d1f1e46439d_Out_0 = Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
            float _Property_049c2369ee52402da7e76747fd5d4b19_Out_0 = Vector1_8607474205e846fd9baba5fc496fc1a4;
            float4 _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0 = Vector4_7857debdf41d401bba91a8ee4589797d;
            float _Split_812593ea1f7b4cd48228a008310391e8_R_1 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[0];
            float _Split_812593ea1f7b4cd48228a008310391e8_G_2 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[1];
            float _Split_812593ea1f7b4cd48228a008310391e8_B_3 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[2];
            float _Split_812593ea1f7b4cd48228a008310391e8_A_4 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[3];
            float3 _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0.xyz), _Split_812593ea1f7b4cd48228a008310391e8_A_4, _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3);
            float _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0 = Vector1_7dd17304f68b476ea7aca908377acaa8;
            float _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0, _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2);
            float2 _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2.xx), _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3);
            float _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0 = Vector1_3e90a01d954242c19dfed08766b90e95;
            float _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2);
            float2 _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3);
            float _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2);
            float _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2;
            Unity_Add_float(_GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2, _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2);
            float _Divide_ced9f1a8c241466e91792e08856155c5_Out_2;
            Unity_Divide_float(_Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2, 2, _Divide_ced9f1a8c241466e91792e08856155c5_Out_2);
            float _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1;
            Unity_Saturate_float(_Divide_ced9f1a8c241466e91792e08856155c5_Out_2, _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1);
            float _Property_def7d18ce006439b83bdf0435d5dae87_Out_0 = Vector1_e4c7de79ca074dc6acf544fa08058f61;
            float _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2;
            Unity_Power_float(_Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1, _Property_def7d18ce006439b83bdf0435d5dae87_Out_0, _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2);
            float4 _Property_acbb4ec64c894666aed93d6c17bab669_Out_0 = Vector4_d7175560f1a3463cb3aa8bf951d8481c;
            float _Split_7d4cb659812b4aba82359b9cd5676286_R_1 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[0];
            float _Split_7d4cb659812b4aba82359b9cd5676286_G_2 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[1];
            float _Split_7d4cb659812b4aba82359b9cd5676286_B_3 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[2];
            float _Split_7d4cb659812b4aba82359b9cd5676286_A_4 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[3];
            float4 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4;
            float3 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5;
            float2 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_R_1, _Split_7d4cb659812b4aba82359b9cd5676286_G_2, 0, 0, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6);
            float4 _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4;
            float3 _Combine_97b350e15af444549b08b7cccad8507b_RGB_5;
            float2 _Combine_97b350e15af444549b08b7cccad8507b_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_B_3, _Split_7d4cb659812b4aba82359b9cd5676286_A_4, 0, 0, _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4, _Combine_97b350e15af444549b08b7cccad8507b_RGB_5, _Combine_97b350e15af444549b08b7cccad8507b_RG_6);
            float _Remap_7e4aea3511c044c096a39756751a8edf_Out_3;
            Unity_Remap_float(_Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6, _Combine_97b350e15af444549b08b7cccad8507b_RG_6, _Remap_7e4aea3511c044c096a39756751a8edf_Out_3);
            float _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1;
            Unity_Absolute_float(_Remap_7e4aea3511c044c096a39756751a8edf_Out_3, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1);
            float _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3;
            Unity_Smoothstep_float(_Property_053ddb8da804443e8b374d1f1e46439d_Out_0, _Property_049c2369ee52402da7e76747fd5d4b19_Out_0, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1, _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3);
            float _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0 = Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
            float _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0, _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2);
            float2 _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2.xx), _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3);
            float _Property_5e4cf85948674accba829baa1128f457_Out_0 = Vector1_2b90fecba49247d69fea4250dd6f2b05;
            float _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3, _Property_5e4cf85948674accba829baa1128f457_Out_0, _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2);
            float _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0 = Vector1_85705dce160b423095b83fec18834b94;
            float _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2;
            Unity_Multiply_float(_GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2);
            float _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2;
            Unity_Add_float(_Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2, _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2);
            float _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2;
            Unity_Add_float(1, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2);
            float _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2;
            Unity_Divide_float(_Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2, _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2);
            float3 _Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_8d035f5a1dd247c991949a2468e485ed_Out_2.xxx), _Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2);
            float _Property_a31cd2828e384b93a347c401039dc22f_Out_0 = Vector1_08428239c85e48588fbdefbbdba657d0;
            float3 _Multiply_a450069c754545c0a818930e08827565_Out_2;
            Unity_Multiply_float(_Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2, (_Property_a31cd2828e384b93a347c401039dc22f_Out_0.xxx), _Multiply_a450069c754545c0a818930e08827565_Out_2);
            float3 _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a450069c754545c0a818930e08827565_Out_2, _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2);
            float3 _Add_d021335a91474d7e933acf61f6e5b302_Out_2;
            Unity_Add_float3(_Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2, _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2, _Add_d021335a91474d7e933acf61f6e5b302_Out_2);
            description.Position = _Add_d021335a91474d7e933acf61f6e5b302_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1);
            float4 _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0 = IN.ScreenPosition;
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_R_1 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[0];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_G_2 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[1];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_B_3 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[2];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_A_4 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[3];
            float _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2;
            Unity_Subtract_float(_Split_88bd4eaad1bc473bafd9769e43fc6eae_A_4, 1, _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2);
            float _Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2;
            Unity_Subtract_float(_SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1, _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2, _Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2);
            float _Property_eec2c1a9e98a4156b7ae81ef6fd2adfa_Out_0 = Vector1_554b3b77df094a20ae20fb7a09a219e7;
            float _Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2;
            Unity_Divide_float(_Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2, _Property_eec2c1a9e98a4156b7ae81ef6fd2adfa_Out_0, _Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2);
            float _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1;
            Unity_Saturate_float(_Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2, _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }

            // Render State
            Cull Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_META
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv1 : TEXCOORD1;
            float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceViewDirection;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float3 interp2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.viewDirectionWS = input.interp2.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_7857debdf41d401bba91a8ee4589797d;
        float Vector1_3e90a01d954242c19dfed08766b90e95;
        float Vector1_7dd17304f68b476ea7aca908377acaa8;
        float Vector1_08428239c85e48588fbdefbbdba657d0;
        float4 Vector4_d7175560f1a3463cb3aa8bf951d8481c;
        float4 Color_6339afdcca124ffdacbdb2d95c288d1f;
        float4 Color_4c92777dd71a44c28f40a8b89797d9cf;
        float Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
        float Vector1_8607474205e846fd9baba5fc496fc1a4;
        float Vector1_e4c7de79ca074dc6acf544fa08058f61;
        float Vector1_2b90fecba49247d69fea4250dd6f2b05;
        float Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
        float Vector1_85705dce160b423095b83fec18834b94;
        float Vector1_2d8f347bfae0495495a1901da88f5503;
        float Vector1_abdcc9bf2c3e4b2784bd5b3cd35ee51c;
        float Vector1_e422a47f8df24c3db74aea0d635974ab;
        float Vector1_a692e6f11a4a48ce952d8c7a0c61c1aa;
        float Vector1_554b3b77df094a20ae20fb7a09a219e7;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2);
            float _Property_854cff9e0336411abc3494adb5949df2_Out_0 = Vector1_abdcc9bf2c3e4b2784bd5b3cd35ee51c;
            float _Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2;
            Unity_Divide_float(_Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2, _Property_854cff9e0336411abc3494adb5949df2_Out_0, _Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2);
            float _Power_b076041ae9da49808786f2e74199f99b_Out_2;
            Unity_Power_float(_Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2, 3, _Power_b076041ae9da49808786f2e74199f99b_Out_2);
            float3 _Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2;
            Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_b076041ae9da49808786f2e74199f99b_Out_2.xxx), _Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2);
            float _Property_053ddb8da804443e8b374d1f1e46439d_Out_0 = Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
            float _Property_049c2369ee52402da7e76747fd5d4b19_Out_0 = Vector1_8607474205e846fd9baba5fc496fc1a4;
            float4 _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0 = Vector4_7857debdf41d401bba91a8ee4589797d;
            float _Split_812593ea1f7b4cd48228a008310391e8_R_1 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[0];
            float _Split_812593ea1f7b4cd48228a008310391e8_G_2 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[1];
            float _Split_812593ea1f7b4cd48228a008310391e8_B_3 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[2];
            float _Split_812593ea1f7b4cd48228a008310391e8_A_4 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[3];
            float3 _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0.xyz), _Split_812593ea1f7b4cd48228a008310391e8_A_4, _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3);
            float _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0 = Vector1_7dd17304f68b476ea7aca908377acaa8;
            float _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0, _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2);
            float2 _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2.xx), _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3);
            float _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0 = Vector1_3e90a01d954242c19dfed08766b90e95;
            float _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2);
            float2 _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3);
            float _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2);
            float _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2;
            Unity_Add_float(_GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2, _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2);
            float _Divide_ced9f1a8c241466e91792e08856155c5_Out_2;
            Unity_Divide_float(_Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2, 2, _Divide_ced9f1a8c241466e91792e08856155c5_Out_2);
            float _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1;
            Unity_Saturate_float(_Divide_ced9f1a8c241466e91792e08856155c5_Out_2, _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1);
            float _Property_def7d18ce006439b83bdf0435d5dae87_Out_0 = Vector1_e4c7de79ca074dc6acf544fa08058f61;
            float _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2;
            Unity_Power_float(_Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1, _Property_def7d18ce006439b83bdf0435d5dae87_Out_0, _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2);
            float4 _Property_acbb4ec64c894666aed93d6c17bab669_Out_0 = Vector4_d7175560f1a3463cb3aa8bf951d8481c;
            float _Split_7d4cb659812b4aba82359b9cd5676286_R_1 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[0];
            float _Split_7d4cb659812b4aba82359b9cd5676286_G_2 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[1];
            float _Split_7d4cb659812b4aba82359b9cd5676286_B_3 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[2];
            float _Split_7d4cb659812b4aba82359b9cd5676286_A_4 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[3];
            float4 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4;
            float3 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5;
            float2 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_R_1, _Split_7d4cb659812b4aba82359b9cd5676286_G_2, 0, 0, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6);
            float4 _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4;
            float3 _Combine_97b350e15af444549b08b7cccad8507b_RGB_5;
            float2 _Combine_97b350e15af444549b08b7cccad8507b_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_B_3, _Split_7d4cb659812b4aba82359b9cd5676286_A_4, 0, 0, _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4, _Combine_97b350e15af444549b08b7cccad8507b_RGB_5, _Combine_97b350e15af444549b08b7cccad8507b_RG_6);
            float _Remap_7e4aea3511c044c096a39756751a8edf_Out_3;
            Unity_Remap_float(_Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6, _Combine_97b350e15af444549b08b7cccad8507b_RG_6, _Remap_7e4aea3511c044c096a39756751a8edf_Out_3);
            float _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1;
            Unity_Absolute_float(_Remap_7e4aea3511c044c096a39756751a8edf_Out_3, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1);
            float _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3;
            Unity_Smoothstep_float(_Property_053ddb8da804443e8b374d1f1e46439d_Out_0, _Property_049c2369ee52402da7e76747fd5d4b19_Out_0, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1, _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3);
            float _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0 = Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
            float _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0, _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2);
            float2 _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2.xx), _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3);
            float _Property_5e4cf85948674accba829baa1128f457_Out_0 = Vector1_2b90fecba49247d69fea4250dd6f2b05;
            float _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3, _Property_5e4cf85948674accba829baa1128f457_Out_0, _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2);
            float _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0 = Vector1_85705dce160b423095b83fec18834b94;
            float _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2;
            Unity_Multiply_float(_GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2);
            float _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2;
            Unity_Add_float(_Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2, _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2);
            float _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2;
            Unity_Add_float(1, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2);
            float _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2;
            Unity_Divide_float(_Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2, _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2);
            float3 _Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_8d035f5a1dd247c991949a2468e485ed_Out_2.xxx), _Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2);
            float _Property_a31cd2828e384b93a347c401039dc22f_Out_0 = Vector1_08428239c85e48588fbdefbbdba657d0;
            float3 _Multiply_a450069c754545c0a818930e08827565_Out_2;
            Unity_Multiply_float(_Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2, (_Property_a31cd2828e384b93a347c401039dc22f_Out_0.xxx), _Multiply_a450069c754545c0a818930e08827565_Out_2);
            float3 _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a450069c754545c0a818930e08827565_Out_2, _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2);
            float3 _Add_d021335a91474d7e933acf61f6e5b302_Out_2;
            Unity_Add_float3(_Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2, _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2, _Add_d021335a91474d7e933acf61f6e5b302_Out_2);
            description.Position = _Add_d021335a91474d7e933acf61f6e5b302_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_ba0f647605054add9ecb748acfab7189_Out_0 = Color_6339afdcca124ffdacbdb2d95c288d1f;
            float4 _Property_0f6a99dfadb1482ebb8abc5826059d6d_Out_0 = Color_4c92777dd71a44c28f40a8b89797d9cf;
            float _Property_053ddb8da804443e8b374d1f1e46439d_Out_0 = Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
            float _Property_049c2369ee52402da7e76747fd5d4b19_Out_0 = Vector1_8607474205e846fd9baba5fc496fc1a4;
            float4 _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0 = Vector4_7857debdf41d401bba91a8ee4589797d;
            float _Split_812593ea1f7b4cd48228a008310391e8_R_1 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[0];
            float _Split_812593ea1f7b4cd48228a008310391e8_G_2 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[1];
            float _Split_812593ea1f7b4cd48228a008310391e8_B_3 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[2];
            float _Split_812593ea1f7b4cd48228a008310391e8_A_4 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[3];
            float3 _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0.xyz), _Split_812593ea1f7b4cd48228a008310391e8_A_4, _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3);
            float _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0 = Vector1_7dd17304f68b476ea7aca908377acaa8;
            float _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0, _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2);
            float2 _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2.xx), _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3);
            float _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0 = Vector1_3e90a01d954242c19dfed08766b90e95;
            float _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2);
            float2 _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3);
            float _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2);
            float _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2;
            Unity_Add_float(_GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2, _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2);
            float _Divide_ced9f1a8c241466e91792e08856155c5_Out_2;
            Unity_Divide_float(_Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2, 2, _Divide_ced9f1a8c241466e91792e08856155c5_Out_2);
            float _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1;
            Unity_Saturate_float(_Divide_ced9f1a8c241466e91792e08856155c5_Out_2, _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1);
            float _Property_def7d18ce006439b83bdf0435d5dae87_Out_0 = Vector1_e4c7de79ca074dc6acf544fa08058f61;
            float _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2;
            Unity_Power_float(_Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1, _Property_def7d18ce006439b83bdf0435d5dae87_Out_0, _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2);
            float4 _Property_acbb4ec64c894666aed93d6c17bab669_Out_0 = Vector4_d7175560f1a3463cb3aa8bf951d8481c;
            float _Split_7d4cb659812b4aba82359b9cd5676286_R_1 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[0];
            float _Split_7d4cb659812b4aba82359b9cd5676286_G_2 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[1];
            float _Split_7d4cb659812b4aba82359b9cd5676286_B_3 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[2];
            float _Split_7d4cb659812b4aba82359b9cd5676286_A_4 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[3];
            float4 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4;
            float3 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5;
            float2 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_R_1, _Split_7d4cb659812b4aba82359b9cd5676286_G_2, 0, 0, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6);
            float4 _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4;
            float3 _Combine_97b350e15af444549b08b7cccad8507b_RGB_5;
            float2 _Combine_97b350e15af444549b08b7cccad8507b_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_B_3, _Split_7d4cb659812b4aba82359b9cd5676286_A_4, 0, 0, _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4, _Combine_97b350e15af444549b08b7cccad8507b_RGB_5, _Combine_97b350e15af444549b08b7cccad8507b_RG_6);
            float _Remap_7e4aea3511c044c096a39756751a8edf_Out_3;
            Unity_Remap_float(_Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6, _Combine_97b350e15af444549b08b7cccad8507b_RG_6, _Remap_7e4aea3511c044c096a39756751a8edf_Out_3);
            float _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1;
            Unity_Absolute_float(_Remap_7e4aea3511c044c096a39756751a8edf_Out_3, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1);
            float _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3;
            Unity_Smoothstep_float(_Property_053ddb8da804443e8b374d1f1e46439d_Out_0, _Property_049c2369ee52402da7e76747fd5d4b19_Out_0, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1, _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3);
            float _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0 = Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
            float _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0, _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2);
            float2 _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2.xx), _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3);
            float _Property_5e4cf85948674accba829baa1128f457_Out_0 = Vector1_2b90fecba49247d69fea4250dd6f2b05;
            float _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3, _Property_5e4cf85948674accba829baa1128f457_Out_0, _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2);
            float _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0 = Vector1_85705dce160b423095b83fec18834b94;
            float _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2;
            Unity_Multiply_float(_GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2);
            float _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2;
            Unity_Add_float(_Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2, _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2);
            float _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2;
            Unity_Add_float(1, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2);
            float _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2;
            Unity_Divide_float(_Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2, _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2);
            float4 _Lerp_1d146db540d144cea0c82b0d31afe7fb_Out_3;
            Unity_Lerp_float4(_Property_ba0f647605054add9ecb748acfab7189_Out_0, _Property_0f6a99dfadb1482ebb8abc5826059d6d_Out_0, (_Divide_8d035f5a1dd247c991949a2468e485ed_Out_2.xxxx), _Lerp_1d146db540d144cea0c82b0d31afe7fb_Out_3);
            float _Property_db3130cfd93f4e20a2eea366d3e7c3cb_Out_0 = Vector1_e422a47f8df24c3db74aea0d635974ab;
            float _FresnelEffect_f1ecbfd78ca54d9a82c60183643a368d_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_db3130cfd93f4e20a2eea366d3e7c3cb_Out_0, _FresnelEffect_f1ecbfd78ca54d9a82c60183643a368d_Out_3);
            float _Multiply_67c2514ffb7f47e2b62c67ff73747b76_Out_2;
            Unity_Multiply_float(_Divide_8d035f5a1dd247c991949a2468e485ed_Out_2, _FresnelEffect_f1ecbfd78ca54d9a82c60183643a368d_Out_3, _Multiply_67c2514ffb7f47e2b62c67ff73747b76_Out_2);
            float _Property_1e995a1735c045988eba42a23c39c906_Out_0 = Vector1_a692e6f11a4a48ce952d8c7a0c61c1aa;
            float _Multiply_60b7ea1e156f4b5099f325cddb89a068_Out_2;
            Unity_Multiply_float(_Multiply_67c2514ffb7f47e2b62c67ff73747b76_Out_2, _Property_1e995a1735c045988eba42a23c39c906_Out_0, _Multiply_60b7ea1e156f4b5099f325cddb89a068_Out_2);
            float4 _Add_3d1174b8fb2346af8156df38795e2a28_Out_2;
            Unity_Add_float4(_Lerp_1d146db540d144cea0c82b0d31afe7fb_Out_3, (_Multiply_60b7ea1e156f4b5099f325cddb89a068_Out_2.xxxx), _Add_3d1174b8fb2346af8156df38795e2a28_Out_2);
            float _Property_d2746846112f46188c604caf72994dd9_Out_0 = Vector1_2d8f347bfae0495495a1901da88f5503;
            float4 _Multiply_6a7e610df71a42cbbc5238f078bc0fbd_Out_2;
            Unity_Multiply_float(_Add_3d1174b8fb2346af8156df38795e2a28_Out_2, (_Property_d2746846112f46188c604caf72994dd9_Out_0.xxxx), _Multiply_6a7e610df71a42cbbc5238f078bc0fbd_Out_2);
            float _SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1);
            float4 _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0 = IN.ScreenPosition;
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_R_1 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[0];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_G_2 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[1];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_B_3 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[2];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_A_4 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[3];
            float _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2;
            Unity_Subtract_float(_Split_88bd4eaad1bc473bafd9769e43fc6eae_A_4, 1, _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2);
            float _Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2;
            Unity_Subtract_float(_SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1, _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2, _Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2);
            float _Property_eec2c1a9e98a4156b7ae81ef6fd2adfa_Out_0 = Vector1_554b3b77df094a20ae20fb7a09a219e7;
            float _Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2;
            Unity_Divide_float(_Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2, _Property_eec2c1a9e98a4156b7ae81ef6fd2adfa_Out_0, _Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2);
            float _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1;
            Unity_Saturate_float(_Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2, _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1);
            surface.BaseColor = (_Add_3d1174b8fb2346af8156df38795e2a28_Out_2.xyz);
            surface.Emission = (_Multiply_6a7e610df71a42cbbc5238f078bc0fbd_Out_2.xyz);
            surface.Alpha = _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_2D
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceViewDirection;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float3 interp2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.viewDirectionWS = input.interp2.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_7857debdf41d401bba91a8ee4589797d;
        float Vector1_3e90a01d954242c19dfed08766b90e95;
        float Vector1_7dd17304f68b476ea7aca908377acaa8;
        float Vector1_08428239c85e48588fbdefbbdba657d0;
        float4 Vector4_d7175560f1a3463cb3aa8bf951d8481c;
        float4 Color_6339afdcca124ffdacbdb2d95c288d1f;
        float4 Color_4c92777dd71a44c28f40a8b89797d9cf;
        float Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
        float Vector1_8607474205e846fd9baba5fc496fc1a4;
        float Vector1_e4c7de79ca074dc6acf544fa08058f61;
        float Vector1_2b90fecba49247d69fea4250dd6f2b05;
        float Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
        float Vector1_85705dce160b423095b83fec18834b94;
        float Vector1_2d8f347bfae0495495a1901da88f5503;
        float Vector1_abdcc9bf2c3e4b2784bd5b3cd35ee51c;
        float Vector1_e422a47f8df24c3db74aea0d635974ab;
        float Vector1_a692e6f11a4a48ce952d8c7a0c61c1aa;
        float Vector1_554b3b77df094a20ae20fb7a09a219e7;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2);
            float _Property_854cff9e0336411abc3494adb5949df2_Out_0 = Vector1_abdcc9bf2c3e4b2784bd5b3cd35ee51c;
            float _Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2;
            Unity_Divide_float(_Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2, _Property_854cff9e0336411abc3494adb5949df2_Out_0, _Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2);
            float _Power_b076041ae9da49808786f2e74199f99b_Out_2;
            Unity_Power_float(_Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2, 3, _Power_b076041ae9da49808786f2e74199f99b_Out_2);
            float3 _Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2;
            Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_b076041ae9da49808786f2e74199f99b_Out_2.xxx), _Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2);
            float _Property_053ddb8da804443e8b374d1f1e46439d_Out_0 = Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
            float _Property_049c2369ee52402da7e76747fd5d4b19_Out_0 = Vector1_8607474205e846fd9baba5fc496fc1a4;
            float4 _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0 = Vector4_7857debdf41d401bba91a8ee4589797d;
            float _Split_812593ea1f7b4cd48228a008310391e8_R_1 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[0];
            float _Split_812593ea1f7b4cd48228a008310391e8_G_2 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[1];
            float _Split_812593ea1f7b4cd48228a008310391e8_B_3 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[2];
            float _Split_812593ea1f7b4cd48228a008310391e8_A_4 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[3];
            float3 _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0.xyz), _Split_812593ea1f7b4cd48228a008310391e8_A_4, _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3);
            float _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0 = Vector1_7dd17304f68b476ea7aca908377acaa8;
            float _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0, _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2);
            float2 _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2.xx), _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3);
            float _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0 = Vector1_3e90a01d954242c19dfed08766b90e95;
            float _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2);
            float2 _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3);
            float _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2);
            float _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2;
            Unity_Add_float(_GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2, _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2);
            float _Divide_ced9f1a8c241466e91792e08856155c5_Out_2;
            Unity_Divide_float(_Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2, 2, _Divide_ced9f1a8c241466e91792e08856155c5_Out_2);
            float _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1;
            Unity_Saturate_float(_Divide_ced9f1a8c241466e91792e08856155c5_Out_2, _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1);
            float _Property_def7d18ce006439b83bdf0435d5dae87_Out_0 = Vector1_e4c7de79ca074dc6acf544fa08058f61;
            float _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2;
            Unity_Power_float(_Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1, _Property_def7d18ce006439b83bdf0435d5dae87_Out_0, _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2);
            float4 _Property_acbb4ec64c894666aed93d6c17bab669_Out_0 = Vector4_d7175560f1a3463cb3aa8bf951d8481c;
            float _Split_7d4cb659812b4aba82359b9cd5676286_R_1 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[0];
            float _Split_7d4cb659812b4aba82359b9cd5676286_G_2 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[1];
            float _Split_7d4cb659812b4aba82359b9cd5676286_B_3 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[2];
            float _Split_7d4cb659812b4aba82359b9cd5676286_A_4 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[3];
            float4 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4;
            float3 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5;
            float2 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_R_1, _Split_7d4cb659812b4aba82359b9cd5676286_G_2, 0, 0, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6);
            float4 _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4;
            float3 _Combine_97b350e15af444549b08b7cccad8507b_RGB_5;
            float2 _Combine_97b350e15af444549b08b7cccad8507b_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_B_3, _Split_7d4cb659812b4aba82359b9cd5676286_A_4, 0, 0, _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4, _Combine_97b350e15af444549b08b7cccad8507b_RGB_5, _Combine_97b350e15af444549b08b7cccad8507b_RG_6);
            float _Remap_7e4aea3511c044c096a39756751a8edf_Out_3;
            Unity_Remap_float(_Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6, _Combine_97b350e15af444549b08b7cccad8507b_RG_6, _Remap_7e4aea3511c044c096a39756751a8edf_Out_3);
            float _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1;
            Unity_Absolute_float(_Remap_7e4aea3511c044c096a39756751a8edf_Out_3, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1);
            float _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3;
            Unity_Smoothstep_float(_Property_053ddb8da804443e8b374d1f1e46439d_Out_0, _Property_049c2369ee52402da7e76747fd5d4b19_Out_0, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1, _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3);
            float _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0 = Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
            float _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0, _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2);
            float2 _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2.xx), _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3);
            float _Property_5e4cf85948674accba829baa1128f457_Out_0 = Vector1_2b90fecba49247d69fea4250dd6f2b05;
            float _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3, _Property_5e4cf85948674accba829baa1128f457_Out_0, _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2);
            float _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0 = Vector1_85705dce160b423095b83fec18834b94;
            float _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2;
            Unity_Multiply_float(_GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2);
            float _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2;
            Unity_Add_float(_Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2, _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2);
            float _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2;
            Unity_Add_float(1, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2);
            float _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2;
            Unity_Divide_float(_Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2, _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2);
            float3 _Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_8d035f5a1dd247c991949a2468e485ed_Out_2.xxx), _Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2);
            float _Property_a31cd2828e384b93a347c401039dc22f_Out_0 = Vector1_08428239c85e48588fbdefbbdba657d0;
            float3 _Multiply_a450069c754545c0a818930e08827565_Out_2;
            Unity_Multiply_float(_Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2, (_Property_a31cd2828e384b93a347c401039dc22f_Out_0.xxx), _Multiply_a450069c754545c0a818930e08827565_Out_2);
            float3 _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a450069c754545c0a818930e08827565_Out_2, _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2);
            float3 _Add_d021335a91474d7e933acf61f6e5b302_Out_2;
            Unity_Add_float3(_Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2, _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2, _Add_d021335a91474d7e933acf61f6e5b302_Out_2);
            description.Position = _Add_d021335a91474d7e933acf61f6e5b302_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_ba0f647605054add9ecb748acfab7189_Out_0 = Color_6339afdcca124ffdacbdb2d95c288d1f;
            float4 _Property_0f6a99dfadb1482ebb8abc5826059d6d_Out_0 = Color_4c92777dd71a44c28f40a8b89797d9cf;
            float _Property_053ddb8da804443e8b374d1f1e46439d_Out_0 = Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
            float _Property_049c2369ee52402da7e76747fd5d4b19_Out_0 = Vector1_8607474205e846fd9baba5fc496fc1a4;
            float4 _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0 = Vector4_7857debdf41d401bba91a8ee4589797d;
            float _Split_812593ea1f7b4cd48228a008310391e8_R_1 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[0];
            float _Split_812593ea1f7b4cd48228a008310391e8_G_2 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[1];
            float _Split_812593ea1f7b4cd48228a008310391e8_B_3 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[2];
            float _Split_812593ea1f7b4cd48228a008310391e8_A_4 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[3];
            float3 _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0.xyz), _Split_812593ea1f7b4cd48228a008310391e8_A_4, _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3);
            float _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0 = Vector1_7dd17304f68b476ea7aca908377acaa8;
            float _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0, _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2);
            float2 _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2.xx), _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3);
            float _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0 = Vector1_3e90a01d954242c19dfed08766b90e95;
            float _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2);
            float2 _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3);
            float _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2);
            float _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2;
            Unity_Add_float(_GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2, _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2);
            float _Divide_ced9f1a8c241466e91792e08856155c5_Out_2;
            Unity_Divide_float(_Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2, 2, _Divide_ced9f1a8c241466e91792e08856155c5_Out_2);
            float _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1;
            Unity_Saturate_float(_Divide_ced9f1a8c241466e91792e08856155c5_Out_2, _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1);
            float _Property_def7d18ce006439b83bdf0435d5dae87_Out_0 = Vector1_e4c7de79ca074dc6acf544fa08058f61;
            float _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2;
            Unity_Power_float(_Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1, _Property_def7d18ce006439b83bdf0435d5dae87_Out_0, _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2);
            float4 _Property_acbb4ec64c894666aed93d6c17bab669_Out_0 = Vector4_d7175560f1a3463cb3aa8bf951d8481c;
            float _Split_7d4cb659812b4aba82359b9cd5676286_R_1 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[0];
            float _Split_7d4cb659812b4aba82359b9cd5676286_G_2 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[1];
            float _Split_7d4cb659812b4aba82359b9cd5676286_B_3 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[2];
            float _Split_7d4cb659812b4aba82359b9cd5676286_A_4 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[3];
            float4 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4;
            float3 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5;
            float2 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_R_1, _Split_7d4cb659812b4aba82359b9cd5676286_G_2, 0, 0, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6);
            float4 _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4;
            float3 _Combine_97b350e15af444549b08b7cccad8507b_RGB_5;
            float2 _Combine_97b350e15af444549b08b7cccad8507b_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_B_3, _Split_7d4cb659812b4aba82359b9cd5676286_A_4, 0, 0, _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4, _Combine_97b350e15af444549b08b7cccad8507b_RGB_5, _Combine_97b350e15af444549b08b7cccad8507b_RG_6);
            float _Remap_7e4aea3511c044c096a39756751a8edf_Out_3;
            Unity_Remap_float(_Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6, _Combine_97b350e15af444549b08b7cccad8507b_RG_6, _Remap_7e4aea3511c044c096a39756751a8edf_Out_3);
            float _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1;
            Unity_Absolute_float(_Remap_7e4aea3511c044c096a39756751a8edf_Out_3, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1);
            float _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3;
            Unity_Smoothstep_float(_Property_053ddb8da804443e8b374d1f1e46439d_Out_0, _Property_049c2369ee52402da7e76747fd5d4b19_Out_0, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1, _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3);
            float _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0 = Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
            float _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0, _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2);
            float2 _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2.xx), _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3);
            float _Property_5e4cf85948674accba829baa1128f457_Out_0 = Vector1_2b90fecba49247d69fea4250dd6f2b05;
            float _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3, _Property_5e4cf85948674accba829baa1128f457_Out_0, _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2);
            float _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0 = Vector1_85705dce160b423095b83fec18834b94;
            float _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2;
            Unity_Multiply_float(_GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2);
            float _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2;
            Unity_Add_float(_Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2, _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2);
            float _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2;
            Unity_Add_float(1, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2);
            float _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2;
            Unity_Divide_float(_Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2, _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2);
            float4 _Lerp_1d146db540d144cea0c82b0d31afe7fb_Out_3;
            Unity_Lerp_float4(_Property_ba0f647605054add9ecb748acfab7189_Out_0, _Property_0f6a99dfadb1482ebb8abc5826059d6d_Out_0, (_Divide_8d035f5a1dd247c991949a2468e485ed_Out_2.xxxx), _Lerp_1d146db540d144cea0c82b0d31afe7fb_Out_3);
            float _Property_db3130cfd93f4e20a2eea366d3e7c3cb_Out_0 = Vector1_e422a47f8df24c3db74aea0d635974ab;
            float _FresnelEffect_f1ecbfd78ca54d9a82c60183643a368d_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_db3130cfd93f4e20a2eea366d3e7c3cb_Out_0, _FresnelEffect_f1ecbfd78ca54d9a82c60183643a368d_Out_3);
            float _Multiply_67c2514ffb7f47e2b62c67ff73747b76_Out_2;
            Unity_Multiply_float(_Divide_8d035f5a1dd247c991949a2468e485ed_Out_2, _FresnelEffect_f1ecbfd78ca54d9a82c60183643a368d_Out_3, _Multiply_67c2514ffb7f47e2b62c67ff73747b76_Out_2);
            float _Property_1e995a1735c045988eba42a23c39c906_Out_0 = Vector1_a692e6f11a4a48ce952d8c7a0c61c1aa;
            float _Multiply_60b7ea1e156f4b5099f325cddb89a068_Out_2;
            Unity_Multiply_float(_Multiply_67c2514ffb7f47e2b62c67ff73747b76_Out_2, _Property_1e995a1735c045988eba42a23c39c906_Out_0, _Multiply_60b7ea1e156f4b5099f325cddb89a068_Out_2);
            float4 _Add_3d1174b8fb2346af8156df38795e2a28_Out_2;
            Unity_Add_float4(_Lerp_1d146db540d144cea0c82b0d31afe7fb_Out_3, (_Multiply_60b7ea1e156f4b5099f325cddb89a068_Out_2.xxxx), _Add_3d1174b8fb2346af8156df38795e2a28_Out_2);
            float _SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1);
            float4 _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0 = IN.ScreenPosition;
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_R_1 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[0];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_G_2 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[1];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_B_3 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[2];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_A_4 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[3];
            float _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2;
            Unity_Subtract_float(_Split_88bd4eaad1bc473bafd9769e43fc6eae_A_4, 1, _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2);
            float _Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2;
            Unity_Subtract_float(_SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1, _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2, _Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2);
            float _Property_eec2c1a9e98a4156b7ae81ef6fd2adfa_Out_0 = Vector1_554b3b77df094a20ae20fb7a09a219e7;
            float _Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2;
            Unity_Divide_float(_Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2, _Property_eec2c1a9e98a4156b7ae81ef6fd2adfa_Out_0, _Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2);
            float _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1;
            Unity_Saturate_float(_Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2, _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1);
            surface.BaseColor = (_Add_3d1174b8fb2346af8156df38795e2a28_Out_2.xyz);
            surface.Alpha = _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

            ENDHLSL
        }
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        Zwrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment '
            Instancing' */
            #define SHADERPASS SHADERPASS_FORWARD
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 TangentSpaceNormal;
            float3 WorldSpaceViewDirection;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float3 interp3 : TEXCOORD3;
            #if defined(LIGHTMAP_ON)
            float2 interp4 : TEXCOORD4;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp5 : TEXCOORD5;
            #endif
            float4 interp6 : TEXCOORD6;
            float4 interp7 : TEXCOORD7;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp5.xyz =  input.sh;
            #endif
            output.interp6.xyzw =  input.fogFactorAndVertexLight;
            output.interp7.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp4.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp5.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp6.xyzw;
            output.shadowCoord = input.interp7.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_7857debdf41d401bba91a8ee4589797d;
        float Vector1_3e90a01d954242c19dfed08766b90e95;
        float Vector1_7dd17304f68b476ea7aca908377acaa8;
        float Vector1_08428239c85e48588fbdefbbdba657d0;
        float4 Vector4_d7175560f1a3463cb3aa8bf951d8481c;
        float4 Color_6339afdcca124ffdacbdb2d95c288d1f;
        float4 Color_4c92777dd71a44c28f40a8b89797d9cf;
        float Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
        float Vector1_8607474205e846fd9baba5fc496fc1a4;
        float Vector1_e4c7de79ca074dc6acf544fa08058f61;
        float Vector1_2b90fecba49247d69fea4250dd6f2b05;
        float Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
        float Vector1_85705dce160b423095b83fec18834b94;
        float Vector1_2d8f347bfae0495495a1901da88f5503;
        float Vector1_abdcc9bf2c3e4b2784bd5b3cd35ee51c;
        float Vector1_e422a47f8df24c3db74aea0d635974ab;
        float Vector1_a692e6f11a4a48ce952d8c7a0c61c1aa;
        float Vector1_554b3b77df094a20ae20fb7a09a219e7;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2);
            float _Property_854cff9e0336411abc3494adb5949df2_Out_0 = Vector1_abdcc9bf2c3e4b2784bd5b3cd35ee51c;
            float _Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2;
            Unity_Divide_float(_Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2, _Property_854cff9e0336411abc3494adb5949df2_Out_0, _Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2);
            float _Power_b076041ae9da49808786f2e74199f99b_Out_2;
            Unity_Power_float(_Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2, 3, _Power_b076041ae9da49808786f2e74199f99b_Out_2);
            float3 _Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2;
            Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_b076041ae9da49808786f2e74199f99b_Out_2.xxx), _Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2);
            float _Property_053ddb8da804443e8b374d1f1e46439d_Out_0 = Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
            float _Property_049c2369ee52402da7e76747fd5d4b19_Out_0 = Vector1_8607474205e846fd9baba5fc496fc1a4;
            float4 _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0 = Vector4_7857debdf41d401bba91a8ee4589797d;
            float _Split_812593ea1f7b4cd48228a008310391e8_R_1 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[0];
            float _Split_812593ea1f7b4cd48228a008310391e8_G_2 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[1];
            float _Split_812593ea1f7b4cd48228a008310391e8_B_3 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[2];
            float _Split_812593ea1f7b4cd48228a008310391e8_A_4 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[3];
            float3 _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0.xyz), _Split_812593ea1f7b4cd48228a008310391e8_A_4, _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3);
            float _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0 = Vector1_7dd17304f68b476ea7aca908377acaa8;
            float _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0, _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2);
            float2 _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2.xx), _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3);
            float _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0 = Vector1_3e90a01d954242c19dfed08766b90e95;
            float _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2);
            float2 _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3);
            float _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2);
            float _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2;
            Unity_Add_float(_GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2, _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2);
            float _Divide_ced9f1a8c241466e91792e08856155c5_Out_2;
            Unity_Divide_float(_Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2, 2, _Divide_ced9f1a8c241466e91792e08856155c5_Out_2);
            float _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1;
            Unity_Saturate_float(_Divide_ced9f1a8c241466e91792e08856155c5_Out_2, _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1);
            float _Property_def7d18ce006439b83bdf0435d5dae87_Out_0 = Vector1_e4c7de79ca074dc6acf544fa08058f61;
            float _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2;
            Unity_Power_float(_Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1, _Property_def7d18ce006439b83bdf0435d5dae87_Out_0, _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2);
            float4 _Property_acbb4ec64c894666aed93d6c17bab669_Out_0 = Vector4_d7175560f1a3463cb3aa8bf951d8481c;
            float _Split_7d4cb659812b4aba82359b9cd5676286_R_1 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[0];
            float _Split_7d4cb659812b4aba82359b9cd5676286_G_2 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[1];
            float _Split_7d4cb659812b4aba82359b9cd5676286_B_3 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[2];
            float _Split_7d4cb659812b4aba82359b9cd5676286_A_4 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[3];
            float4 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4;
            float3 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5;
            float2 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_R_1, _Split_7d4cb659812b4aba82359b9cd5676286_G_2, 0, 0, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6);
            float4 _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4;
            float3 _Combine_97b350e15af444549b08b7cccad8507b_RGB_5;
            float2 _Combine_97b350e15af444549b08b7cccad8507b_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_B_3, _Split_7d4cb659812b4aba82359b9cd5676286_A_4, 0, 0, _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4, _Combine_97b350e15af444549b08b7cccad8507b_RGB_5, _Combine_97b350e15af444549b08b7cccad8507b_RG_6);
            float _Remap_7e4aea3511c044c096a39756751a8edf_Out_3;
            Unity_Remap_float(_Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6, _Combine_97b350e15af444549b08b7cccad8507b_RG_6, _Remap_7e4aea3511c044c096a39756751a8edf_Out_3);
            float _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1;
            Unity_Absolute_float(_Remap_7e4aea3511c044c096a39756751a8edf_Out_3, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1);
            float _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3;
            Unity_Smoothstep_float(_Property_053ddb8da804443e8b374d1f1e46439d_Out_0, _Property_049c2369ee52402da7e76747fd5d4b19_Out_0, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1, _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3);
            float _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0 = Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
            float _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0, _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2);
            float2 _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2.xx), _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3);
            float _Property_5e4cf85948674accba829baa1128f457_Out_0 = Vector1_2b90fecba49247d69fea4250dd6f2b05;
            float _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3, _Property_5e4cf85948674accba829baa1128f457_Out_0, _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2);
            float _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0 = Vector1_85705dce160b423095b83fec18834b94;
            float _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2;
            Unity_Multiply_float(_GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2);
            float _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2;
            Unity_Add_float(_Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2, _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2);
            float _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2;
            Unity_Add_float(1, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2);
            float _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2;
            Unity_Divide_float(_Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2, _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2);
            float3 _Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_8d035f5a1dd247c991949a2468e485ed_Out_2.xxx), _Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2);
            float _Property_a31cd2828e384b93a347c401039dc22f_Out_0 = Vector1_08428239c85e48588fbdefbbdba657d0;
            float3 _Multiply_a450069c754545c0a818930e08827565_Out_2;
            Unity_Multiply_float(_Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2, (_Property_a31cd2828e384b93a347c401039dc22f_Out_0.xxx), _Multiply_a450069c754545c0a818930e08827565_Out_2);
            float3 _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a450069c754545c0a818930e08827565_Out_2, _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2);
            float3 _Add_d021335a91474d7e933acf61f6e5b302_Out_2;
            Unity_Add_float3(_Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2, _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2, _Add_d021335a91474d7e933acf61f6e5b302_Out_2);
            description.Position = _Add_d021335a91474d7e933acf61f6e5b302_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_ba0f647605054add9ecb748acfab7189_Out_0 = Color_6339afdcca124ffdacbdb2d95c288d1f;
            float4 _Property_0f6a99dfadb1482ebb8abc5826059d6d_Out_0 = Color_4c92777dd71a44c28f40a8b89797d9cf;
            float _Property_053ddb8da804443e8b374d1f1e46439d_Out_0 = Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
            float _Property_049c2369ee52402da7e76747fd5d4b19_Out_0 = Vector1_8607474205e846fd9baba5fc496fc1a4;
            float4 _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0 = Vector4_7857debdf41d401bba91a8ee4589797d;
            float _Split_812593ea1f7b4cd48228a008310391e8_R_1 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[0];
            float _Split_812593ea1f7b4cd48228a008310391e8_G_2 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[1];
            float _Split_812593ea1f7b4cd48228a008310391e8_B_3 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[2];
            float _Split_812593ea1f7b4cd48228a008310391e8_A_4 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[3];
            float3 _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0.xyz), _Split_812593ea1f7b4cd48228a008310391e8_A_4, _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3);
            float _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0 = Vector1_7dd17304f68b476ea7aca908377acaa8;
            float _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0, _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2);
            float2 _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2.xx), _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3);
            float _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0 = Vector1_3e90a01d954242c19dfed08766b90e95;
            float _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2);
            float2 _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3);
            float _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2);
            float _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2;
            Unity_Add_float(_GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2, _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2);
            float _Divide_ced9f1a8c241466e91792e08856155c5_Out_2;
            Unity_Divide_float(_Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2, 2, _Divide_ced9f1a8c241466e91792e08856155c5_Out_2);
            float _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1;
            Unity_Saturate_float(_Divide_ced9f1a8c241466e91792e08856155c5_Out_2, _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1);
            float _Property_def7d18ce006439b83bdf0435d5dae87_Out_0 = Vector1_e4c7de79ca074dc6acf544fa08058f61;
            float _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2;
            Unity_Power_float(_Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1, _Property_def7d18ce006439b83bdf0435d5dae87_Out_0, _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2);
            float4 _Property_acbb4ec64c894666aed93d6c17bab669_Out_0 = Vector4_d7175560f1a3463cb3aa8bf951d8481c;
            float _Split_7d4cb659812b4aba82359b9cd5676286_R_1 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[0];
            float _Split_7d4cb659812b4aba82359b9cd5676286_G_2 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[1];
            float _Split_7d4cb659812b4aba82359b9cd5676286_B_3 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[2];
            float _Split_7d4cb659812b4aba82359b9cd5676286_A_4 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[3];
            float4 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4;
            float3 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5;
            float2 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_R_1, _Split_7d4cb659812b4aba82359b9cd5676286_G_2, 0, 0, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6);
            float4 _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4;
            float3 _Combine_97b350e15af444549b08b7cccad8507b_RGB_5;
            float2 _Combine_97b350e15af444549b08b7cccad8507b_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_B_3, _Split_7d4cb659812b4aba82359b9cd5676286_A_4, 0, 0, _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4, _Combine_97b350e15af444549b08b7cccad8507b_RGB_5, _Combine_97b350e15af444549b08b7cccad8507b_RG_6);
            float _Remap_7e4aea3511c044c096a39756751a8edf_Out_3;
            Unity_Remap_float(_Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6, _Combine_97b350e15af444549b08b7cccad8507b_RG_6, _Remap_7e4aea3511c044c096a39756751a8edf_Out_3);
            float _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1;
            Unity_Absolute_float(_Remap_7e4aea3511c044c096a39756751a8edf_Out_3, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1);
            float _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3;
            Unity_Smoothstep_float(_Property_053ddb8da804443e8b374d1f1e46439d_Out_0, _Property_049c2369ee52402da7e76747fd5d4b19_Out_0, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1, _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3);
            float _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0 = Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
            float _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0, _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2);
            float2 _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2.xx), _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3);
            float _Property_5e4cf85948674accba829baa1128f457_Out_0 = Vector1_2b90fecba49247d69fea4250dd6f2b05;
            float _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3, _Property_5e4cf85948674accba829baa1128f457_Out_0, _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2);
            float _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0 = Vector1_85705dce160b423095b83fec18834b94;
            float _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2;
            Unity_Multiply_float(_GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2);
            float _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2;
            Unity_Add_float(_Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2, _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2);
            float _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2;
            Unity_Add_float(1, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2);
            float _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2;
            Unity_Divide_float(_Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2, _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2);
            float4 _Lerp_1d146db540d144cea0c82b0d31afe7fb_Out_3;
            Unity_Lerp_float4(_Property_ba0f647605054add9ecb748acfab7189_Out_0, _Property_0f6a99dfadb1482ebb8abc5826059d6d_Out_0, (_Divide_8d035f5a1dd247c991949a2468e485ed_Out_2.xxxx), _Lerp_1d146db540d144cea0c82b0d31afe7fb_Out_3);
            float _Property_db3130cfd93f4e20a2eea366d3e7c3cb_Out_0 = Vector1_e422a47f8df24c3db74aea0d635974ab;
            float _FresnelEffect_f1ecbfd78ca54d9a82c60183643a368d_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_db3130cfd93f4e20a2eea366d3e7c3cb_Out_0, _FresnelEffect_f1ecbfd78ca54d9a82c60183643a368d_Out_3);
            float _Multiply_67c2514ffb7f47e2b62c67ff73747b76_Out_2;
            Unity_Multiply_float(_Divide_8d035f5a1dd247c991949a2468e485ed_Out_2, _FresnelEffect_f1ecbfd78ca54d9a82c60183643a368d_Out_3, _Multiply_67c2514ffb7f47e2b62c67ff73747b76_Out_2);
            float _Property_1e995a1735c045988eba42a23c39c906_Out_0 = Vector1_a692e6f11a4a48ce952d8c7a0c61c1aa;
            float _Multiply_60b7ea1e156f4b5099f325cddb89a068_Out_2;
            Unity_Multiply_float(_Multiply_67c2514ffb7f47e2b62c67ff73747b76_Out_2, _Property_1e995a1735c045988eba42a23c39c906_Out_0, _Multiply_60b7ea1e156f4b5099f325cddb89a068_Out_2);
            float4 _Add_3d1174b8fb2346af8156df38795e2a28_Out_2;
            Unity_Add_float4(_Lerp_1d146db540d144cea0c82b0d31afe7fb_Out_3, (_Multiply_60b7ea1e156f4b5099f325cddb89a068_Out_2.xxxx), _Add_3d1174b8fb2346af8156df38795e2a28_Out_2);
            float _Property_d2746846112f46188c604caf72994dd9_Out_0 = Vector1_2d8f347bfae0495495a1901da88f5503;
            float4 _Multiply_6a7e610df71a42cbbc5238f078bc0fbd_Out_2;
            Unity_Multiply_float(_Add_3d1174b8fb2346af8156df38795e2a28_Out_2, (_Property_d2746846112f46188c604caf72994dd9_Out_0.xxxx), _Multiply_6a7e610df71a42cbbc5238f078bc0fbd_Out_2);
            float _SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1);
            float4 _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0 = IN.ScreenPosition;
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_R_1 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[0];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_G_2 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[1];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_B_3 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[2];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_A_4 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[3];
            float _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2;
            Unity_Subtract_float(_Split_88bd4eaad1bc473bafd9769e43fc6eae_A_4, 1, _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2);
            float _Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2;
            Unity_Subtract_float(_SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1, _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2, _Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2);
            float _Property_eec2c1a9e98a4156b7ae81ef6fd2adfa_Out_0 = Vector1_554b3b77df094a20ae20fb7a09a219e7;
            float _Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2;
            Unity_Divide_float(_Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2, _Property_eec2c1a9e98a4156b7ae81ef6fd2adfa_Out_0, _Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2);
            float _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1;
            Unity_Saturate_float(_Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2, _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1);
            surface.BaseColor = (_Add_3d1174b8fb2346af8156df38795e2a28_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_6a7e610df71a42cbbc5238f078bc0fbd_Out_2.xyz);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_7857debdf41d401bba91a8ee4589797d;
        float Vector1_3e90a01d954242c19dfed08766b90e95;
        float Vector1_7dd17304f68b476ea7aca908377acaa8;
        float Vector1_08428239c85e48588fbdefbbdba657d0;
        float4 Vector4_d7175560f1a3463cb3aa8bf951d8481c;
        float4 Color_6339afdcca124ffdacbdb2d95c288d1f;
        float4 Color_4c92777dd71a44c28f40a8b89797d9cf;
        float Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
        float Vector1_8607474205e846fd9baba5fc496fc1a4;
        float Vector1_e4c7de79ca074dc6acf544fa08058f61;
        float Vector1_2b90fecba49247d69fea4250dd6f2b05;
        float Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
        float Vector1_85705dce160b423095b83fec18834b94;
        float Vector1_2d8f347bfae0495495a1901da88f5503;
        float Vector1_abdcc9bf2c3e4b2784bd5b3cd35ee51c;
        float Vector1_e422a47f8df24c3db74aea0d635974ab;
        float Vector1_a692e6f11a4a48ce952d8c7a0c61c1aa;
        float Vector1_554b3b77df094a20ae20fb7a09a219e7;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2);
            float _Property_854cff9e0336411abc3494adb5949df2_Out_0 = Vector1_abdcc9bf2c3e4b2784bd5b3cd35ee51c;
            float _Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2;
            Unity_Divide_float(_Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2, _Property_854cff9e0336411abc3494adb5949df2_Out_0, _Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2);
            float _Power_b076041ae9da49808786f2e74199f99b_Out_2;
            Unity_Power_float(_Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2, 3, _Power_b076041ae9da49808786f2e74199f99b_Out_2);
            float3 _Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2;
            Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_b076041ae9da49808786f2e74199f99b_Out_2.xxx), _Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2);
            float _Property_053ddb8da804443e8b374d1f1e46439d_Out_0 = Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
            float _Property_049c2369ee52402da7e76747fd5d4b19_Out_0 = Vector1_8607474205e846fd9baba5fc496fc1a4;
            float4 _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0 = Vector4_7857debdf41d401bba91a8ee4589797d;
            float _Split_812593ea1f7b4cd48228a008310391e8_R_1 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[0];
            float _Split_812593ea1f7b4cd48228a008310391e8_G_2 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[1];
            float _Split_812593ea1f7b4cd48228a008310391e8_B_3 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[2];
            float _Split_812593ea1f7b4cd48228a008310391e8_A_4 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[3];
            float3 _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0.xyz), _Split_812593ea1f7b4cd48228a008310391e8_A_4, _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3);
            float _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0 = Vector1_7dd17304f68b476ea7aca908377acaa8;
            float _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0, _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2);
            float2 _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2.xx), _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3);
            float _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0 = Vector1_3e90a01d954242c19dfed08766b90e95;
            float _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2);
            float2 _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3);
            float _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2);
            float _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2;
            Unity_Add_float(_GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2, _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2);
            float _Divide_ced9f1a8c241466e91792e08856155c5_Out_2;
            Unity_Divide_float(_Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2, 2, _Divide_ced9f1a8c241466e91792e08856155c5_Out_2);
            float _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1;
            Unity_Saturate_float(_Divide_ced9f1a8c241466e91792e08856155c5_Out_2, _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1);
            float _Property_def7d18ce006439b83bdf0435d5dae87_Out_0 = Vector1_e4c7de79ca074dc6acf544fa08058f61;
            float _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2;
            Unity_Power_float(_Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1, _Property_def7d18ce006439b83bdf0435d5dae87_Out_0, _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2);
            float4 _Property_acbb4ec64c894666aed93d6c17bab669_Out_0 = Vector4_d7175560f1a3463cb3aa8bf951d8481c;
            float _Split_7d4cb659812b4aba82359b9cd5676286_R_1 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[0];
            float _Split_7d4cb659812b4aba82359b9cd5676286_G_2 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[1];
            float _Split_7d4cb659812b4aba82359b9cd5676286_B_3 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[2];
            float _Split_7d4cb659812b4aba82359b9cd5676286_A_4 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[3];
            float4 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4;
            float3 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5;
            float2 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_R_1, _Split_7d4cb659812b4aba82359b9cd5676286_G_2, 0, 0, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6);
            float4 _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4;
            float3 _Combine_97b350e15af444549b08b7cccad8507b_RGB_5;
            float2 _Combine_97b350e15af444549b08b7cccad8507b_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_B_3, _Split_7d4cb659812b4aba82359b9cd5676286_A_4, 0, 0, _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4, _Combine_97b350e15af444549b08b7cccad8507b_RGB_5, _Combine_97b350e15af444549b08b7cccad8507b_RG_6);
            float _Remap_7e4aea3511c044c096a39756751a8edf_Out_3;
            Unity_Remap_float(_Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6, _Combine_97b350e15af444549b08b7cccad8507b_RG_6, _Remap_7e4aea3511c044c096a39756751a8edf_Out_3);
            float _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1;
            Unity_Absolute_float(_Remap_7e4aea3511c044c096a39756751a8edf_Out_3, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1);
            float _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3;
            Unity_Smoothstep_float(_Property_053ddb8da804443e8b374d1f1e46439d_Out_0, _Property_049c2369ee52402da7e76747fd5d4b19_Out_0, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1, _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3);
            float _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0 = Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
            float _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0, _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2);
            float2 _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2.xx), _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3);
            float _Property_5e4cf85948674accba829baa1128f457_Out_0 = Vector1_2b90fecba49247d69fea4250dd6f2b05;
            float _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3, _Property_5e4cf85948674accba829baa1128f457_Out_0, _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2);
            float _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0 = Vector1_85705dce160b423095b83fec18834b94;
            float _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2;
            Unity_Multiply_float(_GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2);
            float _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2;
            Unity_Add_float(_Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2, _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2);
            float _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2;
            Unity_Add_float(1, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2);
            float _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2;
            Unity_Divide_float(_Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2, _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2);
            float3 _Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_8d035f5a1dd247c991949a2468e485ed_Out_2.xxx), _Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2);
            float _Property_a31cd2828e384b93a347c401039dc22f_Out_0 = Vector1_08428239c85e48588fbdefbbdba657d0;
            float3 _Multiply_a450069c754545c0a818930e08827565_Out_2;
            Unity_Multiply_float(_Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2, (_Property_a31cd2828e384b93a347c401039dc22f_Out_0.xxx), _Multiply_a450069c754545c0a818930e08827565_Out_2);
            float3 _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a450069c754545c0a818930e08827565_Out_2, _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2);
            float3 _Add_d021335a91474d7e933acf61f6e5b302_Out_2;
            Unity_Add_float3(_Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2, _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2, _Add_d021335a91474d7e933acf61f6e5b302_Out_2);
            description.Position = _Add_d021335a91474d7e933acf61f6e5b302_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1);
            float4 _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0 = IN.ScreenPosition;
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_R_1 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[0];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_G_2 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[1];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_B_3 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[2];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_A_4 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[3];
            float _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2;
            Unity_Subtract_float(_Split_88bd4eaad1bc473bafd9769e43fc6eae_A_4, 1, _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2);
            float _Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2;
            Unity_Subtract_float(_SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1, _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2, _Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2);
            float _Property_eec2c1a9e98a4156b7ae81ef6fd2adfa_Out_0 = Vector1_554b3b77df094a20ae20fb7a09a219e7;
            float _Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2;
            Unity_Divide_float(_Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2, _Property_eec2c1a9e98a4156b7ae81ef6fd2adfa_Out_0, _Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2);
            float _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1;
            Unity_Saturate_float(_Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2, _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1);
            surface.Alpha = _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_7857debdf41d401bba91a8ee4589797d;
        float Vector1_3e90a01d954242c19dfed08766b90e95;
        float Vector1_7dd17304f68b476ea7aca908377acaa8;
        float Vector1_08428239c85e48588fbdefbbdba657d0;
        float4 Vector4_d7175560f1a3463cb3aa8bf951d8481c;
        float4 Color_6339afdcca124ffdacbdb2d95c288d1f;
        float4 Color_4c92777dd71a44c28f40a8b89797d9cf;
        float Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
        float Vector1_8607474205e846fd9baba5fc496fc1a4;
        float Vector1_e4c7de79ca074dc6acf544fa08058f61;
        float Vector1_2b90fecba49247d69fea4250dd6f2b05;
        float Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
        float Vector1_85705dce160b423095b83fec18834b94;
        float Vector1_2d8f347bfae0495495a1901da88f5503;
        float Vector1_abdcc9bf2c3e4b2784bd5b3cd35ee51c;
        float Vector1_e422a47f8df24c3db74aea0d635974ab;
        float Vector1_a692e6f11a4a48ce952d8c7a0c61c1aa;
        float Vector1_554b3b77df094a20ae20fb7a09a219e7;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2);
            float _Property_854cff9e0336411abc3494adb5949df2_Out_0 = Vector1_abdcc9bf2c3e4b2784bd5b3cd35ee51c;
            float _Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2;
            Unity_Divide_float(_Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2, _Property_854cff9e0336411abc3494adb5949df2_Out_0, _Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2);
            float _Power_b076041ae9da49808786f2e74199f99b_Out_2;
            Unity_Power_float(_Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2, 3, _Power_b076041ae9da49808786f2e74199f99b_Out_2);
            float3 _Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2;
            Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_b076041ae9da49808786f2e74199f99b_Out_2.xxx), _Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2);
            float _Property_053ddb8da804443e8b374d1f1e46439d_Out_0 = Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
            float _Property_049c2369ee52402da7e76747fd5d4b19_Out_0 = Vector1_8607474205e846fd9baba5fc496fc1a4;
            float4 _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0 = Vector4_7857debdf41d401bba91a8ee4589797d;
            float _Split_812593ea1f7b4cd48228a008310391e8_R_1 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[0];
            float _Split_812593ea1f7b4cd48228a008310391e8_G_2 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[1];
            float _Split_812593ea1f7b4cd48228a008310391e8_B_3 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[2];
            float _Split_812593ea1f7b4cd48228a008310391e8_A_4 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[3];
            float3 _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0.xyz), _Split_812593ea1f7b4cd48228a008310391e8_A_4, _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3);
            float _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0 = Vector1_7dd17304f68b476ea7aca908377acaa8;
            float _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0, _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2);
            float2 _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2.xx), _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3);
            float _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0 = Vector1_3e90a01d954242c19dfed08766b90e95;
            float _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2);
            float2 _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3);
            float _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2);
            float _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2;
            Unity_Add_float(_GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2, _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2);
            float _Divide_ced9f1a8c241466e91792e08856155c5_Out_2;
            Unity_Divide_float(_Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2, 2, _Divide_ced9f1a8c241466e91792e08856155c5_Out_2);
            float _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1;
            Unity_Saturate_float(_Divide_ced9f1a8c241466e91792e08856155c5_Out_2, _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1);
            float _Property_def7d18ce006439b83bdf0435d5dae87_Out_0 = Vector1_e4c7de79ca074dc6acf544fa08058f61;
            float _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2;
            Unity_Power_float(_Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1, _Property_def7d18ce006439b83bdf0435d5dae87_Out_0, _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2);
            float4 _Property_acbb4ec64c894666aed93d6c17bab669_Out_0 = Vector4_d7175560f1a3463cb3aa8bf951d8481c;
            float _Split_7d4cb659812b4aba82359b9cd5676286_R_1 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[0];
            float _Split_7d4cb659812b4aba82359b9cd5676286_G_2 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[1];
            float _Split_7d4cb659812b4aba82359b9cd5676286_B_3 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[2];
            float _Split_7d4cb659812b4aba82359b9cd5676286_A_4 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[3];
            float4 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4;
            float3 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5;
            float2 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_R_1, _Split_7d4cb659812b4aba82359b9cd5676286_G_2, 0, 0, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6);
            float4 _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4;
            float3 _Combine_97b350e15af444549b08b7cccad8507b_RGB_5;
            float2 _Combine_97b350e15af444549b08b7cccad8507b_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_B_3, _Split_7d4cb659812b4aba82359b9cd5676286_A_4, 0, 0, _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4, _Combine_97b350e15af444549b08b7cccad8507b_RGB_5, _Combine_97b350e15af444549b08b7cccad8507b_RG_6);
            float _Remap_7e4aea3511c044c096a39756751a8edf_Out_3;
            Unity_Remap_float(_Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6, _Combine_97b350e15af444549b08b7cccad8507b_RG_6, _Remap_7e4aea3511c044c096a39756751a8edf_Out_3);
            float _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1;
            Unity_Absolute_float(_Remap_7e4aea3511c044c096a39756751a8edf_Out_3, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1);
            float _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3;
            Unity_Smoothstep_float(_Property_053ddb8da804443e8b374d1f1e46439d_Out_0, _Property_049c2369ee52402da7e76747fd5d4b19_Out_0, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1, _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3);
            float _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0 = Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
            float _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0, _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2);
            float2 _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2.xx), _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3);
            float _Property_5e4cf85948674accba829baa1128f457_Out_0 = Vector1_2b90fecba49247d69fea4250dd6f2b05;
            float _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3, _Property_5e4cf85948674accba829baa1128f457_Out_0, _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2);
            float _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0 = Vector1_85705dce160b423095b83fec18834b94;
            float _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2;
            Unity_Multiply_float(_GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2);
            float _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2;
            Unity_Add_float(_Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2, _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2);
            float _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2;
            Unity_Add_float(1, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2);
            float _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2;
            Unity_Divide_float(_Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2, _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2);
            float3 _Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_8d035f5a1dd247c991949a2468e485ed_Out_2.xxx), _Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2);
            float _Property_a31cd2828e384b93a347c401039dc22f_Out_0 = Vector1_08428239c85e48588fbdefbbdba657d0;
            float3 _Multiply_a450069c754545c0a818930e08827565_Out_2;
            Unity_Multiply_float(_Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2, (_Property_a31cd2828e384b93a347c401039dc22f_Out_0.xxx), _Multiply_a450069c754545c0a818930e08827565_Out_2);
            float3 _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a450069c754545c0a818930e08827565_Out_2, _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2);
            float3 _Add_d021335a91474d7e933acf61f6e5b302_Out_2;
            Unity_Add_float3(_Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2, _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2, _Add_d021335a91474d7e933acf61f6e5b302_Out_2);
            description.Position = _Add_d021335a91474d7e933acf61f6e5b302_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1);
            float4 _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0 = IN.ScreenPosition;
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_R_1 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[0];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_G_2 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[1];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_B_3 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[2];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_A_4 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[3];
            float _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2;
            Unity_Subtract_float(_Split_88bd4eaad1bc473bafd9769e43fc6eae_A_4, 1, _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2);
            float _Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2;
            Unity_Subtract_float(_SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1, _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2, _Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2);
            float _Property_eec2c1a9e98a4156b7ae81ef6fd2adfa_Out_0 = Vector1_554b3b77df094a20ae20fb7a09a219e7;
            float _Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2;
            Unity_Divide_float(_Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2, _Property_eec2c1a9e98a4156b7ae81ef6fd2adfa_Out_0, _Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2);
            float _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1;
            Unity_Saturate_float(_Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2, _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1);
            surface.Alpha = _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_7857debdf41d401bba91a8ee4589797d;
        float Vector1_3e90a01d954242c19dfed08766b90e95;
        float Vector1_7dd17304f68b476ea7aca908377acaa8;
        float Vector1_08428239c85e48588fbdefbbdba657d0;
        float4 Vector4_d7175560f1a3463cb3aa8bf951d8481c;
        float4 Color_6339afdcca124ffdacbdb2d95c288d1f;
        float4 Color_4c92777dd71a44c28f40a8b89797d9cf;
        float Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
        float Vector1_8607474205e846fd9baba5fc496fc1a4;
        float Vector1_e4c7de79ca074dc6acf544fa08058f61;
        float Vector1_2b90fecba49247d69fea4250dd6f2b05;
        float Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
        float Vector1_85705dce160b423095b83fec18834b94;
        float Vector1_2d8f347bfae0495495a1901da88f5503;
        float Vector1_abdcc9bf2c3e4b2784bd5b3cd35ee51c;
        float Vector1_e422a47f8df24c3db74aea0d635974ab;
        float Vector1_a692e6f11a4a48ce952d8c7a0c61c1aa;
        float Vector1_554b3b77df094a20ae20fb7a09a219e7;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2);
            float _Property_854cff9e0336411abc3494adb5949df2_Out_0 = Vector1_abdcc9bf2c3e4b2784bd5b3cd35ee51c;
            float _Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2;
            Unity_Divide_float(_Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2, _Property_854cff9e0336411abc3494adb5949df2_Out_0, _Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2);
            float _Power_b076041ae9da49808786f2e74199f99b_Out_2;
            Unity_Power_float(_Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2, 3, _Power_b076041ae9da49808786f2e74199f99b_Out_2);
            float3 _Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2;
            Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_b076041ae9da49808786f2e74199f99b_Out_2.xxx), _Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2);
            float _Property_053ddb8da804443e8b374d1f1e46439d_Out_0 = Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
            float _Property_049c2369ee52402da7e76747fd5d4b19_Out_0 = Vector1_8607474205e846fd9baba5fc496fc1a4;
            float4 _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0 = Vector4_7857debdf41d401bba91a8ee4589797d;
            float _Split_812593ea1f7b4cd48228a008310391e8_R_1 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[0];
            float _Split_812593ea1f7b4cd48228a008310391e8_G_2 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[1];
            float _Split_812593ea1f7b4cd48228a008310391e8_B_3 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[2];
            float _Split_812593ea1f7b4cd48228a008310391e8_A_4 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[3];
            float3 _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0.xyz), _Split_812593ea1f7b4cd48228a008310391e8_A_4, _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3);
            float _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0 = Vector1_7dd17304f68b476ea7aca908377acaa8;
            float _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0, _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2);
            float2 _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2.xx), _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3);
            float _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0 = Vector1_3e90a01d954242c19dfed08766b90e95;
            float _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2);
            float2 _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3);
            float _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2);
            float _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2;
            Unity_Add_float(_GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2, _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2);
            float _Divide_ced9f1a8c241466e91792e08856155c5_Out_2;
            Unity_Divide_float(_Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2, 2, _Divide_ced9f1a8c241466e91792e08856155c5_Out_2);
            float _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1;
            Unity_Saturate_float(_Divide_ced9f1a8c241466e91792e08856155c5_Out_2, _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1);
            float _Property_def7d18ce006439b83bdf0435d5dae87_Out_0 = Vector1_e4c7de79ca074dc6acf544fa08058f61;
            float _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2;
            Unity_Power_float(_Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1, _Property_def7d18ce006439b83bdf0435d5dae87_Out_0, _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2);
            float4 _Property_acbb4ec64c894666aed93d6c17bab669_Out_0 = Vector4_d7175560f1a3463cb3aa8bf951d8481c;
            float _Split_7d4cb659812b4aba82359b9cd5676286_R_1 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[0];
            float _Split_7d4cb659812b4aba82359b9cd5676286_G_2 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[1];
            float _Split_7d4cb659812b4aba82359b9cd5676286_B_3 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[2];
            float _Split_7d4cb659812b4aba82359b9cd5676286_A_4 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[3];
            float4 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4;
            float3 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5;
            float2 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_R_1, _Split_7d4cb659812b4aba82359b9cd5676286_G_2, 0, 0, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6);
            float4 _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4;
            float3 _Combine_97b350e15af444549b08b7cccad8507b_RGB_5;
            float2 _Combine_97b350e15af444549b08b7cccad8507b_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_B_3, _Split_7d4cb659812b4aba82359b9cd5676286_A_4, 0, 0, _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4, _Combine_97b350e15af444549b08b7cccad8507b_RGB_5, _Combine_97b350e15af444549b08b7cccad8507b_RG_6);
            float _Remap_7e4aea3511c044c096a39756751a8edf_Out_3;
            Unity_Remap_float(_Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6, _Combine_97b350e15af444549b08b7cccad8507b_RG_6, _Remap_7e4aea3511c044c096a39756751a8edf_Out_3);
            float _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1;
            Unity_Absolute_float(_Remap_7e4aea3511c044c096a39756751a8edf_Out_3, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1);
            float _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3;
            Unity_Smoothstep_float(_Property_053ddb8da804443e8b374d1f1e46439d_Out_0, _Property_049c2369ee52402da7e76747fd5d4b19_Out_0, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1, _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3);
            float _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0 = Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
            float _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0, _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2);
            float2 _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2.xx), _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3);
            float _Property_5e4cf85948674accba829baa1128f457_Out_0 = Vector1_2b90fecba49247d69fea4250dd6f2b05;
            float _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3, _Property_5e4cf85948674accba829baa1128f457_Out_0, _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2);
            float _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0 = Vector1_85705dce160b423095b83fec18834b94;
            float _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2;
            Unity_Multiply_float(_GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2);
            float _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2;
            Unity_Add_float(_Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2, _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2);
            float _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2;
            Unity_Add_float(1, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2);
            float _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2;
            Unity_Divide_float(_Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2, _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2);
            float3 _Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_8d035f5a1dd247c991949a2468e485ed_Out_2.xxx), _Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2);
            float _Property_a31cd2828e384b93a347c401039dc22f_Out_0 = Vector1_08428239c85e48588fbdefbbdba657d0;
            float3 _Multiply_a450069c754545c0a818930e08827565_Out_2;
            Unity_Multiply_float(_Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2, (_Property_a31cd2828e384b93a347c401039dc22f_Out_0.xxx), _Multiply_a450069c754545c0a818930e08827565_Out_2);
            float3 _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a450069c754545c0a818930e08827565_Out_2, _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2);
            float3 _Add_d021335a91474d7e933acf61f6e5b302_Out_2;
            Unity_Add_float3(_Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2, _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2, _Add_d021335a91474d7e933acf61f6e5b302_Out_2);
            description.Position = _Add_d021335a91474d7e933acf61f6e5b302_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1);
            float4 _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0 = IN.ScreenPosition;
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_R_1 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[0];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_G_2 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[1];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_B_3 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[2];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_A_4 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[3];
            float _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2;
            Unity_Subtract_float(_Split_88bd4eaad1bc473bafd9769e43fc6eae_A_4, 1, _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2);
            float _Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2;
            Unity_Subtract_float(_SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1, _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2, _Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2);
            float _Property_eec2c1a9e98a4156b7ae81ef6fd2adfa_Out_0 = Vector1_554b3b77df094a20ae20fb7a09a219e7;
            float _Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2;
            Unity_Divide_float(_Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2, _Property_eec2c1a9e98a4156b7ae81ef6fd2adfa_Out_0, _Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2);
            float _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1;
            Unity_Saturate_float(_Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2, _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }

            // Render State
            Cull Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_META
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv1 : TEXCOORD1;
            float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceViewDirection;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float3 interp2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.viewDirectionWS = input.interp2.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_7857debdf41d401bba91a8ee4589797d;
        float Vector1_3e90a01d954242c19dfed08766b90e95;
        float Vector1_7dd17304f68b476ea7aca908377acaa8;
        float Vector1_08428239c85e48588fbdefbbdba657d0;
        float4 Vector4_d7175560f1a3463cb3aa8bf951d8481c;
        float4 Color_6339afdcca124ffdacbdb2d95c288d1f;
        float4 Color_4c92777dd71a44c28f40a8b89797d9cf;
        float Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
        float Vector1_8607474205e846fd9baba5fc496fc1a4;
        float Vector1_e4c7de79ca074dc6acf544fa08058f61;
        float Vector1_2b90fecba49247d69fea4250dd6f2b05;
        float Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
        float Vector1_85705dce160b423095b83fec18834b94;
        float Vector1_2d8f347bfae0495495a1901da88f5503;
        float Vector1_abdcc9bf2c3e4b2784bd5b3cd35ee51c;
        float Vector1_e422a47f8df24c3db74aea0d635974ab;
        float Vector1_a692e6f11a4a48ce952d8c7a0c61c1aa;
        float Vector1_554b3b77df094a20ae20fb7a09a219e7;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2);
            float _Property_854cff9e0336411abc3494adb5949df2_Out_0 = Vector1_abdcc9bf2c3e4b2784bd5b3cd35ee51c;
            float _Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2;
            Unity_Divide_float(_Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2, _Property_854cff9e0336411abc3494adb5949df2_Out_0, _Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2);
            float _Power_b076041ae9da49808786f2e74199f99b_Out_2;
            Unity_Power_float(_Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2, 3, _Power_b076041ae9da49808786f2e74199f99b_Out_2);
            float3 _Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2;
            Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_b076041ae9da49808786f2e74199f99b_Out_2.xxx), _Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2);
            float _Property_053ddb8da804443e8b374d1f1e46439d_Out_0 = Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
            float _Property_049c2369ee52402da7e76747fd5d4b19_Out_0 = Vector1_8607474205e846fd9baba5fc496fc1a4;
            float4 _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0 = Vector4_7857debdf41d401bba91a8ee4589797d;
            float _Split_812593ea1f7b4cd48228a008310391e8_R_1 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[0];
            float _Split_812593ea1f7b4cd48228a008310391e8_G_2 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[1];
            float _Split_812593ea1f7b4cd48228a008310391e8_B_3 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[2];
            float _Split_812593ea1f7b4cd48228a008310391e8_A_4 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[3];
            float3 _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0.xyz), _Split_812593ea1f7b4cd48228a008310391e8_A_4, _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3);
            float _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0 = Vector1_7dd17304f68b476ea7aca908377acaa8;
            float _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0, _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2);
            float2 _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2.xx), _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3);
            float _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0 = Vector1_3e90a01d954242c19dfed08766b90e95;
            float _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2);
            float2 _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3);
            float _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2);
            float _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2;
            Unity_Add_float(_GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2, _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2);
            float _Divide_ced9f1a8c241466e91792e08856155c5_Out_2;
            Unity_Divide_float(_Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2, 2, _Divide_ced9f1a8c241466e91792e08856155c5_Out_2);
            float _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1;
            Unity_Saturate_float(_Divide_ced9f1a8c241466e91792e08856155c5_Out_2, _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1);
            float _Property_def7d18ce006439b83bdf0435d5dae87_Out_0 = Vector1_e4c7de79ca074dc6acf544fa08058f61;
            float _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2;
            Unity_Power_float(_Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1, _Property_def7d18ce006439b83bdf0435d5dae87_Out_0, _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2);
            float4 _Property_acbb4ec64c894666aed93d6c17bab669_Out_0 = Vector4_d7175560f1a3463cb3aa8bf951d8481c;
            float _Split_7d4cb659812b4aba82359b9cd5676286_R_1 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[0];
            float _Split_7d4cb659812b4aba82359b9cd5676286_G_2 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[1];
            float _Split_7d4cb659812b4aba82359b9cd5676286_B_3 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[2];
            float _Split_7d4cb659812b4aba82359b9cd5676286_A_4 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[3];
            float4 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4;
            float3 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5;
            float2 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_R_1, _Split_7d4cb659812b4aba82359b9cd5676286_G_2, 0, 0, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6);
            float4 _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4;
            float3 _Combine_97b350e15af444549b08b7cccad8507b_RGB_5;
            float2 _Combine_97b350e15af444549b08b7cccad8507b_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_B_3, _Split_7d4cb659812b4aba82359b9cd5676286_A_4, 0, 0, _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4, _Combine_97b350e15af444549b08b7cccad8507b_RGB_5, _Combine_97b350e15af444549b08b7cccad8507b_RG_6);
            float _Remap_7e4aea3511c044c096a39756751a8edf_Out_3;
            Unity_Remap_float(_Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6, _Combine_97b350e15af444549b08b7cccad8507b_RG_6, _Remap_7e4aea3511c044c096a39756751a8edf_Out_3);
            float _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1;
            Unity_Absolute_float(_Remap_7e4aea3511c044c096a39756751a8edf_Out_3, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1);
            float _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3;
            Unity_Smoothstep_float(_Property_053ddb8da804443e8b374d1f1e46439d_Out_0, _Property_049c2369ee52402da7e76747fd5d4b19_Out_0, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1, _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3);
            float _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0 = Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
            float _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0, _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2);
            float2 _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2.xx), _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3);
            float _Property_5e4cf85948674accba829baa1128f457_Out_0 = Vector1_2b90fecba49247d69fea4250dd6f2b05;
            float _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3, _Property_5e4cf85948674accba829baa1128f457_Out_0, _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2);
            float _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0 = Vector1_85705dce160b423095b83fec18834b94;
            float _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2;
            Unity_Multiply_float(_GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2);
            float _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2;
            Unity_Add_float(_Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2, _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2);
            float _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2;
            Unity_Add_float(1, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2);
            float _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2;
            Unity_Divide_float(_Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2, _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2);
            float3 _Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_8d035f5a1dd247c991949a2468e485ed_Out_2.xxx), _Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2);
            float _Property_a31cd2828e384b93a347c401039dc22f_Out_0 = Vector1_08428239c85e48588fbdefbbdba657d0;
            float3 _Multiply_a450069c754545c0a818930e08827565_Out_2;
            Unity_Multiply_float(_Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2, (_Property_a31cd2828e384b93a347c401039dc22f_Out_0.xxx), _Multiply_a450069c754545c0a818930e08827565_Out_2);
            float3 _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a450069c754545c0a818930e08827565_Out_2, _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2);
            float3 _Add_d021335a91474d7e933acf61f6e5b302_Out_2;
            Unity_Add_float3(_Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2, _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2, _Add_d021335a91474d7e933acf61f6e5b302_Out_2);
            description.Position = _Add_d021335a91474d7e933acf61f6e5b302_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_ba0f647605054add9ecb748acfab7189_Out_0 = Color_6339afdcca124ffdacbdb2d95c288d1f;
            float4 _Property_0f6a99dfadb1482ebb8abc5826059d6d_Out_0 = Color_4c92777dd71a44c28f40a8b89797d9cf;
            float _Property_053ddb8da804443e8b374d1f1e46439d_Out_0 = Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
            float _Property_049c2369ee52402da7e76747fd5d4b19_Out_0 = Vector1_8607474205e846fd9baba5fc496fc1a4;
            float4 _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0 = Vector4_7857debdf41d401bba91a8ee4589797d;
            float _Split_812593ea1f7b4cd48228a008310391e8_R_1 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[0];
            float _Split_812593ea1f7b4cd48228a008310391e8_G_2 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[1];
            float _Split_812593ea1f7b4cd48228a008310391e8_B_3 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[2];
            float _Split_812593ea1f7b4cd48228a008310391e8_A_4 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[3];
            float3 _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0.xyz), _Split_812593ea1f7b4cd48228a008310391e8_A_4, _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3);
            float _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0 = Vector1_7dd17304f68b476ea7aca908377acaa8;
            float _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0, _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2);
            float2 _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2.xx), _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3);
            float _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0 = Vector1_3e90a01d954242c19dfed08766b90e95;
            float _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2);
            float2 _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3);
            float _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2);
            float _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2;
            Unity_Add_float(_GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2, _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2);
            float _Divide_ced9f1a8c241466e91792e08856155c5_Out_2;
            Unity_Divide_float(_Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2, 2, _Divide_ced9f1a8c241466e91792e08856155c5_Out_2);
            float _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1;
            Unity_Saturate_float(_Divide_ced9f1a8c241466e91792e08856155c5_Out_2, _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1);
            float _Property_def7d18ce006439b83bdf0435d5dae87_Out_0 = Vector1_e4c7de79ca074dc6acf544fa08058f61;
            float _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2;
            Unity_Power_float(_Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1, _Property_def7d18ce006439b83bdf0435d5dae87_Out_0, _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2);
            float4 _Property_acbb4ec64c894666aed93d6c17bab669_Out_0 = Vector4_d7175560f1a3463cb3aa8bf951d8481c;
            float _Split_7d4cb659812b4aba82359b9cd5676286_R_1 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[0];
            float _Split_7d4cb659812b4aba82359b9cd5676286_G_2 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[1];
            float _Split_7d4cb659812b4aba82359b9cd5676286_B_3 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[2];
            float _Split_7d4cb659812b4aba82359b9cd5676286_A_4 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[3];
            float4 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4;
            float3 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5;
            float2 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_R_1, _Split_7d4cb659812b4aba82359b9cd5676286_G_2, 0, 0, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6);
            float4 _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4;
            float3 _Combine_97b350e15af444549b08b7cccad8507b_RGB_5;
            float2 _Combine_97b350e15af444549b08b7cccad8507b_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_B_3, _Split_7d4cb659812b4aba82359b9cd5676286_A_4, 0, 0, _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4, _Combine_97b350e15af444549b08b7cccad8507b_RGB_5, _Combine_97b350e15af444549b08b7cccad8507b_RG_6);
            float _Remap_7e4aea3511c044c096a39756751a8edf_Out_3;
            Unity_Remap_float(_Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6, _Combine_97b350e15af444549b08b7cccad8507b_RG_6, _Remap_7e4aea3511c044c096a39756751a8edf_Out_3);
            float _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1;
            Unity_Absolute_float(_Remap_7e4aea3511c044c096a39756751a8edf_Out_3, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1);
            float _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3;
            Unity_Smoothstep_float(_Property_053ddb8da804443e8b374d1f1e46439d_Out_0, _Property_049c2369ee52402da7e76747fd5d4b19_Out_0, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1, _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3);
            float _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0 = Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
            float _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0, _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2);
            float2 _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2.xx), _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3);
            float _Property_5e4cf85948674accba829baa1128f457_Out_0 = Vector1_2b90fecba49247d69fea4250dd6f2b05;
            float _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3, _Property_5e4cf85948674accba829baa1128f457_Out_0, _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2);
            float _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0 = Vector1_85705dce160b423095b83fec18834b94;
            float _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2;
            Unity_Multiply_float(_GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2);
            float _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2;
            Unity_Add_float(_Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2, _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2);
            float _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2;
            Unity_Add_float(1, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2);
            float _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2;
            Unity_Divide_float(_Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2, _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2);
            float4 _Lerp_1d146db540d144cea0c82b0d31afe7fb_Out_3;
            Unity_Lerp_float4(_Property_ba0f647605054add9ecb748acfab7189_Out_0, _Property_0f6a99dfadb1482ebb8abc5826059d6d_Out_0, (_Divide_8d035f5a1dd247c991949a2468e485ed_Out_2.xxxx), _Lerp_1d146db540d144cea0c82b0d31afe7fb_Out_3);
            float _Property_db3130cfd93f4e20a2eea366d3e7c3cb_Out_0 = Vector1_e422a47f8df24c3db74aea0d635974ab;
            float _FresnelEffect_f1ecbfd78ca54d9a82c60183643a368d_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_db3130cfd93f4e20a2eea366d3e7c3cb_Out_0, _FresnelEffect_f1ecbfd78ca54d9a82c60183643a368d_Out_3);
            float _Multiply_67c2514ffb7f47e2b62c67ff73747b76_Out_2;
            Unity_Multiply_float(_Divide_8d035f5a1dd247c991949a2468e485ed_Out_2, _FresnelEffect_f1ecbfd78ca54d9a82c60183643a368d_Out_3, _Multiply_67c2514ffb7f47e2b62c67ff73747b76_Out_2);
            float _Property_1e995a1735c045988eba42a23c39c906_Out_0 = Vector1_a692e6f11a4a48ce952d8c7a0c61c1aa;
            float _Multiply_60b7ea1e156f4b5099f325cddb89a068_Out_2;
            Unity_Multiply_float(_Multiply_67c2514ffb7f47e2b62c67ff73747b76_Out_2, _Property_1e995a1735c045988eba42a23c39c906_Out_0, _Multiply_60b7ea1e156f4b5099f325cddb89a068_Out_2);
            float4 _Add_3d1174b8fb2346af8156df38795e2a28_Out_2;
            Unity_Add_float4(_Lerp_1d146db540d144cea0c82b0d31afe7fb_Out_3, (_Multiply_60b7ea1e156f4b5099f325cddb89a068_Out_2.xxxx), _Add_3d1174b8fb2346af8156df38795e2a28_Out_2);
            float _Property_d2746846112f46188c604caf72994dd9_Out_0 = Vector1_2d8f347bfae0495495a1901da88f5503;
            float4 _Multiply_6a7e610df71a42cbbc5238f078bc0fbd_Out_2;
            Unity_Multiply_float(_Add_3d1174b8fb2346af8156df38795e2a28_Out_2, (_Property_d2746846112f46188c604caf72994dd9_Out_0.xxxx), _Multiply_6a7e610df71a42cbbc5238f078bc0fbd_Out_2);
            float _SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1);
            float4 _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0 = IN.ScreenPosition;
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_R_1 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[0];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_G_2 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[1];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_B_3 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[2];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_A_4 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[3];
            float _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2;
            Unity_Subtract_float(_Split_88bd4eaad1bc473bafd9769e43fc6eae_A_4, 1, _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2);
            float _Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2;
            Unity_Subtract_float(_SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1, _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2, _Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2);
            float _Property_eec2c1a9e98a4156b7ae81ef6fd2adfa_Out_0 = Vector1_554b3b77df094a20ae20fb7a09a219e7;
            float _Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2;
            Unity_Divide_float(_Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2, _Property_eec2c1a9e98a4156b7ae81ef6fd2adfa_Out_0, _Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2);
            float _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1;
            Unity_Saturate_float(_Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2, _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1);
            surface.BaseColor = (_Add_3d1174b8fb2346af8156df38795e2a28_Out_2.xyz);
            surface.Emission = (_Multiply_6a7e610df71a42cbbc5238f078bc0fbd_Out_2.xyz);
            surface.Alpha = _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_2D
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceViewDirection;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float3 interp2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.viewDirectionWS = input.interp2.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_7857debdf41d401bba91a8ee4589797d;
        float Vector1_3e90a01d954242c19dfed08766b90e95;
        float Vector1_7dd17304f68b476ea7aca908377acaa8;
        float Vector1_08428239c85e48588fbdefbbdba657d0;
        float4 Vector4_d7175560f1a3463cb3aa8bf951d8481c;
        float4 Color_6339afdcca124ffdacbdb2d95c288d1f;
        float4 Color_4c92777dd71a44c28f40a8b89797d9cf;
        float Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
        float Vector1_8607474205e846fd9baba5fc496fc1a4;
        float Vector1_e4c7de79ca074dc6acf544fa08058f61;
        float Vector1_2b90fecba49247d69fea4250dd6f2b05;
        float Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
        float Vector1_85705dce160b423095b83fec18834b94;
        float Vector1_2d8f347bfae0495495a1901da88f5503;
        float Vector1_abdcc9bf2c3e4b2784bd5b3cd35ee51c;
        float Vector1_e422a47f8df24c3db74aea0d635974ab;
        float Vector1_a692e6f11a4a48ce952d8c7a0c61c1aa;
        float Vector1_554b3b77df094a20ae20fb7a09a219e7;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2);
            float _Property_854cff9e0336411abc3494adb5949df2_Out_0 = Vector1_abdcc9bf2c3e4b2784bd5b3cd35ee51c;
            float _Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2;
            Unity_Divide_float(_Distance_ce4ffa8428964db696d6904dadb8a59f_Out_2, _Property_854cff9e0336411abc3494adb5949df2_Out_0, _Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2);
            float _Power_b076041ae9da49808786f2e74199f99b_Out_2;
            Unity_Power_float(_Divide_f8e73571cbb84754a7cdfecedc4b528e_Out_2, 3, _Power_b076041ae9da49808786f2e74199f99b_Out_2);
            float3 _Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2;
            Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_b076041ae9da49808786f2e74199f99b_Out_2.xxx), _Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2);
            float _Property_053ddb8da804443e8b374d1f1e46439d_Out_0 = Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
            float _Property_049c2369ee52402da7e76747fd5d4b19_Out_0 = Vector1_8607474205e846fd9baba5fc496fc1a4;
            float4 _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0 = Vector4_7857debdf41d401bba91a8ee4589797d;
            float _Split_812593ea1f7b4cd48228a008310391e8_R_1 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[0];
            float _Split_812593ea1f7b4cd48228a008310391e8_G_2 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[1];
            float _Split_812593ea1f7b4cd48228a008310391e8_B_3 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[2];
            float _Split_812593ea1f7b4cd48228a008310391e8_A_4 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[3];
            float3 _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0.xyz), _Split_812593ea1f7b4cd48228a008310391e8_A_4, _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3);
            float _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0 = Vector1_7dd17304f68b476ea7aca908377acaa8;
            float _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0, _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2);
            float2 _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2.xx), _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3);
            float _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0 = Vector1_3e90a01d954242c19dfed08766b90e95;
            float _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2);
            float2 _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3);
            float _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2);
            float _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2;
            Unity_Add_float(_GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2, _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2);
            float _Divide_ced9f1a8c241466e91792e08856155c5_Out_2;
            Unity_Divide_float(_Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2, 2, _Divide_ced9f1a8c241466e91792e08856155c5_Out_2);
            float _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1;
            Unity_Saturate_float(_Divide_ced9f1a8c241466e91792e08856155c5_Out_2, _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1);
            float _Property_def7d18ce006439b83bdf0435d5dae87_Out_0 = Vector1_e4c7de79ca074dc6acf544fa08058f61;
            float _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2;
            Unity_Power_float(_Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1, _Property_def7d18ce006439b83bdf0435d5dae87_Out_0, _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2);
            float4 _Property_acbb4ec64c894666aed93d6c17bab669_Out_0 = Vector4_d7175560f1a3463cb3aa8bf951d8481c;
            float _Split_7d4cb659812b4aba82359b9cd5676286_R_1 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[0];
            float _Split_7d4cb659812b4aba82359b9cd5676286_G_2 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[1];
            float _Split_7d4cb659812b4aba82359b9cd5676286_B_3 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[2];
            float _Split_7d4cb659812b4aba82359b9cd5676286_A_4 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[3];
            float4 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4;
            float3 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5;
            float2 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_R_1, _Split_7d4cb659812b4aba82359b9cd5676286_G_2, 0, 0, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6);
            float4 _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4;
            float3 _Combine_97b350e15af444549b08b7cccad8507b_RGB_5;
            float2 _Combine_97b350e15af444549b08b7cccad8507b_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_B_3, _Split_7d4cb659812b4aba82359b9cd5676286_A_4, 0, 0, _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4, _Combine_97b350e15af444549b08b7cccad8507b_RGB_5, _Combine_97b350e15af444549b08b7cccad8507b_RG_6);
            float _Remap_7e4aea3511c044c096a39756751a8edf_Out_3;
            Unity_Remap_float(_Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6, _Combine_97b350e15af444549b08b7cccad8507b_RG_6, _Remap_7e4aea3511c044c096a39756751a8edf_Out_3);
            float _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1;
            Unity_Absolute_float(_Remap_7e4aea3511c044c096a39756751a8edf_Out_3, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1);
            float _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3;
            Unity_Smoothstep_float(_Property_053ddb8da804443e8b374d1f1e46439d_Out_0, _Property_049c2369ee52402da7e76747fd5d4b19_Out_0, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1, _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3);
            float _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0 = Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
            float _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0, _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2);
            float2 _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2.xx), _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3);
            float _Property_5e4cf85948674accba829baa1128f457_Out_0 = Vector1_2b90fecba49247d69fea4250dd6f2b05;
            float _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3, _Property_5e4cf85948674accba829baa1128f457_Out_0, _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2);
            float _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0 = Vector1_85705dce160b423095b83fec18834b94;
            float _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2;
            Unity_Multiply_float(_GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2);
            float _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2;
            Unity_Add_float(_Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2, _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2);
            float _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2;
            Unity_Add_float(1, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2);
            float _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2;
            Unity_Divide_float(_Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2, _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2);
            float3 _Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_8d035f5a1dd247c991949a2468e485ed_Out_2.xxx), _Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2);
            float _Property_a31cd2828e384b93a347c401039dc22f_Out_0 = Vector1_08428239c85e48588fbdefbbdba657d0;
            float3 _Multiply_a450069c754545c0a818930e08827565_Out_2;
            Unity_Multiply_float(_Multiply_d6e6552f1e9f4046847d1797f5fabb42_Out_2, (_Property_a31cd2828e384b93a347c401039dc22f_Out_0.xxx), _Multiply_a450069c754545c0a818930e08827565_Out_2);
            float3 _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a450069c754545c0a818930e08827565_Out_2, _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2);
            float3 _Add_d021335a91474d7e933acf61f6e5b302_Out_2;
            Unity_Add_float3(_Multiply_aa63c20fc4854dda848c5e598d08e996_Out_2, _Add_f939f0fdba5443cb8b1ae219f7a05923_Out_2, _Add_d021335a91474d7e933acf61f6e5b302_Out_2);
            description.Position = _Add_d021335a91474d7e933acf61f6e5b302_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_ba0f647605054add9ecb748acfab7189_Out_0 = Color_6339afdcca124ffdacbdb2d95c288d1f;
            float4 _Property_0f6a99dfadb1482ebb8abc5826059d6d_Out_0 = Color_4c92777dd71a44c28f40a8b89797d9cf;
            float _Property_053ddb8da804443e8b374d1f1e46439d_Out_0 = Vector1_5abfb00a4eb94e0dabe8c0e0a3d3ec5f;
            float _Property_049c2369ee52402da7e76747fd5d4b19_Out_0 = Vector1_8607474205e846fd9baba5fc496fc1a4;
            float4 _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0 = Vector4_7857debdf41d401bba91a8ee4589797d;
            float _Split_812593ea1f7b4cd48228a008310391e8_R_1 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[0];
            float _Split_812593ea1f7b4cd48228a008310391e8_G_2 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[1];
            float _Split_812593ea1f7b4cd48228a008310391e8_B_3 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[2];
            float _Split_812593ea1f7b4cd48228a008310391e8_A_4 = _Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0[3];
            float3 _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_3c64b23d8ac743369f94c9fb430e9aa9_Out_0.xyz), _Split_812593ea1f7b4cd48228a008310391e8_A_4, _RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3);
            float _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0 = Vector1_7dd17304f68b476ea7aca908377acaa8;
            float _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_217ac260fc974a9b9a26a5d6c947658c_Out_0, _Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2);
            float2 _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_fa7d1a1666174f6bb35caf25858cf544_Out_2.xx), _TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3);
            float _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0 = Vector1_3e90a01d954242c19dfed08766b90e95;
            float _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_b254c2a9384f44bb8609ec1dc9fb39f2_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2);
            float2 _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3);
            float _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_43e56abf96dc452fafa5f74b753f9ea3_Out_3, _Property_f929aed9df8846d2acb08d0e3d2b6829_Out_0, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2);
            float _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2;
            Unity_Add_float(_GradientNoise_b66d8a399dca4b1db328be6a641a62e5_Out_2, _GradientNoise_62415a4356c14f34a19ec855c421dfca_Out_2, _Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2);
            float _Divide_ced9f1a8c241466e91792e08856155c5_Out_2;
            Unity_Divide_float(_Add_d6978e1fd9d347c5a86a7aa0cb2f47c6_Out_2, 2, _Divide_ced9f1a8c241466e91792e08856155c5_Out_2);
            float _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1;
            Unity_Saturate_float(_Divide_ced9f1a8c241466e91792e08856155c5_Out_2, _Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1);
            float _Property_def7d18ce006439b83bdf0435d5dae87_Out_0 = Vector1_e4c7de79ca074dc6acf544fa08058f61;
            float _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2;
            Unity_Power_float(_Saturate_0ee5b90bc57f4fdb8746bafc31653d20_Out_1, _Property_def7d18ce006439b83bdf0435d5dae87_Out_0, _Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2);
            float4 _Property_acbb4ec64c894666aed93d6c17bab669_Out_0 = Vector4_d7175560f1a3463cb3aa8bf951d8481c;
            float _Split_7d4cb659812b4aba82359b9cd5676286_R_1 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[0];
            float _Split_7d4cb659812b4aba82359b9cd5676286_G_2 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[1];
            float _Split_7d4cb659812b4aba82359b9cd5676286_B_3 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[2];
            float _Split_7d4cb659812b4aba82359b9cd5676286_A_4 = _Property_acbb4ec64c894666aed93d6c17bab669_Out_0[3];
            float4 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4;
            float3 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5;
            float2 _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_R_1, _Split_7d4cb659812b4aba82359b9cd5676286_G_2, 0, 0, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGBA_4, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RGB_5, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6);
            float4 _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4;
            float3 _Combine_97b350e15af444549b08b7cccad8507b_RGB_5;
            float2 _Combine_97b350e15af444549b08b7cccad8507b_RG_6;
            Unity_Combine_float(_Split_7d4cb659812b4aba82359b9cd5676286_B_3, _Split_7d4cb659812b4aba82359b9cd5676286_A_4, 0, 0, _Combine_97b350e15af444549b08b7cccad8507b_RGBA_4, _Combine_97b350e15af444549b08b7cccad8507b_RGB_5, _Combine_97b350e15af444549b08b7cccad8507b_RG_6);
            float _Remap_7e4aea3511c044c096a39756751a8edf_Out_3;
            Unity_Remap_float(_Power_c8537d143aae4cb9ab11cadb96ad9e2b_Out_2, _Combine_3c4c888221c34f9b87d33f7ed5fc1c65_RG_6, _Combine_97b350e15af444549b08b7cccad8507b_RG_6, _Remap_7e4aea3511c044c096a39756751a8edf_Out_3);
            float _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1;
            Unity_Absolute_float(_Remap_7e4aea3511c044c096a39756751a8edf_Out_3, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1);
            float _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3;
            Unity_Smoothstep_float(_Property_053ddb8da804443e8b374d1f1e46439d_Out_0, _Property_049c2369ee52402da7e76747fd5d4b19_Out_0, _Absolute_2e77f46f9ac5419e8e1dda72956407c5_Out_1, _Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3);
            float _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0 = Vector1_df25efdeef3c49a3b8b6dc75dafa5f0b;
            float _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_b87f9548b3924d1d9fe0877bae2d5bdd_Out_0, _Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2);
            float2 _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_899a83a5f48443ec901e395fb1c3a6ec_Out_3.xy), float2 (1, 1), (_Multiply_c7c488cfac3e4227a56948f5d9f2de5b_Out_2.xx), _TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3);
            float _Property_5e4cf85948674accba829baa1128f457_Out_0 = Vector1_2b90fecba49247d69fea4250dd6f2b05;
            float _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_a854b15e9c024098862268d1f1a87063_Out_3, _Property_5e4cf85948674accba829baa1128f457_Out_0, _GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2);
            float _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0 = Vector1_85705dce160b423095b83fec18834b94;
            float _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2;
            Unity_Multiply_float(_GradientNoise_439a96d4bfad426683dd2fa41fe7b4a9_Out_2, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2);
            float _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2;
            Unity_Add_float(_Smoothstep_d5bfbc4e045f47a58ae0f03282052b28_Out_3, _Multiply_b860e995980c43fa9046b392e3c11bb5_Out_2, _Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2);
            float _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2;
            Unity_Add_float(1, _Property_95b336adc9db4ab7bdf2b98c5c9eae60_Out_0, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2);
            float _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2;
            Unity_Divide_float(_Add_f4ff2059482a4a84b7c575bf5b40799d_Out_2, _Add_6d72add27d0e4e2bb0b71190f0a0699a_Out_2, _Divide_8d035f5a1dd247c991949a2468e485ed_Out_2);
            float4 _Lerp_1d146db540d144cea0c82b0d31afe7fb_Out_3;
            Unity_Lerp_float4(_Property_ba0f647605054add9ecb748acfab7189_Out_0, _Property_0f6a99dfadb1482ebb8abc5826059d6d_Out_0, (_Divide_8d035f5a1dd247c991949a2468e485ed_Out_2.xxxx), _Lerp_1d146db540d144cea0c82b0d31afe7fb_Out_3);
            float _Property_db3130cfd93f4e20a2eea366d3e7c3cb_Out_0 = Vector1_e422a47f8df24c3db74aea0d635974ab;
            float _FresnelEffect_f1ecbfd78ca54d9a82c60183643a368d_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_db3130cfd93f4e20a2eea366d3e7c3cb_Out_0, _FresnelEffect_f1ecbfd78ca54d9a82c60183643a368d_Out_3);
            float _Multiply_67c2514ffb7f47e2b62c67ff73747b76_Out_2;
            Unity_Multiply_float(_Divide_8d035f5a1dd247c991949a2468e485ed_Out_2, _FresnelEffect_f1ecbfd78ca54d9a82c60183643a368d_Out_3, _Multiply_67c2514ffb7f47e2b62c67ff73747b76_Out_2);
            float _Property_1e995a1735c045988eba42a23c39c906_Out_0 = Vector1_a692e6f11a4a48ce952d8c7a0c61c1aa;
            float _Multiply_60b7ea1e156f4b5099f325cddb89a068_Out_2;
            Unity_Multiply_float(_Multiply_67c2514ffb7f47e2b62c67ff73747b76_Out_2, _Property_1e995a1735c045988eba42a23c39c906_Out_0, _Multiply_60b7ea1e156f4b5099f325cddb89a068_Out_2);
            float4 _Add_3d1174b8fb2346af8156df38795e2a28_Out_2;
            Unity_Add_float4(_Lerp_1d146db540d144cea0c82b0d31afe7fb_Out_3, (_Multiply_60b7ea1e156f4b5099f325cddb89a068_Out_2.xxxx), _Add_3d1174b8fb2346af8156df38795e2a28_Out_2);
            float _SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1);
            float4 _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0 = IN.ScreenPosition;
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_R_1 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[0];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_G_2 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[1];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_B_3 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[2];
            float _Split_88bd4eaad1bc473bafd9769e43fc6eae_A_4 = _ScreenPosition_7e9bb2a7ff9f47e1b3f6ea6ba805de18_Out_0[3];
            float _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2;
            Unity_Subtract_float(_Split_88bd4eaad1bc473bafd9769e43fc6eae_A_4, 1, _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2);
            float _Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2;
            Unity_Subtract_float(_SceneDepth_e668982b8a954824bd30f57b412c7deb_Out_1, _Subtract_039e1e3d9b6044e391959e4e8849db68_Out_2, _Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2);
            float _Property_eec2c1a9e98a4156b7ae81ef6fd2adfa_Out_0 = Vector1_554b3b77df094a20ae20fb7a09a219e7;
            float _Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2;
            Unity_Divide_float(_Subtract_4b69929b0c6d4b708a3b347036ac8970_Out_2, _Property_eec2c1a9e98a4156b7ae81ef6fd2adfa_Out_0, _Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2);
            float _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1;
            Unity_Saturate_float(_Divide_fd7cfdf8863743e69cf20026a0bb8173_Out_2, _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1);
            surface.BaseColor = (_Add_3d1174b8fb2346af8156df38795e2a28_Out_2.xyz);
            surface.Alpha = _Saturate_43eb1ad3f3b743aa86d96b04d165a793_Out_1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

            ENDHLSL
        }
    }
    CustomEditor "ShaderGraph.PBRMasterGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}