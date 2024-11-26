extends ColorRect

signal game_restart

var is_game_over := false

@onready var menu_label: Label = %MenuLabel
@onready var score: Label = %Score
@onready var high_score: Label = %HighScore
@onready var restart: Button = %Restart
@onready var quit: Button = %Quit
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	if not restart.pressed.is_connected(_on_restart_pressed):
		restart.pressed.connect(_on_restart_pressed)
	if not quit.pressed.is_connected(_on_quit_pressed):
		quit.pressed.connect(_on_quit_pressed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		menu_label.text = "Game Paused"
		get_tree().paused = !get_tree().paused
		visible = !visible


func _on_restart_pressed() -> void:
	audio_stream_player.play()
	is_game_over = false
	game_restart.emit()
	visible = false
	get_tree().paused = false


func _on_quit_pressed() -> void:
	audio_stream_player.finished.connect(get_tree().quit)
	audio_stream_player.play()


func set_score(value: int) -> void:
	score.text = str(value)
	if value > int(high_score.text):
		set_high_score(value)


func set_high_score(value: int) -> void:
	high_score.text = str(value)


func game_over() -> void:
	is_game_over = true
	menu_label.text = "Game Over"
