shader_type canvas_item;

uniform int frame = 0;
uniform bool outlined = false;
uniform vec4 line_color : source_color = vec4(1);

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	
	vec4 previous_color = texture(TEXTURE, UV);
	vec4 white_color = vec4(1.0, 1.0, 1.0, previous_color.a);
	vec4 red_color = vec4(1.0, 0.25, 0.25, previous_color.a);
	vec4 new_color = previous_color;
	if (frame == 1) {
		new_color = white_color;
	} else if (frame == 2) {
		new_color = red_color;
	} else if (outlined) {
		if (floor(mod(10, 2.5)) < 0.0001) {
			vec2 size = TEXTURE_PIXEL_SIZE;
		
			float outline = texture(TEXTURE, UV + vec2(-size.x, 0)).a;
			outline += texture(TEXTURE, UV + vec2(0, size.y)).a;
			outline += texture(TEXTURE, UV + vec2(size.x, 0)).a;
			outline += texture(TEXTURE, UV + vec2(0, -size.y)).a;
			outline += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
			outline += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
			outline += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
			outline += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
			outline = min(outline, 1.0);
		
			new_color = mix(color, line_color, outline - color.a);
		}
	}
	COLOR = new_color;
}
