extends Node2D

var move_lookup_table_let_it_slide: Dictionary = {}
var move_lookup_table_primary: Dictionary = {}

#func _ready() -> void:
	#for row in range(20):
		#print(get_zeros(row))

# Takes in an Array that represents the empty positions in the row
# Returns an Array that represents the possible ways 
#func get_states(zeros: Array) -> Array:
	#pass

func create_lookup_table_let_it_slide() -> void:
	move_lookup_table_let_it_slide.clear()
	for row: int in range(0, 255):
		for empty in get_zeros(row):
			#print("Vector2i(" + str(row) + ", " + str(empty) + "): Vector2i(" + str(move_left(row, empty)) + ", " + str(move_right(row, empty)) + "),")
			move_lookup_table_let_it_slide[[row, empty]] = [move_left_let_it_slide(row, empty), move_right_let_it_slide(row, empty)]
	
func create_lookup_table_primary() -> void:
	move_lookup_table_primary.clear()
	for row: int in range(160, 255):
		for empty in get_zeros(row):
			print("Vector2i(" + str(row) + ", " + str(empty) + "): Vector2i(" + str(move_left_primary(row, empty)) + ", " + str(move_right_primary(row, empty)) + "),")
			#move_lookup_table_primary[[row, empty]] = [move_left_primary(row, empty), move_right_primary(row, empty)]
	

func load_lookup_table_let_it_slide() -> void:
	move_lookup_table_let_it_slide = load("uid://jjdrqdaxxb5t").get_meta("move_table_let_it_slide")

func load_lookup_table_primary() -> void:
	pass

func get_zeros(x: int) -> Array:
	var indices: Array[int] = []
	var temp: int = 0
	var invert_x: int = x ^ 0xFF
	while invert_x > 0:
		if invert_x % 2 != 0:
			indices.append(temp)
		temp += 1
		invert_x >>= 1
	return indices

func get_ones(x: int) -> Array:
	var indices: Array[int] = []
	var temp: int = 0
	while x > 0:
		if x % 2 != 0:
			indices.append(temp)
		temp += 1
		x >>= 1
	return indices

func move_right_let_it_slide(row, index) -> int:
	if index == 7:
		return 7
	var ones: Array[int] = get_ones(row)
	while index + 1 not in ones and index < 7:
		index += 1
	return index

func move_left_let_it_slide(row, index) -> int:
	if index == 0:
		return 0
	var ones: Array = get_ones(row)
	while index - 1 not in ones and index > 0:
		index -= 1
	return index

func move_right_primary(row, index) -> int:
	if index == 7:
		return 7
	var ones: Array = get_ones(row)
	if index + 1 not in ones:
		return index + 1
	else:
		return index

func move_left_primary(row, index) -> int:
	if index == 0:
		return 0
	var ones: Array = get_ones(row)
	if index - 1 not in ones:
		return index - 1
	else:
		return index

func measure_function_time(function_to_measure: Callable, iterations: int):
	var start_time = Time.get_ticks_usec()  # Get current time in milliseconds
	function_to_measure.call()
	var end_time = Time.get_ticks_usec()  # Get time after function execution
	var elapsed_time = end_time - start_time
	print(elapsed_time)
