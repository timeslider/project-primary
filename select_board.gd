extends VBoxContainer

@onready var board_value_label: Label = %BoardValue
@onready var quick_select: HSlider = %QuickSelect
@onready var exact_select: LineEdit = %ExactSelect
@onready var scroll_select: HSlider = %ScrollSelect
@onready var decrement: Button = %Decrement
@onready var increment: Button = %Increment
@onready var random: Button = %Random
## Limits how often something happens in the process function
var i: int = 0

const MAX_VALUE: int = 51016818604894742 - 1

## This value is read to determine which board is picked.
var board_value: int = 0:
	set(value):
		for node in get_node("../../Node2D").get_children():
			node.queue_free()
		board_value = value
		quick_select.set_value_no_signal(float(value) / MAX_VALUE)
		exact_select.text = str(int(value))
		var a: bitboard = bitboard.new()
		a.wall_data = Util.get_nth_polyomino(board_value)
		a.print_bitboard()
		for row in range(8):
			for col in range(8):
				if a.get_bitboard_cell_by_col_row(col, row) == false:
					var sprite2D: Sprite2D = Sprite2D.new()
					sprite2D.position = Vector2(col * 128, row * 128)
					sprite2D.texture = preload("res://icon.svg") as Texture2D
					$"../../Node2D".add_child(sprite2D)
		
		
var dragging: bool = false

@export var scroll_select_scale: int

func _ready() -> void:
	# For testing only, please delete
	Util.load_gen_states_v2()
	board_value_label.text = str(0)
	exact_select.text = "0"
	quick_select.value_changed.connect(_on_quick_select_value_changed)
	exact_select.text_submitted.connect(_on_exact_select_text_submitted)
	scroll_select.drag_ended.connect(_on_scroll_select_drag_ended)
	decrement.pressed.connect(_on_decrement_pressed)
	increment.pressed.connect(_on_increment_pressed)
	random.pressed.connect(_on_random_pressed)


func _on_quick_select_value_changed(value: float) -> void:
	if is_equal_approx(value, 1.0):
		board_value = MAX_VALUE
	else:
		board_value = int(value * MAX_VALUE)


func _on_exact_select_text_submitted(new_text: String) -> void:
	board_value = int(new_text)

func _on_scroll_select_drag_ended(_value_changed: bool) -> void:
	scroll_select.value = 0
	dragging = false


func _on_random_pressed() -> void:
	board_value = int(randf() * MAX_VALUE)

func _process(_delta: float) -> void:
	var temp_scroll_select: float = snappedf(scroll_select.value, 1.0)
	
	if scroll_select.value == 0:
		i = 0
		return
	
	if board_value + scroll_select.value * scroll_select_scale < 0.0:
		board_value = 0
		return
	
	if board_value + scroll_select.value * -scroll_select_scale > MAX_VALUE:
		board_value = MAX_VALUE
		return
	
	i += 1
	# This SHOULD limit execution to every 60 frames
	# Or about 1 second
	if i % 30 != 0:
		return
		
	if scroll_select.value < 0:
		board_value -= int(pow(10, -(temp_scroll_select + 1)))
	elif scroll_select.value > 0:
		board_value += int(pow(10, temp_scroll_select - 1))


func _on_decrement_pressed() -> void:
	board_value -= 1


func _on_increment_pressed() -> void:
	board_value += 1
