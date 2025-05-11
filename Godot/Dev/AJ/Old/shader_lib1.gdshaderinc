
vec2 get_world_pos(vec2 vertex, mat4 model_matrix) {
	return (model_matrix * vec4(vertex, 1.0, 1.0)).xy;
}

// Credit: https://iquilezles.org/articles/distfunctions2d/
float sd_sbox( in vec2 p, in vec2 b, in vec4 r )
{
    r.xy = (p.x>0.0)?r.xy : r.zw;
    r.x  = (p.y>0.0)?r.x  : r.y;
    vec2 q = abs(p)-b+r.x;
    return min(max(q.x,q.y),0.0) + length(max(q,0.0)) - r.x;
}

// 2D rotation. Always handy.
mat2 rot(float th) { float cs = cos(th), si = sin(th); return mat2(vec2(cs, -si), vec2(si, cs)); }

// 3D Voronoi-like function. Cheap, low quality, 1st and 2nd order 3D Voronoi imitation.
//
// I wrote this a while back because I wanted a stand-alone algorithm fast enough to produce regular, or
// 2nd order, Voronoi-looking patterns in a raymarching setting. Anyway, this is what I came up with.
// Obviously, it wouldn't pass as genuine 3D Voronoi, but there's only so much you can do with a few lines.
// Even so, it has a Voronoi feel to it. Hence, Voronesque.
//
// Here's a rough explanation of how it works: Instead of partitioning space into cubes, partition it into
// its simplex form, namely tetrahedrons. Use the four tetrahedral vertices to create some random falloff
// values, then pick off the two highest, or lowest, depending on perspective. That's it. If you'd like to
// know more, the function is roughly commented, plus there's a simplex noise related link below that should
// make it more clear.
//
// Credits: Ken Perlin, the creator of simplex noise, of course. Stefan Gustavson's paper - "Simplex Noise
// Demystified." IQ, other "ShaderToy.com" people, Brian Sharpe (does interesting work), etc.
//
// My favorite simplex-related write up: "Simplex Noise, keeping it simple." - Jasper Flick?
// http://catlikecoding.com/unity/tutorials/simplex-noise/
//
float Voronesque( in vec3 p ){

    // Skewing the cubic grid, then determining the first vertex.
    vec3 i  = floor(p + dot(p, vec3(.333333)) );  p -= i - dot(i, vec3(.166666)) ;

    // Breaking the skewed cube into tetrahedra with partitioning planes, then determining which side of the
    // intersecting planes the skewed point is on. Ie: Determining which tetrahedron the point is in.
    vec3 i1 = step(p.yzx, p), i2 = max(i1, 1. - i1.zxy); i1 = min(i1, 1. - i1.zxy);

    // Using the above to calculate the other three vertices. Now we have all four tetrahedral vertices.
    vec3 p1 = p - i1 + .166666, p2 = p - i2 + .333333, p3 = p - .5;

    vec3 rnd = vec3(7, 157, 113); // I use this combination to pay homage to Shadertoy.com. :)

    // Falloff values from the skewed point to each of the tetrahedral points.
    vec4 v = max(0.5 - vec4(dot(p, p), dot(p1, p1), dot(p2, p2), dot(p3, p3)), 0.);

    // Assigning four random values to each of the points above.
    vec4 d = vec4( dot(i, rnd), dot(i + i1, rnd), dot(i + i2, rnd), dot(i + 1., rnd) );

    // Further randomizing "d," then combining it with "v" to produce the final random falloff values.
    // Range [0, 1]
    d = fract(sin(d)*262144.)*v*2.;

    // Reusing "v" to determine the largest, and second largest falloff values. Analogous to distance.
    v.x = max(d.x, d.y);
	v.y = max(d.z, d.w);
	v.z = max(min(d.x, d.y), min(d.z, d.w));
	v.w = min(v.x, v.y);

    // Maximum minus second order, for that beveled Voronoi look. Range [0, 1].
    return  max(v.x, v.y) - max(v.z, v.w);

    //return max(v.x, v.y); // Maximum, or regular value for the regular Voronoi aesthetic.  Range [0, 1].
}

float minkowski(vec2 p, float e) {
	return pow(p.x + p.y, 1.0 / e);
}

vec2 random2(vec2 seed) {
	mat3 m = mat3(
		vec3(12.23, 34.34, 95.39),
		vec3(437.94, 901.39, 29.94),
		vec3(84.28, 49.60, 4.02)
	);

	vec3 mult = m * vec3(seed, 1.0);
	return vec2(fract(mult.x), fract(mult.y));
}

float voronoi(vec2 uv, float angle_offset) {
	vec2 grid = fract(uv);
	vec2 id = floor(uv);
	float min_dist = 100.0;

	for (float x = -1.0; x <= 1.0; x++) {
		for (float y = -1.0; y <= 1.0; y++) {
			vec2 offset = vec2(x, y);
			vec2 n = random2(id + offset) + angle_offset;
			vec2 p = offset + vec2(sin(n.x), cos(n.y)) * 0.5 + 0.5;
			float d = length(p - grid);

			min_dist = max(min_dist, d);
		}
	}

	return min_dist;
}

float spiralSDF(vec2 p,vec2 c, float t) {
	const float a=1.0;
	const float b=.1759;
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

// ires == SCREEN_PIXEL_SIZE
vec2 ndc(vec2 uv, vec2 ires) {
	uv = uv * 2.0 - 1.0;
	uv.x *= ires.y / ires.x;

	return uv;
}

vec3 channel_mix(vec3 a, vec3 b, vec3 w) {
    return vec3(mix(a.r, b.r, w.r), mix(a.g, b.g, w.g), mix(a.b, b.b, w.b));
}

float gaussian(float z, float u, float o) {
    return (1.0 / (o * sqrt(2.0 * 3.1415))) * exp(-(((z - u) * (z - u)) / (2.0 * (o * o))));
}

vec3 madd(vec3 a, vec3 b, float w) {
    return a + a * b * w;
}

vec3 screen(vec3 a, vec3 b, float w) {
    return mix(a, vec3(1.0) - (vec3(1.0) - a) * (vec3(1.0) - b), w);
}

vec3 overlay(vec3 a, vec3 b, float w) {
    return mix(a, channel_mix(
        2.0 * a * b,
        vec3(1.0) - 2.0 * (vec3(1.0) - a) * (vec3(1.0) - b),
        step(vec3(0.5), a)
    ), w);
}

vec3 soft_light(vec3 a, vec3 b, float w) {
    return mix(a, pow(a, pow(vec3(2.0), 2.0 * (vec3(0.5) - b))), w);
}

// Credit: https://chilliant.com/rgb2hsv.html
vec3 hue_to_rgb(float h) {
	float r = abs(h * 6.0 - 3.0) - 1.0;
	float g = 2.0 - abs(h * 6.0 - 2.0);
	float b = 2.0 - abs(h * 6.0 - 4.0);
	return clamp(vec3(r, g, b), 0.0, 1.0);
}

vec3 hsv_to_rgb(vec3 hsv) {
	vec3 rgb = hue_to_rgb(hsv.x);
	return ((rgb - 1.0) * hsv.y + 1.0) * hsv.z;
}

vec3 hsl_to_rgb(vec3 hsl) {
	vec3 rgb = hue_to_rgb(hsl.x);
	float c = (1.0 - abs(2.0 * hsl.z - 1.0)) * hsl.y;
	return (rgb - 0.5) * c + hsl.z;
}

float rgb_to_hue(vec3 rgb) {
    float min_channel = min(min(rgb.r, rgb.g), rgb.b);
    float max_channel = max(max(rgb.r, rgb.g), rgb.b);

    if (min_channel == max_channel) {
        return 0.0;
    }

    float hue = 0.0;

    if (max_channel == rgb.r) {
        hue = (rgb.g - rgb.b) / (max_channel - min_channel);

    } else if (max_channel == rgb.g) {
        hue = 2.0 + (rgb.b - rgb.r) / (max_channel - min_channel);

    } else {
        hue = 4.0 + (rgb.r - rgb.g) / (max_channel - min_channel);
    }

    hue = hue * 60.0;

    if (hue < 0.0) hue = hue + 360.0;

    return round(hue);
}

vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
	return a + b * cos(6.28318 * (c * t + d));
}

// vec3 mix4(vec3 a, vec3 b, vec3 c, vec3 d, float t) {
//	return mix(a, b, smoothstep(0.0, 0.5, t)) + mix(c, d, smoothstep(0.5, 1.0, t));
//}

vec3 mix4(vec3 a, vec3 b, vec3 c, vec3 d, float t) {
	return mix(a, mix(b, mix(c, d, smoothstep(2.0 / 3.0, 1.0, t)), smoothstep(1.0 / 3.0, 2.0 / 3.0, t)), smoothstep(0.0, 1.0 / 3.0, t));
}
