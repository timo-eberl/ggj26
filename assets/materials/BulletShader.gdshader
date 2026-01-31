shader_type spatial;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	EMISSION = vec3(1,1,0) * 0.7;
	ALBEDO = vec3(0,0,0);
	SPECULAR = 0.0;
    ROUGHNESS = 1.0;
}