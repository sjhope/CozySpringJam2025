shader_type canvas_item;
// render_mode blend_add;

uniform sampler2D noise_tex;
const vec2 gradient_multiplier = vec2(1.0, 1.0);
const float gradient_exponent = 1.0;
const float wiggle_frequency = 6.0;
const float wiggle_amplitude = 0.03;
const float wiggle_speed = 1.0;
const vec3 inner_color = vec3(0.2, 0.5, 0.1);
const vec3 outer_color = vec3(0.1, 2.0, 0.5);

uniform vec3 color: source_color = vec3(0.9, 0.8, 1.0);
uniform float id = 0;

varying vec2 world_pos;
const float world_scale = 0.025;
uniform float noise_scale = 0.05;

void vertex() {
	// Called for every vertex the material is visible on.
	// VERTEX += vec2(sin(UV.x), cos(UV.y));
	// vec2 vertex_world = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	// COLOR.rg = vertex_world;
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0, 1.0)).xy;
}

void fragment() {
	vec2 mesh_uv = UV;
	vec2 mesh_ndc = mesh_uv * 2.0 - 1.0;
	vec2 world_uv = world_pos * world_scale;
	float mesh_noise = texture(noise_tex, mesh_ndc * noise_scale).r;
	float world_noise = texture(noise_tex, fract(world_uv * noise_scale)).r;
	float radial = 1.0 - length(mesh_ndc);
	// uv.x += sin(world_uv.x + UV.y * wiggle_frequency + TIME * wiggle_speed) * wiggle_amplitude;
	// uv.y += cos(world_uv.y + UV.x * wiggle_frequency + TIME * wiggle_speed) * wiggle_amplitude;
	
	float gradient_b = radial; // mix(min(gradient_a.x, gradient_a.y), gradient_a.x * gradient_a.y, 0.75);
	float offset = mix(0.2, 0.3, mesh_noise + id + sin(TIME) * 0.5 + 0.5);
	float thickness = 0.05;
	float gradient_c = smoothstep(offset, offset + thickness, gradient_b - (0.3 * exp(-world_noise)));

	// vec4(mix(inner_color, outer_color, length(ndc) * gradient_c), gradient_c)
	//COLOR.rgb = mix(inner_color, outer_color, gradient_c * length(ndc)); //  * pow(1.0 - length(ndc), 2.0)
	
	// vec2 uv2 = vec2(uv1.x * SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x, uv1.y);
	// float screen_sdf = smoothstep(0.9, 1.0, length(uv2));
	
	// COLOR.rgb = vec3(cell_wall);
	// float d = spiralSDF(uv1, vec2(0.0), -TIME * 0.02);

    // Alter distance for a satisfying visual
    // float v = exp(-d * 0.75) * 2.0 - 1.0; // pow(d, 1.32) / 0.23
	
	// COLOR.a = (v + (1.0 - length(uv1) * 2.5)) * gradient_c; // v * (1.0 - length(uv1) * 1.8);
	
	// COLOR.a = (v + (1.0 - length(uv1) * 2.5)) * gradient_c;
	// COLOR.rgb = vec3(clamp(radial, 0.0, 1.0));
	COLOR.rgb = color; // mix(vec3(0.0), color, exp(gradient_c * 2.0) * 0.5 - 0.5);
	COLOR.a = clamp(exp(gradient_c * 2.0) * 0.5 - 0.5, 0.0, 1.0);
	// COLOR.rg = fract(world_uv) * (1.0 - length(uv1));
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
