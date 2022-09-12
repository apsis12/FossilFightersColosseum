extends Node2D

signal finished()

onready var tween = $Tween

var color:Color
func set_element(element:int):
	color = VivoDBEntry.element_to_color(element)
	color.a = 0.6

var radius:float = 0 setget set_radius
func set_radius(new:float):
	radius = new
	update()

func _draw():
	draw_circle(Vector2.ZERO, radius, color)

func animate():
	tween.interpolate_property(self, "radius", 0, 35, 0.5, Tween.TRANS_QUART, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_all_completed")
	emit_signal("finished")
	tween.interpolate_property(self, "radius", radius, 0, 0.1, Tween.TRANS_QUINT)
	tween.start()
