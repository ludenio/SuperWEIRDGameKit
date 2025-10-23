varying mediump vec2 var_texcoord0;
varying mediump vec2 var_texcoord1;
varying mediump vec4 var_position;

uniform lowp sampler2D diffuse;
uniform lowp sampler2D normal;

const int LIGHT_COUNT = 100;
uniform fragment_inputs {  
    lowp vec4 ambient_color;
    lowp vec4 falloff;
    lowp mat4 iRotation;
    lowp vec4 light_positions[LIGHT_COUNT];
    lowp vec4 light_colors[LIGHT_COUNT];
    lowp vec4 directional_direction;
    lowp vec4 directional_color;
    lowp vec4 light_source_count;
    lowp vec4 lights_max;
};

out lowp vec4 color_out;

void main() {
    lowp vec4 diffuse_rgba = texture(diffuse, var_texcoord0);
    lowp vec4 normal_rgba = texture(normal, var_texcoord1);
    normal_rgba = vec4(0.5,0.5,1,1);
    lowp vec3 N = normalize((iRotation * vec4((normal_rgba * 2.0 - 1.0).rgb, 1)).xyz);
    lowp vec3 ambient = ambient_color.rgb * ambient_color.a;

    lowp vec3 DIR = normalize(directional_direction.xyz);

    lowp vec3 intensity = ambient + directional_color.rgb * directional_color.a * max(dot(N, DIR), 0.0);

    for (lowp int i = 0; i < int(light_source_count.x); ++i) {
        lowp vec3 light_dir = (light_positions[i] - var_position).xyz;
        lowp float D = length(light_dir) / 2000.0;
        lowp vec3 L = normalize(light_dir);
        lowp vec3 diffuse = (light_colors[i].rgb * light_colors[i].a) * max(dot(N, L), 0.0);
        lowp float attenuation = 1.0 / ( falloff.x + (falloff.y * D) + (falloff.z * D * D) );
        intensity = intensity + diffuse * attenuation;
    }

    lowp vec3 final_color = diffuse_rgba.rgb * intensity;
    color_out = vec4(final_color, diffuse_rgba.a);
}
