extends HBoxContainer


func reset() -> void:
	const SHIP_TEXTURE := preload("res://assets/Ship.svg")
	for child in get_children():
		child.queue_free()

	for life in 3:
		var new_life := TextureRect.new()
		new_life.texture = SHIP_TEXTURE
		add_child(new_life)
