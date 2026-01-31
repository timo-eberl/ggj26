extends Node3D

const mouse_sensitivity = 0.002
@export var dislodge_force = 8
@export_range(-90,90) var dislodge_angle_offset = 20
@export var time_scale = 0.1
@export var mask_shoot_force = 3
@export var rigid_body: RigidBody3D
@export var transition_speed = 10

@onready var ray_cast = $Camera3D/RayCast3D

var is_dislodged = false
var is_in_aim_mode = false
var was_in_aim_mode = false
var is_in_transition = false
var start_trans:Transform3D


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	start_trans = global_transform


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_action_just_pressed("ui_left"):
		global_transform = start_trans
		rigid_body.freeze = true
		rigid_body.global_transform = start_trans
		is_dislodged = false
		is_in_aim_mode = false
		was_in_aim_mode = false
		c = 0
			
			
	if is_dislodged:
		if not is_in_transition:
			if Input.is_action_pressed("right_mouse_button"):
				if not is_in_aim_mode: start_mask_aim_mode()
			elif is_in_aim_mode:
				leave_aim_mode()
				return
			if is_in_aim_mode:
				global_position = rigid_body.global_position
			else:
				if was_in_aim_mode and c <= 5:
					print(global_rotation, " ----- ", rigid_body.global_rotation, " **************** ", global_position, " ----- ", rigid_body.global_position)
					c += 1
				global_transform = rigid_body.global_transform
				$Camera3D.rotation = Vector3.ZERO
	else:
		if Input.is_action_just_pressed("ui_accept"):
			start_dislodge()
	
		
func _input(event):
	if is_dislodged and not is_in_aim_mode: return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation.y += -event.screen_relative.x * mouse_sensitivity
		$Camera3D.rotation.x += -event.screen_relative.y * mouse_sensitivity
		
var c = 0
func start_dislodge():
	rigid_body.global_basis = $Camera3D.global_basis
	start_trans = global_transform
	is_dislodged = true
	rigid_body.freeze = false
	var dir = Vector3.FORWARD.rotated(Vector3.RIGHT, deg_to_rad(dislodge_angle_offset)) * rigid_body.global_basis.inverse()
	
	rigid_body.apply_central_impulse(dir * dislodge_force)

func start_mask_aim_mode():
	is_in_aim_mode = true
	Engine.time_scale = time_scale

func leave_aim_mode():
	is_in_aim_mode = false
	was_in_aim_mode = true
	Engine.time_scale = 1
	var collider = ray_cast.get_collider() as CollisionObject3D
	if collider == null:
		print(global_rotation, " ----- ", rigid_body.global_rotation, " **************** ", global_position, " ----- ", rigid_body.global_position)
		rigid_body.global_rotation = $Camera3D.global_rotation
		print(global_rotation, " ----- ", rigid_body.global_rotation, " **************** ", global_position, " ----- ", rigid_body.global_position)
		return
	print("*******Hit*******")
	start_transition(collider)

func start_transition(target: Node3D):
	is_in_transition = true
	var target_trans = (target.find_child("Marker3D") as Node3D).global_transform
	var dist = global_position.distance_to(target_trans.origin)
	var duration = dist / transition_speed
	var tween = get_tree().create_tween()
	rigid_body.freeze = true
	tween.tween_property(rigid_body, "transform", target_trans, duration)
	
	
