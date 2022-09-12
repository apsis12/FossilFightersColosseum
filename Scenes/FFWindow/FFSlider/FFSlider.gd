extends "res://Scenes/FFWindow/FFWindow.gd"

class_name FFSlider

signal value_set(value)

export var values:Array = range(0, 51)

var value_label:Label

export var show_current_value:bool = true setget set_show_current_value
func set_show_current_value(new:bool):
	show_current_value = new
	adjust_window()

export var length:int = 100 setget set_length
func set_length(new:int):
	assert(new > 0)
	length = new
	backline.points = [Vector2(0, 0), Vector2(float(length), 0)]
	if is_inside_tree():
		adjust_window()

export var pos:int = 0 setget set_pos

func set_pos(new:int):
	pos = int(clamp(float(new), 0, values.size()-1))
	if is_inside_tree():
		slider.position.x = round(float(pos) / float(values.size()-1) * float(length))
		value_label.text = str(values[pos])
		emit_signal("value_set", values[pos])

func adjust_window():
	accepting_input = false
	backline.hide()
	value_label.hide()
	value_label.rect_size.x = length
	set_target_size(Vector2(length + 10, 33 if show_current_value else 21))
	if $Tween.is_active():
		yield($Tween, "tween_all_completed")
	backline.show()
	value_label.visible = show_current_value
	accepting_input = true

func open():
	show()
	set_show_current_value(show_current_value)
	set_length(length)
	set_pos(pos)

func close():
	accepting_input = false
	backline.hide()
	value_label.hide()
	set_target_size(Vector2.ZERO)
	if $Tween.is_active():
		yield($Tween, "tween_all_completed")
	hide()
	emit_signal("closed")

var backline:Line2D
var slider:Sprite

func readystuff():
	backline = $Border/WTL/Reasons/Back
	slider = $Border/WTL/Reasons/Back/Slider
	value_label = $Border/WBL/Label

var window_hovering:bool = false
var slider_clicked:bool = false

func mouse_to_pos():
	var new_pos:int = int(clamp(round((Mouse.get_abs_mouse().x - backline.global_position.x) / float(length) * float(values.size() - 1)), 0, values.size()-1))
	if pos != new_pos:
		set_pos(new_pos)

var accepting_input:bool = false

func _unhandled_input(event):
	if accepting_input:
		if event.is_action_pressed("ui_left", true):
			set_pos(pos - 1)
		elif event.is_action_pressed("ui_right", true):
			set_pos(pos + 1)
		elif event.is_action_pressed("ui_page_down", true):
			set_pos(pos - 5)
		elif event.is_action_pressed("ui_page_up", true):
			set_pos(pos + 5)
		elif event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
			close()
		elif event is InputEventMouseButton:
			if event.pressed and window_hovering:
				match event.button_index:
					BUTTON_LEFT:
						mouse_to_pos()
						slider_clicked = true
					BUTTON_WHEEL_UP:
						set_pos(pos + 1)
					BUTTON_WHEEL_DOWN:
						set_pos(pos - 1)
			else:
				slider_clicked = false
		elif event is InputEventMouseMotion:
			window_hovering = get_global_rect().has_point(Mouse.get_abs_mouse())
			if slider_clicked:
				mouse_to_pos()
		get_tree().set_input_as_handled()
