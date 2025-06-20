class_name Puzzle
extends Node

## This class combines a lot of information to create a puzzle class
## It contains everything about the puzzle including wall data, player data,
## goal data, is_playable, reasons for why it's not playable if applicable.

# walls: 64-bit bitboard
#static var wall_data: int:
	#get():
		#return PuzzleSelectGlobal.layout

# NOTE: Do we need to store this?
## true = this puzzle is playable
static var playable: bool

# NOTE: Do we need to store this?
## A list of human-readable string for why this puzzle isn't playable
static var reasons: Array[String]

## A bitboard with a single bit representing where the red tile is
static var red: int

## A bitboard with a single bit representing where the yellow tile is
static var yellow: int

## A bitboard with a single bit representing where the blue tile is
static var blue: int

## The state of the board
static var state: int:
	get():
		return get_state()

## Player tiles: Dictionary of positions in the format "color" : Vector2i(x, y)
static var players: Dictionary = {
	"red": Vector2i(0, 0),
	"yellow": Vector2i(0, 0),
	"blue": Vector2i(0, 0),
}

## Goal tiles: Dictionary of positions
static var goals: Dictionary = {
	"red": Vector2i(0, 0),
	"yellow": Vector2i(0, 0),
	"blue": Vector2i(0, 0),
}

## A bitboard repsenting all the players
static var players_bb: int = 0

## The states array is an array of all possible ways the player or goal tiles
## can be arranged.
static var states: Array[int] = []

const MAX_POLYOMINO: int = 51016818604894741

const BOUNDARIES: Array[int] = [255, 9259542123273814144, -72057594037927936, 72340172838076673]
enum Direction {UP, RIGHT, DOWN, LEFT}




func _ready() -> void:
	#set_initial_state()
	players
	pass


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





# The algorithm for setting the initial state works like this
# The red tile will be placed at the first empty cell when scanning the board
# Left to right, top to bottom. The yellow tile will be placed at the first empty
# cell that is to the right or below the red tile. If both cells are empty, then right has priority.
# The blue tile will be placed to the left, to the right, or below the yellow tile.
# Left has priority, then right, then below.
static func set_initial_state() -> void:
	var colors: Array = []
	colors.append(Bitboard.trailing_zero_count(~PuzzleSelectGlobal.layout))
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
	# Out of bounds. Below puzzle.
	if direction_vector > 64:
		return 0
	# Out of bounds. Past edge.
	if _direction != Direction.DOWN and (current_position + edge) % 8 == 0:
		return 0
	#print(Bitboard.get_bitboard_cell_by_index(PuzzleSelectGlobal.layout, direction_vector))
	# A wall is in the way.
	if Bitboard.get_bitboard_cell_by_index(PuzzleSelectGlobal.layout, direction_vector):
		return 0
	# The red tile is already there.
	if direction_vector == red:
		return 0
	return direction_vector


## Since bit shifting by a negative amount is undefined, we'll define it here
func shift_bitboard_cell(bitboard: int, shift_amount) -> int:
	if shift_amount > 0:
		return bitboard >> shift_amount
	else:
		return bitboard << -shift_amount


func _move_to_new_state(direction: Direction):
	# Colors array with bitboards and identifiers
	var colors: Array = [
		{"bitboard": 1 << red, "name": "r"},
		{"bitboard": 1 << red, "name": "y"},
		{"bitboard": 1 << red, "name": "b"},
	]
	
	# Direction variables
	var boundary: int = 0
	var move_direction: int = 0
	
	# Configure movement parameters
	match direction:
		Direction.UP:
			boundary = BOUNDARIES[0]
			move_direction = 8
			colors.sort_custom(func(a, b): return a["bitboard"] < b["bitboard"])
		Direction.RIGHT:
			boundary = BOUNDARIES[1]
			move_direction = -1
			# Hopefully, this is reverse sorted
			colors.sort_custom(func(a, b): return a["bitboard"] > b["bitboard"])
		Direction.DOWN:
			boundary = BOUNDARIES[2]
			move_direction = -8
			# Hopefully, this is reverse sorted
			colors.sort_custom(func(a, b): return a["bitboard"] > b["bitboard"])
		Direction.LEFT:
			boundary = BOUNDARIES[3]
			move_direction = 1
			colors.sort_custom(func(a, b): return a["bitboard"] < b["bitboard"])
	
	for i in range(colors.size()):
		var color = colors[i]
		var bitboard = color["bitboard"]
		
		# Skip if already at boundary
		if bitboard & boundary != 0:
			continue
		
		# Skip if would overlap other colors
		if check_overlaping_colors(i, colors, move_direction):
			continue
		
		# Skip if would hit wall
		var new_bitboard = shift_bitboard_cell(bitboard, move_direction)
		if new_bitboard & PuzzleSelectGlobal.layout != 0:
			continue
		
		# Update color position
		colors[i]["bitboard"] = new_bitboard
	
	# Apply new positions
	for color in colors:
		match color["name"]:
			"r":
				red = Bitboard.bitboard_to_index(color["bitboard"])
			"y":
				yellow = Bitboard.bitboard_to_index(color["bitboard"])
			"b":
				yellow = Bitboard.bitboard_to_index(color["bitboard"])
	return get_state()




func check_overlaping_colors(i: int, colors: Array, move_direction: int):
	for j in range(colors.size()):
		if j == i:
			continue
		if shift_bitboard_cell(colors[i]["bitboard"], move_direction) & colors[j]["bitboard"] != 0:
			return true
	pass

func get_states() -> Array[int]:
	# Since Godot doesn't have hash sets, we're using a dictionary with a dummy value instead.
	var visited: Dictionary[int, bool]
	var queue: Array[int]
	
	states.clear()
	
	# Set initial states and add to data structures
	set_initial_state()
	queue.append(get_state())
	visited[get_state()] = true # Dummy value
	states.append(get_state())
	
	while queue.size() > 0:
		var current_state = queue.pop_front()
		set_state(current_state)
		
		for direction in Direction:
			var new_state: int = _move_to_new_state(direction)
			
			if visited.has(new_state) == false:
				visited[new_state] = true
				queue.append(new_state)
				states.append(new_state)
		set_state(current_state)
	return states


## Determines if the puzzle is playable
func is_playable() -> bool:
	return false
