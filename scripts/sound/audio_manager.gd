extends Node

var active_music_stream: AudioStreamPlayer

@export_group("Main")
@export var clips: Node

var _original_music_volume: float = -30.0
var _original_music_pitch: float = 1.0
var _is_slow_down: bool = false

var background_music_action: AudioStreamPlayer
var background_music_chill: AudioStreamPlayer

func _ready() -> void:
	background_music_action = clips.get_node("BackgroundMusicAction")
	background_music_chill = clips.get_node("BackgroundMusicChill")

func play(audio_name: String, from_position: float = 0.0, restart: bool = true) -> void:
	if active_music_stream and active_music_stream.name == audio_name and active_music_stream.playing and !restart:
		return

	active_music_stream = clips.get_node(audio_name)
	active_music_stream.play(from_position)

func stop(audio_name: String) -> void:
	if active_music_stream and active_music_stream.name == audio_name and active_music_stream.playing:
		active_music_stream.stop()


func slow_down_music(slow_down_progress : float, target_time_scale: float = 0.3) -> void:
	if not active_music_stream or not active_music_stream.playing:
		return

	if !background_music_action:
		return
	
	_is_slow_down = true

	var target_pitch = target_time_scale
	var target_volume = _original_music_volume - 30.0

	background_music_action.pitch_scale = lerp(_original_music_pitch, target_pitch, slow_down_progress)
	background_music_action.volume_db = lerp(_original_music_volume, target_volume, slow_down_progress)


func reset_music_speed() -> void:
	if not background_music_action:
		return
	
	_is_slow_down = false
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(background_music_action, "pitch_scale", _original_music_pitch, 0.2)
	tween.tween_property(background_music_action, "volume_db", _original_music_volume, 0.2)
