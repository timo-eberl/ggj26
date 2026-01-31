extends Area3D


func get_my_enemies() -> Array[Enemy]:
	var enemies: Array[Enemy] = []
	for child in get_children():
		if child is Enemy:
			enemies.append(child)
	return enemies

func _on_area_entered(area: Area3D) -> void:
	if area is MaskArea:
		var enemies = get_my_enemies()
		for enemy in enemies:
			enemy.state_chart.send_event("onActivate")
