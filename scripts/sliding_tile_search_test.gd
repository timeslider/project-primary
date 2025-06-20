extends Node

func _ready() -> void:
	var searcher = SlidingTileSearch.new()
	searcher.walls = 0
	var count = searcher.find_valid_starting_points(2)
	print("Total valid starting states", count)
