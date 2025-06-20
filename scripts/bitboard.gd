class_name Bitboard
extends Node

static func get_bitboard_cell_by_index(bitboard: int, index: int) -> bool:
	#assert(index >= 0 and index < 64, "Index was %s which outside the range [0, 63] inclusive." % index)
	return (bitboard & (1 << index)) != 0


static func get_bitboard_cell_by_col_row(bitboard: int, col: int, row: int) -> bool:
	#var bit_position: int = row * 8 + col
	return (bitboard & (1 << (row * 8 + col))) != 0


# TODO: use string pool instead if the performace is too slow
static func print_bitboard(bitboard: int, invert: bool = false) -> void:
	var output: String = ""
	
	output += "Puzzle: " + str(bitboard) + "\n"
	for row in range(0, 8):
		for col in range(0, 8):
			if invert == true:
				output += "- " if get_bitboard_cell_by_col_row(bitboard, col, row) else "1 "
			else:
				output += "1 " if get_bitboard_cell_by_col_row(bitboard, col, row) else "- "
		output += "\n"
	print(output)


# TODO: Move this to an auto load and trigger during the loading process
# Written by Deepseek
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


# NOTE: Can be performed in one operation with _byte_swap_uint64(x)
## Flips the bitboard horizontally
static func flip_vertical(bitboard: int) -> int:
	# Flip the bitboard vertically
	bitboard = (bitboard << 56) | \
	((bitboard << 40) & 0x00FF000000000000) | \
	((bitboard << 24) & 0x0000FF0000000000) | \
	((bitboard << 8)  & 0x000000FF00000000) | \
	((bitboard >> 8)  & 0x00000000FF000000) | \
	((bitboard >> 24) & 0x0000000000FF0000) | \
	((bitboard >> 40) & 0x000000000000FF00) | \
	((bitboard >> 56) & 0x00000000000000FF)  # Mask to 8 bits to prevent sign extension
	
	return bitboard


# Diagonal flip over a1-h8 axis (for rotations)
static func flip_diag_a1_h8(bitboard: int) -> int:
	var temp: int = 0
	const K1 = 0x5500550055005500  # Binary: 0101010100000000... pattern
	const K2 = 0x3333000033330000  # Binary: 0011001100000000... pattern
	const K4 = 0x0f0f0f0f00000000  # Binary: 0000111100000000... pattern

	temp = K4 & (bitboard ^ (bitboard << 28))
	bitboard ^= temp ^ (temp >> 28)
	temp = K2 & (bitboard ^ (bitboard << 14))
	bitboard ^= temp ^ (temp >> 14)
	temp = K1 & (bitboard ^ (bitboard << 7))
	bitboard ^= temp ^ (temp >> 7)
	return bitboard


## Rotate 90 degrees clockwise
static func rotate_cw(bitboard: int) -> int:
	return flip_horizontal(flip_diag_a1_h8(bitboard))


## Rotate 90 degrees counter-clockwise
static func rotate_ccw(bitboard: int) -> int:
	return flip_vertical(flip_diag_a1_h8(bitboard))


## Returns the bitboard's smallest symmetric representation (canonical form)
static func canonicalize(bitboard: int) -> int:
	var min_board = bitboard  # Start with original
	var transforms = [
		rotate_cw(bitboard),
		rotate_ccw(bitboard),
		rotate_cw(rotate_cw(bitboard)),
		flip_horizontal(bitboard),
		flip_horizontal(rotate_cw(bitboard)),
		flip_horizontal(rotate_ccw(bitboard)),
		flip_horizontal(rotate_cw(rotate_cw(bitboard))),
	]
	
	# Find the smallest representation
	for transform in transforms:
		if compare_unsigned(transform, min_board) == -1:
			min_board = transform
	return min_board


## Compares two signed 64-bit integers a and b [br]
## as if they were unsigned 64-bit integers
static func compare_unsigned(a: int, b: int) -> int:
	var a_sign: int = (a >> 63) & 1
	var b_sign: int = (b >> 63) & 1
	
	if a_sign != b_sign:
		# a is non-negative, b is negative -> a < b
		if a_sign == 0:
			return -1
		# a is negative, b is non-negative -> a > b
		else:
			return 1
	else:
		if a < b:
			return -1
		elif a > b:
			return 1
		else:
			return 0


# There's an insintric that does this if we had access to it...
static func trailing_zero_count(value: int) -> int:
	if value == 0:
		return 64
	var result: int = 0
	while ((value & 1) == 0):
		result += 1
		value >>= 1
	return result


## Takes a color bitboard (a bitboard with exactly 1 bit) and returns where
## it's located in the bitboard as a 1D index. (0, 63)
static func bitboard_to_index(bitboard: int) -> int:
	assert(pop_count(bitboard) != 1, "bitboard must contain exactly 1 bit")
	var bit_position: int = trailing_zero_count(bitboard)
	@warning_ignore("integer_division")
	var row: int = bit_position / 8
	var col: int = bit_position % 8
	return row * 8 + col


## Returns the number of bits set in the bitboard
static func pop_count(bitboard: int) -> int:
	var count: int = 0
	while bitboard > 0:
		bitboard &= (bitboard - 1)
		count += 1
	return count
