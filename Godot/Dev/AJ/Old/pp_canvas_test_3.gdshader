shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap_anisotropic, repeat_disable;

void fragment() {
	vec4 screen = textureLod(screen_texture, SCREEN_UV, 0.0);
	vec2 uv0 = SCREEN_UV;
	vec2 uv1 = uv0 * 2.0 - 1.0;
	vec2 uv2 = vec2(uv1.x * SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x, uv1.y);
	float screen_sdf = smoothstep(0.9, 1.0, length(uv2));
	
	float cell_mask = smoothstep(0.0, 1.0, screen.r + screen_sdf);
	float cell_interior = abs(cell_mask);
	float cell_exterior = abs(cell_mask - 1.0);
	float cell_wall = smoothstep(0.0, 0.2, 1.0 - abs(cell_mask - 0.5) * 2.0);
	vec3 cell_color = mix(vec3(0.3, 1.0, 0.3), vec3(0.3, 0.3, 1.0) * vec3(0.3, 0.3, 1.0), cell_interior);
	
	// COLOR.rgb = vec3(cell_wall);
	COLOR.rgb = mix(cell_color, vec3(1.0), cell_wall);
}
