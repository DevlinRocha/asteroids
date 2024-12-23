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
var viewport_size: Vector2
var scene_tree_timer: SceneTreeTimer
var current_level := 1
var current_score := 0 : set = set_score
var high_score := 0

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var life_counter: HBoxContainer = %LifeCounter
@onready var menu: ColorRect = %Menu
@onready var score: Label = %Score


func _ready() -> void:
	load_score()
	if not life_counter.life_lost.is_connected(_on_life_lost):
		life_counter.life_lost.connect(_on_life_lost)
	if not menu.game_restart.is_connected(restart):
		menu.game_restart.connect(restart)

	viewport_size = get_viewport().size
	restart()


func _on_player_hit() -> void:
	if life_counter.get_child(0):
		life_counter.get_child(0).queue_free()

	scene_tree_timer = get_tree().create_timer(3, false)
	scene_tree_timer.timeout.connect(respawn_player)


func _on_life_lost() -> void:
	if life_counter.get_child_count() <= 0:
		if scene_tree_timer:
			scene_tree_timer.timeout.disconnect(respawn_player)
		game_over()


func _on_player_hyperspace(player: Player) -> void:
	player.collision_layer = 0
	player.jumping = true
	player.velocity = Vector2(0, 0)

	audio_stream_player.play()
	var tween = create_tween()
	tween.parallel().tween_property(player, "rotation", player.rotation + 8, 1)
	tween.parallel().tween_property(player, "scale", Vector2(0.1, 0.1), 1)
	tween.tween_property(player, "global_position", Vector2(randi_range(0, viewport_size.x), randi_range(0, viewport_size.y)), 0)
	tween.parallel().tween_property(player, "rotation", player.rotation - 8, 1)
	tween.parallel().tween_property(player, "scale", Vector2(1, 1), 1)
	tween.tween_callback(
		func() -> void:
			if !player:
				tween.kill()
				return
			player.jumping = false
			audio_stream_player.stop()

			get_tree().create_timer(0, false).timeout.connect(
				func() -> void:
					if !player:
						tween.kill()
						return
					player.collision_layer = 1
			)
			tween.kill()
	)


func _on_asteroid_hit(value: int, asteroid: Asteroid) -> void:
	audio_stream_player_2d.global_position = asteroid.global_position
	audio_stream_player_2d.finished.connect(
		func() -> void:
			audio_stream_player_2d.global_position = Vector2(0, 0)
	)
	audio_stream_player_2d.play()

	set_score(current_score + value)
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

	if life_counter.get_child_count() <= 0:
		return

	get_tree().create_timer(2, false).timeout.connect(
		func() -> void:
			current_level += 1
			new_level()
	)


func new_level() -> void:
	if scene_tree_timer:
		scene_tree_timer.timeout.disconnect(respawn_player)

	wipe("all")
	respawn_player()
	for level in current_level:
		spawn_asteroid(Asteroid.Size.LARGE)


func set_score(value: int) -> void:
	current_score = value
	score.text = str(value)
	if value > high_score:
		high_score = value
		save_score()
	menu.set_score(value)


func save_score() -> void:
	var save_file := FileAccess.open("user://savegame.save", FileAccess.WRITE_READ)
	save_file.store_line(str(current_score))


func load_score() -> void:
	if not FileAccess.file_exists("user://savegame.save"):
		return

	var save_file := FileAccess.open("user://savegame.save", FileAccess.READ)
	set_score(int(save_file.get_as_text()))


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
	audio_stream_player.stop()
	const PLAYER := preload("res://scenes/player.tscn")
	var new_player := PLAYER.instantiate()
	new_player.global_position = viewport_size / 2
	new_player.hit.connect(_on_player_hit)
	new_player.hyperspace.connect(_on_player_hyperspace)
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


func restart() -> void:
	audio_stream_player_2d.stop()
	if scene_tree_timer:
		scene_tree_timer.timeout.disconnect(respawn_player)
		scene_tree_timer.timeout.disconnect(game_over)

	life_counter.reset()
	current_level = 1
	set_score(0)
	new_level()


func game_over() -> void:
	const GAME_OVER = preload("res://assets/sfx/Game Over.wav")
	const BIT = preload("res://assets/sfx/8-Bit.wav")
	audio_stream_player.stream = GAME_OVER
	audio_stream_player.finished.connect(
		func() -> void:
			audio_stream_player.stream = BIT
	)
	audio_stream_player.play()

	menu.visible = true
	menu.game_over()
