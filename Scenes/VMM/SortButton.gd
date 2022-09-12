extends UIItem

func _init():
	show_cursor = false

func enter():
	if modulate == Color.white:
		modulate = Color.gray
	elif modulate == Color.slategray:
		modulate = Color.darkslategray
func leave():
	if modulate == Color.gray:
		modulate = Color.white
	elif modulate == Color.darkslategray:
		modulate = Color.slategray
