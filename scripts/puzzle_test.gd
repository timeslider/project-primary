extends Node

@onready var puzzle: Puzzle = $Puzzle
@onready var button: Button = $Button


func _ready():
	#region _ready()
	#Puzzle.red
	button.pressed.connect(Puzzle.set_initial_state)
	#endregion
	#region get_state()

	#endregion
	#region trailing_zero_count()

	#endregion
	#region set_initial_state()

	#endregion
	#region can_move()

	#endregion
	#region get_states()

	#endregion
	pass
