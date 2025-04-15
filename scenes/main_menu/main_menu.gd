class_name MainMenu
extends Control




# Continue
@onready var continue_button: Button = %ContinueButton

# New game
@onready var new_game_button: Button = %NewGameButton
@onready var new_game_select_overlay: CanvasLayer = %NewGameSelectOverlay
@onready var new_game_back_button: Button = %NewGameBackButton

# Load game
@onready var load_game_button: Button = %LoadGameButton

# Select chapter
@onready var select_chapter_button: Button = %SelectChapterButton

# Explore
@onready var explore_button: Button = %ExploreButton

# Settings
@onready var settings_button: Button = %SettingsButton
@onready var settings_overlay: Settings = $SettingsOverlay

# Quit
@onready var quit_to_desktop_button: Button = %QuitToDesktopButton
@onready var quit_overlay: CanvasLayer = %QuitOverlay
@onready var yes_quit: Button = %YesQuit
@onready var no_quit: Button = %NoQuit


@onready var main_menu_canvas: CanvasLayer = %MainMenuCanvas



@export var move_lookup_table: Dictionary
const MOVE_LOOKUP_TABLES = preload("res://move_lookup_tables.tres")
var PRIMARY_LOOKUP_TABLE: Dictionary = MOVE_LOOKUP_TABLES.get_meta("primary") as Dictionary
#const LET_IT_SLIDE_LOOKUP_TABLE = MOVE_LOOKUP_TABLES.get_meta("let_it_slide")
const x: Dictionary = {
		2: "Hello",
		4: "Buy",
		5: "What's good son",
		}


#@onready var margin_container_2: MarginContainer = $MarginContainer2

#@onready var start_level = preload()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#start_button.button_up.connect(_on_start_button_button_up)
	#exit_button.button_up.connect(_on_exit_button_button_up)
	#print(MOVE_LOOKUP_TABLES.get_meta("let_it_slide"))
	#continue_button.pressed.connect()
	#new_game_button.pressed.connect()
	#load_game_button.pressed.connect()
	#select_chapter_button.pressed.connect()
	#explore_button.pressed.connect()
	
	# Connections
	settings_button.pressed.connect(_on_settings_button_pressed)
	quit_to_desktop_button.pressed.connect(_on_quit_to_desktop_button_pressed)
	yes_quit.pressed.connect(_on_yes_quit_pressed)
	no_quit.pressed.connect(_on_no_quit_pressed)
	new_game_back_button.pressed.connect(_new_game_back_button_pressed)
	new_game_button.pressed.connect(_new_game_press)
	
	continue_button.grab_focus()
	#print(MOVE_LOOKUP_TABLES.get_meta("primary"))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_start_button_button_up() -> void:
	pass # Replace with function body.

func _on_quit_to_desktop_button_pressed() -> void:
	main_menu_canvas.hide()
	quit_overlay.show()


func _on_settings_button_pressed() -> void:
	main_menu_canvas.hide()
	main_menu_canvas.visible = false
	settings_overlay.show()
	settings_overlay.grab_focus()
	

func _on_yes_quit_pressed() -> void:
	get_tree().quit()


func _on_no_quit_pressed() -> void:
	main_menu_canvas.show()
	quit_overlay.hide()


func _new_game_press() -> void:
	main_menu_canvas.hide()
	new_game_select_overlay.show()


func _new_game_back_button_pressed() -> void:
	main_menu_canvas.show()
	new_game_select_overlay.hide()


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("test"):
		if main_menu_canvas.visible == true:
			main_menu_canvas.visible = false
		else:
			main_menu_canvas.visible = true
		print(main_menu_canvas.visible)
