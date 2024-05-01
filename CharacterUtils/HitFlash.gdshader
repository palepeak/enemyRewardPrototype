shader_type canvas_item;

uniform int frame = 0;

void fragment() {
	vec4 previous_color = texture(TEXTURE, UV);
	vec4 white_color = vec4(1.0, 1.0, 1.0, previous_color.a);
	vec4 red_color = vec4(1.0, 0.25, 0.25, previous_color.a);
	vec4 new_color = previous_color;
	if (frame == 1) {
		new_color = white_color;
	} else if (frame == 2) {
		new_color = red_color;
	}
	COLOR = new_color;
}
