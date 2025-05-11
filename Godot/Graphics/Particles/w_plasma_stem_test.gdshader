shader_type canvas_item;
//render_mode blend_add;

const vec2 gradient_multiplier = vec2(1.0, 2.0);
const float gradient_exponent = 1.0;
const float wiggle_frequency = 6.0;
const float wiggle_amplitude = 0.03;
const float wiggle_speed = 1.0;
const vec3 inner_color = vec3(0.2, 0.5, 0.1);
const vec3 outer_color = vec3(0.1, 2.0, 0.5);

mat2 rot(float th) { float cs = cos(th), si = sin(th); return mat2(vec2(cs, -si), vec2(si, cs)); }

float minkowski(vec2 p, float e) {
	return pow(p.x + p.y, 1.0 / e);
}

void vertex() {
	// Called for every vertex the material is visible on.
	// VERTEX.x += sin(UV.y * TIME);
}

void fragment() {
	vec2 uv = UV;
	vec2 ndc = uv * 2.0 - 1.0;
	ndc.x *= 2.0;
	ndc.x += sin(ndc.y * wiggle_frequency + TIME * wiggle_speed) * wiggle_amplitude;
	vec2 gradient_a = (1.0 - abs(ndc)) * gradient_multiplier;
	float gradient_b =  clamp(mix(min(gradient_a.x, gradient_a.y), gradient_a.x * gradient_a.y, 0.75), 0.0, 1.0);
	float gradient_c = clamp(smoothstep(0.0, 0.4, gradient_b - 0.3), 0.0, 1.0);

	// vec4(mix(inner_color, outer_color, length(ndc) * gradient_c), gradient_c)
	COLOR.rgb = mix(inner_color, outer_color, gradient_c * length(ndc)); //  * pow(1.0 - length(ndc), 2.0)
	COLOR.rgb = mix(COLOR.rgb, vec3(0.2, 0.8, 0.4), min(float(gradient_c < gradient_b), length(ndc)));
	COLOR.a = max(gradient_b, gradient_c);
	// COLOR.a = mix(vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), float(gradient_c > gradient_b));
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
