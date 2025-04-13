extends Node

var save_file_name: String = ""

#var label_confirmation = preload("uid://cm55f7vqlfjre") # save_load_confirmation

func save_game():
	var save_file = FileAccess.open("user://save_game2.json", FileAccess.WRITE)
	var saved_data: Dictionary = {}
	
	# This calls the on_save_game function inside every persist node and gives
	# them a piece of paper called saved_data so they can write either data to it
	await get_tree().call_group("persist", "on_save_game", saved_data)

	# Then we turn that data into a valid JSON string and save it to file
	var json_string = JSON.stringify(saved_data)
	save_file.store_line(json_string)


func load_game():
	# Check if file exists
	if not FileAccess.file_exists("user://save_game2.json"):
		print("no save file found.")
		return
	
	var save_file = FileAccess.open("user://save_game2.json", FileAccess.READ)
	var save_nodes = get_tree().get_nodes_in_group("persist")

	var json_string = save_file.get_line()
	var node_data = JSON.parse_string(json_string)
	
	if node_data == null:
		print("JSON parse error: ", json_string)
		return
	print(node_data)
	# Loading is just one line of code. We get the data from node_data
	# using the uuid. The on_load_game function inside each persist node handles
	# It's own loading.
	for node in save_nodes:
		var key = str(node.uuid)
		if node_data.has(key):
			node.on_load_game(node_data[key])
		else:
			print("No data for UUID: %s" % key)

func save_config():
	pass

func load_config():
	pass

func save_favorites():
	pass

func load_favorites():
	pass

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("save"):
		save_game()
		#var instance = label_confirmation.instantiate() as SaveLoadConfirmation
		#instance.set_new_text("Data saved! (Also, I miss my Mimi 😭)")
		#instance.position = Vector2(364, 249)
		#add_child(instance)
		
	if Input.is_action_just_pressed("load"):
		load_game()
		#var instance = label_confirmation.instantiate() as SaveLoadConfirmation
		#instance.set_new_text("Data loaded! (Also, I miss my Mimi 😭)")
		#instance.position = Vector2(364, 249)
		#add_child(instance)
