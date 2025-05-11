
shader_type canvas_item;

#include "res://Dev/AJ/Old/shader_lib1.gdshaderinc"

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap_anisotropic, repeat_disable;
uniform sampler2D mask_tex;
uniform sampler2D canvas_tex;
uniform sampler2D noise_tex;
uniform float noise_scale = 0.2;

varying vec2 world_pos;
const float world_scale = 0.025;

void vertex() {
	world_pos = get_world_pos(VERTEX, MODEL_MATRIX);
}

void fragment() {
	vec2 uv0 = SCREEN_UV;
	vec2 uv1 = ndc(uv0, SCREEN_PIXEL_SIZE);
	vec2 uv2 = world_pos * world_scale;
	float mask = smoothstep(0.9, 1.0, length(uv1) + 0.05); // texture(mask_tex, SCREEN_UV).r;
	COLOR.rgb = mix(texture(screen_tex, SCREEN_UV).rgb, vec3(1.0), mask);
	
	float screen_noise = texture(noise_tex, uv1 * noise_scale).r;
	float world_noise = texture(noise_tex, fract(uv2 * noise_scale)).r;
	float radial = 1.0 - length(uv1);
	float gradient_b = radial; // mix(min(gradient_a.x, gradient_a.y), gradient_a.x * gradient_a.y, 0.75);
	float offset = mix(0.2, 0.3, screen_noise + sin(TIME) * 0.5 + 0.5);
	float thickness = 0.05;
	float gradient_c = smoothstep(offset, offset + thickness, gradient_b - (0.3 * exp(-world_noise)));
}
