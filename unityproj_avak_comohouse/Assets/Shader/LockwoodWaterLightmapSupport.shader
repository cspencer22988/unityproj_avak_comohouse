Shader "Lockwood/WaterLightmapSupport" {
	Properties {
		_BumpMap ("Normals ", 2D) = "bump" {}
		_DistortParams ("Distortions (Bump waves, Reflection, Fresnel power, Fresnel bias)", Vector) = (1,1,2,1.15)
		_BumpTiling ("Bump Tiling", Vector) = (1,1,-2,3)
		_BumpDirection ("Bump Direction & Speed", Vector) = (1,1,-1,1)
		_FresnelScale ("FresnelScale", Range(0.15, 4)) = 0.75
		_BaseColor ("Base color", Vector) = (0.54,0.95,0.99,0.5)
		_ReflectionColor ("Reflection color", Vector) = (0.54,0.95,0.99,0.5)
		_SpecularColor ("Specular color", Vector) = (0.72,0.72,0.72,1)
		_FadeColor ("Fade color", Vector) = (0.72,0.72,0.72,1)
		_WorldLightDir ("Specular light direction", Vector) = (0,0.1,-0.5,0)
		_Shininess ("Shininess", Range(2, 500)) = 200
		_LightmapSpec ("Lightmap Spec threshold", Range(0, 3)) = 1.6
	}
	SubShader {
		Tags { "QUEUE" = "Geometry" "RenderType" = "Opaque" }
		Pass {
			Tags { "QUEUE" = "Geometry" "RenderType" = "Opaque" }
			ColorMask RGB -1
			Cull Off
			GpuProgramID 42629
			Program "vp" {
				SubProgram "gles hw_tier00 " {
					"!!GLES
					#version 100
					
					#ifdef VERTEX
					attribute vec4 _glesVertex;
					attribute vec4 _glesMultiTexCoord1;
					uniform highp vec4 _Time;
					uniform highp vec3 _WorldSpaceCameraPos;
					uniform highp mat4 unity_ObjectToWorld;
					uniform highp mat4 unity_MatrixVP;
					uniform highp vec4 unity_LightmapST;
					uniform highp vec4 _BumpTiling;
					uniform highp vec4 _BumpDirection;
					varying highp vec4 xlv_TEXCOORD0;
					varying highp vec4 xlv_TEXCOORD1;
					varying highp vec2 xlv_TEXCOORD2;
					void main ()
					{
					  mediump vec3 worldSpaceVertex_1;
					  highp vec4 tmpvar_2;
					  highp vec3 tmpvar_3;
					  tmpvar_3 = (unity_ObjectToWorld * _glesVertex).xyz;
					  worldSpaceVertex_1 = tmpvar_3;
					  tmpvar_2.xyz = (worldSpaceVertex_1 - _WorldSpaceCameraPos);
					  highp vec4 tmpvar_4;
					  tmpvar_4.w = 1.0;
					  tmpvar_4.xyz = _glesVertex.xyz;
					  gl_Position = (unity_MatrixVP * (unity_ObjectToWorld * tmpvar_4));
					  xlv_TEXCOORD0 = tmpvar_2;
					  xlv_TEXCOORD1 = ((worldSpaceVertex_1.xzxz + (_Time.xxxx * _BumpDirection)) * _BumpTiling);
					  xlv_TEXCOORD2 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
					}
					
					
					#endif
					#ifdef FRAGMENT
					uniform mediump sampler2D unity_Lightmap;
					uniform mediump vec4 unity_Lightmap_HDR;
					uniform sampler2D _BumpMap;
					uniform highp vec4 _SpecularColor;
					uniform highp vec4 _BaseColor;
					uniform highp vec4 _ReflectionColor;
					uniform highp float _Shininess;
					uniform highp vec4 _WorldLightDir;
					uniform highp float _LightmapSpec;
					uniform highp vec4 _DistortParams;
					uniform highp float _FresnelScale;
					varying highp vec4 xlv_TEXCOORD0;
					varying highp vec4 xlv_TEXCOORD1;
					varying highp vec2 xlv_TEXCOORD2;
					void main ()
					{
					  mediump vec4 baseColor_1;
					  mediump vec3 viewVector_2;
					  mediump vec3 worldNormal_3;
					  mediump vec3 bump_4;
					  lowp vec3 tmpvar_5;
					  tmpvar_5 = (((texture2D (_BumpMap, xlv_TEXCOORD1.xy).xyz * 2.0) - 1.0) + ((texture2D (_BumpMap, xlv_TEXCOORD1.zw).xyz * 2.0) - 1.0));
					  bump_4 = tmpvar_5;
					  highp vec3 tmpvar_6;
					  tmpvar_6 = (vec3(0.0, 1.0, 0.0) + ((bump_4.xxy * _DistortParams.x) * vec3(1.0, 0.0, 1.0)));
					  worldNormal_3 = tmpvar_6;
					  mediump vec3 tmpvar_7;
					  tmpvar_7 = normalize(worldNormal_3);
					  worldNormal_3 = tmpvar_7;
					  highp vec3 tmpvar_8;
					  tmpvar_8 = normalize(xlv_TEXCOORD0.xyz);
					  viewVector_2 = tmpvar_8;
					  highp float tmpvar_9;
					  tmpvar_9 = max (0.0, pow (dot (tmpvar_7, 
					    -(normalize((_WorldLightDir.xyz + viewVector_2)))
					  ), _Shininess));
					  mediump vec3 x_10;
					  x_10 = -(viewVector_2);
					  mediump float tmpvar_11;
					  highp float tmpvar_12;
					  tmpvar_12 = clamp ((1.0 - max (
					    dot (x_10, (tmpvar_7 * _FresnelScale))
					  , 0.0)), 0.0, 1.0);
					  tmpvar_11 = tmpvar_12;
					  mediump float tmpvar_13;
					  highp float tmpvar_14;
					  tmpvar_14 = clamp ((_DistortParams.w + (
					    ((1.0 - _DistortParams.w) * pow (tmpvar_11, _DistortParams.z))
					   * 2.0)), 0.0, 1.0);
					  tmpvar_13 = tmpvar_14;
					  baseColor_1 = _BaseColor;
					  mediump vec4 tmpvar_15;
					  tmpvar_15 = texture2D (unity_Lightmap, xlv_TEXCOORD2);
					  lowp vec4 color_16;
					  color_16 = tmpvar_15;
					  mediump vec3 tmpvar_17;
					  tmpvar_17 = (unity_Lightmap_HDR.x * color_16.xyz);
					  mediump float tmpvar_18;
					  tmpvar_18 = sqrt(dot (tmpvar_17, tmpvar_17));
					  mediump float tmpvar_19;
					  highp float tmpvar_20;
					  tmpvar_20 = clamp ((tmpvar_18 - _LightmapSpec), 0.0, 1.0);
					  tmpvar_19 = tmpvar_20;
					  baseColor_1.xyz = (baseColor_1.xyz * tmpvar_17);
					  baseColor_1.xyz = (baseColor_1.xyz + ((tmpvar_9 * _SpecularColor.xyz) * tmpvar_19));
					  highp vec4 tmpvar_21;
					  tmpvar_21 = mix (baseColor_1, _ReflectionColor, vec4(tmpvar_13));
					  baseColor_1.xyz = tmpvar_21.xyz;
					  baseColor_1.w = 1.0;
					  gl_FragData[0] = baseColor_1;
					}
					
					
					#endif"
				}
				SubProgram "gles hw_tier01 " {
					"!!GLES
					#version 100
					
					#ifdef VERTEX
					attribute vec4 _glesVertex;
					attribute vec4 _glesMultiTexCoord1;
					uniform highp vec4 _Time;
					uniform highp vec3 _WorldSpaceCameraPos;
					uniform highp mat4 unity_ObjectToWorld;
					uniform highp mat4 unity_MatrixVP;
					uniform highp vec4 unity_LightmapST;
					uniform highp vec4 _BumpTiling;
					uniform highp vec4 _BumpDirection;
					varying highp vec4 xlv_TEXCOORD0;
					varying highp vec4 xlv_TEXCOORD1;
					varying highp vec2 xlv_TEXCOORD2;
					void main ()
					{
					  mediump vec3 worldSpaceVertex_1;
					  highp vec4 tmpvar_2;
					  highp vec3 tmpvar_3;
					  tmpvar_3 = (unity_ObjectToWorld * _glesVertex).xyz;
					  worldSpaceVertex_1 = tmpvar_3;
					  tmpvar_2.xyz = (worldSpaceVertex_1 - _WorldSpaceCameraPos);
					  highp vec4 tmpvar_4;
					  tmpvar_4.w = 1.0;
					  tmpvar_4.xyz = _glesVertex.xyz;
					  gl_Position = (unity_MatrixVP * (unity_ObjectToWorld * tmpvar_4));
					  xlv_TEXCOORD0 = tmpvar_2;
					  xlv_TEXCOORD1 = ((worldSpaceVertex_1.xzxz + (_Time.xxxx * _BumpDirection)) * _BumpTiling);
					  xlv_TEXCOORD2 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
					}
					
					
					#endif
					#ifdef FRAGMENT
					uniform mediump sampler2D unity_Lightmap;
					uniform mediump vec4 unity_Lightmap_HDR;
					uniform sampler2D _BumpMap;
					uniform highp vec4 _SpecularColor;
					uniform highp vec4 _BaseColor;
					uniform highp vec4 _ReflectionColor;
					uniform highp float _Shininess;
					uniform highp vec4 _WorldLightDir;
					uniform highp float _LightmapSpec;
					uniform highp vec4 _DistortParams;
					uniform highp float _FresnelScale;
					varying highp vec4 xlv_TEXCOORD0;
					varying highp vec4 xlv_TEXCOORD1;
					varying highp vec2 xlv_TEXCOORD2;
					void main ()
					{
					  mediump vec4 baseColor_1;
					  mediump vec3 viewVector_2;
					  mediump vec3 worldNormal_3;
					  mediump vec3 bump_4;
					  lowp vec3 tmpvar_5;
					  tmpvar_5 = (((texture2D (_BumpMap, xlv_TEXCOORD1.xy).xyz * 2.0) - 1.0) + ((texture2D (_BumpMap, xlv_TEXCOORD1.zw).xyz * 2.0) - 1.0));
					  bump_4 = tmpvar_5;
					  highp vec3 tmpvar_6;
					  tmpvar_6 = (vec3(0.0, 1.0, 0.0) + ((bump_4.xxy * _DistortParams.x) * vec3(1.0, 0.0, 1.0)));
					  worldNormal_3 = tmpvar_6;
					  mediump vec3 tmpvar_7;
					  tmpvar_7 = normalize(worldNormal_3);
					  worldNormal_3 = tmpvar_7;
					  highp vec3 tmpvar_8;
					  tmpvar_8 = normalize(xlv_TEXCOORD0.xyz);
					  viewVector_2 = tmpvar_8;
					  highp float tmpvar_9;
					  tmpvar_9 = max (0.0, pow (dot (tmpvar_7, 
					    -(normalize((_WorldLightDir.xyz + viewVector_2)))
					  ), _Shininess));
					  mediump vec3 x_10;
					  x_10 = -(viewVector_2);
					  mediump float tmpvar_11;
					  highp float tmpvar_12;
					  tmpvar_12 = clamp ((1.0 - max (
					    dot (x_10, (tmpvar_7 * _FresnelScale))
					  , 0.0)), 0.0, 1.0);
					  tmpvar_11 = tmpvar_12;
					  mediump float tmpvar_13;
					  highp float tmpvar_14;
					  tmpvar_14 = clamp ((_DistortParams.w + (
					    ((1.0 - _DistortParams.w) * pow (tmpvar_11, _DistortParams.z))
					   * 2.0)), 0.0, 1.0);
					  tmpvar_13 = tmpvar_14;
					  baseColor_1 = _BaseColor;
					  mediump vec4 tmpvar_15;
					  tmpvar_15 = texture2D (unity_Lightmap, xlv_TEXCOORD2);
					  lowp vec4 color_16;
					  color_16 = tmpvar_15;
					  mediump vec3 tmpvar_17;
					  tmpvar_17 = (unity_Lightmap_HDR.x * color_16.xyz);
					  mediump float tmpvar_18;
					  tmpvar_18 = sqrt(dot (tmpvar_17, tmpvar_17));
					  mediump float tmpvar_19;
					  highp float tmpvar_20;
					  tmpvar_20 = clamp ((tmpvar_18 - _LightmapSpec), 0.0, 1.0);
					  tmpvar_19 = tmpvar_20;
					  baseColor_1.xyz = (baseColor_1.xyz * tmpvar_17);
					  baseColor_1.xyz = (baseColor_1.xyz + ((tmpvar_9 * _SpecularColor.xyz) * tmpvar_19));
					  highp vec4 tmpvar_21;
					  tmpvar_21 = mix (baseColor_1, _ReflectionColor, vec4(tmpvar_13));
					  baseColor_1.xyz = tmpvar_21.xyz;
					  baseColor_1.w = 1.0;
					  gl_FragData[0] = baseColor_1;
					}
					
					
					#endif"
				}
				SubProgram "gles hw_tier02 " {
					"!!GLES
					#version 100
					
					#ifdef VERTEX
					attribute vec4 _glesVertex;
					attribute vec4 _glesMultiTexCoord1;
					uniform highp vec4 _Time;
					uniform highp vec3 _WorldSpaceCameraPos;
					uniform highp mat4 unity_ObjectToWorld;
					uniform highp mat4 unity_MatrixVP;
					uniform highp vec4 unity_LightmapST;
					uniform highp vec4 _BumpTiling;
					uniform highp vec4 _BumpDirection;
					varying highp vec4 xlv_TEXCOORD0;
					varying highp vec4 xlv_TEXCOORD1;
					varying highp vec2 xlv_TEXCOORD2;
					void main ()
					{
					  mediump vec3 worldSpaceVertex_1;
					  highp vec4 tmpvar_2;
					  highp vec3 tmpvar_3;
					  tmpvar_3 = (unity_ObjectToWorld * _glesVertex).xyz;
					  worldSpaceVertex_1 = tmpvar_3;
					  tmpvar_2.xyz = (worldSpaceVertex_1 - _WorldSpaceCameraPos);
					  highp vec4 tmpvar_4;
					  tmpvar_4.w = 1.0;
					  tmpvar_4.xyz = _glesVertex.xyz;
					  gl_Position = (unity_MatrixVP * (unity_ObjectToWorld * tmpvar_4));
					  xlv_TEXCOORD0 = tmpvar_2;
					  xlv_TEXCOORD1 = ((worldSpaceVertex_1.xzxz + (_Time.xxxx * _BumpDirection)) * _BumpTiling);
					  xlv_TEXCOORD2 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
					}
					
					
					#endif
					#ifdef FRAGMENT
					uniform mediump sampler2D unity_Lightmap;
					uniform mediump vec4 unity_Lightmap_HDR;
					uniform sampler2D _BumpMap;
					uniform highp vec4 _SpecularColor;
					uniform highp vec4 _BaseColor;
					uniform highp vec4 _ReflectionColor;
					uniform highp float _Shininess;
					uniform highp vec4 _WorldLightDir;
					uniform highp float _LightmapSpec;
					uniform highp vec4 _DistortParams;
					uniform highp float _FresnelScale;
					varying highp vec4 xlv_TEXCOORD0;
					varying highp vec4 xlv_TEXCOORD1;
					varying highp vec2 xlv_TEXCOORD2;
					void main ()
					{
					  mediump vec4 baseColor_1;
					  mediump vec3 viewVector_2;
					  mediump vec3 worldNormal_3;
					  mediump vec3 bump_4;
					  lowp vec3 tmpvar_5;
					  tmpvar_5 = (((texture2D (_BumpMap, xlv_TEXCOORD1.xy).xyz * 2.0) - 1.0) + ((texture2D (_BumpMap, xlv_TEXCOORD1.zw).xyz * 2.0) - 1.0));
					  bump_4 = tmpvar_5;
					  highp vec3 tmpvar_6;
					  tmpvar_6 = (vec3(0.0, 1.0, 0.0) + ((bump_4.xxy * _DistortParams.x) * vec3(1.0, 0.0, 1.0)));
					  worldNormal_3 = tmpvar_6;
					  mediump vec3 tmpvar_7;
					  tmpvar_7 = normalize(worldNormal_3);
					  worldNormal_3 = tmpvar_7;
					  highp vec3 tmpvar_8;
					  tmpvar_8 = normalize(xlv_TEXCOORD0.xyz);
					  viewVector_2 = tmpvar_8;
					  highp float tmpvar_9;
					  tmpvar_9 = max (0.0, pow (dot (tmpvar_7, 
					    -(normalize((_WorldLightDir.xyz + viewVector_2)))
					  ), _Shininess));
					  mediump vec3 x_10;
					  x_10 = -(viewVector_2);
					  mediump float tmpvar_11;
					  highp float tmpvar_12;
					  tmpvar_12 = clamp ((1.0 - max (
					    dot (x_10, (tmpvar_7 * _FresnelScale))
					  , 0.0)), 0.0, 1.0);
					  tmpvar_11 = tmpvar_12;
					  mediump float tmpvar_13;
					  highp float tmpvar_14;
					  tmpvar_14 = clamp ((_DistortParams.w + (
					    ((1.0 - _DistortParams.w) * pow (tmpvar_11, _DistortParams.z))
					   * 2.0)), 0.0, 1.0);
					  tmpvar_13 = tmpvar_14;
					  baseColor_1 = _BaseColor;
					  mediump vec4 tmpvar_15;
					  tmpvar_15 = texture2D (unity_Lightmap, xlv_TEXCOORD2);
					  lowp vec4 color_16;
					  color_16 = tmpvar_15;
					  mediump vec3 tmpvar_17;
					  tmpvar_17 = (unity_Lightmap_HDR.x * color_16.xyz);
					  mediump float tmpvar_18;
					  tmpvar_18 = sqrt(dot (tmpvar_17, tmpvar_17));
					  mediump float tmpvar_19;
					  highp float tmpvar_20;
					  tmpvar_20 = clamp ((tmpvar_18 - _LightmapSpec), 0.0, 1.0);
					  tmpvar_19 = tmpvar_20;
					  baseColor_1.xyz = (baseColor_1.xyz * tmpvar_17);
					  baseColor_1.xyz = (baseColor_1.xyz + ((tmpvar_9 * _SpecularColor.xyz) * tmpvar_19));
					  highp vec4 tmpvar_21;
					  tmpvar_21 = mix (baseColor_1, _ReflectionColor, vec4(tmpvar_13));
					  baseColor_1.xyz = tmpvar_21.xyz;
					  baseColor_1.w = 1.0;
					  gl_FragData[0] = baseColor_1;
					}
					
					
					#endif"
				}
			}
			Program "fp" {
				SubProgram "gles hw_tier00 " {
					"!!GLES"
				}
				SubProgram "gles hw_tier01 " {
					"!!GLES"
				}
				SubProgram "gles hw_tier02 " {
					"!!GLES"
				}
			}
		}
	}
	Fallback "Lockwood/Diffuse"
}