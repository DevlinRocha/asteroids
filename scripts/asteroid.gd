class_name Asteroid
extends Area2D

signal hit

enum Size { SMALL = 16, MEDIUM = 32, LARGE = 64 }

var min_speed := 32
var max_speed := 128

@export var size := Size.LARGE : set = set_size

var direction: Vector2

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	var polarity := [-1, 1]
	direction = Vector2(randi_range(min_speed, max_speed) * polarity[(randi() % polarity.size())], randi_range(min_speed, max_speed) * polarity[(randi() % polarity.size())])

func _draw() -> void:
	draw_circle(Vector2(0, 0), size, Color.DIM_GRAY, 1)
	collision_shape_2d.shape.radius = size


func _physics_process(delta: float) -> void:
	position += direction * delta


func _on_area_entered(area: Area2D) -> void:
	resize()


func _on_body_entered(body: Node2D) -> void:
	body.hit.emit()
	resize()


func set_size(value: Size) -> void:
	size = value
	max_speed += 32
	direction = Vector2(randi_range(direction.x, (max_speed + direction.x) * (abs(direction.x) / direction.x)), randi_range(direction.y, (max_speed + direction.y) * (abs(direction.y) / direction.y)))

	queue_redraw()


func resize() -> void:
	match size:
		64:
			hit.emit(20, self)
			set_size(32)
		32:
			hit.emit(50, self)
			set_size(16)
		16:
			hit.emit(100, self)
			queue_free()
