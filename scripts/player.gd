class_name Player
extends CharacterBody2D

signal hit

const SPEED = 256.0
const TURN_SPEED = 2.0

@onready var rocket_launcher: RocketLauncher = $RocketLauncher


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
	if acceleration:
		position += transform.y * acceleration * SPEED * delta

	var shooting := Input.is_action_pressed("shoot")
	if shooting:
		rocket_launcher.fire()


	move_and_slide()


func _on_hit() -> void:
	const EXPLOSION := preload("res://effects/explosion.tscn")
	var new_explosion := EXPLOSION.instantiate()
	new_explosion.explode(self)
	queue_free()
