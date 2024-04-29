shader_type canvas_item;

uniform sampler2D color_map;

void fragment() {
	vec4 color_map_value = texture(color_map, UV);
	if (color_map_value.r != 1.0) {
		COLOR = texture(TEXTURE, UV);
		if (COLOR.r < 0.5 && COLOR.g < 0.5 && COLOR.b < 0.5) {
			COLOR.rgb = vec3(0.0, 0.0, 0.0);
		} else {
			COLOR.rgb = vec3(1.0, 1.0, 1.0);
		}
		
	}
}
