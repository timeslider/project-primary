shader_type canvas_item;

uniform vec4 color1: source_color;
uniform vec4 color2: source_color;
uniform float threshold;
uniform float intensity;
uniform float opacity;
uniform vec4 glow_color: source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 pixel_color = texture(TEXTURE, UV);
	float distance = length(pixel_color - color1);
	float distance_second = length(pixel_color - color2);
	vec4 modified_glow = glow_color;
	modified_glow.a = opacity;
	
	if (distance < threshold || distance_second < threshold){
		COLOR = mix(pixel_color, modified_glow * intensity, modified_glow.a);
	}
	else{
		COLOR = pixel_color;
	}
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
