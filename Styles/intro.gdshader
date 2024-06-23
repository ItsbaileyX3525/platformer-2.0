shader_type canvas_item;

uniform float speed = .5;

void vertex() {
	UV.y +=  TIME * speed;
	UV.x -= TIME * speed;
}