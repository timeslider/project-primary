extends LineEdit

var previous_value: String = ""
var numbers: String = "0123456789"

func _ready() -> void:
	previous_value = self.text
	self.text_changed.connect(_limit_input)

func _limit_input(current_value: String) -> void:
	if current_value.is_empty() == true:
		return
	
	if current_value.length() < previous_value.length():
		previous_value = current_value
		return
	
	# Since we can't get the last input, just loop over everything
	var is_number: bool = true
	for i in range(current_value.length()):
		# Check if it's a number
		match current_value[i]:
			"0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
				continue
			_:
				 # Last input was not a number"
				#print("Current value: %s" % current_value)
				#print("Substr: %s" % current_value.substr(0, current_value.length() - 1))
				is_number = false
				self.text = current_value.substr(0, i) + current_value.substr(i + 1, -1)
				self.caret_column = i
				break
