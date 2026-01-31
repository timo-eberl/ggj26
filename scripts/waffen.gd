class_name Waffe
extends Node3D
@onready var bulletExitPos: Node3D = $bulletStartPos;
@onready var hand: Node3D = $"..";
@export var bullet_vis_scene: PackedScene
@export var base_recoil: float = 400;

var aimTarget : Vector3;
var recoilAdd : Vector3;
@export var nextTarget : Vector3;

func _process(delta):
	aimTarget = lerp(aimTarget, nextTarget, delta * 10);
	hand.look_at(aimTarget);
	recoilAdd = lerp(recoilAdd, Vector3.ZERO, delta * 10);
	pass

func shoot() -> Dictionary:
	var space = get_world_3d().direct_space_state
	var extendetTarget = bulletExitPos.global_position + (aimTarget - bulletExitPos.global_position).normalized() * 500;

	var query = PhysicsRayQueryParameters3D.create(
		bulletExitPos.global_position,
		extendetTarget
	)
	
	query.exclude = [self]
	
	var result := space.intersect_ray(query)
	
	if result:
		var collider = result.collider
		var hit_pos = result.position
		
		if result.collider is RigidBody3D:
			result.collider.apply_impulse(-global_basis.z * 100, hit_pos)
		if result.collider is Enemy:
			result.collider.queue_free()
	
	spawn_bullet_vis(bulletExitPos.global_position, extendetTarget)
	add_recoil(base_recoil)
	
	return result

func add_recoil(amount):
	recoilAdd += Vector3(0,amount,0) * 0.0001

func set_target(target : Vector3):
	nextTarget = target + recoilAdd;

func spawn_bullet_vis(start: Vector3, end: Vector3) -> void:
	var vfx = bullet_vis_scene.instantiate()
	get_tree().current_scene.add_child(vfx)
	
	vfx.set_line(start, end)
