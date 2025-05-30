extends ColorRect

const UI_THEME = preload("uid://bganbh0ijrnt7")
var tween

func _ready() -> void:
	print(material.get("shader_parameter/gradient"))
	
#	How to change a GradientTexture2D, could be useful changing themes
	material.set("shader_parameter/gradient", preload("uid://ddwt5dglitg54") as GradientTexture2D) # UID = world 1

	var tab_container_stylebox_flat: StyleBoxFlat = UI_THEME.get_stylebox("panel", "TabContainer")
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_interval(2.0)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(tab_container_stylebox_flat, "border_width_bottom", 50.0, 0.5)
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_tab_container_tab_hovered(tab: int) -> void:
	if tween:
		tween.kill()
	var tab_container_stylebox_flat: StyleBoxFlat = UI_THEME.get_stylebox("tab_hovered", "TabContainer")
	tab_container_stylebox_flat.border_color = Color(0.0, 0.0, 0.0)

	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(tab_container_stylebox_flat, "border_color", Color(5.0, 5.0, 5.0), 0.5)
