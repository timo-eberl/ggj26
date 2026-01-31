class_name CameraEffects extends Camera3D

@export_category("References")
@export var player: PlayerController
@export var blur_effect: ColorRect

@export_category("Effects")
@export var enable_tilt: bool = true
@export var enable_headbob: bool = true
@export var enable_screen_shake: bool = true

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

const MIN_SCREEN_SHAKE: float = 0.05
const MAX_SCREEN_SHAKE: float = 0.4

func _ready():
	set_blur_strength(0.0)

func _process(delta: float) -> void:
	calculate_view_offset(delta)

func set_blur_strength(strength: float) -> void:
	blur_effect.material.set_shader_parameter("blur_amount", strength * 5.0)
	blur_effect.material.set_shader_parameter("tint_strenght", strength * 0.3)

func enable_blur_smooth():
	var tween = create_tween()
	tween.tween_method(set_blur_strength, 0.0, 1.0, 0.3)

func disable_blur_smooth():
	var tween = create_tween()
	tween.create_method(set_blur_strength, 1.0, 0.0, 0.3)

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


	if enable_tilt:
		var forward = global_transform.basis.z
		var right = global_transform.basis.x

		var forward_dot = velocity.dot(forward)
		var forward_tilt = clampf(forward_dot * deg_to_rad(run_pitch), deg_to_rad(-max_pitch), deg_to_rad(max_pitch))
		angles.x = lerp(rotation.x, forward_tilt, 10.0 * delta)

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
