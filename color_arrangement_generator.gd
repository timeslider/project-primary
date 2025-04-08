class_name ColorArrangementGenerator

extends Node


# Constants for color positions in the encoded state
const RED_SHIFT := 0
const YELLOW_SHIFT := 6
const BLUE_SHIFT := 12
const COLOR_MASK := 0x3F  # 6-bit mask (111111 in binary)

# Gets the indices of empty spots (zeros) in the row
static func get_zeros(x: int) -> Array[int]:
	var indices: Array[int] = []
	var temp: int = 0
	var invert_x: int = x ^ 0xFF
	while invert_x > 0:
		if invert_x % 2 != 0:
			indices.append(temp)
		temp += 1
		invert_x >>= 1
	return indices

# Converts array of colors (0=red, 1=yellow, 2=blue) to encoded state
static func encode_colors(colors: Array[int]) -> int:
	var red := 0
	var yellow := 0
	var blue := 0
	
	for i in range(colors.size()):
		var bit := 1 << i
		match colors[i]:
			0: red |= bit
			1: yellow |= bit
			2: blue |= bit
	
	return red | (yellow << YELLOW_SHIFT) | (blue << BLUE_SHIFT)

# Generates all possible color arrangements for given empty spots
static func generate_arrangements(empty_positions: Array[int]) -> Array[int]:
	var arrangements: Array[int] = []
	var num_positions := empty_positions.size()
	
	# Total number of combinations (3^num_positions)
	var total_combinations := pow(3, num_positions)
	
	# Generate each possible combination
	for i in range(total_combinations):
		var temp := i
		var colors: Array[int] = []
		
		# Convert number to base-3 representation
		for _j in range(num_positions):
			colors.append(temp % 3)
			temp /= 3
		
		arrangements.append(encode_colors(colors))
	
	return arrangements

# Helper function to decode and print a state (for debugging)
static func decode_state(state: int) -> Dictionary:
	return {
		"red": state & COLOR_MASK,
		"yellow": (state >> YELLOW_SHIFT) & COLOR_MASK,
		"blue": (state >> BLUE_SHIFT) & COLOR_MASK
	}

# Example usage:
func _ready() -> void:
	for row in range(1):
		var empty_spots = get_zeros(row)
		var arrangements = generate_arrangements(empty_spots)
		print(arrangements.size())
		for i in range(10):
			print(decode_state(arrangements[i]))
	#var occupied := 0b11000000  # First two cells occupied
	#var empty_spots := get_zeros(occupied)
	#var arrangements := generate_arrangements(empty_spots)
	#
	#print("Number of arrangements: ", arrangements.size())
	#print("First arrangement: ", decode_state(arrangements[0]))
	#print("Last arrangement: ", decode_state(arrangements[-1]))
