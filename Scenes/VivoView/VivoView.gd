extends Sprite

var vivo:Vivosaur setget push_vivosaur

func push_vivosaur(new:Vivosaur) -> bool:
	if new != null:
		vivo = new
		$VivoHeader.push_vivo(vivo)
		$Slides/VivoOverview.push_vivo(vivo)
		
		$Slides/SkillView.push_skills(vivo.dbentry.skills)
		return true
	return false

func switch_slide(index:int):
	for i in $Slides.get_children():
		if i.get_index() == index:
			if not i.visible:
				$TabSound.play()
			(i as CanvasItem).show()
		else:
			(i as CanvasItem).hide()
	for i in $Tabs.get_children():
		(i as CanvasItem).modulate = Color.white if i.get_index() == index else Color.darkgray

func _tab_selected(node:UIItem):
	var index:int = node.get_index()
	switch_slide(index)

func _on_Cry_selected(_node):
	if vivo != null:
		$Cry.stream = load("res://Assets/Vivosaur/Cries/" + vivo.get_label() + ".wav")
		$Cry.play()

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and not event.echo:
			match event.scancode:
				KEY_Y: 
					if not Input.is_key_pressed(KEY_CONTROL):
						_on_Cry_selected(null)
				KEY_BACKSLASH: $Slides/VivoOverview.switch_art_with_wheel()
				KEY_1: switch_slide(0)
				KEY_2: switch_slide(1)
				KEY_3: switch_slide(2)

func _ready():
	switch_slide(0)
