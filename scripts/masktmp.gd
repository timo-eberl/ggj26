extends Node3D

@export var first_enemy: Enemy
@onready var player_controller: PlayerController = $PlayerController
@onready var camera_controller: CameraController = $CameraController

func _physics_process(delta: float) -> void:
	# very stupid mask temporary logic
	player_controller.control_body(first_enemy, delta)
	camera_controller.update_camera(first_enemy, delta)
	self.global_transform = first_enemy.mask_target.global_transform
