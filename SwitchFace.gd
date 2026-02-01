extends MeshInstance3D

@export var faces : Array[Texture2D]

func _ready():
	var material = material_override.duplicate()
	material_override = material
	material_override.set_shader_parameter("tex_frg_2", faces[randi_range(0,8)])
	#material_override = material
