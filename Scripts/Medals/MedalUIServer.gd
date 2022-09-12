extends UIServer

class_name MedalUIServer

signal new_vivosaur_focused(vivo)
signal slots_updated()

var transfer_tween:Tween
var audio0:AudioStreamPlayer
var audio1:AudioStreamPlayer

func _init():
	transfer_tween = Tween.new()
	add_child(transfer_tween)
	
	audio0 = AudioStreamPlayer.new()
	add_child(audio0)
	
	audio1 = AudioStreamPlayer.new()
	add_child(audio1)

# if defined, menus will be the child of this node
var menu_node:Node2D
# if defined, this will act as a cancel function
var back_button:UIItem

func movement_conditions(item:UIItem) -> bool:
	return not transfer_tween.is_active() and item.operative and items.has(item)

func selection_conditions() -> bool:
	return current_item != null and not transfer_tween.is_active()

#################
# Medal Movement
#################

func __raise_medal(medal:DinoMedal):
	current_item.select()
	medal.play_glint(true)
	audio1.stream = preload("res://Assets/SFX/VMM/lift_medal.wav")
	audio1.play()

var medal_trans_z_ind:int = 3
var medal_trans_z_ind_no_ascend:int = 2

var medal_max_height:float = 15.0
var medal_air_time:float = 0.5
var medal_ascent_time:float = 0.1
var medal_descent_time:float = 0.25

func __medal_transfer(medal:DinoMedal, to:Vector2, animate:bool = true, ascend:bool = true):
	medal.show()
	
	if animate:
		if ascend:
			medal.z_index = medal_trans_z_ind
			transfer_tween.interpolate_property(medal, "height", medal.height, medal_max_height, medal_ascent_time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			transfer_tween.interpolate_property(medal, "height", medal_max_height, 0.0, medal_descent_time, Tween.TRANS_BOUNCE, Tween.EASE_OUT, medal_air_time)
		else:
			medal.z_index = medal_trans_z_ind_no_ascend
			transfer_tween.interpolate_property(medal, "height", medal.height, 0.0, medal_descent_time, Tween.TRANS_BOUNCE, Tween.EASE_OUT, medal_air_time)
		transfer_tween.interpolate_property(medal, "global_position", medal.global_position, to, medal_air_time, Tween.TRANS_CUBIC)
		
		transfer_tween.start()
		
		audio1.stream = preload("res://Assets/SFX/VMM/medal_transfer.wav")
		audio1.play()
		
		Mouse.mouse_read = false
		
		yield(transfer_tween, "tween_all_completed")
		
		if Mouse.mouse_read:
			poll_items_hovering()
	else:
		medal.global_position = to
		medal.height = 0
	
	medal.z_index = 0
	medal.stop_glint()

########
# Menus
########

func add_menu(opts:Array, pos:Vector2) -> FFMenu:
	current_item.hovering = false
	
	var menu = SubWindow.create_menu(opts)
	
	menu.global_position = pos
	menu.anchor = FFMenu.anchor_type.TOP
	
	menu.connect("closed", self, "_on_menu_closed")
	
	if cursor != null:
		cursor.vanish()
	
	Mouse.mouse_read = false
	
	if menu_node == null:
		add_child(menu)
	else:
		menu_node.add_child(menu)
	
	return menu

func _on_menu_closed():
	if cursor != null:
		cursor.emerge()
	
	if Mouse.mouse_read:
		poll_items_hovering()
