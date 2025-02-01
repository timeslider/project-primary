extends Node3D

@export var move_mode: GUIDEMappingContext
@export var move: GUIDEAction
@export var move_speed = 0.2

func _ready() -> void:
	GUIDE.enable_mapping_context(move_mode)

func _process(delta: float) -> void:
	#print(move.value_axis_3d[0])
	position += move.value_axis_3d * move_speed
