class_name PlayerController extends CharacterBody3D

@export var debug: bool = false
@export_category("References")
@export var camera: CameraController
@export var state_chart: StateChart
@export_category("Movement Settings")
@export_group("Easing")
@export var accelartion: float = 1.0
@export var deceleration: float = 0.4
@export_group("Speed")
@export var default_speed: float = 6.0

var _input_dir: Vector2 = Vector2.ZERO
var _movement_velocity: Vector3 = Vector3.ZERO
var speed: float


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	speed = default_speed

	_input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var current_velocity = Vector2(_movement_velocity.x, _movement_velocity.z)
	var direction = (transform.basis * Vector3(_input_dir.x, 0, _input_dir.y)).normalized()

	if direction:
		current_velocity = lerp(current_velocity, Vector2(direction.x, direction.z) * speed, accelartion)
	else:
		current_velocity = current_velocity.move_toward(Vector2.ZERO, deceleration)
	
	_movement_velocity = Vector3(current_velocity.x, velocity.y, current_velocity.y)
	velocity = _movement_velocity

	move_and_slide()

func update_rotation(rotation_input: Vector3) -> void:
	global_transform.basis = Basis.from_euler(rotation_input)
