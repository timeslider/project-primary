extends Node

func _ready() -> void:
	print("Testing bitboard class")
	var a
	var b


	#region _ready
	#endregion
	#region get_bitboard_cell_by_index
	#endregion
	#region get_bitboard_cell_by_col_row
	#endregion
	#region get_state
	#endregion
	#region set_state
	#endregion
	#region trailing_zero_count
	#endregion
	#region print_bitboard
	#endregion
	#region set_initial_state
	#endregion
	#region can_move
	#endregion
	#region flip_horizontal
	#endregion
	#region flip_vertical
	#endregion
	#region flip_diag_a1_h8
	#endregion
	#region rotate_cw
	#endregion
	#region rotate_ccw
	#endregion
	#region canonicalize
	#endregion
	#region compare_unsigned
	a = 0
	b = 2
	print("(%s, %s): %s" % [String.num_uint64(a), String.num_uint64(b), Bitboard.compare_unsigned(a, b)])
	a = 2
	b = 0
	print("(%s, %s): %s" % [String.num_uint64(a), String.num_uint64(b), Bitboard.compare_unsigned(a, b)])
	a = -5
	b = 0
	print("(%s, %s): %s" % [String.num_uint64(a), String.num_uint64(b), Bitboard.compare_unsigned(a, b)])
	a = 0
	b = -5
	print("(%s, %s): %s" % [String.num_uint64(a), String.num_uint64(b), Bitboard.compare_unsigned(a, b)])
	print("Ending testing for bitboard class")
	#endregion
