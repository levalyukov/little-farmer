shader_type canvas_item;

/* Написал его за пару минут.
 * Этот шейдер заменяет целые 
 * спрайты для подсветки узлов  */

uniform bool highligth = false;
uniform bool destroy = false; 
uniform bool success = false;
const vec4 HOVER = vec4(0.20, 0.20, 0.20, 0.0);
const vec4 DELETE = vec4(0.20, 0.0, 0.0, 0.0);
const vec4 SUCCESS = vec4(0.0, 0.20, 0.0, 0.0);

vec4 get_state()
{
	vec4 color = vec4(0,0,0,0);
	if (!destroy && !success)
	{
		color = HOVER;
	}
	
	else 
	{
		color = (destroy) ? DELETE : SUCCESS;
	}
	
	return(color);
}

void fragment() 
{
    vec4 color = vec4(0,0,0,0);
    if (highligth)
    {
        COLOR = texture(TEXTURE,UV) + get_state();
    }
}