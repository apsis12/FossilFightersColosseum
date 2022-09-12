extends UIItem


func _ready():
	cursor_offset = Vector2(-5,2)
	spatial_detection_rect = $LineEdit.get_global_rect()

func mouse_detect_method():
	return spatial_detection_rect.has_point(Mouse.get_abs_mouse())

func select():
	$LineEdit.self_modulate = Color.darkslateblue
	$LineEdit.caret_position = $LineEdit.text.length()
	$LineEdit.grab_focus()

func leave():
	$LineEdit.release_focus()
	$LineEdit.self_modulate = Color.black
