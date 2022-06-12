Shader "Custom/DisableZWriteTUT"
{
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
       
        Pass{
            ZWrite Off
        }
    }
   
}
