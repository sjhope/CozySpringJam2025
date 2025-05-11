
shader_type canvas_item;

#include "res://Graphics/shader_lib.gdshaderinc"

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap_anisotropic, repeat_disable;
uniform sampler2D noise_tex;
varying vec2 world_pos;
const float world_scale = 0.025;

void vertex() {
	world_pos = get_world_pos(VERTEX, MODEL_MATRIX);
}

void fragment() {
	vec2 uv0 = SCREEN_UV;
	vec2 uv1 = ndc(uv0, SCREEN_PIXEL_SIZE);
	vec2 world_uv = world_pos * world_scale;
	float noise = texture(noise_tex, fract(world_uv * 0.006)).r;
	float t = sin(TIME) * 0.5 + 0.5;
	float mask = 1.0 - smoothstep(0.0, mix(0.1, 0.2, t), noise - mix(0.2, 0.1, t));
	vec3 color = hsv_to_rgb(vec3(mix(0.17, 0.4, noise), 1.0, 1.0));
	float alpha = mask * 0.5;
	COLOR.rgb = mix(vec3(1.0, 1.0, 0.9), color, alpha); // texture(screen_tex, SCREEN_UV).rgb;
	// COLOR.rgb = vec3(voronoise(world_uv, mix(0.5, 1.5, sin(TIME * 0.5) * 0.5 + 0.5), 0.0)); //mix(vec3(1.0), texture(canvas_tex, fract(world_pos * vec2(0.001))).rgb, 0.75);
}
