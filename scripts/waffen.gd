class_name Waffe
extends Node3D
@onready var bulletExitPos: Node3D = $bulletStartPos;
@onready var hand: Node3D = $"..";
@export var bullet_vis_scene: PackedScene

var aimTarget : Vector3;
var recoilAdd : Vector3;
@export var nextTarget : Vector3;
var aim_speed := 5.0
var recoil_amount: float = 150;
var bullet_viz_scale := 50.0
var bullet_viz_thickness := 1.0

func _process(delta):
	aimTarget = lerp(aimTarget, nextTarget, delta * aim_speed);
	hand.look_at(aimTarget);
	recoilAdd = lerp(recoilAdd, Vector3.ZERO, delta * 10);
	pass

func shoot() -> Dictionary:
	var space = get_world_3d().direct_space_state
	var extendetTarget = bulletExitPos.global_position + (aimTarget - bulletExitPos.global_position).normalized() * 25;

	var query = PhysicsRayQueryParameters3D.create(
		bulletExitPos.global_position,
		extendetTarget,
		0b11
	)
	
	query.exclude = [self]
	
	var result := space.intersect_ray(query)
	
	if result:
		var collider = result.collider
		var hit_pos = result.position
		
		if result.collider is RigidBody3D:
			result.collider.apply_impulse(-global_basis.z * 100, hit_pos)
		#if result.collider is Enemy :
			#(result.collider as Enemy).hit(hit_pos, bulletExitPos.global_position.direction_to(extendetTarget))
		#if result.collider is Enemy and result.collider.state_possessed.active:
			#var direction := bulletExitPos.global_position.direction_to(extendetTarget)
			#(result.collider as Enemy).hit(hit_pos, direction)
			#var mask: Mask = result.collider._mask
			#mask.state_chart.send_event("onHit")
			#mask.on_hit_by_bullet(direction)
	
	var dir: Vector3 = (extendetTarget - bulletExitPos.global_position).normalized() * bullet_viz_scale
	spawn_bullet_vis(bulletExitPos.global_position, bulletExitPos.global_position + dir)
	recoilAdd.y += recoil_amount
	
	return result

func set_target(target : Vector3):
	nextTarget = target + recoilAdd;

func spawn_bullet_vis(start: Vector3, end: Vector3) -> void:
	var vfx = bullet_vis_scene.instantiate()
	vfx.thickness = bullet_viz_thickness
	get_tree().current_scene.add_child(vfx)
	
	vfx.set_line(start, end)
