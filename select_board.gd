extends VBoxContainer

@onready var board_value: Label = %BoardValue
@onready var quick_select: HSlider = %QuickSelect
@onready var exact_select: LineEdit = %ExactSelect
@onready var scroll_select: HSlider = %ScrollSelect

func _ready() -> void:
	board_value.text = str(0)
	quick_select.value_changed.connect(_on_quick_select_value_changed)
	exact_select.text_submitted.connect(_on_exact_select_text_submitted)
	scroll_select.value = scroll_select.max_value / 2
	scroll_select.drag_ended.connect(_on_scroll_select_drag_ended)
	

func _on_quick_select_value_changed(value: float) -> void:
	board_value.text = str(int(value))
	exact_select.text = str(int(value))


func _on_exact_select_text_submitted(new_text: String) -> void:
	board_value.text = new_text
	quick_select.set_value_no_signal(int(new_text))

func _on_scroll_select_drag_ended(_value_changed: bool) -> void:
	scroll_select.value = scroll_select.max_value / 2


func _pro
