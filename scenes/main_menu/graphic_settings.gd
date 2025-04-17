extends Panel

@onready var v_sync_label: Label = %VSyncLabel
@onready var v_sync_decrease_button: Button = %VSyncDecreaseButton
@onready var v_sync_value_label: Label = %VSyncValue
@onready var v_sync_increase_button: Button = %VSyncIncreaseButton
var _v_sync_index: int = 0:
	set(value):
		if _v_sync_index >= 4:
			_v_sync_index = 3
		if _v_sync_index < 0:
			_v_sync_index = 0
		else:
			_v_sync_index = value



@onready var vsync_setting: OptionCycleSetting = $MarginContainer/VBoxContainer/HBoxContainer2
@onready var msaa_setting: OptionCycleSetting = $MarginContainer/VBoxContainer/HBoxContainer3



@export var settings: Settings

const VSYNC_MODES = [
	DisplayServer.VSYNC_DISABLED,
	DisplayServer.VSYNC_ENABLED,
	DisplayServer.VSYNC_ADAPTIVE,
	DisplayServer.VSYNC_MAILBOX,
]

const MSAA = [
	Viewport.MSAA_DISABLED,
	Viewport.MSAA_2X,
	Viewport.MSAA_4X,
	Viewport.MSAA_8X,
]

const VSYNC_MODE_NAMES = [
	"Disabled",
	"Enabled",
	"Adaptive",
	"Mailbox",
]

enum FrameRate {
	THIRTY,
	SIXTY,
	NINTY,
	ONE_FOURTY_FOUR,
	NO_LIMIT,
}

enum Direction {
	UP,
	DOWN,
}

func _ready() -> void:
	vsync_setting.option_values = [
		DisplayServer.VSYNC_ENABLED,
		DisplayServer.VSYNC_ADAPTIVE,
		DisplayServer.VSYNC_MAILBOX,
		DisplayServer.VSYNC_DISABLED,
	]
	
	msaa_setting.option_values = [
		Viewport.MSAA_DISABLED,
		Viewport.MSAA_2X,
		Viewport.MSAA_4X,
		Viewport.MSAA_8X,
	]
	
	
	var current_vsync_value = DisplayServer.window_get_vsync_mode()
	
	
	# TODO: Update label based on loaded settings
	v_sync_increase_button.pressed.connect(change_vsync.bind(Direction.UP))
	v_sync_decrease_button.pressed.connect(change_vsync.bind(Direction.DOWN))
	

func change_vsync(direction: Direction):
	if direction == Direction.UP:
		_v_sync_index += 1
	else:
		_v_sync_index -= 1
	#DisplayServer.window_set_vsync_mode(DisplayServer.VSyncMode[_v_sync_index])


func _on_option_setting_changed_enum(setting_name: String, new_enum_value):
	if setting_name == "VSync Mode":
		print("Applying VSync Mode: ", new_enum_value)
		DisplayServer.window_set_vsync_mode(new_enum_value)
