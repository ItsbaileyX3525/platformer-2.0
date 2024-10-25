shader_type canvas_item;

void fragment() {
    // Calculate the gradient position based on the Y-coordinate (vertical axis)
    float gradient_position = UV.y;
    
    // Create a black color with transparency that increases from 0 (top) to 1 (bottom)
    vec4 color = vec4(0.0, 0.0, 0.0, gradient_position);

    // Output the color
    COLOR = color;
}
