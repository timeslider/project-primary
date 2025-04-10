extends Control

var progress: Array = []
@export var scene_name: String
@export var packed: PackedScene
var scene_load_status = 0
@onready var label: Label = $Label

func _ready() -> void:
	ResourceLoader.load_threaded_request(scene_name)

func _process(_delta: float) -> void:
	scene_load_status = ResourceLoader.load_threaded_get_status(scene_name, progress)
	label.text = str(progress[0]) + "%"
	if progress[0] == 1.0:
		get_tree().change_scene_to_packed(packed)
