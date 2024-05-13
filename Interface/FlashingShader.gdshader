shader_type canvas_item;
uniform bool enabled = false;
uniform bool default_show = false;
uniform float speed = 10;

void fragment() {
	if (enabled) {
		vec4 previous_color = texture(TEXTURE, UV);
		float w = speed * TIME;
		if (floor(mod(w, 2.5)) < 0.0001) {
			COLOR = previous_color;
		} else {
			COLOR = vec4(0.0);
		}
	} else if (!default_show) {
		COLOR = vec4(0.0);
	}
}
