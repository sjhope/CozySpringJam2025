shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap_anisotropic, repeat_disable;

const float a=1.0;
const float b=.1759;

float spiralSDF(vec2 p,vec2 c, float t){
    // t = theta
    p = p - c;
    float t1=atan(p.y, p.x) + t*8.0;
    // t=(t+PI)/(2.*PI);
    float r=length(p.xy);
    
    float n=(log(r/a)/b-t1)/(2.*PI);

    // Cap the spiral
    // float nm = (log(0.11)/b-t)/(2.0*PI);
    // n = min(n,nm);
    // return (n+1.0)/100.0;
    float upper_r=a*exp(b*(t1+2.*PI*ceil(n)));
    float lower_r=a*exp(b*(t1+2.*PI*floor(n)));
    // float lower_r = 0.0;
    
    return min(abs(upper_r-r),abs(r-lower_r));
}

void fragment() {
	vec4 screen = textureLod(screen_texture, SCREEN_UV, 0.0);
	vec2 uv0 = SCREEN_UV;
	vec2 uv1 = uv0 * 2.0 - 1.0;
	vec2 uv2 = vec2(uv1.x * SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x, uv1.y);
	float screen_sdf = smoothstep(0.9, 1.0, length(uv2));
	
	// COLOR.rgb = vec3(cell_wall);
	float d = 1.0 - spiralSDF(uv2,vec2(0.0), TIME);

    // Alter distance for a satisfying visual
    float v = exp(-d) * 2.0 - 1.0; // pow(d, 1.32) / 0.23
    COLOR.rgb=screen.rgb;
	//COLOR.rgba = screen;
}
