class_name GameState
extends Node

## This class represents the state of the entire game
var worlds_status: Dictionary[String, bool] = {
	"world_1_unlocked": true,
	"world_2_unlocked": false,
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
	
	
