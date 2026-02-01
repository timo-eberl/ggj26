class_name CameraEffects extends Camera3D

@export_category("References")
@export var player: PlayerController
@export var blur_effect: ColorRect
@export var mask: Mask

@export_category("Effects")
@export var enable_tilt: bool = true
@export var enable_headbob: bool = true
@export var enable_screen_shake: bool = true

@export_category("Blur Settings")
@export var max_blur_intensity: float = 4.0
@export var max_tint_strength: float = 0.5
@export var min_inner_radius: float = 0.0
@export var max_inner_radius: float = 0.75
@export var min_saturation: float = 0.25

@export_category("Kick and Recoil Settings")
@export_group("Run Tilt")
@export var run_pitch: float = 0.2
@export var run_roll: float = 0.5
@export var max_pitch: float = 1.0
@export var max_roll: float = 2.0
@export_group("Headbob")
@export_range(0.0, 0.1, 0.001) var bob_pitch: float = 0.05
@export_range(0.0, 0.1, 0.001) var bob_roll: float = 0.025
@export_range(0.0, 0.04, 0.001) var bob_up: float = 0.005
@export_range(3.0, 8.0, 0.1) var bob_frequency: float = 6.0

var _screen_shake_tween: Tween
var _step_timer = 0.0

var _previous_bob_sin: float = 0.0
var _footstep_triggered: bool = false

const MIN_SCREEN_SHAKE: float = 0.05
const MAX_SCREEN_SHAKE: float = 0.4

func _ready():
	blur_effect.visible = false

func _process(delta: float) -> void:
	calculate_view_offset(delta)

func enable_full_blur() -> void:
	blur_effect.visible = true
	blur_effect.material.set_shader_parameter("inner_radius", min_inner_radius)
	blur_effect.material.set_shader_parameter("saturation", min_saturation)
	blur_effect.material.set_shader_parameter("blur_amount", max_blur_intensity)
	blur_effect.material.set_shader_parameter("color_blend", max_tint_strength)


func set_blur_intensity(intensity: float) -> void:
	intensity = clamp(intensity, 0.0, 1.0)
	
	var current_inner_radius = lerp(max_inner_radius, min_inner_radius, intensity)
	var current_saturation = lerp(1.0, min_saturation, intensity)

	blur_effect.material.set_shader_parameter("inner_radius", current_inner_radius)
	blur_effect.material.set_shader_parameter("saturation", current_saturation)
	blur_effect.material.set_shader_parameter("blur_amount", intensity * max_blur_intensity)
	blur_effect.material.set_shader_parameter("color_blend", intensity * max_tint_strength)

func enable_blur(flag: bool):
	blur_effect.visible = flag
	blur_effect.material.set_shader_parameter("inner_radius", max_inner_radius)
	blur_effect.material.set_shader_parameter("saturation", 1.0)
	blur_effect.material.set_shader_parameter("blur_amount", 0.0)
	blur_effect.material.set_shader_parameter("color_blend", 0.0)

	if not flag:
		set_blur_intensity(0.0)


func calculate_view_offset(delta: float) -> void:
	if not player:
		return
	
	var velocity = player._movement_velocity
	var offset = Vector2.ZERO
	var angles = Vector3.ZERO

	var speed = Vector2(velocity.x, velocity.z).length()
	if speed > 0.1:
		_step_timer += delta * (speed / bob_frequency)
		_step_timer = fmod(_step_timer, 1.0)
	else:
		_step_timer = 0.0

	var bob_sin = sin(_step_timer * 2.0 * PI) * 0.5 # doom2: sin(time) * speed * amplitude

	if speed > 0.1 and enable_headbob:
		if _previous_bob_sin > 0.0 and bob_sin <= 0.0 and not _footstep_triggered:
			AudioManager.play("Footstep", 0.0)
			_footstep_triggered = true
		elif bob_sin > 0.0:
			_footstep_triggered = false
	
	_previous_bob_sin = bob_sin

	if enable_tilt:
		var forward = global_transform.basis.z
		var right = global_transform.basis.x

		var forward_dot = velocity.dot(forward)
		var forward_tilt = clampf(forward_dot * deg_to_rad(run_pitch), deg_to_rad(-max_pitch), deg_to_rad(max_pitch))
		#angles.x = lerp(rotation.x, forward_tilt, 10.0 * delta)

		var right_dot = velocity.dot(right)
		var side_tilt = clampf(right_dot * deg_to_rad(run_roll), deg_to_rad(-max_roll), deg_to_rad(max_roll))
		angles.z = lerp(rotation.z, -side_tilt, 10.0 * delta)
	
	if enable_headbob:
		var pitch_delta = bob_sin * deg_to_rad(bob_pitch) * speed
		angles.x -= pitch_delta

		# var roll_delta = bob_sin * deg_to_rad(bob_roll) * speed
		# angles.z -= roll_delta
		
		var bob_height = bob_sin * speed * bob_up
		offset.y += bob_height
	
	rotation = angles
		
func add_screen_shake(amount: float, seconds: float) -> void:
	if _screen_shake_tween:
		_screen_shake_tween.kill()
	
	_screen_shake_tween = create_tween()
	_screen_shake_tween.tween_method(update_screen_shake.bind(amount), 0.0, 1.0, seconds).set_ease(Tween.EASE_OUT)

func update_screen_shake(alpha: float, amount: float) -> void:
	amount = remap(amount, 0.0, 1.0, MIN_SCREEN_SHAKE, MAX_SCREEN_SHAKE)
	var current_shake_amount = amount * (1.0 - alpha)
	h_offset = randf_range(-current_shake_amount, current_shake_amount)
	v_offset = randf_range(-current_shake_amount, current_shake_amount)


func _on_possessing_state_exited() -> void:
	enable_headbob = false
	AudioManager.stop("Footstep")
