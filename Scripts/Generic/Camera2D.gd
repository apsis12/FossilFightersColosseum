extends Camera2D

func _ready():
	# identify self for mouse detection and other functions
	Canvas.camera = self
	Window.set_window_scale(Window.window_scale)

func _draw():
	draw_rect(Rect2(Vector2.ZERO, OS.window_size / Window.window_scale), Color.white)
