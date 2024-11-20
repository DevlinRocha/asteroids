extends GPUParticles2D


func explode(node: Node) -> void:
	var new_explosion := duplicate()
	node.add_sibling(new_explosion)
	new_explosion.global_position = node.global_position
	new_explosion.emitting = true
	new_explosion.finished.connect(queue_free)
