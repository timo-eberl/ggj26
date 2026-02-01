extends Node3D

@export var life_time := 0.2
@onready var cylinder: MeshInstance3D = $MeshInstance3D
var start: Vector3;
var end: Vector3;
@export var alive: float;
var thickness := 1.0

func _process(delta):
	alive += delta * 1.0;
	
	if start != Vector3.ZERO && end != Vector3.ZERO:
		set_line(lerp(start, end, alive), end)
		pass
		
	if alive >= 0.95:
		queue_free()

func set_line(_start: Vector3, _end: Vector3) -> void:
	if start == Vector3.ZERO && end == Vector3.ZERO:
		start = _start
		end = _end
	
	var dir = _end - _start
	var length = dir.length()

	# Position = Mitte zwischen Start & End
	global_position = _start + dir * 0.5

	# Rotation: Y-Achse des Cylinders auf Richtung ausrichten
	look_at(_end, Vector3.UP)
	rotate_object_local(Vector3.RIGHT, PI / 2)

	# Skalieren (Y = Länge)
	cylinder.scale = Vector3(
		thickness,
		length,
		thickness
	)
