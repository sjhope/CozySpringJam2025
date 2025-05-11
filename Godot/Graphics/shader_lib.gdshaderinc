
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

// https://gist.github.com/ayamflow/c06bc0c8a64f985dd431bd0ac5b557cd
vec2 rotate_uv(vec2 uv, float rotation)
{
    float mid = 0.5;
    float cosAngle = cos(rotation);
    float sinAngle = sin(rotation);
    return vec2(
        cosAngle * (uv.x - mid) + sinAngle * (uv.y - mid) + mid,
        cosAngle * (uv.y - mid) - sinAngle * (uv.x - mid) + mid
    );
}

vec2 rotate_uv(vec2 uv, float rotation, vec2 mid)
{
    float cosAngle = cos(rotation);
    float sinAngle = sin(rotation);
    return vec2(
        cosAngle * (uv.x - mid.x) + sinAngle * (uv.y - mid.y) + mid.x,
        cosAngle * (uv.y - mid.y) - sinAngle * (uv.x - mid.x) + mid.y
    );
}

vec2 rotate_uv(vec2 uv, float rotation, float mid)
{
    float cosAngle = cos(rotation);
    float sinAngle = sin(rotation);
    return vec2(
        cosAngle * (uv.x - mid) + sinAngle * (uv.y - mid) + mid,
        cosAngle * (uv.y - mid) - sinAngle * (uv.x - mid) + mid
    );
}

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
float voronesque( in vec3 p ){

    // Skewing the cubic grid, then determining the first vertex.
    vec3 i  = floor(p + dot(p, vec3(1.0 / 3.0)) );
	p -= i - dot(i, vec3(1.0 / 6.0)) ;

    // Breaking the skewed cube into tetrahedra with partitioning planes, then determining which side of the
    // intersecting planes the skewed point is on. Ie: Determining which tetrahedron the point is in.
    vec3 i1 = step(p.yzx, p), i2 = max(i1, 1. - i1.zxy); i1 = min(i1, 1. - i1.zxy);

    // Using the above to calculate the other three vertices. Now we have all four tetrahedral vertices.
    vec3 p1 = p - i1 + (1.0 / 6.0), p2 = p - i2 + (1.0 / 3.0), p3 = p - .5;

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

// The MIT License
// https://www.youtube.com/c/InigoQuilez
// https://iquilezles.org/
// Copyright © 2014 Inigo Quilez
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


// This is a procedural pattern that has 2 parameters, that generalizes cell-noise, 
// perlin-noise and voronoi, all of which can be written in terms of the former as:
//
// cellnoise(x) = pattern(0,0,x)
// perlin(x) = pattern(0,1,x)
// voronoi(x) = pattern(1,0,x)
//
// From this generalization of the three famouse patterns, a new one (which I call 
// "Voronoise") emerges naturally. It's like perlin noise a bit, but within a jittered 
// grid like voronoi):
//
// voronoise(x) = pattern(1,1,x)
//
// Not sure what one would use this generalization for, because it's slightly slower 
// than perlin or voronoise (and certainly much slower than cell noise), and in the 
// end as a shading TD you just want one or another depending of the type of visual 
// features you are looking for, I can't see a blending being needed in real life.  
// But well, if only for the math fun it was worth trying. And they say a bit of 
// mathturbation can be healthy anyway!
//
// More info here: https://iquilezles.org/articles/voronoise

// More Voronoi shaders:
//
// Exact edges:  https://www.shadertoy.com/view/ldl3W8
// Hierarchical: https://www.shadertoy.com/view/Xll3zX
// Smooth:       https://www.shadertoy.com/view/ldB3zc
// Voronoise:    https://www.shadertoy.com/view/Xd23Dh

// All noise functions here:
//
// https://www.shadertoy.com/playlist/fXlXzf&from=0&num=12


vec3 hash3( vec2 p )
{
    vec3 q = vec3( dot(p,vec2(127.1,311.7)), 
				   dot(p,vec2(269.5,183.3)), 
				   dot(p,vec2(419.2,371.9)) );
	return fract(sin(q)*43758.5453);
}

float voronoise( in vec2 p, float u, float v )
{
	float k = 1.0+63.0*pow(1.0-v,6.0);

    vec2 i = floor(p);
    vec2 f = fract(p);
    
	vec2 a = vec2(0.0,0.0);
    for( int y=-2; y<=2; y++ ) {
    	for( int x=-2; x<=2; x++ ) {
        	vec2  g = vec2( float(x), float(y) );
			vec3  o = hash3( i + g )*vec3(u,u,1.0);
			vec2  d = g - f + o.xy;
			float w = pow( 1.0-smoothstep(0.0,1.414,length(d)), k );
			a += vec2(o.z*w,w);
		}
    }
	
    return a.x/a.y;
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
