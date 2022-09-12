extends Node2D

const POINT_START:Vector2 = Vector2(0, -1)
const POINT_COUNT:int = 5
const POINT_ANGLE:float = TAU/float(POINT_COUNT)

var radius:float = 50

var poly:PoolVector2Array = []

var element:int

func _draw():
	draw_circle(Vector2.ZERO, radius + 25, Color.darkgray)
	draw_circle(Vector2.ZERO, radius, Color.gray)
	
	draw_colored_polygon(poly, VivoDBEntry.element_to_color(element), [], null, null, true)
	
	var point:Vector2 = POINT_START * radius
	for i in range(POINT_COUNT):
		draw_line(point, Vector2.ZERO, Color.lightgray)
		($Icons.get_child(i) as Node2D).position = point * 1.25
		point = point.rotated(POINT_ANGLE)

const MAX_STATS:PoolIntArray = PoolIntArray([888, 104, 62, 65, 40])

func push_stats(stats:PoolIntArray):
	assert(stats.size() == 5)
	
	poly = []
	
	var point:Vector2 = POINT_START
	for i in range(POINT_COUNT):
		poly.append(float(stats[i]) / float(MAX_STATS[i]) * radius * point)
		point = point.rotated(POINT_ANGLE)
	
	update()
