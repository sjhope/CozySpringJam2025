
shader_type canvas_item;

#include "res://Dev/AJ/Old/shader_lib1.gdshaderinc"

// 0: Addition, 1: Screen, 2: Overlay, 3: Soft Light, 4: Lighten-Only
#define BLEND_MODE 0
#define SPEED 2.0
#define INTENSITY 0.075
// What gray level noise should tend to.
#define MEAN 0.0
// Controls the contrast/variance of noise.
#define VARIANCE 0.5

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap_anisotropic, repeat_disable;
uniform sampler2D mask_tex;
uniform sampler2D canvas_tex;
varying vec2 world_pos;
const float world_scale = 0.025;

void vertex() {
	world_pos = get_world_pos(VERTEX, MODEL_MATRIX);
}

void fragment() {
	// Credit: https://www.shadertoy.com/view/4t2fRz
	float t = TIME * float(SPEED);
    float seed = dot(SCREEN_UV, vec2(12.9898, 78.233));
    float noise = fract(sin(seed) * 43758.5453 + t);
    noise = gaussian(noise, float(MEAN), float(VARIANCE) * float(VARIANCE));
    
    float w = float(INTENSITY);
	
    vec3 grain = vec3(noise) * (1.0 - vec4(noise).rgb);
    
	COLOR = texture(screen_tex, SCREEN_UV);
	
    #if BLEND_MODE == 0
    COLOR.rgb += grain * w;
    #elif BLEND_MODE == 1
    COLOR.rgb = screen(color.rgb, grain, w);
    #elif BLEND_MODE == 2
    COLOR.rgb = overlay(color.rgb, grain, w);
    #elif BLEND_MODE == 3
    COLOR.rgb = soft_light(color.rgb, grain, w);
    #elif BLEND_MODE == 4
    COLOR.rgb = max(color.rgb, grain * w);
    #endif
}
