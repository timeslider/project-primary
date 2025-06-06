class_name SelectBase
extends VBoxContainer

## This is a base class for selecing a large value
## It uses sliders and clever math to get around the 64-bit signed integer limit

## The label for the title of this page
@export var select_title: Label

## The next for the label for the title of this page
@export var select_title_string: String

## The main value to be selected
@export var value_label: Label

## The name of the main value to be selected
@export var value_name: String

## The quick select slider. It ranges from 0 to n and quickly
## lets us pick a value within that range
@export var quick_select: HSlider

## The is a LineEdit that lets us type an exact value into the field.
## Has logic that prevents non-numeric values from being entered
@export var exact_select: NumericLineEdit

## This slider lets the player increment or decrement by powers of 10 every
## n frames
@export var scroll_select: HSlider

## Used in conjunction with scroll_select to determine how often it updates
@export var scroll_select_speed: int = 15

## Decrease the value by exactly 1
@export var decrement_by_1: Button

## Decrease the value by exactly 10
@export var decrement_by_10: Button

## Decrease the value by exactly 100
@export var decrement_by_100: Button

## Increase the value by exactly 1
@export var increment_by_1: Button

## Increase the value by exactly 10
@export var increment_by_10: Button

## Increase the value by exactly 100
@export var increment_by_100: Button

# NOTE: This could probably be its own separate class (class_name Pagination?)
## The back button for this page
@export var back_button: Button

## The help button for this page
@export var help_button: Button

## The next button for this page
@export var next_button: Button

# This probably needs to be something different
@export_file("*.tscn") var back_scene: String
@export_file("*.tscn") var help_scene: String
@export_file("*.tscn") var next_scene: String

# This should be stored globally, maybe?
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
			_update_tiles()
			return
		
		if _value > MAX_VALUE:
			value = MAX_VALUE
			_update_ui(MAX_VALUE)
			_update_tiles()
			return

		value = _value
		_update_ui(value)
		_update_tiles()

enum SelectOptions {POLYOMINO, PLAYERS, GOALS}

@export var Select: SelectOptions


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

	back_button.pressed.connect(_on_back_pressed)
	help_button.pressed.connect(_on_help_pressed)
	next_button.pressed.connect(_on_next_pressed)
	
	
	# Initalize as 0 for now.
	# TODO: Save polyomino_index to file and read it
	match Select:
		SelectOptions.POLYOMINO:
			if PuzzleSelectGlobal.polyomino == -1:
				value = 0
				_update_ui(0)
				_update_tiles()
		SelectOptions.PLAYERS:
			if PuzzleSelectGlobal.players == -1:
				value = 0
				_update_ui(0)
				_update_tiles()
		SelectOptions.GOALS:
			if PuzzleSelectGlobal.goals == -1:
				value = 0
				_update_ui(0)
				_update_tiles()

	_update_tiles()
func _on_quick_select_value_changed(_value: float) -> void:
	if is_equal_approx(_value, 1.0):
		value = MAX_VALUE
	else:
		value = int(_value * MAX_VALUE)


func _on_exact_select_text_submitted(new_text: String) -> void:
	value = int(new_text)


func _on_scroll_select_drag_ended(_value_changed: bool) -> void:
	scroll_select.value = 0


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

# TODO: Use the select export variable to change which value we are setting
# in the global scope
func _update_ui(_value: int) -> void:
	match Select:
		SelectOptions.POLYOMINO:
			PuzzleSelectGlobal.polyomino = Util.get_polyomino(_value)
			value_label.text = value_name + String.num_uint64(PuzzleSelectGlobal.polyomino)
		SelectOptions.PLAYERS:
			PuzzleSelectGlobal.players = _value
			value_label.text = value_name + String.num_uint64(PuzzleSelectGlobal.players)
		SelectOptions.GOALS:
			PuzzleSelectGlobal.goals = _value
			value_label.text = value_name + String.num_uint64(PuzzleSelectGlobal.goals)
	#value_label.text = value_name + str(_value)
	# Not sure
	quick_select.set_value_no_signal(float(_value) / MAX_VALUE)
	exact_select.text = str(int(_value))


# We won't be update the polyomino here
func _update_tiles() -> void:
	match Select:
		SelectOptions.POLYOMINO:
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
		SelectOptions.PLAYERS:
			pass
		SelectOptions.GOALS:
			pass
	# TODO: Instead of clearing %Tiles, it needs to decide based on what we're
	# selecting
	# Clear value

	#Bitboard.print_bitboard(PuzzleSelectGlobal.polyomino)
	match Select:
		SelectOptions.POLYOMINO:
			if PuzzleSelectGlobal.polyomino == -1:
				value = 0
				_update_ui(0)
				_update_tiles()
		SelectOptions.PLAYERS:
			if PuzzleSelectGlobal.players == -1:
				value = 0
				_update_ui(0)
				_update_tiles()
		SelectOptions.GOALS:
			if PuzzleSelectGlobal.goals == -1:
				value = 0
				_update_ui(0)
				_update_tiles()


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
