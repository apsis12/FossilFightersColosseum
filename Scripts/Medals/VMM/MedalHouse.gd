extends UIItem
class_name MedalHouse

const center_position = Vector2(29,16)

func get_medal_position():
	return global_position + center_position if is_inside_tree() else position + center_position

var index_text:Label

func _init(medal_input:DinoMedal = null):
	cursor_offset = Vector2(5, 0)
	centered = false
	texture = preload("res://Assets/VivoView/medals/Dino_Medal_Container.png")
	index_text = Label.new()
	index_text.rect_position = Vector2(2,2)
	index_text.modulate = Color("4A4A4A")
	index_text.theme = preload("res://Fonts/Resource/FFMedalDigit.tres")
	add_child(index_text)
	
	ghost_medal = Sprite.new()
	ghost_medal.scale *= 0
	ghost_medal.modulate = Color.darkgray
	ghost_medal.position = center_position
	ghost_medal.hide()
	add_child(ghost_medal)
	ghost_medal_tween = Tween.new()
	add_child(ghost_medal_tween)
	
	set_medal(medal_input)


var medal:DinoMedal setget set_medal
func set_medal(new:DinoMedal):
	medal = new
	if medal != null:
		if medal.vivo == null:
			index_text.text = "000"
		else:
			index_text.text = str(medal.vivo.list_index+1).pad_zeros(3)
		ghost_medal.texture = medal.texture

var assigned:bool = false setget set_assigned
var ghost_medal:Sprite
var ghost_medal_tween:Tween

func set_assigned(new:bool):
	assigned = new
	
	if assigned:
		ghost_medal.show()
		ghost_medal_tween.interpolate_property(ghost_medal, "scale", ghost_medal.scale, Vector2.ONE, 0.2)
		ghost_medal_tween.start()
	else:
		ghost_medal_tween.interpolate_property(ghost_medal, "scale", ghost_medal.scale, Vector2.ZERO, 0.2, Tween.TRANS_CIRC                          )
		ghost_medal_tween.start()
		yield(ghost_medal_tween, "tween_all_completed")
		ghost_medal.visible = assigned

func set_assigned_choose_animate(new:bool, animate:bool = false):
	if animate:
		set_assigned(new)
	else:
		assigned = new
		
		if assigned:
			ghost_medal.scale = Vector2.ONE
			ghost_medal.show()
		else:
			ghost_medal.scale = Vector2.ZERO
			ghost_medal.hide()

func restore_medal():
	if medal != null and not assigned:
		medal.global_position = get_medal_position()

func position_with_medal(pos:Vector2):
	global_position = pos
	restore_medal()

func mouse_detect_method():
	return Mouse.get_abs_mouse().distance_to(get_medal_position()) <= 15

func enter():
	if medal != null and not assigned:
		medal.enter()

func leave():
	if medal != null and not assigned:
		medal.leave()

func select():
	if medal != null and not assigned:
		medal.select()
