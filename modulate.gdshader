shader_type spatial; // Defines this as a 3D shader

// Expose a color variable to the editor, defaulting to white
uniform vec3 modulate_color : source_color = vec3(1.0, 1.0, 1.0);
uniform sampler2D albedo_texture : source_color;

void fragment() {
    vec3 texture_color = texture(albedo_texture, UV).rgb;
	ALBEDO = (texture_color * modulate_color).rgb;

    // Modulate the alpha as well, if desired
    //ALPHA = texture_albedo.a * modulate_color.a;
}