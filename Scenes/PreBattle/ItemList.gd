extends ItemList

func _init():
	focus_mode = Control.FOCUS_NONE
	for iter in TeamFile.list_saved_teams():
		add_item(iter)
	select(0)
