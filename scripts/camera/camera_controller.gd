class_name CameraController
extends Node3D

@export_category("References")
@export var component_mouse_capture: MouseCaptureComponent
@export_category("Camera Settings")
@export_group("Camera Tilt")
@export_range(-90, -60) var tilt_lower_limit: int = -90
@export_range(60, 90) var tilt_upper_limit: int = 90

var _rotation: Vector3

func update_camera(y_rot_node: Node3D, delta: float) -> void:
	_update_camera_rotation(y_rot_node, component_mouse_capture._mouse_input, delta)

func _update_camera_rotation(y_rot_node: Node3D, input: Vector2, delta: float) -> void:
	_rotation.x += input.y * delta
	_rotation.y += input.x * delta
	_rotation.x = clamp(_rotation.x, deg_to_rad(tilt_lower_limit), deg_to_rad(tilt_upper_limit))
	
	var y_rotation = Vector3(0.0, _rotation.y, 0.0)
	var _camera_rotation = Vector3(_rotation.x, 0.0, 0.0)

	transform.basis = Basis.from_euler(_camera_rotation)
	y_rot_node.global_transform.basis = Basis.from_euler(y_rotation)

	_rotation.z = 0.0
