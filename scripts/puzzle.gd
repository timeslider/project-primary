class_name Puzzle
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


const MAX_POLYOMINO: int = 51016818604894741

#const BOUNDARIES: Array[int] = [255, 9259542123273814144, -72057594037927936, 72340172838076673]
enum Direction {UP, RIGHT, DOWN, LEFT}




func _ready() -> void:
	set_initial_state()


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
	print("Initial state was " + str(state))


# Simplified version of the can move function for calculating the states
static func can_move(_direction: Puzzle.Direction, current_position: int) -> int:
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
	if Bitboard.get_bitboard_cell_by_index(direction_vector, wall_data):
		return 0
	if direction_vector == red:
		return 0
	return direction_vector
