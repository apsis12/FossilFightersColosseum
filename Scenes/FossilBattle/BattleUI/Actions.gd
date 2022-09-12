extends Node2D

func set_rotation(new:float):
	rotation = new
	for i in get_children():
		if i is Node2D:
			i.rotation = -rotation

func actuate(withdraw:bool = false):
	var terms:Array = [[0, Vector2.ZERO], [TAU, Vector2.ONE]]
	if withdraw:
		terms.invert()
	
	$Tween.interpolate_method(self, "set_rotation", terms[0][0], terms[1][0], 0.5, Tween.TRANS_SINE)
	$Tween.interpolate_property(self, "scale",      terms[0][1], terms[1][1], 0.4)
	$Tween.start()

func _init():
	scale = Vector2.ZERO
