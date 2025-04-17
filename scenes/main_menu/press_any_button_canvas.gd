extends CanvasLayer

#@onready var animation_player: AnimationPlayer = $AnimationPlayer
# Press any button
@onready var press_any_button_canvas: CanvasLayer = %PressAnyButtonCanvas
#var press_any_button_bool: bool = false
@onready var main_menu_canvas: CanvasLayer = %MainMenuCanvas

func _ready() -> void:
	pass
	#animation_player.play("fade_in_out_loop")

func _input(event: InputEvent) -> void:
	if Input.is_anything_pressed() and press_any_button_canvas.visible == true:
		print(InputEventKey)
		# TODO: Juice, fade one out and fade in the other
		# Play a sound
		press_any_button_canvas.visible = false
		main_menu_canvas.visible = true
		self.process_mode = Node.PROCESS_MODE_DISABLED
