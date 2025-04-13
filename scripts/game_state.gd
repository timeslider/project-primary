class_name GameState
extends Node

# During the loading process, we need to check if current_save_file_location is
# and set it. This reperesets the last save file the player used. If one is set,
# then the main menu should have a continue button. Otherwise, continue can be
# hidden.
var current_save_file_location = ""

## This class represents the state of the entire game
# There might be a better way of handling this since it can only be beaten in order.
var worlds_status: Dictionary[String, Array] = {
	"world_unlocked": [true, false, false, false],
}



func on_save_game(saved_data: Array[SavedData]):
	#if condition_shouldn't_be_saved == true:
		#return
	var my_data = SavedData.new()
	
	# scene_file_path is a built-in string that is the name of the current scene of self.
	my_data.scene_path = scene_file_path
	saved_data.append(my_data)
	
	
func on_before_load_game():
	pass


func on_load_game():
	pass
	
	
