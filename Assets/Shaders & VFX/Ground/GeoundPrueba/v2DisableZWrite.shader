Shader "Custom/v2DisableZWrite"
{
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        Pass{
            ZWrite Off
        }
        
    }
    
}
