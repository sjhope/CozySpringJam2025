
shader_type canvas_item;
render_mode blend_add;

#include "res://Graphics/shader_lib.gdshaderinc"

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap_anisotropic, repeat_disable;
uniform sampler2D vines_noise_tex;
uniform sampler2D splotches_noise_tex;
varying vec2 world_pos;
const float world_scale = 0.025;

void vertex() {
	world_pos = get_world_pos(VERTEX, MODEL_MATRIX);
}

void fragment() {
	vec2 uv0 = SCREEN_UV;
	vec2 uv1 = ndc(uv0, SCREEN_PIXEL_SIZE);
	vec2 world_uv = world_pos * world_scale;
	vec2 wobble = vec2(sin(TIME + world_pos.x * world_scale), cos(TIME + world_pos.y * world_scale));
	float vines_noise = texture(vines_noise_tex, fract((world_uv + wobble * 0.09) * 0.006)).r;
	float t = sin(TIME) * 0.5 + 0.5;
	float mask = 1.0 - smoothstep(0.0, mix(0.3, 0.4, t), vines_noise);// - mix(0.2, 0.1, t));
	vec3 vines = hsv_to_rgb(vec3(mix(0.5, 0.14, vines_noise * 3.0), 0.9, 1.0)); // mix(0.17, 0.4, noise) // vines_noise + 0.14
	float alpha = mask * 0.5;
	float splotches_noise = texture(splotches_noise_tex, fract(world_uv * 0.005)).r;
	float cells1 = (voronesque(vec3(world_uv, mix(0.5, 1.5, sin(TIME * 0.5 + sin(splotches_noise)) * 0.5 + 0.5))));
	vec3 cells2 = voronoi(world_uv * 2.0);
	cells2 = hsv_to_rgb(vec3(mix(0.45, 0.66, length(cells2.x) + cells2.z * 0.15), 0.3, 0.9));
	vec3 background_color = mix(mix(vec3(0.6, 1.0, 0.55), cells2, length(uv1 + vines_noise * 0.4)), vec3(1.0), 0.6); // vec3(1.0, 0.95, 0.6) //  * exp(-cells1)
	COLOR.rgb = mix(background_color, vines * 0.5 + 0.5, alpha); // texture(screen_tex, SCREEN_UV).rgb;
	// COLOR.rgb = cells2;
	// COLOR.rgb = vec3(1.0 - smoothstep(0.35, 0.45, splotches_noise));
	// COLOR.rgb = vec3(voronoi(world_uv)); //mix(vec3(1.0), texture(canvas_tex, fract(world_pos * vec2(0.001))).rgb, 0.75);
}
