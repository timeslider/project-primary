class_name SelectGoals
extends SelectLargeValueBase


func _ready() -> void:
	MAX_VALUE = 5

func update_ui(_value: int) -> void:
	PuzzleSelectGlobal.goals = _value
	value_label.text = value_string + String.num_uint64(PuzzleSelectGlobal.goals)
	
	quick_select.set_value_no_signal(float(_value) / MAX_VALUE)
	exact_select.text = str(int(_value))


# We won't be update the polyomino here
# TODO: Redo this so that we use our 3D tiles.
# TODO: In the base class, do nothing. In 
func update_tiles() -> void:
	pass
	#match Select:
		#SelectOptions.POLYOMINO:
			#for node in %Tiles.get_children():
				#node.queue_free()
			## Create polyomino
			## TODO: Figure out a better way to store tiles so they can be accessed
			## and moved easier later
			## TODO: The floor doens't have to be added each time. It can be static
			## in the background.
			#for row in range(8):
				#for col in range(8):
					#var sprite2D: Sprite2D = Sprite2D.new()
					#if Bitboard.get_bitboard_cell_by_col_row(PuzzleSelectGlobal.polyomino, col, row) == true:
						#sprite2D.position = Vector2(col * 128, row * 128)
						#sprite2D.texture = preload("res://Resources/wall.tres") as Texture2D
						#tiles.add_child(sprite2D)
					#else:
						#sprite2D.position = Vector2(col * 128, row * 128)
						#sprite2D.texture = preload("res://Resources/floor.tres") as Texture2D
						#tiles.add_child(sprite2D)
		#SelectOptions.PLAYERS:
			#pass
		#SelectOptions.GOALS:
			#pass
	# TODO: Instead of clearing %Tiles, it needs to decide based on what we're
	# selecting
	# Clear value

	#Bitboard.print_bitboard(PuzzleSelectGlobal.polyomino)
	#match Select:
		#SelectOptions.POLYOMINO:
			#if PuzzleSelectGlobal.polyomino == -1:
				#value = 0
				#_update_ui(0)
				#_update_tiles()
		#SelectOptions.PLAYERS:
			#if PuzzleSelectGlobal.players == -1:
				#value = 0
				#_update_ui(0)
				#_update_tiles()
		#SelectOptions.GOALS:
			#if PuzzleSelectGlobal.goals == -1:
				#value = 0
				#_update_ui(0)
				#_update_tiles()
