extends UIItem
class_name MedalSlot

# used only in VMM
var house:MedalHouse setget set_house
# used only in pre-battle
var medal:DinoMedal

func _init():
	spatial_detection_rect = Rect2(-15, -15, 30, 30)
	hide()
	texture = preload("res://Assets/VivoView/medals/slot_indicator.png")

func mouse_detect_method():
	return Mouse.get_abs_mouse().distance_to(global_position) <= 15

func set_house(new:MedalHouse):
	house = new
	hide()

func enter():
	if house != null:
		house.medal.enter()
	elif medal != null:
		medal.enter()
	else:
		show()

func leave():
	if house != null:
		house.medal.leave()
	elif medal != null:
		medal.leave()
	hide()

func select():
	if house != null:
		house.medal.select()
	elif medal != null:
		medal.select()
