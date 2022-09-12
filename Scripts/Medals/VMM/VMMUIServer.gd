extends MedalUIServer

class_name VMMUIServer

###########
# Movement
###########

func movement_conditions(item:UIItem) -> bool:
	return not transfer_tween.is_active() and item.operative and items.has(item)

########
# Input
########

func alt_inputs(event:InputEvent):
	if event.is_action_pressed("ui_cancel"):
		cancel()
	elif event.is_action_pressed("undo", true):
		undo_action()
	elif event.is_action_pressed("redo", true):
		undo_action(true)
	elif event.is_action_pressed("clear_slots"):
		clear_slots()

#####################
# Interaction Status
#####################

enum status_type {
	NORMAL,
	ASSIGNMENT,
	REASSIGNMENT,
	PROMPT_ASSIGNMENT
}

var status:int = status_type.NORMAL setget set_status

func set_status(new:int):
	assert(new in status_type.values(), "Invalid status code")
	
	status = new
	
	match status:
		status_type.NORMAL:
			for iter in items:
				if iter == back_button:
					back_button.operative = false
				else:
					var parent:Node = iter.get_parent()
					if not (parent is Node2D and not parent.visible):
						iter.operative = true
		status_type.ASSIGNMENT:
			for iter in items:
				if iter == back_button:
					back_button.operative = true
				elif not iter is MedalSlot:
					iter.operative = false
		status_type.REASSIGNMENT:
			selected_slot.operative = false
			for iter in items:
				if iter == back_button:
					back_button.operative = true
				elif not iter is MedalHouse and not iter is MedalSlot:
					iter.operative = false
			if current_item != null:
				cursor.to_item(current_item, true, Vector2(0, 20), -PI/4)
		status_type.PROMPT_ASSIGNMENT:
			for iter in items:
				if iter == back_button:
					back_button.operative = true
				elif not iter is MedalHouse:
					iter.operative = false
		_: assert(false)
	
	if status == status_type.ASSIGNMENT:
		var slots:Array = figure_team_slots()
		for slot in slots:
			if slot.house == null:
				move_to(slot)
				return
		for slot in slots:
			move_to(slot)
			return
	elif status != status_type.REASSIGNMENT:
		if not current_item.operative:
			to_first_operative()

####################
# Interaction Tools
####################

var selected_house:MedalHouse
var selected_slot:MedalSlot

func default():
	selected_house = null
	selected_slot = null
	set_status(status_type.NORMAL)
	
	if transfer_tween.is_active():
		yield(transfer_tween,"tween_all_completed")
	
	enter_current_item()

func cancel():
	if selected_house != null:
		selected_house.leave()
	selected_house = null
	
	if selected_slot != null:
		if selected_slot.house != null:
			selected_slot.leave()
	selected_slot = null
	
	for iter in items:
		if iter is MedalHouse and iter.medal != null:
			iter.medal.stop_glint()
	
	if status != status_type.NORMAL:
		audio1.stream = preload("res://Assets/SFX/VMM/back.wav")
		audio1.play()
	
	default()

############
# UI Events
############

var focused_vivosaur:Vivosaur

func enter_leave_conditions() -> bool:
	return status == status_type.NORMAL or (current_item != selected_house and current_item != selected_slot)

func enter_current_item():
	if enter_leave_conditions():
		if not current_item_has_entered:
			audio0.stream = preload("res://Assets/SFX/UI/move_click.wav")
			audio0.play()
		
		if current_item is MedalHouse:
			if current_item.medal != null and focused_vivosaur != current_item.medal.vivo:
				focused_vivosaur = current_item.medal.vivo
				emit_signal("new_vivosaur_focused", focused_vivosaur)
		elif current_item is MedalSlot:
			if current_item.house != null and current_item.house.medal != null and focused_vivosaur != current_item.house.medal.vivo:
				focused_vivosaur = current_item.house.medal.vivo
				emit_signal("new_vivosaur_focused", focused_vivosaur)
		
		current_item.enter()
		current_item_has_entered = true

func leave_current_item():
	if enter_leave_conditions():
		current_item.leave()
	current_item_has_entered = false

func select_current_item():
	if selection_conditions():
		if current_item == back_button:
			back_button.select()
			cancel()
		elif current_item is MedalHouse:
			if current_item.medal != null:
				match status:
					status_type.NORMAL:
						if current_item.assigned:
							for iter in items:
								if iter is MedalSlot and iter.house == current_item:
									move_to(iter)
									break
						else:
							selected_house = current_item
							__raise_medal(current_item.medal)
							set_status(status_type.ASSIGNMENT)
					status_type.REASSIGNMENT, status_type.PROMPT_ASSIGNMENT:
						if current_item.assigned:
							if current_item == selected_slot.house:
								remove(selected_slot)
							else:
								for iter in items:
									if iter is MedalSlot and iter.house == current_item:
										reassign(selected_slot, iter)
										break
						else:
							assign(current_item,selected_slot)
		elif current_item is MedalSlot:
			match status:
				status_type.NORMAL:
					selected_slot = current_item
					if current_item.house == null or current_item.house.medal == null:
						yield(add_menu(["Assign", "Back"], current_item.global_position + Vector2(0, 20)), "closed")
						match SubWindow.last_selection:
							"Assign":
								set_status(status_type.PROMPT_ASSIGNMENT)
							_:
								cancel()
					else:
						yield(add_menu(["Move", "Remove", "Back"], current_item.global_position + Vector2(0, 20)), "closed")
						match SubWindow.last_selection:
							"Move":
								__raise_medal(current_item.house.medal)
								set_status(status_type.REASSIGNMENT)
							"Remove":
								remove(current_item)
							_:
								cancel()
				status_type.ASSIGNMENT:
					assign(selected_house, current_item)
				status_type.REASSIGNMENT:
					if current_item != selected_slot:
						reassign(selected_slot, current_item)
		else:
			current_item.select()

##########
# Actions
##########

func remove(slot:MedalSlot, animate:bool = true, commit:bool = true) -> bool:
	if slot.house != null:
		if commit:
			var action:Removal = Removal.new()
			action.slot = slot
			action.house = slot.house
			action.medal = slot.house.medal
			__commit_action(action)
		
		slot.house.set_assigned_choose_animate(false, animate)
		__medal_transfer(slot.house.medal, slot.house.get_medal_position(), animate)
		slot.house = null
		
		emit_signal("slots_updated")
		
		default()
		
		return true
	
	return false

func assign(house:MedalHouse, slot:MedalSlot, animate:bool = true, commit:bool = true) -> bool:
	if not house.assigned:
		var slot_house:MedalHouse = slot.house
		
		if slot.house != null:
			# remove existing medal
			slot.house.set_assigned_choose_animate(false, animate)
			__medal_transfer(slot.house.medal, slot.house.get_medal_position(), animate, false)
		
		slot.house = house
		house.set_assigned_choose_animate(true, animate)
		__medal_transfer(house.medal, slot.global_position, animate)
		
		if commit:
			var action:Assignment = Assignment.new()
			action.slot = slot
			action.house = house
			action.medal = house.medal
			action.replaced_house = slot_house
			if slot_house != null:
				action.replaced_medal = slot_house.medal
			__commit_action(action)
		
		emit_signal("slots_updated")
		
		default()
		
		return true
	
	return false

func reassign(slot1:MedalSlot, slot2:MedalSlot, animate:bool = true, commit:bool = true) -> bool:
	if slot1.house != null:
		var slot1_house:MedalHouse = slot1.house
		
		if slot2.house == null:
			slot1.house = null
		else:
			slot1.house = slot2.house
			__medal_transfer(slot2.house.medal, slot1.global_position, animate, false)
		
		slot2.house = slot1_house
		
		__medal_transfer(slot1_house.medal, slot2.global_position, animate)
		
		if commit:
			var action:Reassignment = Reassignment.new()
			action.slot1 = slot1
			action.slot2 = slot2
			__commit_action(action)
		
		emit_signal("slots_updated")
		
		default()
		
		return true
	
	return false

func clear_slots():
	if status == status_type.NORMAL:
		for iter in items:
			if iter is MedalSlot:
				remove(iter)

###################
# Action Undo/Redo
###################

# Really really bad

class Action extends Reference:
	pass

class Removal extends Action:
	var slot:MedalSlot
	var house:MedalHouse
	var medal:DinoMedal

class Assignment extends Action:
	var slot:MedalSlot
	var house:MedalHouse
	var medal:DinoMedal
	var replaced_house:MedalHouse
	var replaced_medal:DinoMedal

class Reassignment extends Action:
	var slot1:MedalSlot
	var slot2:MedalSlot

var actions:Array = []
var do_offset:int = 0

func __commit_action(new:Action):
	if do_offset != 0:
		actions.resize(actions.size() - do_offset)
		do_offset = 0
	
	actions.append(new)

func search_house(medal:DinoMedal) -> MedalHouse:
	for iter in items:
		if iter is MedalHouse and iter.medal == medal:
			return iter
	return null

func undo_action(redo:bool = false) -> bool:
	if status == status_type.NORMAL:
		var action_index:int = actions.size() - do_offset
		
		if not redo:
			action_index -= 1
		
		if action_index >= 0 and action_index < actions.size():
			var action:Action = actions[action_index]
			
			# if medals have been sorted since action was committed, houses may no longer be correct
			if action != null:
				if action is Removal:
					if action.house.medal != action.medal:
						action.house = search_house(action.medal)
				elif action is Assignment:
					if action.house.medal != action.medal:
						action.house = search_house(action.medal)
					if action.replaced_house != null and action.replaced_house.medal != action.replaced_medal:
						action.replaced_house = search_house(action.replaced_medal)
				
				if redo:
					do_offset -= 1
					
					if action is Removal:
						remove(action.slot, false, false)
					elif action is Assignment:
						assign(action.house, action.slot, false, false)
					elif action is Reassignment:
						reassign(action.slot1, action.slot2, false, false)
					
					audio1.stream = preload("res://Assets/SFX/VMM/back_reverse.wav")
				else:
					do_offset += 1
					
					if action is Removal:
						assign(action.house, action.slot, false, false)
					elif action is Assignment:
						if action.replaced_house == null:
							remove(action.slot, false, false)
						else:
							assign(action.replaced_house, action.slot, false, false)
					elif action is Reassignment:
						reassign(action.slot2, action.slot1, false, false)
					
					audio1.stream = preload("res://Assets/SFX/VMM/back.wav")
			
			audio1.play()
			
			return true
	
	return false


################
# Medal Sorting
################

# Houses are sorted in accordance with their order in 'items'

func sort_houses(method:String):
	
	var medals:Array = []
	var assigned_medals:Array = []
	var slots:Array = []
	
	for iter in items:
		if iter is MedalHouse and iter.medal != null and iter.medal.vivo != null:
			medals.append(iter.medal)
		elif iter is MedalSlot and iter.house != null and iter.house.medal != null and iter.house.medal.vivo != null:
			assigned_medals.append(iter.house.medal)
			slots.append(iter)
	
	medals.sort_custom(MedalSort, method)
	
	var medals_size:int = medals.size()
	var count:int = 0
	
	for iter in items:
		if iter is MedalHouse:
			iter.medal = medals[count]
			
			var assigned_medal_index:int = assigned_medals.find(iter.medal)
			
			iter.set_assigned_choose_animate(assigned_medal_index != -1)
			
			if iter.assigned:
				slots[assigned_medal_index].house = iter
			
			iter.medal.visible = iter.assigned or (iter.get_parent() as CanvasItem).is_visible_in_tree()
			
			iter.restore_medal()
			
			count += 1
			if count >= medals_size:
				break

func figure_team_slots() -> Array:
	var arr:Array = []
	for iter in items:
		if iter is MedalSlot:
			arr.append(iter)
			if arr.size() == 5:
				break
	return arr

func find_house(vivo:Vivosaur) -> MedalHouse:
	for iter in items:
		if iter is MedalHouse and iter.medal != null:
			if iter.medal.vivo == vivo:
				return iter
	return null

func load_team(team:Team):
	var vivos = team.get_all()
	var slots:Array = figure_team_slots()
	
	for iter in range(5):
		if vivos[iter] == null:
			remove(slots[iter])
		else:
			var house:MedalHouse = find_house(vivos[iter])
			
			if slots[iter].house == house:
				continue
			
			remove(slots[iter])
			
			if house == null:
				continue
			
			assign(house, slots[iter])
