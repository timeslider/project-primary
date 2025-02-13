shader_type canvas_item;

uniform float current_angle;
uniform float start_angle;
uniform bool flip;



void fragment() {
	// Called for every pixel the material is visible on.
	mat2 rot = mat2( vec2(cos(start_angle), -sin(start_angle)),
					 vec2(sin(start_angle), cos(start_angle)) );

	vec2 pos = UV - vec2(0.5,0.5); //shift the space so that (0,0) is at the center of the sprite
	if (flip) {
		pos.x = -pos.x;
	}
	pos = rot * pos;
	float angle = atan(pos.y, pos.x) + PI; //Need to add PI here? I think i did something wrong in the rotation matrix...

	COLOR.a *= step(current_angle, angle);
	}


//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
