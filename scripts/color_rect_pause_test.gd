extends ColorRect

var x: float = 0.0

func _process(delta: float) -> void:
	if x > 2 * PI:
		x = 0
	x += delta
	global_position = Vector2(cos(x) * 10, sin(x) * 10)
