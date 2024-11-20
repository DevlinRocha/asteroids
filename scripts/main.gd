extends Node

var player_spawn_position: Vector2

func _ready() -> void:
	player_spawn_position = get_viewport().size / 2
	wipe("d")
	respawn_player()


func _on_player_hit() -> void:
	get_tree().create_timer(3).timeout.connect(respawn_player)


func respawn_player() -> void:
	const PLAYER := preload("res://scenes/player.tscn")
	var new_player := PLAYER.instantiate()
	new_player.global_position = player_spawn_position
	new_player.hit.connect(_on_player_hit)
	add_child(new_player)


func wipe(group: String) -> void:
	for child in get_children():
		if child is Player: child.queue_free()
		if group != "all" && !child.is_in_group(group):
			continue
		child.queue_free()
