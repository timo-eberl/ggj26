class_name CharacterModel
extends Node

@export var explosion_force := 5

@onready var head: RigidBody3D = $Head
@onready var body: RigidBody3D = $Body
@onready var hand_left: RigidBody3D = $HandLeft
@onready var hand_right: RigidBody3D = $HandRight

func _ready():
	head.freeze = true
	body.freeze = true
	hand_left.freeze = true
	hand_right.freeze = true

func explode(position: Vector3, direction: Vector3):
	head.freeze = false
	body.freeze = false
	hand_left.freeze = false
	hand_right.freeze = false
	
	var rand_offset = Vector3(randf_range(-1,1), randf_range(-1,1), randf_range(-1,1)).normalized()
	
	body.apply_impulse(direction*explosion_force, body.global_position+rand_offset)
	head.apply_impulse(3*direction+0.5*body.global_position.direction_to(head.global_position)*explosion_force, head.global_position+rand_offset)
	hand_left.apply_impulse(2*direction+0.5*body.global_position.direction_to(hand_left.global_position)*explosion_force, hand_left.global_position+rand_offset)
	hand_right.apply_impulse(2*direction+0.5*body.global_position.direction_to(hand_right.global_position)*explosion_force, hand_right.global_position+rand_offset)
	
