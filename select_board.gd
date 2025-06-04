extends VBoxContainer

@onready var board_index_label: Label = %BoardIndexLabel
@onready var polyomino_label: Label = %PolyominoLabel

@onready var quick_select: HSlider = %QuickSelect
@onready var exact_select: LineEdit = %ExactSelect
@onready var scroll_select: HSlider = %ScrollSelect
@onready var decrement: Button = %Decrement
@onready var increment: Button = %Increment
@onready var random: Button = %Random

@onready var canon: Button = %Canon
@onready var flip_h: Button = %FlipH
@onready var flip_v: Button = %FlipV
@onready var rotate_cw: Button = %RotateCW
@onready var rotate_ccw: Button = %RotateCCW

## Limits how often the logic runs in the process function
var i: int = 0

# NOTE: This is one less than the total number of polyominoes
# since it's being uses as a zero-based index
## The max index for get_polyomino()
const MAX_VALUE: int = 51016818604894741

## This index is read to determine which board is picked.[br]
## get_polyomino(index: int) performs a lookup to find the polyomino at index[br]
## It ranges from 0 to 51016818604894741
var board_index: int = 0:
	set(value):
		# Guard against bad values
		if value < 0:
			printerr("value was less than 0")
			board_index = 0
			board_index_label.text = "Board index: 0"
			polyomino = Util.get_polyomino(0) # Can probably make this 0
			polyomino_label.text = "Polyomino: " + str(polyomino)
			quick_select.set_value_no_signal(0)
			exact_select.text = str("0")
			return
		if value > MAX_VALUE:
			printerr("value was greater than MAX_VALUE")
			board_index = MAX_VALUE
			board_index_label.text = "Board index: " + str(MAX_VALUE)
			polyomino = Util.get_polyomino(MAX_VALUE)
			polyomino_label.text = "Polyomino: " + String.num_uint64(polyomino)
			quick_select.set_value_no_signal(MAX_VALUE)
			exact_select.text = str(int(MAX_VALUE))
			return

		for node in get_node("../../Node2D").get_children():
			node.queue_free()
		board_index = value
		board_index_label.text = "Board index: " + str(board_index)
		polyomino = Util.get_polyomino(board_index)
		polyomino_label.text = "Polyomino: " + String.num_uint64(polyomino)
		quick_select.set_value_no_signal(float(value) / MAX_VALUE)
		exact_select.text = str(int(value))
		var a: Bitboard = Bitboard.new()
		a.wall_data = Util.get_polyomino(board_index)

		for row in range(8):
			for col in range(8):
				if Bitboard.get_bitboard_cell_by_col_row(col, row) == false:
					var sprite2D: Sprite2D = Sprite2D.new()
					sprite2D.position = Vector2(col * 128, row * 128)
					sprite2D.texture = preload("res://icon.svg") as Texture2D
					$"../../Node2D".add_child(sprite2D)
		
		
var dragging: bool = false
var polyomino: int
#@export var scroll_select_scale: int

func _ready() -> void:
	#region For testing only, please delete
	print("Testing begining")
	await Util.load_gen_states_v2()
	var polyomino_index: int = 128
	var a: Bitboard = Bitboard.new()
	a.wall_data = Util.get_polyomino(polyomino_index)
	Bitboard.print_bitboard()
	a.wall_data = Bitboard.flip_vertical(a.wall_data)
	Bitboard.print_bitboard()
	print(Util.get_polyomino_index(a.wall_data))
	# The above work should work... 23237128408669395
	
	print("Testing going the other way...")
	polyomino_index = 23237128408669395
	a.wall_data = Util.get_polyomino(polyomino_index)
	Bitboard.print_bitboard()
	a.wall_data = Bitboard.flip_vertical(a.wall_data)
	Bitboard.print_bitboard()
	print(String.num_uint64(-500))
	#print(int64_to_string(-500))
	print(Util.get_polyomino_index(a.wall_data))
	
	print("Testing ended")
	#endregion
	exact_select.text = "0"
	quick_select.value_changed.connect(_on_quick_select_value_changed)
	exact_select.text_submitted.connect(_on_exact_select_text_submitted)
	scroll_select.drag_ended.connect(_on_scroll_select_drag_ended)
	decrement.pressed.connect(_on_decrement_pressed)
	increment.pressed.connect(_on_increment_pressed)
	random.pressed.connect(_on_random_pressed)
	canon.pressed.connect(_on_canon_pressed)
	flip_h.pressed.connect(_on_flip_h_pressed)
	flip_v.pressed.connect(_on_flip_v_pressed)
	rotate_cw.pressed.connect(_on_rotate_cw_pressed)
	rotate_ccw.pressed.connect(_on_rotate_ccw_pressed)
	
	# Initalize as 0 for now.
	# TODO: Save board_index to file and read it
	board_index = 0
	board_index_label.text = "Board index: " + str(board_index)
	polyomino = Util.get_polyomino(board_index)
	polyomino_label.text = "Polyomino: " + str(polyomino)


func _on_quick_select_value_changed(value: float) -> void:
	if is_equal_approx(value, 1.0):
		board_index = MAX_VALUE
	else:
		board_index = int(value * MAX_VALUE)


func _on_exact_select_text_submitted(new_text: String) -> void:
	board_index = int(new_text)


func _on_scroll_select_drag_ended(_value_changed: bool) -> void:
	scroll_select.value = 0
	dragging = false


func _on_random_pressed() -> void:
	board_index = int(randf() * MAX_VALUE)


func _process(_delta: float) -> void:
	# var i is initalized outside the process function so it doesn't create
	# an annoyance for the GB collector
	i += 1
	# This SHOULD limit execution to every n frames
	if i % 15 != 0:
		return
	
	var temp_scroll_select: float = snappedf(scroll_select.value, 1.0)
	
	if scroll_select.value == 0:
		i = 0
		return
	
	# This has been moved to the board_index setter	
	#if board_index + scroll_select.value < 0.0:
		#print("Returing because board_index would have been less than 0")
		#board_index = 0
		#return
	#
	#
	#if board_index + scroll_select.value > MAX_VALUE:
		#board_index = MAX_VALUE
		#print("Returning because board_index is MAX_VALUE")
		#return
	
	
	if scroll_select.value < 0:
		board_index -= int(pow(10, -(temp_scroll_select + 1)))
	elif scroll_select.value > 0:
		board_index += int(pow(10, temp_scroll_select - 1))


func _on_decrement_pressed() -> void:
	print("Decrement")
	board_index -= 1


func _on_increment_pressed() -> void:
	print("Increment")
	board_index += 1


func _on_canon_pressed() -> void:
	board_index = Util.get_polyomino_index(Bitboard.canonicalize(Util.get_polyomino(board_index)))
	


func _on_flip_h_pressed() -> void:
	board_index = Util.get_polyomino_index(Bitboard.flip_horizontal(Util.get_polyomino(board_index)))


func _on_flip_v_pressed() -> void:
	board_index = Util.get_polyomino_index(Bitboard.flip_vertical(Util.get_polyomino(board_index)))


func _on_rotate_cw_pressed() -> void:
	board_index = Util.get_polyomino_index(Bitboard.rotate_cw(Util.get_polyomino(board_index)))


func _on_rotate_ccw_pressed() -> void:
	board_index = Util.get_polyomino_index(Bitboard.rotate_ccw(Util.get_polyomino(board_index)))


# Prints a signed 64-bit int as if it's unsigned
#func int64_to_string(x: int) -> String:
	#
	#if x >= 0:
		#return str(x)
	#
	#var hi: int = x & 0xFFFF_FFFF
	#var lo: int = (x >> 32) & 0xFFFF_FFFF
	#var buffer: PackedByteArray = PackedByteArray()
	#while value != 0:
		#var digit: int = value % 10
		#buffer.append(48 + int(digit))
		#value /= 10
	#buffer.reverse()
	#return buffer.get_string_from_ascii()
