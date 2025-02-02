extends Node

var wall_data: int
var playable: bool
var reasons: Array[String]
var red: int
var yellow: int
var blue: int
var state: int

var boundaries: Array[int] = [255, 9259542123273814144, 18374686479671623680, 72340172838076673]
enum direction {up, right, down, left}

func get_bitboard_cell(index: int) -> bool:
	assert(index < 0 and index > 63)
	return (wall_data & (1 << index)) != 0
