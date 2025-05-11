
shader_type canvas_item;

#include "res://Dev/AJ/Old/shader_lib1.gdshaderinc"

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap_anisotropic, repeat_disable;
uniform sampler2D canvas_tex;
varying vec2 world_pos;
const float world_scale = 0.025;

void vertex() {
	world_pos = get_world_pos(VERTEX, MODEL_MATRIX);
}

void fragment() {
	vec2 uv0 = SCREEN_UV;
	vec2 uv1 = ndc(uv0, SCREEN_PIXEL_SIZE);
	vec2 world_uv = world_pos * world_scale;
	//COLOR.rgb = texture(screen_tex, SCREEN_UV).rgb;
	COLOR.rgb = texture(canvas_tex, fract(uv0 * 0.3)).rgb;
	float mask = smoothstep(0.9, 1.0, length(uv1) + 0.05); // texture(mask_tex, SCREEN_UV).r;
	vec3 col = texture(screen_tex, uv0).rgb;
	// COLOR.rgb = mix(vec3(texture(screen_tex, uv0).a), vec3(1.0), mask);
}
