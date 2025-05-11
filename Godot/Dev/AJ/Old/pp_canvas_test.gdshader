shader_type spatial;
render_mode unshaded, fog_disabled;

void vertex() {
  POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	ALBEDO = vec3(0.5);
	ALPHA = 0.5;
}