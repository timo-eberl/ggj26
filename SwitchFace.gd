extends MeshInstance3D

@export var faces : Array[Texture2D]

func _ready():
	var material: ShaderMaterial = load("res://assets/materials/Gesichtermaterial.tres")
		
	
	material_override.set_shader_parameter("tex_frg_2", faces[randi_range(0,8)])
	
	set_surface_override_material(0, material)
	#material_override = material
