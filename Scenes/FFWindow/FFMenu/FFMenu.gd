extends "res://Scenes/FFWindow/FFWindow.gd"

# instance scene, not this script
class_name FFMenu

signal option_selected(option_text, index)
signal select_recover()

var highlight:Line2D
var shovel_cursor:Sprite
var animations:AnimationPlayer

func readystuff():
	highlight = $Offset/Menu/Highlight
	shovel_cursor= $Offset/Menu/ShovelCursor
	animations = $MenuAnimationPlayer
	$Offset/Menu.add_child(options_node)

################
# Adding items
################
class Item extends BitmapTextLine:
	signal select(node)
	signal hover(node)
	
	var conclusive:bool = false
	
	var dimensions:Vector2
	var mouse_offset:Vector2
	
	var hovering:bool = false
	var focused:bool = false
	
	func check_mouse_hover(re_emit:bool = false):
		if Rect2(global_position + mouse_offset, dimensions).has_point(Mouse.get_abs_mouse()):
			if not hovering or re_emit:
				hovering = true
				emit_signal("hover", self)
		else:
			hovering = false
	
	func _unhandled_input(event):
		if event is InputEventMouseMotion:
			check_mouse_hover()
		if focused:
			if (hovering and event.is_action_pressed("click_left")) or event.is_action_pressed("ui_accept"):
				emit_signal("select", self)

var options_node:Node2D

const option_height:int = 18
const option_mouse_offset:Vector2 = Vector2(0, -option_height/4)

# don't use
func __add_item(tag:String, conclusive:bool):
	var new:Item = Item.new()
	new.text = tag
	new.conclusive = conclusive
	new.position.y = option_height * options_node.get_child_count()
	new.mouse_offset = option_mouse_offset
	new.connect("select", self, "select")
	new.connect("hover", self, "_on_item_mouse_hover")
	options_node.add_child(new)

export var default_conclusive:bool = true

# use this instead
func add_items(requests:Array):
	for i in requests:
		if i is String:
			__add_item(i, default_conclusive)
		elif i is Array:
			assert(i.size()==2 and i[0] is String and i[1] is bool)
			__add_item(i[0],i[1])
	adjust_window()

func rid_all():
	current_item = null
	for i in options_node.get_children():
		i.free()

func clear():
	rid_all()
	adjust_window()

func re_add_items(requests:Array):
	rid_all()
	add_items(requests)
	if options_node.get_child_count() > 0:
		set_current_item(options_node.get_child(0))

func get_full_dimensions() -> Vector2:
	var dimensions:Vector2 = Vector2.ZERO
	for line in options_node.get_children():
		var length:int = line.get_actual_length() 
		if length > dimensions.x:
			dimensions.x = length
		dimensions.y += option_height
	dimensions.x += 15 if dimensions.x != 0 else 30
	dimensions.y += 5  if dimensions.y != 0 else option_height
	return dimensions

func adjust_window():
	if is_inside_tree():
		accepting_input = false
		$Offset/Menu.hide()
		
		var dimensions:Vector2 = get_full_dimensions()
		
		var highlight_len:int = int(dimensions.x) - 22
		highlight.points[1].x = highlight_len
		(highlight.get_node("CapRight") as Sprite).position.x = highlight_len
		
		for i in options_node.get_children():
			(i as Item).dimensions = Vector2(dimensions.x - 22, option_height)
		set_target_size(dimensions)
		$Offset/Menu.position = get_corners(true)[0]
		
		if $Tween.is_active():
			yield($Tween, "tween_all_completed")
		
		$Offset/Menu.show()

################
# Management
################
const move_click:AudioStream = preload("res://Assets/SFX/UI/move_click.wav")

var current_item:Item setget set_current_item
func set_current_item(new_item:Item):
	if options_node.is_a_parent_of(new_item) and new_item != current_item:
		if current_item != null:
			current_item.focused = false
		new_item.focused = true
		
		highlight.position.y = new_item.position.y + 1
		
		if $Offset/Menu.visible:
			$MenuTween.interpolate_property(shovel_cursor, "position:y", shovel_cursor.position.y, new_item.position.y, 0.07, Tween.TRANS_CUBIC, Tween.EASE_OUT)
			$MenuTween.start()
			
			if not $AudioStreamPlayer.playing or $AudioStreamPlayer.stream == move_click:
				$AudioStreamPlayer.set_stream(preload("res://Assets/SFX/UI/move_click.wav"))
				$AudioStreamPlayer.play()
		else:
			shovel_cursor.position.y = new_item.position.y
		
		current_item = new_item

var accepting_input:bool = false

func _on_item_mouse_hover(node:Item):
	if accepting_input:
		set_current_item(node)

func poll_items_hovering():
	for item in options_node.get_children():
		(item as Item).check_mouse_hover()

func select(node:Item):
	if accepting_input:
		accepting_input = false
		emit_signal("option_selected", node.text, node.get_index())
		$AudioStreamPlayer.set_stream(preload("res://Assets/SFX/UI/select.wav"))
		$AudioStreamPlayer.play()
		
		if current_item.conclusive:
			$MenuAnimationPlayer.play("Select_Conclusive")
			yield($MenuAnimationPlayer, "animation_finished")
			close()
		else:
			$MenuAnimationPlayer.play("Select")
			yield($MenuAnimationPlayer,"animation_finished")
			emit_signal("select_recover")
			$MenuAnimationPlayer.play("Idle")

export var initial_option:int = 0

func open():
	accepting_input = false
	show()
	highlight.hide()
	options_node.hide()
	
	if options_node.get_child_count() == 0:
		add_items(["cancel"])
	else:
		adjust_window()
	
	current_item = options_node.get_child(int(clamp(initial_option, 0, options_node.get_child_count() - 1)))
	current_item.focused = true
	shovel_cursor.position.y = current_item.position.y
	highlight.position.y = current_item.position.y + 1
	
	$AudioStreamPlayer.set_stream(preload("res://Assets/SFX/UI/menu_open.wav"))
	$AudioStreamPlayer.play()
	$MenuAnimationPlayer.play("Init")
	yield($MenuAnimationPlayer, "animation_finished")
	highlight.show()
	options_node.show()
	$MenuAnimationPlayer.play("Idle")
	
	accepting_input = true


export var allow_escape:bool = true
export var close_on_escape:bool = true

func escape():
	if accepting_input and allow_escape:
		$AudioStreamPlayer.set_stream(preload("res://Assets/SFX/UI/escape.wav"))
		$AudioStreamPlayer.play()
		emit_signal("option_selected", null, null)
		if close_on_escape:
			close()

export var free_automatically:bool = true

func close():
	accepting_input = false
	emit_signal("initiate_close")
	$Offset/Menu.hide()
	set_target_size(Vector2.ZERO)
	yield($Tween, "tween_all_completed")
	hide()
	emit_signal("closed")
	if free_automatically:
		if $AudioStreamPlayer.is_playing():
			yield($AudioStreamPlayer,"finished")
		queue_free()

func move_to_option_index(new:int):
	accepting_input = false
	set_current_item(options_node.get_child(wrapi(new, 0, options_node.get_child_count())))
	if $MenuTween.is_active():
		yield($MenuTween,"tween_all_completed")
	accepting_input = true

func _unhandled_input(event):
	get_tree().set_input_as_handled()
	if accepting_input:
		if event.is_action_pressed("ui_up", true):
			move_to_option_index(current_item.get_index() - 1)
		elif event.is_action_pressed("ui_down", true):
			move_to_option_index(current_item.get_index() + 1)
		elif event.is_action_pressed("ui_cancel"):
			escape()

func _init():
	options_node = Node2D.new()
	options_node.position = Vector2(15,-5)
