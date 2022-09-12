extends Node2D

var dir:Vector2


func _ready():
	randomize()
	dir = Vector2(float(randi() % 20) - 10, float(randi() % 20) - 10) / 20
	if dir.x == 0:
		dir.x = 1
	if dir.y == 0:
		dir.y = 1

func _process(_delta:float):
	position += dir
	if position.x >= Window.default_window_size.x or position.x <= 0:
		dir.x = -dir.x
	if position.y >= Window.default_window_size.y or position.y <= 0:
		dir.y = -dir.y
		
	if Input.is_key_pressed(KEY_8):
		dir.y += 0.02
	if Input.is_key_pressed(KEY_9):
		dir.y -= 0.02
	if Input.is_key_pressed(KEY_0):
		dir.x += 0.02
	if Input.is_key_pressed(KEY_7):
		dir.x -= 0.02
