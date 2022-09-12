extends Node

const default_window_size:Vector2 = Vector2(512, 300)

var window_scale:Vector2 = Vector2.ONE * 2 setget set_window_scale

func set_window_scale(new:Vector2):
	window_scale = new
	Canvas.camera.zoom = Vector2.ONE / window_scale
	OS.window_size = default_window_size * window_scale

func get_scale_int() -> int:
	return window_scale.x as int

func _ready():
	get_tree().root.connect("size_changed", self, "_on_viewport_size_changed")

func _on_viewport_size_changed():
	set_window_scale(OS.window_size / default_window_size)
