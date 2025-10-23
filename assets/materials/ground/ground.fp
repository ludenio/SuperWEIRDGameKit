varying mediump vec2 var_texcoord0;
varying mediump vec4 var_position;

uniform lowp sampler2D diffuse;
uniform lowp sampler2D normal;

const int LIGHT_COUNT = 100;
uniform fragment_inputs {  
    vec4 ambient_color;
    vec4 falloff;
    mat4 iRotation;
    vec4 light_positions[LIGHT_COUNT];
    vec4 light_colors[LIGHT_COUNT];
    vec4 directional_direction;
    vec4 directional_color;
    vec4 light_source_count;
    vec4 lights_max;
};

out vec4 color_out;

void main() {
    vec4 diffuse_rgba = texture(diffuse, var_texcoord0);
    vec3 N = vec3(0, 1, 0);
    vec3 ambient = ambient_color.rgb * ambient_color.a;

    vec3 DIR = normalize(directional_direction.xyz);

    vec3 intensity = ambient + directional_color.rgb * directional_color.a * max(dot(N, DIR), 0.0);

    for (int i = 0; i < light_source_count.x; ++i) {
        vec3 light_dir = (light_positions[i] - var_position).xyz;
        float D = length(light_dir) / 2000.0;
        vec3 L = normalize(light_dir);
        vec3 diffuse = (light_colors[i].rgb * light_colors[i].a) * max(dot(N, L), 0.0);
        float attenuation = 1.0 / ( falloff.x + (falloff.y * D) + (falloff.z * D * D) );
        intensity = intensity + diffuse * attenuation;
    }

    vec3 final_color = diffuse_rgba.rgb * intensity;
    color_out = vec4(final_color, diffuse_rgba.a);
}
