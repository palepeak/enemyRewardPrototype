shader_type canvas_item;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	if (COLOR.a != 0.0) {
		float alpha_offset = (1.0-sqrt(pow(UV.x-0.5, 2) + pow(UV.y - 0.5, 2))*2.0);
		COLOR = vec4(1.0, 0.5, 0.25, alpha_offset);
	}
}
