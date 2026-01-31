extends RigidBody3D


@export var speed := 50.0
@export var direction: Vector3


func _process(delta):
	shoot_ray(delta);
		#global_position += direction * speed * delta


func shoot_ray(delta):
	var space = get_world_3d().direct_space_state

	var query = PhysicsRayQueryParameters3D.create(
		global_position,
		global_position - global_basis.z.normalized()
	)

	var result = space.intersect_ray(query)

	if result:
		print("Getroffen:", result.collider.name)
		
		var collider = result.collider
		var hit_pos = result.position
		
		if result.collider is RigidBody3D:
			result.collider.apply_impulse(-global_basis.z * 100, hit_pos)
		
		queue_free()
