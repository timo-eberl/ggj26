class_name Enemy
extends CharacterBody3D

@export var turn_speed : float = 3.0

@onready var _mask : Node3D = %Mask
@onready var mask_possessing_state: AtomicState = %Mask/StateChart/Root/Possessing
@onready var state_chart: StateChart = $StateChart
@onready var mask_target: Node3D = $MaskTarget
@onready var head: Node3D = $Head
@onready var waffe: Waffe = $Head/HandAnchor/Waffe
@onready var ray_cast: RayCast3D = $Head/RayCast3D
@onready var state_possessed: AtomicState = $StateChart/Root/Possessed

var time_in_sight: float = 0.0
var time_to_trigger: float = pick_new_trigger_time()
var _has_target: bool = false

func get_state_chart() -> StateChart:
	return $StateChart

func pick_new_trigger_time():
	return randf_range(2.0, 3.0)

func _on_active_state_physics_processing(delta: float) -> void:
	var direction := global_position.direction_to(_mask.global_position)
	direction.y = 0
	direction = direction.normalized()
	
	var facing_direction := -global_basis.z.normalized()
	var angle_diff := facing_direction.signed_angle_to(direction, Vector3.UP)
	
	if not mask_possessing_state.active:
		reset_logic()
	
	waffe.set_target(_mask.global_position)
	
	ray_cast.look_at(_mask.global_position)
	var result := ray_cast.get_collider()
	if result is Enemy and result.state_possessed.active:
		if not _has_target:
			reset_logic()
		if time_in_sight >= time_to_trigger:
			print("shooting")
			waffe.shoot()
			reset_logic()
		time_in_sight += delta
	
	rotate_y(angle_diff * turn_speed * delta)

func reset_logic():
	time_in_sight = 0.0
	time_to_trigger = pick_new_trigger_time()
	print("Resetting. time_to_trigger: ", time_to_trigger)
	_has_target = true

func _on_possessed_state_entered() -> void:
	waffe.aim_speed = 25.0
	waffe.bullet_viz_scale = 200.0
	waffe.bullet_viz_thickness = 3.0

func _on_active_state_entered() -> void:
	waffe.aim_speed = 5.0
	waffe.bullet_viz_scale = 20.0
	waffe.bullet_viz_thickness = 0.5
