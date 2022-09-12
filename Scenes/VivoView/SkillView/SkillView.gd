extends Node2D

func hide_all():
	for i in get_children():
		i.hide()

func push_skills(skills:Array):
	hide_all()
	var count:int = 0
	for i in skills:
		if count >= get_child_count():
			return
		if i is Skill:
			var skill_node:Node2D = get_child(count)
			skill_node.set_data(i)
			skill_node.show()
			count += 1
