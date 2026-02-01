class_name Mask
extends RigidBody3D

@export var first_enemy: Enemy

const mouse_sensitivity = 0.002
@export var dislodge_force = 8
@export_range(-90,90) var dislodge_angle_offset = 50
@export var time_scale = 0.2
@export var mask_shoot_force = 3
@export var transition_speed = 10
@export var min_trans_time = 0.6
@export var max_trans_time = 0.8
@export var shoot_cooldown_sec = 0.2

@export_category("Camera Settings")
@export_group("Camera Tilt")
@export_range(-90, -60) var tilt_lower_limit: int = -90
@export_range(60, 90) var tilt_upper_limit: int = 90

@export_category("Slow down")
@export var max_slow_down_time: float = 2.0

var _slow_down_timer: float = 0.0 
var _cam_rot: Vector3
var _last_shot_time := Time.get_ticks_msec()

@onready var cam: Node3D = $"../CamParent"
@onready var cam_effect: CameraEffects = $"../CamParent/Camera3D"
@onready var ray_cast: RayCast3D = $"../CamParent/Camera3D/RayCast3D"
@onready var player_controller: PlayerController = $PlayerController
@onready var state_chart: StateChart = $StateChart

var _current_enemy: Enemy

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_current_enemy = first_enemy
	await get_tree().process_frame
	_current_enemy.get_state_chart().send_event("onPos")

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
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
	print("hi")
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
	_current_enemy.head.global_transform = self.global_transform
	
	_current_enemy.waffe.set_target(self.global_position - self.global_basis.z * 500)
	
	if Input.is_action_just_pressed("shoot"):
		if (Time.get_ticks_msec() - _last_shot_time) > (shoot_cooldown_sec * 1000.0):
			_current_enemy.waffe.shoot()
			_last_shot_time = Time.get_ticks_msec()
	
	if Input.is_action_just_pressed("right_mouse_button"):
		state_chart.send_event("onDislodge")


# Dislodged
func _on_dislodged_state_entered() -> void:
	cam_effect.add_screen_shake(0.4, 0.4)
	cam_effect.enable_headbob = true
	AudioManager.play("Dislodge", 0.0)
	self.freeze = false
	print("dislodge_angle_offset: ", dislodge_angle_offset)
	var dir = Vector3.FORWARD.rotated(Vector3.RIGHT, deg_to_rad(dislodge_angle_offset)) * self.global_basis.inverse()
	self.apply_central_impulse(dir * dislodge_force)
func _on_dislodged_state_processing(_delta: float) -> void:
	cam.global_transform = self.global_transform
	if true:
		state_chart.send_event("onMaskAim")


# Aiming
func _on_aiming_state_entered() -> void:
	_slow_down_timer = 0.0
	cam_effect.enable_blur(true)
	_cam_rot = self.global_rotation
func _on_aiming_state_processing(delta: float) -> void:			
	Engine.time_scale = lerp(Engine.time_scale, time_scale, delta * 5.0)
	cam.global_position = self.global_position
	cam.global_rotation.y = _cam_rot.y
	cam.global_rotation.x = _cam_rot.x

	_slow_down_timer += delta / Engine.time_scale

	var blur_progress = clamp(_slow_down_timer / max_slow_down_time, 0.0, 1.0)
	cam_effect.set_blur_intensity(blur_progress)

	if _slow_down_timer >= max_slow_down_time:
		state_chart.send_event("onMaskMiss")

	if Input.is_action_just_pressed("right_mouse_button") or Input.is_action_just_pressed("left_mouse_button"):
		var collider = ray_cast.get_collider() as CollisionObject3D
		if collider is Enemy:
			if is_instance_valid(_current_enemy):
				_current_enemy.head.global_transform = _current_enemy.mask_target.global_transform
				_current_enemy.get_state_chart().send_event("onActivate")
			_current_enemy = collider
			_current_enemy.get_state_chart().send_event("onPossessed")
			cam_effect.enable_blur(false)
			state_chart.send_event("onTransition")
		#else:
			#state_chart.send_event("onMaskMiss")
func _on_aiming_state_exited() -> void:
	Engine.time_scale = 1
	_slow_down_timer = 0.0

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
func _on_dead_state_entered() -> void:
	self.global_rotation = cam.global_rotation
	self.freeze = false
	$"../CanvasLayer/Reticle".visible = false
	await get_tree().create_timer(3.0).timeout
	get_tree().reload_current_scene()
func _on_dead_state_processing(_delta: float) -> void:
	cam_effect.enable_full_blur()
	# self.global_rotation = cam.global_rotation
	cam.global_transform = self.global_transform
	

func on_hit_by_bullet(direction: Vector3):
	freeze = false
	apply_central_impulse((direction+Vector3.UP*0.2)*5)
