// CC0 licence
// Credit Bramwell Williams

shader_type canvas_item;

uniform float circle_size : hint_range(0,1) = 0.5f;
uniform vec4 circle_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec4 current_color = circle_color;
    
    if (distance(vec2(0.5,0.5), UV) < circle_size) {
        discard;
    } else {
        COLOR = current_color;
    }
}