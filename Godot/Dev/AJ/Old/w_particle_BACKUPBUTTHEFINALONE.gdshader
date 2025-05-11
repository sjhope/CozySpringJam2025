shader_type canvas_item;
// render_mode blend_mix;

#include "res://Dev/AJ/Old/shader_lib1.gdshaderinc"

uniform sampler2D noise_tex;
const vec2 gradient_multiplier = vec2(1.0, 1.0);
const float gradient_exponent = 1.0;
const float wiggle_frequency = 6.0;
const float wiggle_amplitude = 0.03;
const float wiggle_speed = 1.0;
const vec3 inner_color = vec3(0.2, 0.5, 0.1);
const vec3 outer_color = vec3(0.1, 2.0, 0.5);

// uniform vec3 color: source_color = vec3(1.0,0.2, 1.0);
uniform float hue = 0.0;
uniform float id = 0;

varying vec2 world_pos;
const float world_scale = 0.025;
const float local_scale = 0.05;
const float noise_scale_small = 0.3;
const float noise_scale_med = 0.05;
const float noise_scale_large = 0.001;

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
	vec2 world_ndc = fract(world_uv) * 2.0 - 1.0;
	// float mesh_noise = texture(noise_tex, mesh_ndc * local_scale).r;
	float world_noise_small = texture(noise_tex, fract(world_uv * noise_scale_small)).r;
	float world_noise_med = texture(noise_tex, fract(world_uv * noise_scale_med)).r;
	float world_noise_large = texture(noise_tex, fract(world_uv * noise_scale_large)).r;
	float radial = clamp(1.0 - length(mesh_ndc), 0.0, 1.0);
	
	float gradient_b = radial;
	float per_particle_offset = fract(sin(id) * 43758.5453);
	// float offset = mix(0.1, 0.4, world_noise_small + sin(TIME + (world_noise_large) * 60.0) * 0.5 + 0.5);
	float world_noise_scale = 25.0;
	float offset = world_noise_small + sin(TIME / PI * 3.0 + world_noise_large * world_noise_scale) * 0.5 + 0.5;
	float bleed = 0.32;
	float offset_adj = offset * 0.3 + 0.1; // mix(0.1, 0.4, offset);
	float gradient_c = (clamp(offset * 0.2, 0.0, 1.0) * radial * 0.8) + pow(smoothstep(offset_adj, offset_adj + bleed, gradient_b - (0.3 * exp(-world_noise_small))), 0.8); // ((radial - 0.2) * 0.7); //
	
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
	vec3 color_delta = vec3(0.0, -0.4, 0.5);
	vec3 color_hsv = vec3(hue / 360.0, 1.0, 1.0);
	// vec3 color_gradient = hsl_to_rgb(vec3(rgb_to_hue(color), 0.8, 0.5));
	// color_gradient.r += mix(-color_delta.r, color_delta.r, smoothstep(0.0, 1.0, (mesh_uv.x * 0.5) + (world_noise_large * 2.0)));
	// color_hsv.r += mix(-color_delta.r, color_delta.r,  world_noise_med * 1.5);
	// color_gradient.b += mix(-color_delta.b, color_delta.b, smoothstep(0.0, 1.0, (mesh_uv.y * 0.5) + (world_noise_large * 2.0)));
	float t = clamp(1.0 - length(mesh_ndc) - (world_noise_med * 0.3), 0.0, 1.0); //max(world_noise_med * 1.5, clamp(1.0 - length(mesh_ndc), 0.0, 1.0));
	vec3 blend = mix(vec3(1.0), vec3(0.5, 1.0, 1.0), clamp(length(vec2(sin(world_uv.x), cos(world_uv.y)) * 0.5 + 0.5), 0.0, 1.0));
	blend = mix(vec3(1.0, 1.0, 1.0), blend, smoothstep(0.3, 0.8, abs(t)));
	// vec3 blend = mix(vec3(1.0, 2.0, 0.5), mix(vec3(1.0), vec3(0.5, 1.0, 1.0), length(world_uv * 100.0)), smoothstep(0.1, 0.4, t));
	vec3 color_gradient = hsv_to_rgb(color_hsv * blend);
	vec3 colorful_version = clamp(color_gradient, 0.0, 1.0); // mix(color_gradient, color_gradient * 0.5, min(world_noise_med, radial)); // mix(vec3(0.0), color, exp(gradient_c * 2.0) * 0.5 - 0.5);
	COLOR.a = clamp(exp(gradient_c) * 0.5 - 0.5, -0.2, 1.3); // clamp((exp(gradient_c * 2.0) * 0.5 - 0.5) * radial, 0.0, 1.0); // * world_noise_large;

	vec3 gray_version = vec3(clamp(smoothstep(0.3, 0.4, abs(t)), 0.0, 1.0)); // smoothstep(0.1, 0.4, t)
	COLOR.rgb = screen(colorful_version, 1.0 - gray_version, 1.0);
	// COLOR.rgb = hsv_to_rgb(color_hsv * mix(vec3(1.0), vec3(0.5, 1.0, 1.0), clamp(length(vec2(sin(world_uv.x), cos(world_uv.y)) * 0.5 + 0.5), 0.0, 1.0)));
	// COLOR.a = length(world_ndc);
	// COLOR.rg = texture(noise_tex, fract(world_pos * TEXTURE_PIXEL_SIZE * offset_scale_large * 5.0)).rg;
	// COLOR.rgb = vec3(world_noise_small);
	// COLOR.rg = fract(world_uv) * (1.0 - length(uv1));
}
