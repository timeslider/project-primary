class_name MainMenu
extends Control

@onready var start_button: Button = %StartButton
@onready var exit_button: Button = %ExitButton
@export var move_lookup_table: Dictionary
const MOVE_LOOKUP_TABLES = preload("res://move_lookup_tables.tres")
var PRIMARY_LOOKUP_TABLE: Dictionary = MOVE_LOOKUP_TABLES.get_meta("primary") as Dictionary
#const LET_IT_SLIDE_LOOKUP_TABLE = MOVE_LOOKUP_TABLES.get_meta("let_it_slide")
const x: Dictionary = {
		2: "Hello",
		4: "Buy",
		5: "What's good son",
		}
#@onready var start_level = preload()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.button_up.connect(_on_start_button_button_up)
	exit_button.button_up.connect(_on_exit_button_button_up)
	#print(MOVE_LOOKUP_TABLES.get_meta("let_it_slide"))
	print(MOVE_LOOKUP_TABLES.get_meta("primary"))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_button_up() -> void:
	pass # Replace with function body.

func _on_exit_button_button_up() -> void:
	get_tree().quit()

func _input(event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("test"):
		print(PRIMARY_LOOKUP_TABLE[Vector2i(232, 2)])
