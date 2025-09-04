cbuffer cbPerObject : register(b0)
{
    float4x4 gWorld;
};

cbuffer cbPass : register(b1)
{
    float4x4 gView;
    float4x4 gInvView;
    float4x4 gProj;
    float4x4 gInvProj;
    float4x4 gViewProj;
    float4x4 gInvViewProj;
    float3 gEyePosW;
    float cbPerObjectPad1;
    float2 gRenderTargetSize;
    float2 gInvRenderTargetSize;
    float gNearZ;
    float gFarZ;
    float gTotalTime;
    float gDeltaTime;
};

cbuffer perObjectWorld : register(b2)
{
    float _0_0;
    float _0_1;
    float _0_2;
    float _0_3;
    float _1_0;
    float _1_1;
    float _1_2;
    float _1_3;
    float _2_0;
    float _2_1;
    float _2_2;
    float _2_3;
    float _3_0;
    float _3_1;
    float _3_2;
    float _3_3;
}

struct VertexIn
{
    float3 PosL : POSITION;
    float4 Color : COLOR;
};

struct VertexOut
{
    float4 PosH : SV_POSITION;
    float4 Color : COLOR;
};

VertexOut VS(VertexIn vin)
{
    VertexOut vout;
	
	// Transform to homogeneous clip space.
    float4x4 worldMatrix =
    {
        _0_0, _0_1, _0_2, _0_3,
        _1_0, _1_1, _1_2, _1_3,
        _2_0, _2_1, _2_2, _2_3,
        _3_0, _3_1, _3_2, _3_3
    };
    float4 posW = mul(float4(vin.PosL, 1.0f), worldMatrix);
    vout.PosH = mul(posW, gViewProj);
	
	// Just pass vertex color into the pixel shader.
    vout.Color = vin.Color;
    
    return vout;
}

float4 PS(VertexOut pin) : SV_Target
{
    return pin.Color;
}