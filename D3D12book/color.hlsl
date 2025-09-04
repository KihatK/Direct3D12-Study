cbuffer cbPerObject : register(b0)
{
    float4x4 gWorldViewProj;
    float4 gPulseColor;
    float gTime;
}

struct VertexIn
{
    float3 PosL : POSITION;
    float4 Color : COLOR;
};

struct VertexOut
{
    float4 PosH : SV_Position;
    float4 Color : COLOR;
};

VertexOut VS(VertexIn vin)
{
    VertexOut vout;

    vout.PosH = mul(float4(vin.PosL, 1.0f), gWorldViewProj);
    vout.Color = vin.Color;
    
    return vout;
}

float4 PS(VertexOut pin) : SV_TARGET
{
    const float pi = 3.141592;
    
    float s = 0.5f * sin(gPulseColor * gTime - 0.25f * pi) + 0.5f;
    
    float4 c = lerp(pin.Color, gPulseColor, s);
    
    return c;
}