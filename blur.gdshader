shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float lod: hint_range(0.0, 5) = 0.0;

//void vertex() {
	//// Called for every vertex the material is visible on.
//}

void fragment() {
	COLOR = textureLod(screen_texture, SCREEN_UV, lod);
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
