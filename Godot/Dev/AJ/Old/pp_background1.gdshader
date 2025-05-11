
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
	COLOR.rgb = vec3(1.0); //mix(vec3(1.0), texture(canvas_tex, fract(world_pos * vec2(0.001))).rgb, 0.75);
}
