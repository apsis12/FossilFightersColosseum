extends Node2D

onready var tween:Tween = $Tween
onready var line:Line2D = $Line2D
onready var label:Label = $Label

func set_length(length:float):
	line.points = [Vector2.ZERO, Vector2(length, 0)]
	label.rect_size.x = length

var opening:bool = false

func open():
	opening = true
	show()
	label.hide()
	tween.interpolate_property(self, "scale:y", 0, 1, 0.2)
	tween.start()

func close():
	opening = false
	label.hide()
	tween.interpolate_property(self, "scale:y", 1, 0, 0.2)
	tween.start()

func show_text(text:String, time:float = 2):
	$Timer.stop()
	if scale.y == 1:
		opening = false
	else:
		open()
	label.text = text
	$Timer.wait_time = time
	$Timer.start()

func _on_Tween_tween_all_completed():
	if opening:
		label.show()
	else:
		hide()

func _on_Timer_timeout():
	close()

func _ready():
	hide()
	scale.y = 0
