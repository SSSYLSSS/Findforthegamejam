shader_type canvas_item;

uniform float progress:hint_range(0.0, 1.0);
uniform bool reverse = true;
uniform vec2 num_of_titles = vec2(16,9);

void fragment() {
	vec2 points_in_square = UV * num_of_titles;
	vec2 frac = fract(points_in_square);
	vec2 dis =abs(frac - 0.5);
	float manhattan = dis.x + dis.y;
	if(reverse)
	{
		if(manhattan+UV.x+UV.y<=progress*3.0)
		{
			discard;
		}
	}
	else
	{
		if(manhattan +UV.x+UV.y>=progress*3.0)
		{
			discard;
		}
	}
}
