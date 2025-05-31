extends Node

func _ready() -> void:
	
	#region load_gen_states
	#Util.measure_function_time(Util.load_gen_states, 10, ["res://gen_states.bin"])
	#Util.measure_function_time(Util.load_gen_states_resource, 10, ["res://gen_states.tres"])
	#Util.load_gen_states_new("res://gen_states.bin")
	print("Gen states: ", Util.gen_states.size())
	
	#assert(Util.gen_states.size() == 5126)
	#endregion
	
	
	#region _ready
	#endregion
	
	
	#region make_gen_state
	#endregion
	
	
	#region get_nth_polyomino
	var a: bitboard = bitboard.new()
	# The first 255 should be the same
	for i in range(258):
		assert(Util.get_nth_polyomino(i) == i, "%s was not the same as %s" % [Util.get_nth_polyomino(i), i])
	a.set_initial_state()
	a.wall_data = Util.get_nth_polyomino(1000)
	
	a.print_bitboard()
	print(Util.get_n_value(1252))
	#endregion
	
	
	#region get_n_value
	#endregion
	
	
	#region expand_state
	#endregion
	
	
	#region union
	#endregion
	
	
	#region find
	#endregion
	
	
	#region measure_function_time
	#endregion
	
	
	#region GetTransistionInfo._init
	#endregion
	pass
