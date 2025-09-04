#define MaxLights 16

struct Light
{
    float3 Strength;
    float FalloffStart;
    float3 Direction;
    float FalloffEnd;
    float3 Position;
    float SpotPower;
};

struct Material
{
    float4 DiffuseAlbedo;
    float3 FresnelR0;
    float Shininess;
};

float CalcAttenuation(float d, float falloffStart, float falloffEnd)
{
    return saturate((falloffEnd - d) / (falloffEnd - falloffEnd));
}

float3 SchlickFresnel(float3 R0, float3 normal, float3 lightVec)
{
    float cosIncidentAngle = saturate(dot(normal, lightVec));
    
    float f0 = 1.0f - cosIncidentAngle;
    float3 reflectPercent = R0 + (1.0f - R0) * (f0 * f0 * f0 * f0 * f0);
    
    return reflectPercent;
}

float3 BlinnPhong(float3 lightStrength, float3 lightVec, float3 normal, float3 toEye, Material mat)
{
    const float m = mat.Shininess * 256.0f;
    float3 halfVec = normalize(toEye + lightVec);
    
    float roughnessFactor = (m + 8.0f) * pow(max(dot(halfVec, normal), 0.0f), m) / 8.0f;
    float3 fresnelFactor = SchlickFresnel(mat.FresnelR0, halfVec, lightVec);
    
    float3 specAlbedo = fresnelFactor * roughnessFactor;
    
    specAlbedo = specAlbedo / (specAlbedo + 1.0f);
    //if (roughnessFactor <= 0.1)
    //    specAlbedo = 0.4;
    //else if (roughnessFactor <= 0.8)
    //    specAlbedo = 0.5;
    //else
    //    specAlbedo = 0.8;
    
    //float3 diffuse = 0.0;
    //if (mat.DiffuseAlbedo.r <= 0.0)
    //    diffuse = 0.4;
    //else if (mat.DiffuseAlbedo.r <= 0.5)
    //    diffuse = 0.6;
    //else
    //    diffuse = 1.0;
    //return (diffuse.rgb + specAlbedo) * lightStrength;
    return (mat.DiffuseAlbedo.rgb + specAlbedo) * lightStrength;
}

// kd 변환 함수
float CartoonDiffuse(float kd)
{
    if (kd <= 0.0f)
        return 0.4f;
    else if (kd <= 0.5f)
        return 0.6f;
    else
        return 1.0f;
}

// ks 변환 함수
float CartoonSpecular(float ks)
{
    if (ks <= 0.1f)
        return 0.0f;
    else if (ks <= 0.8f)
        return 0.5f;
    else
        return 0.8f;
}

float3 ComputeDirectionalLight(Light L, Material mat, float3 normal, float3 toEye)
{
    float3 lightVec = -L.Direction;
    
    float ndotl = max(dot(lightVec, normal), 0.0f);
    float3 lightStrength = L.Strength * ndotl;
    
    return BlinnPhong(lightStrength, lightVec, normal, toEye, mat);
}

float3 ComputePointLight(Light L, Material mat, float3 pos, float3 normal, float3 toEye)
{
    float3 lightVec = L.Position - pos;
    
    float d = length(lightVec);
    
    if (d > L.FalloffEnd)
        return 0.0f;

    lightVec /= d;
    
    float ndotl = max(dot(lightVec, normal), 0.0f);
    float3 lightStrength = L.Strength * ndotl;
    
    float att = CalcAttenuation(d, L.FalloffStart, L.FalloffEnd);
    lightStrength *= att;
    
    return BlinnPhong(lightStrength, lightVec, normal, toEye, mat);
}

float3 ComputeSpotLight(Light L, Material mat, float3 pos, float3 normal, float3 toEye)
{
    float3 lightVec = L.Position - pos;
    
    float d = length(lightVec);
    
    if (d > L.FalloffEnd)
        return 0.0f;

    lightVec /= d;
    
    float ndotl = max(dot(lightVec, normal), 0.0f);
    float3 lightStrength = L.Strength * ndotl;
    
    float att = CalcAttenuation(d, L.FalloffStart, L.FalloffEnd);
    lightStrength *= att;

    float spotFactor = pow(max(dot(-lightVec, L.Direction), 0.0f), L.SpotPower);
    lightStrength *= spotFactor;
    
    return BlinnPhong(lightStrength, lightVec, normal, toEye, mat);
}

float4 ComputeLighting(Light gLights[MaxLights], Material mat, float3 pos, float3 normal, float3 toEye, float3 shadowFactor)
{
    float3 result = 0.0f;
    
    int i = 0;
    
#if (NUM_DIR_LIGHTS > 0)
    for (i=0; i<NUM_DIR_LIGHTS; i++) {
        result += shadowFactor[i] * ComputeDirectionalLight(gLights[i], mat, normal, toEye);
    }
#endif
    
#if (NUM_POINT_LIGHTS > 0)
    for (i = NUM_POINT_LIGHTS; i < NUM_DIR_LIGHTS + NUM_POINT_LIGHTS; i++) {
        result += ComputePointLight(gLights[i], mat, pos, normal, toEye);
    }
#endif
    
#if (NUM_SPOT_LIGHTS > 0)
    for(i = NUM_DIR_LIGHTS + NUM_POINT_LIGHTS; i < NUM_DIR_LIGHTS + NUM_POINT_LIGHTS + NUM_SPOT_LIGHTS; ++i)
    {
        result += ComputeSpotLight(gLights[i], mat, pos, normal, toEye);
    }
#endif
    
    return float4(result, 0.0f);
}