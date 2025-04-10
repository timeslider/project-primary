class_name Settings
extends CanvasLayer

@onready var gameplay_button: Button = %GameplayButton
@onready var graphics_button: Button = %GraphicsButton
@onready var audio_button: Button = %AudioButton
@onready var controls_button: Button = %ControlsButton

@onready var ok_button: Button = %OkButton
@onready var cancel_button: Button = %CancelButton
@onready var button_container: MarginContainer = $"../ButtonContainer"

@onready var panels: Array[Panel] = [
		%GameplayPanel,
		%GraphicsPanel,
		%AudioPanel,
		%ControlsPanel
		]


enum SettingMenu {
	GAMEPLAY,
	GRAPHICS,
	AUDIO,
	CONTROLS,
}

var current_menu: SettingMenu

func _ready() -> void:
	gameplay_button.pressed.connect(_on_gameplay_button_pressed)
	graphics_button.pressed.connect(_on_graphics_button_pressed)
	audio_button.pressed.connect(_on_audio_button_pressed)
	controls_button.pressed.connect(_on_controls_button_pressed)
	ok_button.pressed.connect(_on_ok_button_pressed)
	cancel_button.pressed.connect(_on_cancel_button_pressed)
	
	current_menu = SettingMenu.GAMEPLAY


func _on_gameplay_button_pressed():
	_change_menu(SettingMenu.GAMEPLAY)


func _on_graphics_button_pressed():
	_change_menu(SettingMenu.GRAPHICS)


func _on_audio_button_pressed():
	_change_menu(SettingMenu.AUDIO)


func _on_controls_button_pressed():
	_change_menu(SettingMenu.CONTROLS)


func _on_ok_button_pressed():
	# Save the temp options data to perminent options data storage
	self.hide()
	button_container.show()


func _on_cancel_button_pressed():
	# Delete the temp options data and go back to main menu
	self.hide()
	button_container.show()


func _change_menu(setting_menu: SettingMenu):
	for panel in panels:
		panel.hide()
	if setting_menu == SettingMenu.GAMEPLAY:
		panels.get(0).show()
	if setting_menu == SettingMenu.GRAPHICS:
		panels.get(1).show()
	if setting_menu == SettingMenu.AUDIO:
		panels.get(2).show()
	if setting_menu == SettingMenu.CONTROLS:
		panels.get(3).show()

func grab_focus():
	gameplay_button.grab_focus()
