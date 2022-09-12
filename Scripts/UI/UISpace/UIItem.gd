extends Sprite
class_name UIItem

signal entered(node)
signal left(node)
signal selected(node)

signal mouse_hover(node)
signal mouse_depart(node)
signal mouse_select(node)

export var operative:bool = true setget set_operative

func set_operative(new:bool):
	operative = new

export var spatial_detection_rect:Rect2

export var show_cursor:bool = true
export var cursor_offset:Vector2 = Vector2.ZERO
export var cursor_rotation:float = 0
export var mouse_enabled:bool = true

func enter():
	emit_signal("entered", self)
func leave():
	emit_signal("left", self)
func select():
	emit_signal("selected", self)

func get_global_rect() -> Rect2:
	return Rect2(spatial_detection_rect.position + global_position, spatial_detection_rect.size)

func get_global_rect_center() -> Vector2:
	return spatial_detection_rect.size/2 + spatial_detection_rect.position + global_position

func mouse_detect_method() -> bool:
	return get_global_rect().has_point(Mouse.get_abs_mouse())

func emit_mouse_signal(sig:String):
	if operative:
		emit_signal(sig, self)

var hovering:bool = false
func _unhandled_input(event):
	if mouse_enabled:
		if event is InputEventMouseMotion:
			if mouse_detect_method():
				if not hovering:
					hovering = true
					emit_mouse_signal("mouse_hover")
			else:
				hovering = false
				emit_mouse_signal("mouse_depart")
		if hovering and event.is_action_pressed("click_left"):
			emit_mouse_signal("mouse_select") 

func _ready():
	if texture != null:
		spatial_detection_rect = Rect2(Vector2.ZERO, texture.get_size())
		if centered:
			spatial_detection_rect.position -= texture.get_size()/2
