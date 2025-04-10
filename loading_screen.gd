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

#func _process(_delta: float) -> void:
	#scene_load_status = ResourceLoader.load_threaded_get_status(scene_name, progress)
	#label.text = str(progress[0]) + "%"
	#if progress[0] == 1.0:
		#get_tree().change_scene_to_packed(packed)

# Simulate loading...
func simulate_loading_method() -> void:
	var tween = create_tween()
	var simulated_progress: float = 0.0
	tween.tween_method(_update_label.bind(label), 0.0, 100.0, 1.0)
	await tween.finished
	get_tree().change_scene_to_packed(packed)

func _update_label(new_number: float, label: Label) -> void:
	label.text = str(new_number) + "%"
