class_name Enemy
extends Node3D

@export var turn_speed : float = 5.0
@onready var _mask : Node3D = $"../../Camera3D"
var state: State = State.IDLE

enum State { IDLE, ACTIVE }

func _physics_process(delta: float) -> void:
	match state:
		State.IDLE:
			do_idle_logic()
		State.ACTIVE:
			do_active_logic(delta)

func do_idle_logic():
	print("idle")
	pass

func do_active_logic(delta: float):
	var direction := global_position.direction_to(_mask.global_position)
	print("direction: ", direction)

	var facing_direction := -global_basis.z
	var angle_diff := facing_direction.signed_angle_to(direction, Vector3.UP)

	rotate_y(angle_diff * turn_speed * delta)
