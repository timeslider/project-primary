class_name SelectLayout
extends SelectLargeValueBase

## The polyomino is calculated based on the value.
## You can think of the value as the polyomino index.
@onready var polyomino_label: Label = $PolyominoLabel
var _polyomino_value: int = 0

@onready var canon: Button = $HBoxContainer/Canon as Button
@onready var flip_h: Button = $HBoxContainer/FlipH as Button
@onready var flip_v: Button = $HBoxContainer/FlipV as Button
@onready var rotate_cw: Button = $HBoxContainer/RotateCW as Button
@onready var rotate_ccw: Button = $HBoxContainer/RotateCCW as Button


func _ready() -> void:
	super()
	await Util.load_gen_states_v2()
	MAX_VALUE = 51016818604894741
	# This can't run in debug mode.
	# It will have to wait until gen_states is loaded
	#_polyomino_value = Util.get_polyomino(value)
	canon.pressed.connect(_on_canon_pressed)
	flip_h.pressed.connect(_on_flip_h_pressed)
	flip_v.pressed.connect(_on_flip_v_pressed)
	rotate_cw.pressed.connect(_on_rotate_cw_pressed)
	rotate_ccw.pressed.connect(_on_rotate_ccw_pressed)
	

func update_ui(_value: int) -> void:
	PuzzleSelectGlobal.polyomino = Util.get_polyomino(_value)
	value_label.text = value_string + String.num_uint64(PuzzleSelectGlobal.polyomino)

	quick_select.set_value_no_signal(float(_value) / MAX_VALUE)
	exact_select.text = str(int(_value))


func update_tiles() -> void:
	# TODO: Instead of clearing %Tiles, it needs to decide based on what we're
	# selecting
	# Clear value
	for node in %Tiles.get_children():
		node.queue_free()
	# Create polyomino
	# TODO: Figure out a better way to store tiles so they can be accessed
	# and moved easier later
	# TODO: The floor doens't have to be added each time. It can be static
	# in the background.
	for row in range(8):
		for col in range(8):
			var sprite2D: Sprite2D = Sprite2D.new()
			if Bitboard.get_bitboard_cell_by_col_row(PuzzleSelectGlobal.polyomino, col, row) == true:
				sprite2D.position = Vector2(col * 128, row * 128)
				sprite2D.texture = preload("res://Resources/wall.tres") as Texture2D
				tiles.add_child(sprite2D)
			else:
				sprite2D.position = Vector2(col * 128, row * 128)
				sprite2D.texture = preload("res://Resources/floor.tres") as Texture2D
				tiles.add_child(sprite2D)

	#Bitboard.print_bitboard(PuzzleSelectGlobal.polyomino)


func _on_canon_pressed() -> void:
	value = Util.get_polyomino_index(Bitboard.canonicalize(Util.get_polyomino(value)))


func _on_flip_h_pressed() -> void:
	value = Util.get_polyomino_index(Bitboard.flip_horizontal(Util.get_polyomino(value)))


func _on_flip_v_pressed() -> void:
	value = Util.get_polyomino_index(Bitboard.flip_vertical(Util.get_polyomino(value)))


func _on_rotate_cw_pressed() -> void:
	value = Util.get_polyomino_index(Bitboard.rotate_cw(Util.get_polyomino(value)))


func _on_rotate_ccw_pressed() -> void:
	value = Util.get_polyomino_index(Bitboard.rotate_ccw(Util.get_polyomino(value)))


#func _on_random_pressed():
	#value = int(randf() * MAX_VALUE)
