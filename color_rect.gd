extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	print(material.get("shader_parameter/gradient"))
	
#	How to change a GradientTexture2D, could be useful changing themes
	material.set("shader_parameter/gradient", preload("uid://ddwt5dglitg54") as GradientTexture2D) # UID = world 1
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
