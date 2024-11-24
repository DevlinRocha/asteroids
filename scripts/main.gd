extends Node

const ASTEROID_SPAWN_POSITION := {
	LEFT = {
		MIN_X = 64,
		MIN_Y = 64,
		MAX_X = 128,
		MAX_Y = 576,
	},
	RIGHT = {
		MIN_X = 1024,
		MIN_Y = 64,
		MAX_X = 1088,
		MAX_Y = 576
	},
	TOP = {
		MIN_X = 64,
		MIN_Y = 64,
		MAX_X = 1088,
		MAX_Y = 128,
	},
	BOTTOM = {
		MIN_X = 64,
		MIN_Y = 576,
		MAX_X = 1088,
		MAX_Y = 512,
	},
}
var player_spawn_position: Vector2
var current_level := 1
var current_score := 0

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	player_spawn_position = get_viewport().size / 2
	new_level()


func _on_player_hit() -> void:
	get_tree().create_timer(3).timeout.connect(respawn_player)


func _on_asteroid_hit(value: int, asteroid: Asteroid) -> void:
	audio_stream_player_2d.global_position = asteroid.global_position
	audio_stream_player_2d.play()
	current_score += value

	match value:
		20:
			spawn_asteroid(Asteroid.Size.MEDIUM, asteroid.global_position)
		50:
			spawn_asteroid(Asteroid.Size.SMALL, asteroid.global_position)
		100:
			pass


func _on_asteroid_destroyed() -> void:
	var children := get_children()
	for child in get_children():
		if child is Asteroid:
			return
	current_level += 1
	new_level()


func new_level() -> void:
	wipe("all")
	respawn_player()
	for level in current_level:
		spawn_asteroid(Asteroid.Size.LARGE)


func spawn_asteroid(size: Asteroid.Size, position := get_random_spawn_point()) -> void:
	const ASTEROID := preload("res://scenes/asteroid.tscn")
	var new_asteroid := ASTEROID.instantiate()
	new_asteroid.size = size
	new_asteroid.global_position = position
	new_asteroid.hit.connect(_on_asteroid_hit)
	new_asteroid.tree_exited.connect(_on_asteroid_destroyed)
	add_child(new_asteroid)


func get_random_spawn_point() -> Vector2:    
	var spawn_area = ASTEROID_SPAWN_POSITION.keys().pick_random()
	var new_position = ASTEROID_SPAWN_POSITION[spawn_area]
	return Vector2(randi_range(new_position.MIN_X, new_position.MAX_X), randi_range(new_position.MIN_Y, new_position.MAX_Y))


func respawn_player() -> void:
	const PLAYER := preload("res://scenes/player.tscn")
	var new_player := PLAYER.instantiate()
	new_player.global_position = player_spawn_position
	new_player.hit.connect(_on_player_hit)
	add_child(new_player)


func wipe(group: String) -> void:
	for child in get_children():
		if child.is_in_group("no_wipe"):
			continue
		if child is Player:
			child.queue_free()
		if group != "all" && !child.is_in_group(group):
			continue
		child.queue_free()
