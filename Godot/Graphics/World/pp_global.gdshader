
shader_type canvas_item;

#include "res://Graphics/shader_lib.gdshaderinc"

// 0: Addition, 1: Screen, 2: Overlay, 3: Soft Light, 4: Lighten-Only
#define NOISE_BLEND_MODE 0
#define NOISE_INTENSITY 0.075
#define NOISE_SPEED 3.0
// What gray level noise should tend to.
#define NOISE_MEAN 0.0
// Controls the contrast/variance of noise.
#define NOISE_VARIANCE 0.5

uniform sampler2D mask_tex;
uniform sampler2D canvas_tex;
uniform sampler2D noise_tex;
uniform float noise_scale = 0.2;

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap_anisotropic, repeat_disable;
varying vec2 world_pos;
const float world_scale = 0.025;

void vertex() {
	world_pos = get_world_pos(VERTEX, MODEL_MATRIX);
}

// Credit: https://www.shadertoy.com/view/4t2fRz
vec3 noise_layer(vec3 base, float t, float seed) {
	float noise = fract(sin(seed) * 43758.5453 + t);
    noise = gaussian(noise, float(NOISE_MEAN), float(NOISE_VARIANCE) * float(NOISE_VARIANCE));
    
    float w = float(NOISE_INTENSITY);
	
    vec3 grain = vec3(noise) * (1.0 - vec4(noise).rgb);
	
    #if NOISE_BLEND_MODE == 0
    base += grain * w;
    #elif NOISE_BLEND_MODE == 1
    base = screen(color.rgb, grain, w);
    #elif NOISE_BLEND_MODE == 2
    base = overlay(color.rgb, grain, w);
    #elif NOISE_BLEND_MODE == 3
    base = soft_light(color.rgb, grain, w);
    #elif NOISE_BLEND_MODE == 4
    base = max(color.rgb, grain * w);
    #endif
	
	return base;
}

vec3 border_layer(vec3 base, vec2 uvs, vec2 uvw) {
	// vec2 uv0 = SCREEN_UV;
	// vec2 uv1 = ndc(uv0, SCREEN_PIXEL_SIZE);
	// vec2 uv2 = world_pos * world_scale;
	
	float mask = smoothstep(0.9, 1.0, length(uvs) + 0.05); // texture(mask_tex, SCREEN_UV).r;
	base = mix(base, vec3(1.0), mask);
	
	float screen_noise = texture(noise_tex, uvs * noise_scale).r;
	float world_noise = texture(noise_tex, fract(uvw * noise_scale)).r;
	float radial = 1.0 - length(uvs);
	float gradient_b = radial; // mix(min(gradient_a.x, gradient_a.y), gradient_a.x * gradient_a.y, 0.75);
	float offset = mix(0.2, 0.3, screen_noise + sin(TIME) * 0.5 + 0.5);
	float thickness = 0.05;
	float gradient_c = smoothstep(offset, offset + thickness, gradient_b - (0.3 * exp(-world_noise)));
	
	return base;
}

void fragment() {
	COLOR.rgb = texture(screen_tex, SCREEN_UV).rgb;
	// COLOR.rgb = noise_layer(COLOR.rgb, TIME * float(NOISE_SPEED), dot(SCREEN_UV, vec2(12.9898, 78.233)));
	COLOR.rgb = border_layer(COLOR.rgb, ndc(SCREEN_UV, SCREEN_PIXEL_SIZE), world_pos);
}
