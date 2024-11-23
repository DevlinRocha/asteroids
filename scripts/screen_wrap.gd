extends Node


var parent
var viewport_size


func _ready() -> void:
	parent = get_parent()
	viewport_size = get_viewport().size


func _physics_process(delta: float) -> void:
	if parent.global_position.x < 0:
		parent.global_position.x = viewport_size.x
	if parent.global_position.y < 0:
		parent.global_position.y = viewport_size.y
	if parent.global_position.x > viewport_size.x:
		parent.global_position.x = 0
	if parent.global_position.y > viewport_size.y:
		parent.global_position.y = 0
