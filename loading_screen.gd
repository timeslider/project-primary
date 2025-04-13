extends Control

var progress: Array = []
@export var scene_name: String
@export var packed: PackedScene
var scene_load_status = 0
@onready var label: Label = $Label
@export var simulate_loading: bool = false

func _ready() -> void:
	ResourceLoader.load_threaded_request(scene_name)
	if simulate_loading == true:
		simulate_loading_method()

# Simulate loading...
func simulate_loading_method() -> void:
	var tween = create_tween()
	tween.tween_method(_update_label.bind(label), 0.0, 100.0, 1.0)
	await tween.finished
	get_tree().change_scene_to_packed(packed)

func _update_label(new_number: float, _label: Label) -> void:
	_label.text = str(new_number) + "%"
