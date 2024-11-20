extends Area2D

@export var size := Size.LARGE : set = set_size

enum Size { SMALL = 16, MEDIUM = 32, LARGE = 64 }


func _ready() -> void:
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func _draw() -> void:
	draw_circle(Vector2(0, 0), size, Color.DIM_GRAY, 1)
	$CollisionShape2D.shape.radius = size


func _on_area_entered(area: Area2D) -> void:
	resize()


func _on_body_entered(body: Node2D) -> void:
	body.hit.emit()
	resize()


func set_size(value: Size) -> void:
	size = value
	queue_redraw()


func resize() -> void:
	match size:
		64:
			set_size(32)
		32:
			set_size(16)
		16:
			queue_free()
