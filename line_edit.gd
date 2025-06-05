class_name NumericLineEdit
extends LineEdit

#func _ready() -> void:
	#self.text_changed.connect(limit_input)

func limit_input(current_string: String) -> void:
	var caret_column_old: int = self.caret_column
	var new_string: String = ""
	
	for i in range(current_string.length()):
		if current_string[i].is_valid_int():
			new_string += current_string[i]
		else:
			caret_column_old -= 1

	self.text = new_string
	self.caret_column = caret_column_old
