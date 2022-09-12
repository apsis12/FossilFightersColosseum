extends MedalUIServer

class_name PreBattleMedalUIServer

func enter_leave_conditions() -> bool:
	return status == STATUS_TYPE.NORMAL or current_item != selected_slot

var focused_vivosaur:Vivosaur

func enter_current_item():
	if enter_leave_conditions():
		if not current_item_has_entered:
			audio0.stream = preload("res://Assets/SFX/UI/move_click.wav")
			audio0.play()
		
		if current_item is MedalSlot:
			if current_item.medal != null and focused_vivosaur != current_item.medal.vivo:
				focused_vivosaur = current_item.medal.vivo
				emit_signal("new_vivosaur_focused", focused_vivosaur)
		
		current_item.enter()
		current_item_has_entered = true

func default():
	selected_slot = null
	set_status(STATUS_TYPE.NORMAL)
	
	if transfer_tween.is_active():
		yield(transfer_tween,"tween_all_completed")
	
	enter_current_item()

func cancel():
	if selected_slot != null:
		if selected_slot.medal != null:
			selected_slot.leave()
	selected_slot = null
	
	for iter in items:
		if iter is MedalSlot and iter.medal != null:
			iter.medal.stop_glint()
	
	if status != STATUS_TYPE.NORMAL:
		audio1.stream = preload("res://Assets/SFX/VMM/back.wav")
		audio1.play()
	
	default()


var selected_slot:MedalSlot

enum STATUS_TYPE {
	NORMAL,
	REASSIGNMENT,
}

var status:int = STATUS_TYPE.NORMAL setget set_status

func set_status(new:int):
	assert(new in STATUS_TYPE.values(), "Invalid status code")
	
	status = new
	
	match status:
		STATUS_TYPE.NORMAL:
			for iter in items:
				if iter == back_button:
					back_button.operative = false
				else:
					var parent:Node = iter.get_parent()
					if not (parent is Node2D and not parent.visible):
						iter.operative = true
		STATUS_TYPE.REASSIGNMENT:
			selected_slot.operative = false
			for iter in items:
				if not iter is MedalSlot or not $Slots/Own.is_a_parent_of(iter):
					iter.operative = false
			if current_item != null:
				cursor.to_item(current_item, true, Vector2(0, 20), -PI/4)

func select_current_item():
	if selection_conditions():
		if current_item is MedalSlot:
			if $Slots/Own.is_a_parent_of(current_item):
				match status:
					STATUS_TYPE.NORMAL:
						selected_slot = current_item
						if selected_slot.medal == null:
							pass
						else:
							yield(add_menu(["Swap", "Back"], current_item.global_position + Vector2(0, 20)), "closed")
							match SubWindow.last_selection:
								"Swap":
									__raise_medal(current_item.medal)
									set_status(STATUS_TYPE.REASSIGNMENT)
								_:
									cancel()
					STATUS_TYPE.REASSIGNMENT:
						reassign(selected_slot, current_item)
		else:
			current_item.select()


func reassign(slot1:MedalSlot, slot2:MedalSlot) -> bool:
	if slot1.medal != null:
		var slot1_medal:DinoMedal = slot1.medal
		
		if slot2.medal == null:
			slot1.medal = null
		else:
			slot1.medal = slot2.medal
			__medal_transfer(slot2.medal, slot1.global_position)
		
		slot2.medal = slot1_medal
		
		__medal_transfer(slot1_medal, slot2.global_position)
		
		emit_signal("slots_updated")
		
		default()
		
		return true
	
	return false

func alt_inputs(event:InputEvent):
	if event.is_action_pressed("ui_cancel"):
		cancel()
