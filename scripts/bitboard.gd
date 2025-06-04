class_name Bitboard
extends Node

# TODO: This class currently acts more like a puzzle class than a bitboard class
# The problem is that I'm not understanding what a bitboard really is
# A bitboard is just an int and the methods around it to make it work
# A puzzle should be a container for the puzzle data. It should have a bitboard
# And methods to manipulate it

static var wall_data: int
static var playable: bool
static var reasons: Array[String]
static var red: int
static var yellow: int
static var blue: int
static var state: int:
	get ():
		return get_state()


const MAX_POLYOMINO: int = 51016818604894741

#const BOUNDARIES: Array[int] = [255, 9259542123273814144, -72057594037927936, 72340172838076673]
enum Direction {UP, RIGHT, DOWN, LEFT}


func _ready() -> void:
	#wall_data = 49340209542762048 # Dummy test data, can delete
	set_initial_state()


static func get_bitboard_cell_by_index(index: int) -> bool:
	#assert(index >= 0 and index < 64, "Index was %s which outside the range [0, 63] inclusive." % index)
	return (wall_data & (1 << index)) != 0


static func get_bitboard_cell_by_col_row(col: int, row: int) -> bool:
	#var bit_position: int = row * 8 + col
	return (wall_data & (1 << (row * 8 + col))) != 0


# This function isn't being used anywhere. Candidate for deletion
#static func check_bounds(col: int, row: int, zero_indexed: bool = true) -> void:
	#var low_index: int
	#var high_index: int
	#if(zero_indexed == true):
		#low_index = 0
		#high_index = 7
	#else:
		#low_index = 1
		#high_index = 8
	#assert(col < low_index, "Argument was out of range. width was too small.")
	#assert(row < low_index, "Argument was out of range. height was too small.")
	#assert(col < high_index, "Argument was out of range. width was too large.")
	#assert(row < high_index, "Argument was out of range. height was too large.")


## The state of the pieces is represented by a number
## where the first 6 bits is the index (0, 63) of the red tile,
## the next 6 bits is the index of the yellow tile,
## and the next 6 bits is the index of the blue tile.
## Example: 37061 = { red : 5, yellow : 3, blue : 9}
static func get_state() -> int:
	return red | (yellow << 6) | (blue << 12)


static func set_state(new_state: int) -> void:
	red = new_state & 0x3f
	yellow = (new_state >> 6) & 0x3f
	blue = (new_state >> 12) & 0x3f


# There's an insintric that does this if we had access to it...
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
			#if row * 8 + col == red:
				#output += "R "
				#continue
			#if row * 8 + col == yellow:
				#output += "Y "
				#continue
			#if row * 8 + col == blue:
				#output += "B "
				#continue
			if invert == true:
				output += "- " if get_bitboard_cell_by_col_row(col, row) else "1 "
			else:
				output += "1 " if get_bitboard_cell_by_col_row(col, row) else "- "
		output += "\n"
	print(output)


# The algorithm for setting the initial state works like this
# The red tile will be placed at the first empty cell when scanning the board
# Left to right, top to bottom. The yellow tile will be placed at the first empty
# cell that is to the right or below the red tile. If both cells are open, then right has priority.
# The blue tile will be placed to the left, to the right, or below the yellow tile.
# Left has priority, then right, then below.

static func set_initial_state() -> void:
	var colors: Array = []
	colors.append(trailing_zero_count(~wall_data))
	# Case 1: Move right
	if can_move(Direction.RIGHT, colors[0]) > 0:
		colors.append(can_move(Direction.RIGHT, colors[0]))
		if can_move(Direction.RIGHT, colors[1]) > 0:
			colors.append(can_move(Direction.RIGHT, colors[1]))
		elif can_move(Direction.DOWN, colors[0]) > 0:
			colors.append(can_move(Direction.DOWN, colors[0]))
		# Case 4: Move down
		elif can_move(Direction.DOWN, colors[1]) > 0:
			colors.append(can_move(Direction.DOWN, colors[1]))
	# Case 2: Move down
	elif can_move(Direction.DOWN, colors[0]) > 0:
		colors.append(can_move(Direction.DOWN, colors[0]))
		# Case 5: Move left
		if can_move(Direction.LEFT, colors[1]) > 0:
			colors.append(can_move(Direction.LEFT, colors[1]))
		# Case 6: Move right
		elif can_move(Direction.RIGHT, colors[1]) > 0:
			colors.append(can_move(Direction.RIGHT, colors[1]))
		#Case 7: Move down
		elif can_move(Direction.DOWN, colors[1]) > 0:
			colors.append(can_move(Direction.DOWN, colors[1]))

	red = colors[0]
	print("red was: ", red)
	yellow = min(colors[1], colors[2])
	print("yellow was: ", yellow)
	blue = max(colors[1], colors[2])
	print("blue was: ", blue)
	print("Initial state was " + str(state));


# Simplified version of the can move function for calculating the states
static func can_move(_direction: Bitboard.Direction, current_position: int) -> int:
	var direction_vector: int = 0 # Where you are going to land
	var edge: int = 0
	match _direction:
		Direction.RIGHT:
			direction_vector = current_position + 1
			edge = 1
		Direction.LEFT:
			direction_vector = current_position - 1
		Direction.DOWN:
			direction_vector = current_position + 8
		Direction.UP:
			direction_vector = current_position - 8
	if direction_vector > 64:
		return 0
	if _direction != Direction.DOWN and (current_position + edge) % 8 == 0:
		return 0
	if get_bitboard_cell_by_index(direction_vector):
		return 0
	if direction_vector == red:
		return 0
	return direction_vector


# Written by Deeps
static var BYTE_REVERSAL_LOOKUP = []

static func flip_horizontal(bitboard: int) -> int:
	# Initialize lookup table if empty
	if BYTE_REVERSAL_LOOKUP.is_empty():
		for byte in range(256):
			var reversed = 0
			for j in range(8):
				reversed = (reversed << 1) | (byte & 1)
				byte = byte >> 1
			BYTE_REVERSAL_LOOKUP.append(reversed)
	
	# Process each byte (row) in the bitboard
	var result = 0
	for i in range(8):
		var byte = (bitboard >> (i * 8)) & 0xFF
		result |= BYTE_REVERSAL_LOOKUP[byte] << (i * 8)
	return result


## Flips the bitboard horizontally
static func flip_vertical(_bitboard: int) -> int:
	# Flip the bitboard vertically
	var flipped = (_bitboard << 56) | \
	((_bitboard << 40) & 0x00FF000000000000) | \
	((_bitboard << 24) & 0x0000FF0000000000) | \
	((_bitboard << 8)  & 0x000000FF00000000) | \
	((_bitboard >> 8)  & 0x00000000FF000000) | \
	((_bitboard >> 24) & 0x0000000000FF0000) | \
	((_bitboard >> 40) & 0x000000000000FF00) | \
	((_bitboard >> 56) & 0x00000000000000FF)  # Mask to 8 bits to prevent sign extension
	
	return flipped


# Diagonal flip over a1-h8 axis (for rotations)
static func flip_diag_a1_h8(_bitboard: int) -> int:
	var temp: int = 0
	const K1 = 0x5500550055005500  # Binary: 0101010100000000... pattern
	const K2 = 0x3333000033330000  # Binary: 0011001100000000... pattern
	const K4 = 0x0f0f0f0f00000000  # Binary: 0000111100000000... pattern

	temp = K4 & (_bitboard ^ (_bitboard << 28))
	_bitboard ^= temp ^ (temp >> 28)
	temp = K2 & (_bitboard ^ (_bitboard << 14))
	_bitboard ^= temp ^ (temp >> 14)
	temp = K1 & (_bitboard ^ (_bitboard << 7))
	_bitboard ^= temp ^ (temp >> 7)
	return _bitboard


# Rotate 90 degrees clockwise
static func rotate_cw(bitboard: int) -> int:
	return flip_vertical(flip_diag_a1_h8(bitboard))


# Rotate 90 degrees counter-clockwise
static func rotate_ccw(bitboard: int) -> int:
	return flip_horizontal(flip_diag_a1_h8(bitboard))

# TODO: Something about either this or compare_unsigned doesn't work
## Returns the bitboard's smallest symmetric representation (canonical form)
static func canonicalize(bitboard: int) -> int:
	var min_board = bitboard  # Start with original
	var transforms = [
		#bitboard, # you don't need to compare it to the orginal
		rotate_cw(bitboard),
		rotate_ccw(bitboard),
		rotate_cw(rotate_cw(bitboard)),
		flip_horizontal(bitboard),
		flip_horizontal(rotate_cw(bitboard)),
		flip_horizontal(rotate_ccw(bitboard)),
		flip_horizontal(rotate_cw(rotate_cw(bitboard))),
	]
	
	
	var string_output: Array[String] = []
	string_output.append(String.num_uint64(min_board))
	
	# Find the smallest representation (or use another ordering)
	# TODO: Since these are signed, comparing them directly might not be right.
	for transform in transforms:
		string_output.append(String.num_uint64(transform))
		if compare_unsigned(min_board, transform) == -1:
			min_board = transform
	print(string_output)
	print(min_board)
	return min_board

# TODO: Test this method, it currently doesn't work
## Compares two signed integers a with b as if they were unsigned
static func compare_unsigned(a: int, b: int) -> int:
	var a_sign: int = (a >> 63) & 1
	var b_sign: int = (a >> 63) & 1
	
	if a_sign != b_sign:
		return -1 if a_sign == 1 else 1
	elif a < b:
		return -1
	elif a > b:
		return 1
	else:
		return 0
