extends Node3D


@onready var audio_manager_2: AudioManager2 = $"./AudioManager"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	audio_manager_2.play("BackgroundMusicAction", 0.0, false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
