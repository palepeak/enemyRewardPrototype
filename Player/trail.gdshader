shader_type canvas_item;

uniform vec3 trail_color : source_color = vec3(1.0, 1.0, 1.0);

void fragment() {
	COLOR = vec4(trail_color, COLOR.a);
}
