shader_type canvas_item;

// Uniforms
uniform sampler2D screen_texture : hint_screen_texture;
uniform float grain_amount : hint_range(0.0, 1.0) = 0.05; // Adjust the amount of grain
uniform float grain_size : hint_range(0.1, 1000.0) = 1.0; // Adjust the size of the grain


void fragment() {
	//COLOR = screen_textur;
}