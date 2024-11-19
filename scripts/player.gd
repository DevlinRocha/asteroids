extends CharacterBody2D


@onready var rocket_launcher: RocketLauncher = $RocketLauncher


const SPEED = 256.0
const TURN_SPEED = 2.0


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
