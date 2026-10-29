shader_type canvas_item;

uniform bool render_noise = false;
uniform float amplitude : hint_range(0.0, 1.0, 0.001) = 0.2;
uniform float time_scale : hint_range(0.0, 10.0, 0.01) = 0.3;
uniform float noise_scale : hint_range(0.0, 2.0, 0.0001) = 0.02;
uniform float rotation_strength : hint_range(0.0, 5.0, 0.1) = 1;
uniform vec2 rotation_pivot = vec2(0.5, 1);
varying vec2 world_position;

void vertex()
{
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

float hash(vec2 p) 
{
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float get_gpu_noise(vec2 p) 
{
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i + vec2(0.0,0.0)), hash(i + vec2(1.0,0.0)), u.x),
			   mix(hash(i + vec2(0.0,1.0)), hash(i + vec2(1.0,1.0)), u.x), u.y);
}

vec2 rotate_vec(vec2 vec, vec2 pivot, float rotation) 
{
	float cosa = cos(rotation);
	float sina = sin(rotation);
	vec -= pivot;
	return vec2
	(
		cosa * vec.x - sina * vec.y,
		cosa * vec.y + sina * vec.x
	) + pivot;
}

void fragment() 
{
	vec2 noise_pos = world_position * noise_scale;
	noise_pos += vec2(TIME * time_scale * 0.5);
	float noise_amount = get_gpu_noise(noise_pos) - 0.5;
	float rotation = amplitude * noise_amount;
	
	vec2 rotated_uvs = rotate_vec(UV, rotation_pivot, rotation);
	float dist = distance(UV, rotation_pivot) * rotation_strength;
	vec2 result_uvs = mix(UV, rotated_uvs, dist);
	COLOR = texture(TEXTURE, result_uvs);

	if (render_noise) 
	{
		float noise_visual = get_gpu_noise(noise_pos);
		COLOR = vec4(vec3(noise_visual), 1.0);
	}
}
