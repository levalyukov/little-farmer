shader_type canvas_item;

/* - Написал его за пару минут -
 * Этот шейдер заменяет целые 
 * спрайты для подсветки узлов  */

uniform bool highligth = false;
uniform bool destroy = false; 
const vec4 HOVER = vec4(0.20, 0.20, 0.20, 0);
const vec4 DELETE = vec4(0.25, 0.0, 0.0, 0);

void fragment() 
{
    vec4 color = vec4(0,0,0,0);
    if (highligth)
    {
        COLOR = texture(TEXTURE,UV) + ((!destroy) ? HOVER : DELETE);
    }
}