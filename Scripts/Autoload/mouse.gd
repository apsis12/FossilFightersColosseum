extends Node

var abs_mouse:Vector2 = Vector2.ZERO
var abs_mouse_determined:bool = false

func mouse_reset():
	abs_mouse_determined = false

func get_abs_mouse() -> Vector2:
	if not abs_mouse_determined:
		abs_mouse = \
			Canvas.camera.get_camera_screen_center() + Canvas.camera.zoom * ( get_viewport().get_mouse_position() - OS.get_window_size()/2 ) \
				if Canvas.camera != null \
					else get_viewport().get_mouse_position()
		abs_mouse_determined = true
		call_deferred("mouse_reset")
	return abs_mouse

var mouse_read:bool = false

func _input(event):
	if event is InputEventMouseMotion:
		mouse_read = true
