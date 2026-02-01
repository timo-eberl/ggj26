extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.play("BackgroundMusicAction", 0.0, false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
