extends "res://Scenes/FFWindow/FFWindow.gd"

class_name FFTextBox

var textobject:BitmapRichText
var pickaxe_sprite : AnimatedSprite

func adjust_window():
	textobject.hide()
	var dimensions:Vector2 = textobject.get_dimensions()
	set_target_size(dimensions + Vector2(3 + 17 * int(pickaxe and textobject.get_length_of_last_line() > dimensions.x - 20), 3))
	if $Tween.is_active():
		yield($Tween, "tween_all_completed")
	textobject.show()

export var text:String = "Text Box" setget set_text
func set_text(new):
	text = new
	if is_inside_tree():
		textobject.text = text
		adjust_window()

export var pickaxe : bool = true setget set_pickaxe
func set_pickaxe(val):
	pickaxe = val
	if is_inside_tree():
		pickaxe_sprite.set_visible(pickaxe)
		set_text(text)

export var max_width : int = 300 setget set_max_width
func set_max_width(val:int):
	max_width = val
	if is_inside_tree():
		textobject.set_width(val)
		adjust_window()

func open():
	textobject.hide()
	pickaxe_sprite.hide()
	show()
	textobject.set_width(max_width)
	set_text(text)
	if $Tween.is_active():
		yield($Tween, "tween_all_completed")
	textobject.show()
	pickaxe_sprite.visible = pickaxe
	pickaxe_sprite.play()
	accepting_input = true

export var free_automatically:bool = true

func close():
	emit_signal("initiate_close")
	accepting_input = false
	if textobject != null:
		textobject.hide()
	pickaxe_sprite.hide()
	set_target_size(Vector2.ZERO)
	if $Tween.is_active():
		yield($Tween,"tween_all_completed")
	hide()
	emit_signal("closed")
	if free_automatically:
		queue_free()

export var interactive:bool = true

var accepting_input:bool = false

func _unhandled_input(event):
	if interactive and accepting_input:
		if event.is_action_pressed("ui_accept") or \
			(event.is_action_pressed("click_left") and get_global_rect().has_point(Mouse.get_abs_mouse())):
				accepting_input = false
				close()
		get_tree().set_input_as_handled()

func readystuff():
	textobject = $Border/WTL/BitmapRichText
	pickaxe_sprite = $Border/WBR/Pickaxe
