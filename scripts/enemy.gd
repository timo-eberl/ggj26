class_name Enemy
extends CharacterBody3D

@export var turn_speed : float = 3.0

@onready var _mask : Node3D = %Mask
@onready var state_chart: StateChart = $StateChart
@onready var mask_target: Node3D = $MaskTarget

func _on_active_state_physics_processing(delta: float) -> void:
	var direction := global_position.direction_to(_mask.global_position)

	var facing_direction := -global_basis.z
	var angle_diff := facing_direction.signed_angle_to(direction, Vector3.UP)

	rotate_y(angle_diff * turn_speed * delta)
