class_name MainMenu
extends Control

@onready var start_button: Button = %StartButton
@onready var exit_button: Button = %ExitButton
#@onready var start_level = preload()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.button_up.connect(_on_start_button_button_up)
	exit_button.button_up.connect(_on_exit_button_button_up)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_button_up() -> void:
	pass # Replace with function body.

func _on_exit_button_button_up() -> void:
	get_tree().quit()
