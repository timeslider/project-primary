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

var wall_data: int = 72431935112174856

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


# Called every frame. 'delta' is the elapsed time since the previous frame.
# TODO: Need to figure out how to move them smoothly.
# I'm thinking of using a dummy node or a dictionary[Node, bool] where bool is
# it can move or not.
func _process(_delta: float) -> void:
	if(move.is_triggered() and is_moving == false):
		is_moving = true
#		Right
		if(move.value_axis_3d[2] > 0):
			# Loop over each player and merge them with the wall tiles
			#for player: Node3D in player_tiles:
				
			print("Pressed move right")
#		Left
		elif(move.value_axis_3d[2] < 0):
			print("Pressed move left")
#		Up
		elif(move.value_axis_3d[0] > 0):
			print("Pressed move up")
			
#		Down
		elif(move.value_axis_3d[0] < 0):
			print("Pressed move up")
		is_moving = false


func sort_top_left(a: Node, b: Node) -> bool:
	if a.position.z != b.position.z:
		return a.position.z > b.position.z
	return a.position.x < b.position.x


func sort_bottom_right(a: Node, b: Node):
	if a.position.z != b.position.z:
		return a.position.z < b.position.z
	return a.position.x > b.position.x

func can_move(direction: Puzzle.Direction, current_position: int) -> int:
	var direction_vector: int = 0
	var edge: int = 0
	const FAIL = 0
	
	match direction:
		Puzzle.Direction.RIGHT:
			direction_vector = current_position + 1
			edge = 1
		Puzzle.Direction.LEFT:
			direction_vector = current_position - 1
		Puzzle.Direction.DOWN:
			direction_vector = current_position + 8
		Puzzle.Direction.UP:
			direction_vector = current_position - 8
	
	if direction_vector > 63:
		return FAIL
	if direction_vector < 0:
		return FAIL

	if (direction == Puzzle.Direction.LEFT):
		if (current_position + edge) % 8 == 0:
			return FAIL

	if (direction == Puzzle.Direction.RIGHT):
		if (current_position + edge) % 8 == 0:

			return FAIL

	if Bitboard.get_bitboard_cell_by_index(wall_data, direction_vector) == true:
		return FAIL


	for player in player_tiles:
		var index: int = player.position[2] * 8 + player.position[0]
		if direction_vector == index:
			return FAIL

	return direction_vector


func _input(event: InputEvent) -> void:
	if event.is_action_released("test"):
		print("Test pressed.")
