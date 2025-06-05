class_name SelectBase
extends VBoxContainer

## This is a base class for selecing a large value
## It uses sliders and clever math to get around the 64-bit signed integer limit


@export var select_title: Label
@export var select_title_string: String

@export var value_label: Label
@export var value_name: String

@export var quick_select: HSlider
@export var exact_select: LineEdit
@export var scroll_select: HSlider
@export var decrement_by_1: Button
@export var decrement_by_10: Button
@export var decrement_by_100: Button
@export var increment_by_1: Button
@export var increment_by_10: Button
@export var increment_by_100: Button

#@onready var random: Button = %Random

# These will need to be added to a subclass that just selects the polyomino
#@onready var canon: Button = %Canon
#@onready var flip_h: Button = %FlipH
#@onready var flip_v: Button = %FlipV
#@onready var rotate_cw: Button = %RotateCW
#@onready var rotate_ccw: Button = %RotateCCW

@export var back_button: Button
@export var help_button: Button
@export var next_button: Button

# This probably needs to be something different
@export var back_scene: String
@export var help_scene: String
@export var next_scene: String

# This should be stored globally
@onready var tiles: Node2D = %Tiles

## Limits how often the logic runs in the process function
var i: int = 0


# This will have to be set based on what we are modifying
## The max index for the value we're selecting
var MAX_VALUE: int = 255

## This is the main value we are selecting
var value: int = 0:
	set(_value):
		# Only do work if you need too
		if value == _value:
			return
		
		# Guard against bad values
		if _value < 0:
			value = 0
			_update_ui(0)
			_update_value()
			return
		
		if _value > MAX_VALUE:
			printerr("value was greater than MAX_VALUE")
			value = MAX_VALUE
			_update_ui(MAX_VALUE)
			_update_value()
			return

		value = _value
		_update_ui(value)
		_update_value()


## The bitboard used for the polyomino
#var polyomino: int


func _ready() -> void:
	#region For testing only, please delete
	#print("Testing begining")
	await Util.load_gen_states_v2()
	#var polyomino_test_index: int = 128
	#var a: int = Util.get_polyomino(polyomino_test_index)
	#Bitboard.print_bitboard(a)
	#a = Bitboard.flip_vertical(a)
	#Bitboard.print_bitboard(a)
	#print(Util.get_polyomino_index(a))
	## The above work should work... 23237128408669395
	#
	#print("Testing going the other way...")
	#polyomino_test_index = 23237128408669395
	#a = Util.get_polyomino(polyomino_test_index)
	#Bitboard.print_bitboard(a)
	#a = Bitboard.flip_vertical(a)
	#Bitboard.print_bitboard(a)
	#print(String.num_uint64(-500))
	#print(Util.get_polyomino_index(a))
	#
	#print("Testing ended")
	#endregion
	
	# Title
	select_title.text = select_title_string
	
	# This needs to be read from file, maybe?
	exact_select.text = "0"
	quick_select.value_changed.connect(_on_quick_select_value_changed)
	exact_select.text_submitted.connect(_on_exact_select_text_submitted)
	exact_select.text_changed.connect(exact_select.limit_input)
	scroll_select.drag_ended.connect(_on_scroll_select_drag_ended)
	decrement_by_1.pressed.connect(_on_crement_pressed.bind(-1))
	decrement_by_10.pressed.connect(_on_crement_pressed.bind(-10))
	decrement_by_100.pressed.connect(_on_crement_pressed.bind(-100))
	increment_by_1.pressed.connect(_on_crement_pressed.bind(1))
	increment_by_10.pressed.connect(_on_crement_pressed.bind(10))
	increment_by_100.pressed.connect(_on_crement_pressed.bind(100))
	#random.pressed.connect(_on_random_pressed)
	#canon.pressed.connect(_on_canon_pressed)
	#flip_h.pressed.connect(_on_flip_h_pressed)
	#flip_v.pressed.connect(_on_flip_v_pressed)
	#rotate_cw.pressed.connect(_on_rotate_cw_pressed)
	#rotate_ccw.pressed.connect(_on_rotate_ccw_pressed)
	back_button.pressed.connect(_on_back_pressed)
	help_button.pressed.connect(_on_help_pressed)
	next_button.pressed.connect(_on_next_pressed)
	
	# Initalize as 0 for now.
	# TODO: Save polyomino_index to file and read it
	value = 0
	_update_ui(0)
	_update_value()

func _on_quick_select_value_changed(_value: float) -> void:
	if is_equal_approx(_value, 1.0):
		value = MAX_VALUE
	else:
		value = int(_value * MAX_VALUE)


func _on_exact_select_text_submitted(new_text: String) -> void:
	value = int(new_text)


func _on_scroll_select_drag_ended(_value_changed: bool) -> void:
	scroll_select.value = 0


#func _on_random_pressed() -> void:
	#polyomino_index = int(randf() * MAX_VALUE)


func _process(_delta: float) -> void:
	i += 1
	if i % 15 != 0:
		return
	
	var temp_scroll_select: float = snappedf(scroll_select.value, 1.0)
	
	if scroll_select.value == 0:
		i = 0
		return

	if scroll_select.value < 0:
		value -= int(pow(10, -(temp_scroll_select + 1)))
	elif scroll_select.value > 0:
		value += int(pow(10, temp_scroll_select - 1))


func _on_crement_pressed(_value: int) -> void:
	value += _value


#func _on_canon_pressed() -> void:
	#polyomino_index = Util.get_polyomino_index(Bitboard.canonicalize(Util.get_polyomino(polyomino_index)))
#
#
#func _on_flip_h_pressed() -> void:
	#polyomino_index = Util.get_polyomino_index(Bitboard.flip_horizontal(Util.get_polyomino(polyomino_index)))
#
#
#func _on_flip_v_pressed() -> void:
	#polyomino_index = Util.get_polyomino_index(Bitboard.flip_vertical(Util.get_polyomino(polyomino_index)))
#
#
#func _on_rotate_cw_pressed() -> void:
	#polyomino_index = Util.get_polyomino_index(Bitboard.rotate_cw(Util.get_polyomino(polyomino_index)))
#
#
#func _on_rotate_ccw_pressed() -> void:
	#polyomino_index = Util.get_polyomino_index(Bitboard.rotate_ccw(Util.get_polyomino(polyomino_index)))


func _update_ui(_value: int) -> void:
	#value_label.text = value_name + str(_value)
	PuzzleSelectGlobal.polyomino = Util.get_polyomino(_value)
	# Not sure
	value_label.text = value_name + String.num_uint64(PuzzleSelectGlobal.polyomino)
	quick_select.set_value_no_signal(float(_value) / MAX_VALUE)
	exact_select.text = str(int(_value))


# We won't be update the polyomino here
func _update_value() -> void:
	# Clear value
	for node in %Tiles.get_children():
		node.queue_free()

	Bitboard.print_bitboard(PuzzleSelectGlobal.polyomino)
	
	# Create polyomino
	# TODO: Figure out a better way to store tiles so they can be accessed
	# and moved easier later
	# NOTE: The floor doens't have to be added each time. It can be static
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


func _on_back_pressed() -> void:
	# Go back to select polyomino
	get_tree().change_scene_to_file(back_scene)
	pass


func _on_next_pressed() -> void:
	# Go to select_goal_positions
	get_tree().change_scene_to_file(next_scene)


func _on_help_pressed() -> void:
	# Display a help message for this page
	print("Pressed help from the " + select_title.text + " menu.")
	pass
