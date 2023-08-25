shader_type canvas_item;

uniform sampler2D color_map;

void fragment() {
	vec4 color_map_value = texture(color_map, UV);
	if (color_map_value.r != 1.0) {
		COLOR = texture(TEXTURE, UV);
		COLOR.rgb = vec3((COLOR.r + COLOR.g + COLOR.b)/3.0);
	}
}
