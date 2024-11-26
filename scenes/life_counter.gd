extends HBoxContainer


signal life_lost


func reset() -> void:
	const SHIP_TEXTURE := preload("res://assets/Ship.svg")
	for child in get_children():
		child.queue_free()

	for life in 3:
		var new_life := TextureRect.new()
		new_life.tree_exited.connect(life_lost.emit)
		new_life.texture = SHIP_TEXTURE
		add_child(new_life)
