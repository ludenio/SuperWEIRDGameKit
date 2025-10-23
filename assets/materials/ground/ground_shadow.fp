varying mediump vec2 var_texcoord0;
varying mediump vec4 var_position;

uniform lowp sampler2D texture_sampler;

uniform fragment_inputs {  
    lowp vec4 tint;
    lowp vec4 shadow;
    lowp vec4 borders;
    lowp vec4 radius;
    lowp vec4 center;
};

out lowp vec4 color_out;

void main()
{
    lowp vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);

    lowp float h_p = max(borders.x + center.x - var_position.x, max(var_position.x - borders.y - center.x, 0.0f));
    lowp float v_p = max(borders.z + center.y - var_position.z, max(var_position.z - borders.w - center.y, 0.0f));
    lowp float power = min(sqrt(v_p * v_p + h_p * h_p) / radius.x, 1.0f) * shadow.w;

    lowp vec4 color = texture(texture_sampler, var_texcoord0.xy);

    color_out = (color * (1.0f - power) * tint_pm + shadow * power * color.w);
}
