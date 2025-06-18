extends Node
#
#@onready var polyomino_index_label: Label = %PolyominoIndexLabel
#@onready var polyomino_label: Label = %PolyominoLabel
#
#
#@export var canon: Button
#@export var flip_h: Button
#@export var flip_v: Button
#@export var rotate_cw: Button
#@export var rotate_ccw: Button
#@export var random: Button
#
##@onready var back_button: Button = %BackButton
##@onready var help_button: Button = %HelpButton
##@onready var next_button: Button = %NextButton
#
##@onready var tiles: Node2D = %Tiles
#
### Limits how often the logic runs in the process function
##var i: int = 0
#
## NOTE: This is one less than the total number of polyominoes
## since it's being uses as a zero-based index
### The max index for get_polyomino()
#
#
### This index is read to determine which polyomino is picked.[br]
### get_polyomino(index: int) performs a lookup to find the polyomino at index[br]
### It ranges from 0 to 51016818604894741
##var polyomino_index: int = 0:
	##set(value):
		### Only do work if you need too
		##if polyomino_index == value:
			##return
		##
		### Guard against bad values
		##if value < 0:
			##polyomino_index = 0
			##_update_ui(0)
			##_update_polyomino()
			##return
		##
		##if value > MAX_VALUE:
			##printerr("value was greater than MAX_VALUE")
			##polyomino_index = MAX_VALUE
			##_update_ui(MAX_VALUE)
			##_update_polyomino()
			##return
##
		##polyomino_index = value
		##_update_ui(value)
		##_update_polyomino()
#
## In this script, value is the polyomino index and polyomino is the bitboard
## we will be using
### The bitboard used for the polyomino
#var polyomino: int
#
#
#func _ready() -> void:
	#await super()
	##region For testing only, please delete
	##print("Testing begining")
	##await Util.load_gen_states_v2()
	##var polyomino_test_index: int = 128
	##var a: int = Util.get_polyomino(polyomino_test_index)
	##Bitboard.print_bitboard(a)
	##a = Bitboard.flip_vertical(a)
	##Bitboard.print_bitboard(a)
	##print(Util.get_polyomino_index(a))
	### The above work should work... 23237128408669395
	##
	##print("Testing going the other way...")
	##polyomino_test_index = 23237128408669395
	##a = Util.get_polyomino(polyomino_test_index)
	##Bitboard.print_bitboard(a)
	##a = Bitboard.flip_vertical(a)
	##Bitboard.print_bitboard(a)
	##print(String.num_uint64(-500))
	##print(Util.get_polyomino_index(a))
	##
	##print("Testing ended")
	##endregion
	#MAX_VALUE = 51016818604894741
	#exact_select.text = "0"
	##quick_select.value_changed.connect(_on_quick_select_value_changed)
	##exact_select.text_submitted.connect(_on_exact_select_text_submitted)
	##exact_select.text_changed.connect(exact_select.limit_input)
	##scroll_select.drag_ended.connect(_on_scroll_select_drag_ended)
	##decrement_by_1.pressed.connect(_on_crement_pressed.bind(-1))
	##decrement_by_10.pressed.connect(_on_crement_pressed.bind(-10))
	##decrement_by_100.pressed.connect(_on_crement_pressed.bind(-100))
	##increment_by_1.pressed.connect(_on_crement_pressed.bind(1))
	##increment_by_10.pressed.connect(_on_crement_pressed.bind(10))
	##increment_by_100.pressed.connect(_on_crement_pressed.bind(100))
	#random.pressed.connect(_on_random_pressed)
	#canon.pressed.connect(_on_canon_pressed)
	#flip_h.pressed.connect(_on_flip_h_pressed)
	#flip_v.pressed.connect(_on_flip_v_pressed)
	#rotate_cw.pressed.connect(_on_rotate_cw_pressed)
	#rotate_ccw.pressed.connect(_on_rotate_ccw_pressed)
	##back_button.pressed.connect(_on_back_pressed)
	##help_button.pressed.connect(_on_help_pressed)
	##next_button.pressed.connect(_on_next_pressed)
	#
	## Initalize as 0 for now.
	## TODO: Save polyomino_index to file and read it
	#
#
##func _on_quick_select_value_changed(_value: float) -> void:
	##if is_equal_approx(_value, 1.0):
		##polyomino_index = MAX_VALUE
	##else:
		##polyomino_index = int(_value * MAX_VALUE)
##
##
##func _on_exact_select_text_submitted(new_text: String) -> void:
	##polyomino_index = int(new_text)
##
##
##func _on_scroll_select_drag_ended(_value_changed: bool) -> void:
	##scroll_select.value = 0
#
#
#func _on_random_pressed() -> void:
	#value = int(randf() * MAX_VALUE)
#
#
##func _process(_delta: float) -> void:
	##i += 1
	##if i % 15 != 0:
		##return
	##
	##var temp_scroll_select: float = snappedf(scroll_select.value, 1.0)
	##
	##if scroll_select.value == 0:
		##i = 0
		##return
##
	##if scroll_select.value < 0:
		##polyomino_index -= int(pow(10, -(temp_scroll_select + 1)))
	##elif scroll_select.value > 0:
		##polyomino_index += int(pow(10, temp_scroll_select - 1))
#
#
#func _on_canon_pressed() -> void:
	#value = Util.get_polyomino_index(Bitboard.canonicalize(Util.get_polyomino(value)))
#
#
#func _on_flip_h_pressed() -> void:
	#value = Util.get_polyomino_index(Bitboard.flip_horizontal(Util.get_polyomino(value)))
#
#
#func _on_flip_v_pressed() -> void:
	#value = Util.get_polyomino_index(Bitboard.flip_vertical(Util.get_polyomino(value)))
#
#
#func _on_rotate_cw_pressed() -> void:
	#value = Util.get_polyomino_index(Bitboard.rotate_cw(Util.get_polyomino(value)))
#
#
#func _on_rotate_ccw_pressed() -> void:
	#value = Util.get_polyomino_index(Bitboard.rotate_ccw(Util.get_polyomino(value)))
#
#
#func _update_ui(_value: int) -> void:
	#polyomino_index_label.text = "Level index: " + str(_value)
	#PuzzleSelectGlobal.polyomino = Util.get_polyomino(_value)
	#polyomino_label.text = "Level: " + String.num_uint64(PuzzleSelectGlobal.polyomino)
	#quick_select.set_value_no_signal(float(_value) / MAX_VALUE)
	#exact_select.text = str(int(_value))
#
#
#func _update_tiles() -> void:
	## Clear polyomino
	#for node in %Tiles.get_children():
		#node.queue_free()
#
	##Bitboard.print_bitboard(PuzzleSelectGlobal.polyomino)
	#
	## Create polyomino
	## TODO: Figure out a better way to store tiles so they can be accessed
	## and moved easier later
	## NOTE: The floor doens't have to be added each time. It can be static
	## in the background.
	#for row in range(8):
		#for col in range(8):
			#var sprite2D: Sprite2D = Sprite2D.new()
			#if Bitboard.get_bitboard_cell_by_col_row(PuzzleSelectGlobal.polyomino, col, row) == true:
				#sprite2D.position = Vector2(col * 128, row * 128)
				#sprite2D.texture = preload("res://Resources/wall.tres") as Texture2D
				#tiles.add_child(sprite2D)
			#else:
				#sprite2D.position = Vector2(col * 128, row * 128)
				#sprite2D.texture = preload("res://Resources/floor.tres") as Texture2D
				#tiles.add_child(sprite2D)
#
#
##func _on_back_pressed() -> void:
	### Go back to main menu
	##pass
##
##
##func _on_next_pressed() -> void:
	### Go to select_starting_positions
	##get_tree().change_scene_to_file("res://scenes/select_staring_positions.tscn")
#
#
#func _on_help_pressed() -> void:
	## Display a help message for this page
	#pass
