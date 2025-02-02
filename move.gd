extends Camera3D

@export var move: GUIDEAction
const MENU_MODE = preload("res://GUIDE/menu-mode.tres")

@onready var player_tiles: Array[Node]
@onready var goals: Array[Node]
@onready var puzzle: Array[Node]
var puzzle_2d_array = []

var HSliderTest = load("res://HSliderTest.cs")
var HSlider_node = HSliderTest.new()

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
func _process(_delta: float) -> void:
	if(move.is_triggered()):
#		Right
		if(move.value_axis_3d[2] > 0):
			print("pressed D")
			#var move_me: Array[Node]
			player_tiles.sort_custom(sort_top_left)
			for player in player_tiles:
				print(player.name, " is at index: ", str(player.position[2] * 8 + player.position[0]))
				player.position += Vector3(1.0, 0.0, 0.0)
			
#		Left
		if(move.value_axis_3d[2] < 0):
			print("pressed A")
			for x in player_tiles:
				x.position += Vector3(-1.0, 0.0, 0.0)
#		Up
		if(move.value_axis_3d[0] > 0):
			print("pressed W")
			for x in player_tiles:
				x.position += Vector3(0.0, 0.0, -1.0)
#		Down
		if(move.value_axis_3d[0] < 0):
			print("pressed S")
			for x in player_tiles:
				x.position += Vector3(0.0, 0.0, 1.0)

func sort_top_left(a: Node, b: Node):
	# The last one is reversed since the z axis is inverted
	if a.position[0] > b.position[0] and a.position[2] < b.position[2]:
		return true
	return false

func sort_bottom_right(a: Node, b: Node):
	# The last one is reversed since the z axis is inverted
	if a.position[0] > b.position[0] and a.position[2] < b.position[2]:
		return false
	return true
