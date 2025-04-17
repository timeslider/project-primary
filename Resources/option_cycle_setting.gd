## OptionCycleSetting.gd
## A reusable control for cycling through a list of options.
## It displays a name, the current option, and previous/next buttons.
## Emits a signal when the selected value changes.
class_name OptionCycleSetting
extends Control

# --- Signals ---

## Emitted when the user changes the selection via the buttons.
## Passes the setting_name and the *new underlying value* (from option_values).
signal setting_changed(setting_name: String, new_value)


# --- Exports (Configurable Properties) ---

## The unique identifier for this setting (used in the signal).
@export var setting_name: String = "default_setting"

## The user-friendly name displayed on the left label.
## If left empty, it will attempt to use a title-cased version of setting_name.
@export var display_name: String = ""

## Array of user-friendly names for each option (e.g., ["Low", "Medium", "High"]).
@export var option_names: Array[String] = []

## Array of the actual underlying values corresponding to option_names.
## Must be the same size as option_names. (e.g., [0, 1, 2] or ["low_res", "med_res", "high_res"])
@export var option_values: Array = []


# --- Node References ---

@onready var name_label: Label = %NameLabel
@onready var value_label: Label = %ValueLabel
@onready var previous_button: Button = %PreviousButton
@onready var next_button: Button = %NextButton


# --- Internal State ---

var current_index: int = 0
var _is_initialized: bool = false


# --- Godot Lifecycle Methods ---

func _ready() -> void:
	# Basic validation
	if option_names.is_empty() or option_values.is_empty():
		push_error("OptionCycleSetting '%s': option_names or option_values is empty." % setting_name)
		_disable_controls()
		return
	if option_names.size() != option_values.size():
		push_error("OptionCycleSetting '%s': option_names and option_values must have the same size." % setting_name)
		_disable_controls()
		return

	# Setup display name if not provided
	if display_name.is_empty():
		name_label.text = setting_name.capitalize().replace("_", " ")
	else:
		name_label.text = display_name

	# Connect button signals
	previous_button.pressed.connect(_on_previous_pressed)
	next_button.pressed.connect(_on_next_pressed)

	# Initial UI setup will be done by set_current_value or _apply_initial_state
	# Wait for initial value to be set before finalizing initialization
	# Call _apply_initial_state() here if you *don't* plan to set initial value from outside
	# _apply_initial_state()


# --- Public Methods ---

## Sets the currently selected option based on its underlying value.
## Should be called after instancing the scene and setting exports.
## Does NOT emit the setting_changed signal.
func set_current_value(value) -> void:
	var index = option_values.find(value)
	if index != -1:
		current_index = index
	else:
		push_warning("OptionCycleSetting '%s': Initial value '%s' not found in option_values. Defaulting to index 0." % [setting_name, str(value)])
		current_index = 0 # Default to the first option if the provided value isn't found

	# Ensure _ready has potentially run and finished validation
	await ready # Wait in case set_current_value is called very early
	_apply_initial_state()


# --- Internal Methods ---

## Applies the initial state after validation and potentially receiving the initial value.
func _apply_initial_state() -> void:
	if _is_initialized: return # Prevent running twice

	if option_names.is_empty(): # Double check in case validation failed in _ready
		_disable_controls()
		return

	# Handle case with only one option
	if option_names.size() <= 1:
		_disable_controls()

	_update_display()
	_is_initialized = true


## Disables interaction if setup is invalid or only one option exists.
func _disable_controls() -> void:
	previous_button.disabled = true
	next_button.disabled = true
	value_label.modulate = Color(1, 1, 1, 0.5) # Dim the value label slightly
	if option_names.is_empty():
		value_label.text = "Error!"


## Updates the value label text based on the current_index.
func _update_display() -> void:
	if current_index >= 0 and current_index < option_names.size():
		value_label.text = option_names[current_index]
	else:
		# This shouldn't happen with proper clamping, but as a fallback:
		push_error("OptionCycleSetting '%s': Invalid current_index %d" % [setting_name, current_index])
		value_label.text = "Error"


## Handles the logic when the "Previous" button is pressed.
func _on_previous_pressed() -> void:
	print("_is_initialized", _is_initialized)
	if not _is_initialized or option_names.size() <= 1: return # Don't cycle if not ready or only one option

	current_index -= 1
	# Wrap around to the end if we go below 0
	if current_index < 0:
		current_index = option_names.size() - 1

	_apply_change()


## Handles the logic when the "Next" button is pressed.
func _on_next_pressed() -> void:
	print("_is_initialized", _is_initialized)
	if not _is_initialized or option_names.size() <= 1: return # Don't cycle if not ready or only one option

	current_index += 1
	# Wrap around to the beginning if we go past the end
	if current_index >= option_names.size():
		current_index = 0

	_apply_change()


## Updates the display and emits the setting_changed signal.
func _apply_change() -> void:
	_update_display()
	# Ensure index is valid before accessing values array
	if current_index >= 0 and current_index < option_values.size():
		setting_changed.emit(setting_name, option_values[current_index])
	else:
		push_error("OptionCycleSetting '%s': Cannot emit signal, invalid index %d" % [setting_name, current_index])
