extends Node3D

# "res://PuzzleData.bin"
@onready var h_slider: HSlider = $HSlider
@onready var label: Label = $Button/Label
@onready var text_edit: TextEdit = $Button/TextEdit

#@export var Util : Node
var Util = load("res://Util.cs")

func _ready() -> void:
	print(h_slider.value)


func get_puzzle(index: int) -> void:
	var file_path = "res://PuzzleData.bin"

	if FileAccess.file_exists(file_path):
		var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
		
		var ulong_size = 8  # Size of an ulong in bytes
		var position_in_file = index * ulong_size  # Calculate the position
		
		if position_in_file < file.get_length():
			file.seek(position_in_file)
			var ulong_value = file.get_64()
			print("The ulong at index ", index, " is: ", ulong_value)
			Util.PrintBitboard(ulong_value)
		else:
			print("Index ", index, " is out of bounds.")
		
		file.close()
	else:
		print("File not found:", file_path)

#func print_bitboard(bitboard: int) -> void:
	#var output: String = ""
	#output += str(bitboard) + "\n"
	#for row: int in range(8):
		#for col: int in range(8):
			#if get_bitboard_cell(bitboard, col, row) == true:
				#output += "1 "
			#else:
				#output += "- "
		#output += "\n"
	#print(output)

#func get_bitboard_cell(bitboard: int, col: int, row: int) -> bool:
	#var bit_position: int = row * 8 + col
	#return (bitboard & (1 << bit_position)) != 0

#static func get_bitboard_cell_by_index(bitboard: int, index: int):
	#return (bitboard & (1 << index)) != 0
#
#static func trailing_zero_count(bitboard: int) -> int:
	#if bitboard == 0:
		#return 64
	#var count: int = 0
	#while (bitboard & 1) == 0:
		#count += 1
		#bitboard >>= 1
	#return count

#static func polyomino_check(bitboard: int) -> bool:
	#var population: int = 64 - pop_count(bitboard)
	#
	#var visited : Array = []
	#var queue : Array = []
	#
	#visited.append(trailing_zero_count(~bitboard))
	#queue.append(trailing_zero_count(~bitboard))
	#
	#var index: int = 0
	#while !queue.is_empty():
		#index = queue.pop_front()
		## Left
		#if index % 8 > 0 and get_bitboard_cell_by_index(bitboard, index - 1) == false:
			#if index - 1 not in visited:
				#visited.append(index - 1)
				#queue.append(index - 1)
		## Up
		#if index >= 8 and get_bitboard_cell_by_index(bitboard, index - 8) == false:
			#if index - 8 not in visited:
				#visited.append(index - 8)
				#queue.append(index - 8)
		## Down
		#if index + 8 < 64 and get_bitboard_cell_by_index(bitboard, index + 8) == false:
			#if index + 8 not in visited:
				#visited.append(index + 8)
				#queue.append(index + 8)
		## Right
		#if index % 8 < 7 and get_bitboard_cell_by_index(bitboard, index + 1) == false:
			#if index + 1 not in visited:
				#visited.append(index + 1)
				#queue.append(index + 1)
	#return visited.size() == population


#static func pop_count(bitboard: int) -> int:
	#var count: int = 0
	#while bitboard > 0:
		#bitboard &= (bitboard - 1)
		#count += 1
	#return count


func _on_h_slider_drag_ended(_value_changed: bool) -> void:
	if(h_slider.value > 195834706):
		h_slider.value = 195834706.0
	@warning_ignore("narrowing_conversion")
	get_puzzle(h_slider.value)


func _on_button_button_up() -> void:
	var value = int(text_edit.text)
	Util.PrintBitboard(value, false)
	if Util.PolyominoChecker(value) == true:
		print("This was a polyomino")
	else:
		print("This wasn't a polyomino")
