shader_type canvas_item;
//render_mode blend_add;

#include "res://Graphics/shader_lib.gdshaderinc"

const vec2 gradient_multiplier = vec2(1.0, 2.0);
const float gradient_exponent = 1.0;
const float wiggle_frequency = 4.0;
const float wiggle_amplitude = 0.02;
const float wiggle_speed = 1.0;
const vec3 inner_color = vec3(0.2, 0.5, 0.1);
const vec3 outer_color = vec3(0.1, 2.0, 0.5);
uniform sampler2D noise_tex;

float minkowski(vec2 p, float e) {
	return pow(p.x + p.y, 1.0 / e);
}

varying vec2 world_pos;
const float world_scale = 0.025;

void vertex() {
	world_pos = get_world_pos(VERTEX, MODEL_MATRIX);
}

void fragment() {
	vec2 world_uv = world_pos * world_scale;
	vec2 uv = UV;
	vec2 ndc = uv * 2.0 - 1.0;
	// ndc.x *= 2.0;
	ndc.x += sin(ndc.y * wiggle_frequency + TIME * wiggle_speed) * wiggle_amplitude;
	
	float noise = texture(noise_tex, fract(world_uv * 0.2)).r;
	COLOR.rgb = vec3(0.0);
	float a1 = dot(smoothstep(0.5, 0.75, 1.0 - abs(ndc.y)), smoothstep(0.8, 1.0, 1.0 - abs(ndc.x)));
	float a2 = dot(smoothstep(0.4, 0.9, 1.0 - abs(ndc.y)), smoothstep(0.65, 1.0, 1.0 - abs(ndc.x))) * 0.4;
	COLOR.a = mix(a1, noise, a2) + (a1 + a2) * 0.5;
	
	// COLOR.a = smoothstep(0.9, 1.0, min(1.0 - length(ndc * 0.125), 1.0 - abs(ndc.x)));
	
	// vec2 gradient_a = (1.0 - abs(ndc)) * gradient_multiplier;
	// float gradient_b =  clamp(mix(min(gradient_a.x, gradient_a.y), gradient_a.x * gradient_a.y, 0.75), 0.0, 1.0);
	// float gradient_c = clamp(smoothstep(0.0, 0.4, gradient_b - 0.3), 0.0, 1.0);

	// vec4(mix(inner_color, outer_color, length(ndc) * gradient_c), gradient_c)
	// COLOR.rgb = mix(inner_color, outer_color, gradient_c * length(ndc)); //  * pow(1.0 - length(ndc), 2.0)
	// COLOR.rgb = mix(COLOR.rgb, vec3(0.2, 0.8, 0.4), min(float(gradient_c < gradient_b), length(ndc)));
	// COLOR.a = max(gradient_b, gradient_c);
	// COLOR.a = mix(vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), float(gradient_c > gradient_b));
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
