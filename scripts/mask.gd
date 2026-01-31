class_name Mask
extends RigidBody3D

@export var first_enemy: Enemy

const mouse_sensitivity = 0.002
@export var dislodge_force = 8
@export_range(-90,90) var dislodge_angle_offset = 20
@export var time_scale = 0.1
@export var mask_shoot_force = 3
@export var transition_speed = 10
@export var min_trans_time = 0.6
@export var max_trans_time = 0.8

@export_category("Camera Settings")
@export_group("Camera Tilt")
@export_range(-90, -60) var tilt_lower_limit: int = -90
@export_range(60, 90) var tilt_upper_limit: int = 90

var _cam_rot: Vector3

@onready var cam: Camera3D = $"../Camera3D"
@onready var ray_cast: RayCast3D = $"../Camera3D/RayCast3D"
@onready var player_controller: PlayerController = $PlayerController
@onready var state_chart: StateChart = $StateChart

var _current_enemy: Enemy

var is_dislodged = false
var is_in_aim_mode = false
var was_in_aim_mode = false
var is_in_transition = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_current_enemy = first_enemy
	_current_enemy.get_state_chart().send_event.call_deferred("onPossessed")

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_cam_rot.x -= event.screen_relative.y * mouse_sensitivity
		_cam_rot.y -= event.screen_relative.x * mouse_sensitivity
		_cam_rot.x = clamp(_cam_rot.x, deg_to_rad(tilt_lower_limit), deg_to_rad(tilt_upper_limit))
		_cam_rot.z = 0.0

# Possessing
func _on_possessing_state_entered() -> void:
	self.freeze = true
	_cam_rot = _current_enemy.global_rotation
func _on_possessing_state_physics_processing(delta: float) -> void:
	player_controller.control_body(_current_enemy, delta)
func _on_possessing_state_processing(_delta: float) -> void:
	_current_enemy.global_rotation.y = _cam_rot.y
	rotation.x = _cam_rot.x
	
	# sync position and y rotation (but not x)
	self.global_position = _current_enemy.mask_target.global_position
	self.global_rotation.y = _current_enemy.mask_target.global_rotation.y
	
	cam.global_transform = self.global_transform
	
	if Input.is_action_just_pressed("ui_accept"):
		state_chart.send_event("onDislodge")


# Dislodged
func _on_dislodged_state_entered() -> void:
	self.freeze = false
	var dir = Vector3.FORWARD.rotated(Vector3.RIGHT, deg_to_rad(dislodge_angle_offset)) * self.global_basis.inverse()
	self.apply_central_impulse(dir * dislodge_force)
func _on_dislodged_state_processing(_delta: float) -> void:
	cam.global_transform = self.global_transform
	if Input.is_action_just_pressed("right_mouse_button"):
		state_chart.send_event("onMaskAim")


# Aiming
func _on_aiming_state_entered() -> void:
	Engine.time_scale = time_scale
	_cam_rot = self.global_rotation
func _on_aiming_state_processing(_delta: float) -> void:
	cam.global_position = self.global_position
	cam.global_rotation.y = _cam_rot.y
	cam.global_rotation.x = _cam_rot.x
	if Input.is_action_just_released("right_mouse_button"):
		Engine.time_scale = 1
		var collider = ray_cast.get_collider() as CollisionObject3D
		if collider is Enemy:
			_current_enemy = collider
			_current_enemy.get_state_chart().send_event("onPossessed")
			state_chart.send_event("onTransition")
		else:
			self.global_rotation = cam.global_rotation
			state_chart.send_event("onMaskMiss")

# Transition to Possessing
func _on_transition_state_entered() -> void:
	self.freeze = true
	var target_transform := _current_enemy.mask_target.global_transform
	var dist = self.global_position.distance_to(target_transform.origin)
	var duration = dist / transition_speed
	duration = clamp(duration, min_trans_time, max_trans_time)
	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property(self, "global_transform", target_transform, duration / 1.5) \
		.set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(cam, "global_position", target_transform.origin, duration)
	tween.tween_property(cam, "global_rotation", target_transform.basis.get_euler(), duration) \
		.set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_IN)
	tween.set_parallel(false)
	tween.finished.connect(func(): state_chart.send_event("onPossess"))

# Dead
func _on_dead_state_processing(_delta: float) -> void:
	cam.global_transform = self.global_transform
