extends CharacterBody3D
var movementInput: Vector2 = Vector2.ZERO
@onready var hand: Node3D = $Camera3D/Hand
@onready var currentBulletStartPos: Node3D = $Camera3D/Hand/Pistole2/bulletStartPos

@export var currentPistole: Node3D;

var targetPoint: Vector3
var aimTarget: Vector3


func _process(delta):
	get_input(delta);
	if !is_on_floor():
		velocity += get_gravity() * delta;
	
	velocity = Vector3(movementInput.x * delta, velocity.y, movementInput.y * delta);
	
	move_and_slide();
	
	if Input.is_action_just_pressed("shoot"):
		currentPistole.shoot();
	
	currentPistole.set_target(-$Camera3D.global_basis.z.normalized() * 100);
	
	#aim_raycast();
	pass;

func aim_raycast():
	var space = get_world_3d().direct_space_state

	var query = PhysicsRayQueryParameters3D.create(
		$Camera3D.global_position,
		$Camera3D.global_position - $Camera3D.global_basis.z.normalized() * 10000
	)

	var result = space.intersect_ray(query)
	
	if result:
		aimTarget = result.position

func get_input(delta):
	var tempMove = Input.get_vector("move_left", "move_right", "move_forward", "move_backward");;
	#var currentMouseInput = component_mouse_capture._mouse_input;
	
	tempMove = tempMove.normalized();
	movementInput = lerp(movementInput, tempMove * 1000.0, delta * 10.0);
	pass;
