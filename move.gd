extends Camera3D

@export var move: GUIDEAction
@export var move_speed: float = 0.0625
const MENU_MODE = preload("res://GUIDE/menu-mode.tres")
@onready var is_move_label: Label = $"../IsMoveLabel"

@onready var player_tiles: Array[Node]
@onready var goals: Array[Node]
@onready var puzzle: Array[Node]
var puzzle_2d_array = []

var HSliderTest = load("res://HSliderTest.cs")
var HSlider_node = HSliderTest.new()
var is_moving = false:
	set(value):
		print(is_moving)
		is_moving = value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GUIDE.enable_mapping_context(MENU_MODE)

	await get_tree().process_frame
	puzzle = $"../Puzzle".get_children()
	player_tiles = $"../PlayerTiles".get_children()
	goals = $"../Goals".get_children()
	var index = 0
	for col in range(0, 8):
		var temp = []
		for row in range(0, 8):
			index = row * 8 + col
			temp.append(puzzle[index])
		puzzle_2d_array.append(temp)
	bitboard.wall_data = 72431935112174856 # Puzzle 1215799526789426
	print("getting bitboard cell by index", bitboard.get_bitboard_cell_by_index(10))
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
# TODO: Need to figure out how to move them smoothly.
# I'm thinking of using a dummy node or a dictionary[Node, bool] where bool is
# it can move or not.
func _process(delta: float) -> void:
	if(move.is_triggered() and is_moving == false):
		is_moving = true
		
		var original_positions = {}
		for player in player_tiles:
			original_positions[player] = player.position
		
		var moves = []
#		Right
		if(move.value_axis_3d[2] > 0):
			player_tiles.sort_custom(sort_bottom_right)
			for player in player_tiles:
				var index: int = player.position[2] * 8 + player.position[0]
				var valid_move = can_move(bitboard.direction.right, index)
				if valid_move > 0:
					player.position += Vector3(1.0, 0.0, 0.0)
					moves.append({
						"tile": player,
						"destination": player.position
					})
#		Left
		elif(move.value_axis_3d[2] < 0):
			player_tiles.sort_custom(sort_top_left)
			for player in player_tiles:
				var index: int = player.position[2] * 8 + player.position[0]
				var valid_move = can_move(bitboard.direction.left, index)
				if valid_move > 0:
					player.position += Vector3(-1.0, 0.0, 0.0)
					moves.append({
						"tile": player,
						"destination": player.position
					})
#		Up
		elif(move.value_axis_3d[0] > 0):
			player_tiles.sort_custom(sort_bottom_right)
			for player in player_tiles:
				var index: int = player.position[2] * 8 + player.position[0]
				var valid_move = can_move(bitboard.direction.up, index)
				if valid_move > 0:
					player.position += Vector3(0.0, 0.0, -1.0)
					moves.append({
						"tile": player,
						"destination": player.position
					})

#		Down
		elif(move.value_axis_3d[0] < 0):
			player_tiles.sort_custom(sort_top_left)
			for player in player_tiles:
				var index: int = player.position[2] * 8 + player.position[0]
				var valid_move = can_move(bitboard.direction.down, index)
				if valid_move > 0:
					player.position += Vector3(0.0, 0.0, 1.0)
					moves.append({
						"tile": player,
						"destination": player.position
					})
			
		for player in original_positions:
			player.position = original_positions[player]
		
		if moves.is_empty() == false:
			var tween = create_tween()
		
			for _move in moves:
				tween.parallel().tween_property(_move.tile, "position", _move.destination, move_speed)
			await tween.finished
		is_moving = false


func sort_top_left(a: Node, b: Node) -> bool:
	# First compare Z positions (remember Z is inverted)
	if a.position.z != b.position.z:
		# Return true if a should come before b
		return a.position.z > b.position.z
	# If on same row (same Z), sort by X position
	return a.position.x < b.position.x


func sort_bottom_right(a: Node, b: Node):
	# First compare Z positions (remember Z is inverted)
	if a.position.z != b.position.z:
		# Return true if a should come before b
		return a.position.z < b.position.z
	# If on same row (same Z), sort by X position
	return a.position.x > b.position.x

func can_move(direction: bitboard.direction, current_position: int) -> int:
	var direction_vector: int = 0
	var edge: int = 0
	const FAIL = 0
	
	match direction:
		bitboard.direction.right:
			direction_vector = current_position + 1
			edge = 1
		bitboard.direction.left:
			direction_vector = current_position - 1
		bitboard.direction.down:
			direction_vector = current_position + 8
		bitboard.direction.up:
			direction_vector = current_position - 8
	
	# The color's position would be larger than the size of the board
	if direction_vector > 63:
		#print("direction_vector was greater than 64")
		return FAIL
	#else:
		#print("direction_vector was less than 64")
	
	if direction_vector < 0:
		#print("direction_vector was less than 0")
		return FAIL
	#else:
		#print("direction_vector was greater than 0")
	
	# The direction is either left or right and you're already on the edge
	if (direction == bitboard.direction.left):
		#print("direction was left or right but you're already on the edge")
		if (current_position + edge) % 8 == 0:
			#print("You are already on the edge")	
			return FAIL
		#else:
			#print("You are not on the edge")
	#else:
		#print("direction was not left")
		
	if (direction == bitboard.direction.right):
		#print("direction was left or right but you're already on the edge")
		if (current_position + edge) % 8 == 0:
			#print("You are already on the edge")	
			return FAIL
		#else:
			#print("You are not on the edge")
	#else:
		#print("direction was not right")
	
	# A wall is there
	if bitboard.get_bitboard_cell_by_index(direction_vector) == true:
		#print("There is a wall at index: ", direction_vector)
		return FAIL
	#else:
		#print("A wall was not there.")

	for player in player_tiles:
		var index: int = player.position[2] * 8 + player.position[0]
		if direction_vector == index:
			#print("Another player is already here")
			return FAIL

	return direction_vector

##		Right
		#if(move.value_axis_3d[2] > 0 and is_moving == true):
			#var moves = []
			#player_tiles.sort_custom(sort_bottom_right)
			#for player in player_tiles:
				#var index: int = player.position[2] * 8 + player.position[0]
				#print(player.name, " is at index: ", str(index))
				#if can_move(bitboard.direction.right, index) > 0:
					#player.position += Vector3(1.0, 0.0, 0.0)


func _input(event: InputEvent) -> void:
	if event.is_action_released("test"):
		print("Test pressed.")
