extends GPUParticles2D


func _process(delta: float) -> void:
	if not emitting:
		queue_free()


func explode(node: Node) -> void:
	var new_explosion := duplicate()
	node.add_sibling(new_explosion)
	new_explosion.global_position = node.global_position
	new_explosion.emitting = true
	node.queue_free()
