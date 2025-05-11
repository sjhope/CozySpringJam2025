shader_type canvas_item;
render_mode blend_add;

const vec2 gradient_multiplier = vec2(1.0, 2.0);
const float gradient_exponent = 1.0;
const float wiggle_frequency = 6.0;
const float wiggle_amplitude = 0.03;
const float wiggle_speed = 1.0;
const vec3 inner_color = vec3(0.2, 0.5, 0.1);
const vec3 outer_color = vec3(0.1, 2.0, 0.5);

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

void vertex() {
	// Called for every vertex the material is visible on.
	// VERTEX.x += sin(UV.y * TIME);
}

void fragment() {
	vec2 uv = UV;
	uv.x += sin(UV.y * wiggle_frequency + TIME * wiggle_speed) * wiggle_amplitude;
	vec2 ndc = uv * 2.0 - 1.0;
	vec2 gradient_a = (1.0 - abs(ndc)) * gradient_multiplier;
	float gradient_b = minkowski(gradient_a, 0.1); // mix(min(gradient_a.x, gradient_a.y), gradient_a.x * gradient_a.y, 0.75);
	float gradient_c = smoothstep(0.0, 0.4, gradient_b - 0.3);

	// vec4(mix(inner_color, outer_color, length(ndc) * gradient_c), gradient_c)
	//COLOR.rgb = mix(inner_color, outer_color, gradient_c * length(ndc)); //  * pow(1.0 - length(ndc), 2.0)
	COLOR.a = gradient_b;

}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
