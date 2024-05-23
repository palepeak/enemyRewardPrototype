shader_type canvas_item;

uniform float progress = 0.2;

void fragment() {
	if (1.0-UV.y > progress){
		COLOR = vec4(0.2, 0.2, 0.2, COLOR.a);
	} else {
		COLOR = vec4(237.0/255.0, 119.0/255.0, 64.0/255.0, COLOR.a);
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
