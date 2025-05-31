extends Control

# Note, for this to work, everything in the splash screen container must
# have its modulation.a set to 0.

@export var load_scene: PackedScene
@export var in_time: float = 0.5
@export var fade_in_time: float = 1.5
@export var pause_time: float = 1.5
@export var fade_out_time: float = 1.5
@export var out_time: float = 0.5
@export var splash_screen_container: CenterContainer

#region version
var _version_file = "user://version.dat"
var major: int = 0
var minor: int = 0
var patch: int = 0
@onready var major_button: Button = %Major
@onready var minor_button: Button = %Minor
@onready var patch_button: Button = %Patch
@onready var not_yet_button: Button = %NotYet
@onready var version: Control = %Version
@onready var version_label: Label = %version_label
@onready var reset_button: Button = %Reset
signal on_button_pressed
#const HUMAN_AUDIENCE_THEATRE_APPLAUSE_LARGE = preload("res://Audio/human_audience_theatre_applause_large.mp3")
enum UpdateType {
	MAJOR,
	MINOR,
	PATCH,
	RESET,
	NOT_YET,
}
#endregion

var splash_screens: Array[Node]


func _ready() -> void:
	#region version
	# check if version file exist
	if FileAccess.file_exists(_version_file) == true:
		var file = FileAccess.open(_version_file, FileAccess.READ)
		print("The file length is ", file.get_length())
		if file.get_length() > 0:
			major = file.get_var()
			minor = file.get_var()
			patch = file.get_var()
	else:
		var file = FileAccess.open(_version_file, FileAccess.WRITE)
		file.store_var(0) # Major
		file.store_var(0) # Minor
		file.store_var(0) # Patch

	version_label.text = version_to_string()
	major_button.pressed.connect(update.bind(UpdateType.MAJOR))
	minor_button.pressed.connect(update.bind(UpdateType.MINOR))
	patch_button.pressed.connect(update.bind(UpdateType.PATCH))
	not_yet_button.pressed.connect(update.bind(UpdateType.NOT_YET))
	reset_button.pressed.connect(update.bind(UpdateType.RESET))
	
	# wait for one of the buttons to be pressed before continuing
	await on_button_pressed
	#var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
	#audio_player.stream = HUMAN_AUDIENCE_THEATRE_APPLAUSE_LARGE
	#add_child(audio_player)
	#audio_player.play()
	version.hide()
	version.queue_free()
	#endregion version

	Util.load_gen_states_v2()
	splash_screens = splash_screen_container.get_children()
	fade()


func fade() -> void:
	for screen in splash_screens:
		var tween = self.create_tween()
		tween.tween_interval(in_time)
		tween.tween_property(screen, "modulate:a", 1.0, fade_in_time)
		tween.tween_interval(pause_time)
		tween.tween_property(screen, "modulate:a", 0.0, fade_out_time)
		tween.tween_interval(out_time)
		await tween.finished
	get_tree().change_scene_to_packed(load_scene)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed():
		get_tree().change_scene_to_packed(load_scene)


func update(update_type: UpdateType) -> void:
	if update_type == UpdateType.NOT_YET:
		on_button_pressed.emit()
		return
	if update_type == UpdateType.PATCH:
		patch += 1
	if update_type == UpdateType.MINOR:
		minor += 1
		patch = 0
	if update_type == UpdateType.MAJOR:
		major += 1
		minor = 0
		patch = 0
	if update_type == UpdateType.RESET:
		major = 0
		minor = 0
		patch = 0
	var file = FileAccess.open(_version_file, FileAccess.WRITE_READ)
	file.store_var(major)
	file.store_var(minor)
	file.store_var(patch)
	file.close()
	on_button_pressed.emit()


func version_to_string() -> String:
	return "v: " + str(major) + "." + str(minor) + "." + str(patch)
