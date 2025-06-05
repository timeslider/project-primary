shader_type spatial; // Defines this as a 3D shader

// Expose a color variable to the editor, defaulting to white
uniform vec4 modulate_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    // Get the base color from the albedo texture and UV coordinates
    //vec4 texture_albedo = texture(TEXTURE_ALBEDO, UV);

    // Multiply the texture's color by the modulate_color
    // If you want to modulate the material's existing albedo (e.g., if no texture or want to combine with a set color):
    // ALBEDO = ALBEDO * modulate_color.rgb;
    // Or, if you primarily rely on a texture:
    //ALBEDO = texture_albedo.rgb * modulate_color.rgb;

    // Modulate the alpha as well, if desired
    //ALPHA = texture_albedo.a * modulate_color.a;
}