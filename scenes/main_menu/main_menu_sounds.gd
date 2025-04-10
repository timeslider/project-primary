extends VBoxContainer

@onready var continue_button: Button = %ContinueButton
@onready var new_game_button: Button = %NewGameButton
@onready var load_game_button: Button = %LoadGameButton
@onready var select_chapter_button: Button = %SelectChapterButton
@onready var explore_button: Button = %ExploreButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_to_desktop_button: Button = %QuitToDesktopButton

#@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
var audio: AudioStreamPlayer = AudioStreamPlayer.new()

var pitch_table: Array[float] = []
const TWELVETH_ROOT_TWO: float = 1.0594630943592952645618252949463

func _ready() -> void:
	pass
	#start_button.mouse_entered.connect(play_sound)
	#start_button_2.mouse_entered.connect(play_sound)
	#start_button_3.mouse_entered.connect(play_sound)
	#start_button_4.mouse_entered.connect(play_sound)
	#exit_button.mouse_entered.connect(play_sound)
	#add_child(audio)
	#audio.stream = load("res://Audio/drop_002.ogg")

	#var temp: float = 1.0
	for i in range(-10, 10):
		pitch_table.append(pow(TWELVETH_ROOT_TWO, i))
	for i in pitch_table:
		print(i)


func play_sound():
	audio.pitch_scale = pitch_table.pick_random()
	audio.play()
