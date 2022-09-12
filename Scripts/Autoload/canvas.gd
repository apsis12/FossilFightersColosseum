extends Node

var camera:Camera2D
var root_canvas_node:CanvasItem


var tween:Tween

func _init():
	tween = Tween.new()
	add_child(tween)

func interpolate_screen_modulation(to:Color, time:float = 0.1) -> Tween:
	if root_canvas_node == null:
		return null
	tween.interpolate_property(root_canvas_node, "modulate", root_canvas_node.modulate, to, time)
	tween.start()
	return tween
