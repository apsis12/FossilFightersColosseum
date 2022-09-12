extends Node

func push_notification(text:String, max_width:int = 300, darken:bool = true) -> FFTextBox:
	var notif:FFTextBox = preload("res://Scenes/FFWindow/FFTextBox/FFTextBox.tscn").instance()
	notif.z_index = 100
	notif.text = text
	notif.max_width = max_width
	if Canvas.camera != null:
		notif.position = Canvas.camera.get_camera_screen_center()
	if darken and Canvas.interpolate_screen_modulation(Color("#444444")):
		notif.connect("initiate_close", self, "_on_subwindow_initiate_close")
	get_tree().root.add_child(notif)
	return notif

func _on_subwindow_initiate_close():
	Canvas.interpolate_screen_modulation(Color.white)

#############################################################################################

func create_menu(opts:Array) -> FFMenu:
	var menu:FFMenu = preload("res://Scenes/FFWindow/FFMenu/FFMenu.tscn").instance()
	menu.add_items(opts)
	menu.connect("option_selected", self, "_on_menu_option_selected")
	return menu

var last_selection
var last_selection_ind:int

func _on_menu_option_selected(tag, ind):
	last_selection = tag
	last_selection_ind = ind if ind is int else 0

func push_menu(opts:Array, priority:bool = false, darken:bool = true) -> FFMenu:
	var menu:FFMenu = create_menu(opts)
	menu.z_index = 100
	menu.allow_escape = not priority
	if Canvas.camera != null:
		menu.position = Canvas.camera.get_camera_screen_center()
	if darken and Canvas.interpolate_screen_modulation(Color("#444444")):
		menu.connect("initiate_close", self, "_on_subwindow_initiate_close")
	get_tree().root.add_child(menu)
	return menu

#############################################################################################

func create_dialogue(tree:Dictionary) -> FFDialogue:
	var dialogue:FFDialogue = FFDialogue.new()
	dialogue.option_tree = tree
	return dialogue

var dialogue_last_path:PoolStringArray = []

func dialogue_get_last_key():
	var size:int = dialogue_last_path.size()
# warning-ignore:incompatible_ternary
	return dialogue_last_path[size - 1] if size > 0 else null

var dialouge_last_val

func _on_dialogue_option_selected(path:PoolStringArray, val):
	dialogue_last_path = path
	dialouge_last_val = val

func push_dialogue(tree:Dictionary, connect_to:Object = null, method:String = "", profile:int = FFMenu.PROFILES.FF1, center_offset:Vector2= Vector2.ZERO, priority:bool = false, header:bool = true, darken:bool = true) -> FFDialogue:
	var dialogue:FFDialogue = create_dialogue(tree)
	dialogue.z_index = 100
	dialogue.profile = profile
	dialogue.connect("option_selected", self, "_on_dialogue_option_selected")
	if connect_to != null:
		dialogue.connect("option_selected", connect_to, method)
	dialogue.allow_full_escape = not priority
	dialogue.header_text = header
	if Canvas.camera != null:
		dialogue.position = Canvas.camera.get_camera_screen_center() + center_offset
	if darken and Canvas.interpolate_screen_modulation(Color("#444444")):
		dialogue.connect("initiate_close", self, "_on_subwindow_initiate_close")
	get_tree().root.add_child(dialogue)
	return dialogue

func push_yn_dialogue(question:String, profile:int = FFMenu.PROFILES.FF1) -> FFDialogue:
	return push_dialogue({
		question: false,
		"yes": true,
		"back":true,
	}, null, "", profile)

func last_yn_dialogue_affirmative():
	return dialogue_get_last_key() == "yes"
