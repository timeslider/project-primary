abstract class_name SelectLargeValueBase
extends VBoxContainer

## This is a base class for selecing a large value
## It uses sliders and clever math to get around the 64-bit signed integer limit

## The label for the title of this page
@onready var title_label: Label = $SelectTitle as Label

## The text for the label for the title of this page
@export var title_string: String

## The main value to be selected
@onready var value_label: Label = $ValueLabel as Label

## The name of the main value to be selected
@export var value_string: String

## The is a LineEdit that lets us type an exact value into the field.
## Has logic that prevents non-numeric values from being entered
@onready var exact_select: NumericLineEdit = $ExactSelect as NumericLineEdit

## The quick select slider. It ranges from 0 to n and quickly
## lets us pick a value within that range
@onready var quick_select: HSlider = $QuickSelect as HSlider

## This slider lets the player increment or decrement by powers of 10 every
## n frames
@onready var scroll_select: HSlider = $ScrollSelect as HSlider

## Used in conjunction with scroll_select to determine how often it updates
@export var scroll_select_speed: int = 15


@onready var decrement_by_100: Button = $IncrementRow/DecrementBy100 as Button
@onready var decrement_by_10: Button = $IncrementRow/DecrementBy10 as Button
@onready var decrement_by_1: Button = $IncrementRow/DecrementBy1 as Button
@onready var increment_by_1: Button = $IncrementRow/IncrementBy1 as Button
@onready var increment_by_10: Button = $IncrementRow/IncrementBy10 as Button
@onready var increment_by_100: Button = $IncrementRow/IncrementBy100 as Button

@onready var random: Button = $HBoxContainer/Random as Button

# This should be stored globally, maybe?
@onready var tiles: Node2D = %Tiles

# Used in conjustion with scroll select speed to Limit how often the logic runs
# in the process function
var _i: int = 0


# TODO: This will have to be set based on what we are modifying.
## The max index for the value we're selecting.
@export var MAX_VALUE: int = 0
#var MAX_VALUE: int = 51016818604894741

## This is the main value we are selecting
var value: int = 0:
	set(_value):
		# Only do work if you need to
		if value == _value:
			return
		
		# Guard against bad values
		if _value < 0:
			value = 0
			update_ui(0)
			update_tiles()
			return
		
		if _value > MAX_VALUE:
			value = MAX_VALUE
			update_ui(MAX_VALUE)
			update_tiles()
			return

		value = _value
		update_ui(value)
		update_tiles()


func _ready() -> void:
	
	# Title
	title_label.text = title_string
	
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
	
	random.pressed.connect(_on_random_pressed)


# Exact select is a line edit that allows the player to enter in an exact value
# It supports alpha rejection automatically
func _on_exact_select_text_submitted(new_text: String) -> void:
	value = int(new_text)


# Quick select is a scroll bar that allows the player to quickly select a value
func _on_quick_select_value_changed(_value: float) -> void:
	if is_equal_approx(_value, 1.0):
		value = MAX_VALUE
	else:
		value = int(_value * MAX_VALUE)


# Scroll select lets the player increment the value by powers of 10 every
# scroll select speed frames.
func _on_scroll_select_drag_ended(_value_changed: bool) -> void:
	scroll_select.value = 0


func _process(_delta: float) -> void:
	_i += 1
	if _i % scroll_select_speed != 0:
		return
	
	if scroll_select.value == 0:
		_i = 0
		return

	if scroll_select.value < 0:
		value -= int(pow(10, -(snappedf(scroll_select.value, 1.0) + 1)))
	elif scroll_select.value > 0:
		value += int(pow(10, snappedf(scroll_select.value, 1.0) - 1))


func _on_crement_pressed(_value: int) -> void:
	value += _value


func _on_random_pressed():
	value = int(randf() * (MAX_VALUE + 1))


func update_ui(_value: int) -> void:
	pass


func update_tiles() -> void:
	pass
