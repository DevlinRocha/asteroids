class_name Player
extends CharacterBody2D

signal hit

const MAX_SPEED := 800
const SPEED := 256.0
const TURN_SPEED := 2.0

@onready var rocket_launcher: RocketLauncher = $RocketLauncher
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var music: AudioStreamPlaybackInteractive = audio_stream_player.get_stream_playback()


func _ready() -> void:
	if not hit.is_connected(_on_hit):
		hit.connect(_on_hit)


func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("left", "right")
	if direction:
		rotation_degrees = rotate_toward(global_rotation_degrees, global_rotation_degrees + direction * TURN_SPEED, TURN_SPEED)
	else:
		rotation_degrees = rotate_toward(global_rotation_degrees, global_rotation_degrees, delta)

	var acceleration := Input.get_axis("accelerate", "decelerate")
	if acceleration == -1:
		accelerate()
		velocity += transform.y * acceleration * SPEED * delta
	elif acceleration == 1:
		accelerate()
		velocity += transform.y * SPEED * delta
	else:
		audio_stream_player.stop()
	velocity = velocity.limit_length(MAX_SPEED)

	var shooting := Input.is_action_pressed("shoot")
	if shooting:
		rocket_launcher.fire()

	move_and_slide()


func _on_hit() -> void:
	const EXPLOSION := preload("res://effects/explosion.tscn")
	var new_explosion := EXPLOSION.instantiate()
	new_explosion.explode(self)
	queue_free()


func accelerate() -> void:
	if audio_stream_player.playing:
		return

	audio_stream_player.play()
