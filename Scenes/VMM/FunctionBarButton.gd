extends UIItem

func set_operative(new:bool):
	operative = new
	if operative:
		modulate = Color.white
	else:
		modulate = Color("#888888")

func enter():
	emit_signal("entered", self)
	scale = Vector2(1.1, 1.1)

func leave():
	emit_signal("left", self)
	scale = Vector2.ONE

func select():
	emit_signal("selected", self)
	scale = Vector2(1.2, 1.2)
	yield(get_tree().create_timer(0.1), "timeout")
	if scale == Vector2(1.2, 1.2):
		scale = Vector2(1.1, 1.1)
