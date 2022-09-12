extends Line2D

class_name LPFill

const MAX_LENGTH:float = 40.0

var length:float setget set_length

func set_length(new:float):
	length = clamp(new, 0, MAX_LENGTH)
	if points.size() == 2:
		points[1].x = length

func _ready():
	set_length(get_points()[1].x)
