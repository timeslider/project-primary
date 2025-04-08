class_name bitboard
extends Node

static var wall_data: int
static var playable: bool
static var reasons: Array[String]
static var red: int
static var yellow: int
static var blue: int
static var state: int:
	get ():
		return get_state()

# THis is temp. Please delete
static var max_polyomino: int = 51016818604894741

static var boundaries: Array[int] = [255, 9259542123273814144, -72057594037927936, 72340172838076673]
enum direction {up, right, down, left}


func _ready() -> void:
	wall_data = 49340209542762048
	set_initial_state()

static func get_bitboard_cell_by_index(index: int) -> bool:
	if index < 0:
		print("Index was less than 0")
	if index >= 64:
		print("Index was greater than 64")
	assert(index >= 0 and index < 64)
	return (wall_data & (1 << index)) != 0


static func get_bitboard_cell_by_col_row(col: int, row: int) -> bool:
	var bit_position: int = row * 8 + col
	return (wall_data & (1 << bit_position)) != 0


static func check_bounds(col: int, row: int, zero_indexed: bool = true) -> void:
	var low_index: int
	var high_index: int
	if(zero_indexed == true):
		low_index = 0
		high_index = 7
	else:
		low_index = 1
		high_index = 8
	assert(col < low_index, "Argument was out of range. width was too small.")
	assert(row < low_index, "Argument was out of range. height was too small.")
	assert(col < high_index, "Argument was out of range. width was too large.")
	assert(row < high_index, "Argument was out of range. height was too large.")


static func get_state() -> int:
	return red | (yellow << 6) | (blue << 12)


static func set_state(existing_state: int) -> void:
	red = existing_state & 0x3f
	yellow = (existing_state >> 6) & 0x3f
	blue = (existing_state >> 12) & 0x3f


static func trailing_zero_count(value: int) -> int:
	if value == 0:
		return 64
	var result: int = 0
	while ((value & 1) == 0):
		result += 1
		value >>= 1
	return result


# TODO: use string pool instead if the performace is too slow
static func print_bitboard(invert: bool = false) -> void:
	var output: String = ""
	output += "Puzzle: " + str(wall_data) + "\n"
	for row in range(0, 8):
		for col in range(0, 8):
			if row * 8 + col == red:
				output += "R "
				continue
			if row * 8 + col == yellow:
				output += "Y "
				continue
			if row * 8 + col == blue:
				output += "B "
				continue
			if invert == true:
				output += "- " if get_bitboard_cell_by_col_row(col, row) else "1 "
			else:
				output += "1 " if get_bitboard_cell_by_col_row(col, row) else "- "
		output += "\n"
	print(output)


static func set_initial_state() -> void:
	var colors: Array = []
	colors.append(trailing_zero_count(~wall_data))
	# Case 1: Move right
	if can_move(direction.right, colors[0]) > 0:
		colors.append(can_move(direction.right, colors[0]))
		if can_move(direction.right, colors[1]) > 0:
			colors.append(can_move(direction.right, colors[1]))
		elif can_move(direction.down, colors[0]) > 0:
			colors.append(can_move(direction.down, colors[0]))
		# Case 4: Move down
		elif can_move(direction.down, colors[1]) > 0:
			colors.append(can_move(direction.down, colors[1]))
	# Case 2: Move down
	elif can_move(direction.down, colors[0]) > 0:
		colors.append(can_move(direction.down, colors[0]))
		# Case 5: Move left
		if can_move(direction.left, colors[1]) > 0:
			colors.append(can_move(direction.left, colors[1]))
		# Case 6: Move right
		elif can_move(direction.right, colors[1]) > 0:
			colors.append(can_move(direction.right, colors[1]))
		#Case 7: Move down
		elif can_move(direction.down, colors[1]) > 0:
			colors.append(can_move(direction.down, colors[1]))

	red = colors[0]
	print("red was: ", red)
	yellow = min(colors[1], colors[2])
	print("yellow was: ", yellow)
	blue = max(colors[1], colors[2])
	print("blue was: ", blue)
	print("Initial state was " + str(state));

# Simplified version of the can move function for calculating the states
static func can_move(_direction: bitboard.direction, current_position: int) -> int:
	var direction_vector: int = 0 # Where you are going to land
	var edge: int = 0
	match _direction:
		direction.right:
			direction_vector = current_position + 1
			edge = 1
		direction.left:
			direction_vector = current_position - 1
		direction.down:
			direction_vector = current_position + 8
		direction.up:
			direction_vector = current_position - 8
	if direction_vector > 64:
		return 0
	if _direction != direction.down and (current_position + edge) % 8 == 0:
		return 0
	if get_bitboard_cell_by_index(direction_vector):
		return 0
	if direction_vector == red:
		return 0
	return direction_vector


#func _on_h_slider_drag_ended(_value_changed: bool) -> void:
	#print(int(h_slider.ratio * 51016818604894744))
	
