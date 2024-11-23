class_name RocketLauncher
extends Node2D

@onready var fire_rate: Timer = $"Fire Rate"
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@export var rocket := preload("res://scenes/rocket.tscn")

var can_shoot := true


func _ready() -> void:
	if not fire_rate.timeout.is_connected(_on_fire_rate_timeout):
		fire_rate.timeout.connect(_on_fire_rate_timeout)


func fire() -> void:
	if not can_shoot:
		return

	var new_rocket: Rocket = rocket.instantiate()
	new_rocket.global_position = global_position
	new_rocket.global_rotation_degrees = global_rotation_degrees
	get_parent().add_sibling(new_rocket)
	can_shoot = false
	audio_stream_player.play()

	fire_rate.start()


func _on_fire_rate_timeout() -> void:
	can_shoot = true
