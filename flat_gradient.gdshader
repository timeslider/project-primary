shader_type spatial;
uniform sampler2D color_ramp;

void fragment() {
	COLOR = mix(color_ramp, UV);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
