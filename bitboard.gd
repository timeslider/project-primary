class_name bitboard
extends Node

static var wall_data: int
static var playable: bool
static var reasons: Array[String]
static var red: int
static var yellow: int
static var blue: int
static var state: int

static var boundaries: Array[int] = [255, 9259542123273814144, -72057594037927936, 72340172838076673]
enum direction {up, right, down, left}


func _ready() -> void:
	wall_data = -72057594037927936
	print_bitboard(wall_data)
	print(trailing_zero_count(wall_data))


static func get_bitboard_cell_by_index(index: int) -> bool:
	assert(index < 0 and index > 63)
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

# Rename to set_initial_state
static func get_initial_state() -> void:
	var colors: Array
	var bi
	#colors.append()


const multiple_de_bruijn_bit_position: Array = [
	0, 1, 28, 2, 29, 14, 24, 3, 30, 22, 20, 15, 25, 17, 4, 8, 
  	31, 27, 13, 23, 21, 19, 16, 7, 26, 12, 18, 6, 11, 5, 10, 9,
]

const mod_37_bit_position: Array = [
	32, 0, 1, 26, 2, 23, 27, 0, 3, 16, 24, 30, 28, 11, 0, 13, 4,
  7, 17, 0, 25, 22, 31, 15, 29, 10, 12, 6, 0, 21, 14, 9, 5,
  20, 8, 19, 18
]

static func trailing_zero_count(value: int) -> int:
	var result: int
	var i: int
	while ((value % 1) == 0 or i > 10):
		result += 1
		value >>= 1
		print(value)
		i += 1
	return result





# TODO: use string pool instead if the performace is too slow
static func print_bitboard(bitboard: int, invert: bool = false) -> void:
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
