shader_type canvas_item;

uniform vec4 impact_color : source_color = vec4(1);

void fragment() {
	COLOR = impact_color;
	float x = UV.x - 0.5;
	float y = UV.y - 0.5;
	float dist = sqrt(pow(x, 2) + pow(y, 2));
	if (dist > 0.5){
		COLOR = vec4(0.0);
	} else if (dist > 0.495)  {
		COLOR.a = 0.6;
	} else {
		COLOR.a = 0.3;
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
