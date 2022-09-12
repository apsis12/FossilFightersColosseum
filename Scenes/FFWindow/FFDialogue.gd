extends Node2D

class_name FFDialogue

signal option_selected(path, val)
signal initiate_close()
signal closed()

const textbox_scene:PackedScene = preload("res://Scenes/FFWindow/FFTextBox/FFTextBox.tscn")
const menu_scene:PackedScene = preload("res://Scenes/FFWindow/FFMenu/FFMenu.tscn")
const slider_scene:PackedScene = preload("res://Scenes/FFWindow/FFSlider/FFSlider.tscn")

var base_textbox:FFTextBox
var base_menu:FFMenu
var slider:FFSlider
var message_box:FFTextBox

var profile:int

var option_tree:Dictionary = {
	"Make a selection": false,
	"Option 1": {
		"Option 1": false,
		"Ok": false,
		"Back": 1
	},
	"Option 2": {
		"Option 2": false,
		"Another Menu": {
			"Another Menu": false,
			":)":false,
			"D:": {
				":/": false,
				"Back 1": 1,
				"Back 2": 2,
				"Back 3": 3,
			}
		},
		"Do Nothing": false,
		"End": true
	},
	"Option 3":false,
}

func __make_tb(text:String = "text") -> FFTextBox:
	var tb:FFTextBox = textbox_scene.instance()
	tb.free_automatically = false
	tb.interactive = false
	tb.pickaxe = false
	tb.text = text
	return tb

func __make_menu(opts:Array = []) -> FFMenu:
	var menu:FFMenu = menu_scene.instance()
	menu.free_automatically = false
	menu.close_on_escape = false
	menu.connect("option_selected", self, "_report_selection")
	if not opts.empty():
		menu.add_items(opts)
	return menu

var selection = null
var selection_ind:int = 0

func _report_selection(inp, ind):
	selection = inp
	if ind is int:
		selection_ind = ind

func _init():
	base_textbox = __make_tb()
	base_menu = __make_menu()
	
	slider = slider_scene.instance()
	slider.hide()
	slider.auto_open = false
	
	message_box = textbox_scene.instance()
	message_box.hide()
	message_box.auto_open = false
	message_box.free_automatically = false
	message_box.max_width = 300
	
	base_textbox.anchor = base_textbox.anchor_type.BOTTOM
	base_menu.anchor = base_menu.anchor_type.TOP
	
	base_textbox.position.y = -5
	base_menu.position.y = 5

export var header_text:bool = true

func _ready():
	if not header_text:
		base_textbox.hide()
		base_menu.anchor = base_menu.anchor_type.CENTER
	base_textbox.push_predefined(profile)
	add_child(base_textbox)
	base_menu.push_predefined(profile)
	add_child(base_menu)
	slider.push_predefined(profile)
	add_child(slider)
	message_box.push_predefined(profile)
	add_child(message_box)
	run()

func __make_prompt(vals:Dictionary, text_box:FFTextBox, menu:FFMenu):
	assert(vals.size() != 0)
	
	var header_tmp:String
	var opts_tmp:Array = []
	var first:bool = true
	
	for key in vals.keys():
		if first and header_text:
			header_tmp = key
			first = false
		else:
			opts_tmp.append([key, vals[key] is Array or vals[key] is String or (vals[key] is bool and vals[key])])
	
	if header_text:
		text_box.text = header_tmp
	
	menu.re_add_items(opts_tmp)


export var allow_full_escape:bool = true

var path:PoolStringArray = []
var emit_path:PoolStringArray = []

var exit:bool = false

func cleanup_and_exit(emit_null_option:bool = true):
	if emit_null_option:
		emit_signal("option_selected", [], null)
	
	base_menu.free_automatically = true
	base_menu.close()
	
	if base_textbox.visible:
		if base_menu.animations.current_animation == "Select_Conclusive":
			yield(base_menu, "initiate_close")
		base_textbox.close()
	
	emit_signal("initiate_close")
	
	yield(base_menu, "closed")
	emit_signal("closed")
	yield(base_menu, "tree_exiting")
	
	base_textbox.queue_free()
	message_box.queue_free()
	slider.queue_free()
	
	queue_free()

func run():
	var reload:bool = true
	var reload_ind:int = 0
	var prompt_data:Dictionary
	var index_tree:PoolIntArray = []
	
	while true:
		if exit:
			cleanup_and_exit()
			return
		
		if reload:
			base_menu.allow_escape = allow_full_escape or not path.empty()
			
			if base_menu.current_item != null:
				base_menu.initial_option = base_menu.current_item.get_index()
			
			prompt_data = option_tree
			
			for key in path:
				prompt_data = prompt_data[key]
			
			__make_prompt(prompt_data, base_textbox, base_menu)
			
			if reload_ind > base_menu.options_node.get_child_count() - 1:
				reload_ind = 0
			elif reload_ind != 0:
				base_menu.current_item = base_menu.options_node.get_child(reload_ind)
			
			if base_menu.tween.is_active():
				yield(base_menu, "transition_completed")
			if base_menu.animations.is_playing() and base_menu.animations.current_animation == "Select":
				yield(base_menu, "select_recover")
			yield(get_tree().create_timer(0.1), "timeout")
			
			base_menu.poll_items_hovering()
		
		base_menu.accepting_input = true
		reload = true
		reload_ind = 0
		
		yield(base_menu, "option_selected")
		
		if selection == null:
			if path.empty():
				if allow_full_escape:
					cleanup_and_exit()
					return
				else:
					reload = false
			else:
				path.resize(path.size() - 1)
				reload_ind = index_tree[index_tree.size() - 1]
				index_tree.resize(path.size())
			
		elif selection is String:
			emit_path = path + PoolStringArray([selection])
			
			emit_signal("option_selected", emit_path, null)
			
			var val = prompt_data[selection]
			
			if val is int:
				if path.empty() or val == 0:
					reload = false
				else:
					path.resize(path.size() - int(abs(val)))
					reload_ind = index_tree[index_tree.size()-1]
					index_tree.resize(path.size())
				
			elif val is bool:
				reload = false
				if val:
					base_menu.free_automatically = true
					if base_textbox.visible:
						yield(base_menu, "initiate_close")
						base_textbox.close()
					emit_signal("initiate_close")
					yield(base_menu, "closed")
					emit_signal("closed")
					yield(base_menu, "tree_exiting")
					queue_free()
					return
			
			elif val is String:
				base_menu.initial_option = base_menu.current_item.get_index()
				
				if header_text:
					base_textbox.close()
				
				yield(base_menu, "closed")
				
				message_box.text = val
				message_box.show()
				message_box.open()
				
				yield(message_box, "closed")
				
				base_menu.open()
				if header_text:
					base_textbox.open()
				
				reload = false
				continue
				
			elif val is Array:
				val = val.duplicate()
				
				base_menu.initial_option = base_menu.current_item.get_index()
				
				if header_text:
					base_textbox.close()
				
				yield(base_menu, "closed")
				
				# good place for lambda funcs
				assert(val.size() >= 4)
				
				assert(val.back() is Object)
				var obj = val.back()
				val.resize(val.size() - 1)
				
				assert(val.back() is String)
				var init_val = obj.call(val.back())
				val.resize(val.size() - 1)
				
				slider.values = val
				slider.pos = slider.values.find(init_val)
				
				slider.connect("value_set", self, "_on_slider_value_set")
				
				slider.show()
				slider.open()
				
				yield(slider, "closed")
				
				slider.disconnect("value_set", self, "_on_slider_value_set")
				
				base_menu.open()
				if header_text:
					base_textbox.open()
				
				reload = false
				continue
				
			elif val is Dictionary:
				path.append(selection)
				index_tree.append(selection_ind)
				
			else:
				assert(false)
			
			yield(base_menu, "select_recover")

func _on_slider_value_set(val):
	emit_signal("option_selected", emit_path, val)
