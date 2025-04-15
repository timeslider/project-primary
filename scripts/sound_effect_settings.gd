class_name SoundEffectSettings
extends Resource

enum SoundEffectType {
	ON_TILE_PLACED,
	UI_HOVERED,
	UI_BUTTON_PRESSED,
}

@export_range(0, 10) var limit: int = 5
@export var type: SoundEffectType
@export var sound_effect: AudioStream
@export_range(-40, 20) var volume = 0
@export_range(0.0, 4.0, 0.01) var pitch_scale = 1.0
@export_range(0.0, 1.0, 0.1) var pitch_randomness = 0.0

var audio_count = 0

func change_audio_count(amount: int) -> void:
	audio_count = max(0, audio_count + amount)


func has_open_limit() -> bool:
	return audio_count < limit


func on_audio_finished() -> void:
	change_audio_count(-1)
