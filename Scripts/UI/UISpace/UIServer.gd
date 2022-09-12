extends Node2D
class_name UIServer

var items:Array = []

func add_item(new:UIItem):
	if not items.has(new):
		items.append(new)
		new.connect("mouse_hover", self, "_on_item_mouse_hover")
		new.connect("mouse_select", self, "_on_item_mouse_select")

func remove_item(old:UIItem):
	items.erase(old)
	old.disconnect("mouse_hover",self,"_on_item_mouse_hover")
	old.disconnect("mouse_select",self,"_on_item_mouse_select")

func clear():
	leave_current_item()
	cursor.vanish()
	while items.size() > 0:
		remove_item(items[0])
	current_item = null

func make_from_array(arr:Array):
	for iter in arr:
		if iter is UIItem:
			add_item(iter)

func make_from_children(node:Node = self):
	make_from_array(node.get_children())


var cursor:UICursor

var current_item:UIItem setget move_to

func movement_conditions(item:UIItem) -> bool:
	return item.operative and items.has(item)

func move_to(item:UIItem) -> bool:
	if movement_conditions(item):
		if current_item != null:
			leave_current_item()
		current_item = item
		if cursor != null:
			cursor.to_item(current_item)
		enter_current_item()
		return true
	return false

var current_item_has_entered:bool = false

func enter_leave_conditions() -> bool:
	return true

func enter_current_item():
	if current_item != null and enter_leave_conditions():
		current_item.enter()
		current_item_has_entered = true
func leave_current_item():
	if current_item != null and enter_leave_conditions():
		current_item.leave()
		current_item_has_entered = false


func selection_conditions() -> bool:
	return true

func select_current_item():
	if current_item != null and selection_conditions():
		current_item.select()



func get_operative() -> Array:
	var ret:Array = []
	if items.size() > 0:
		for i in items:
			if i is UIItem and movement_conditions(i):
				ret.append(i)
	return ret

func to_first_operative() -> bool:
	var tmp:Array = get_operative()
	if tmp.size() > 0:
		return move_to(get_operative().front())
	else:
		return false

func is_valid_transfer(node:Node) -> bool:
	return node is UIItem and node.operative and node != current_item

func to_area(point:Vector2, max_distance:float = 0) -> bool:
	if items.size() == 0:
		return false
	
	var new_item:UIItem
	var new_item_intersection_distance:float = 0
	for iter in items:
		if is_valid_transfer(iter):
			var iter_position:Vector2 = iter.get_global_rect_center()
			var distance_to_iter:float = point.distance_to(iter_position)
			if new_item == null or (distance_to_iter < new_item_intersection_distance and distance_to_iter <= max_distance):
				new_item = iter
				new_item_intersection_distance = distance_to_iter
	if new_item != null:
		return move_to(new_item)
	
	return false

func dir_input(vec:Vector2):
	move_dir(vec)

func move_dir(vec:Vector2) -> bool:
	# could use some work

	if current_item == null:
		to_first_operative()
	
	if items.size() <= 1:
		return false
	
	if vec == Vector2.ZERO:
		return false
	
	var new_item:UIItem
	var new_item_distance:float = 0
	var current_center:Vector2 = current_item.get_global_rect_center()
	
	var ray = Vector2(vec.y, -vec.x)
	
	for iter in items:
		iter = (iter as UIItem)
		if not is_valid_transfer(iter):
			continue
		
		if abs(Vector2(iter.get_global_rect_center() - current_center).angle_to(vec)) > PI/2:
			continue
		
		var iter_rect:Rect2 = iter.get_global_rect()
		var segments:Array = Util.rect_get_segments(Rect2(iter_rect.position - current_center, iter_rect.size))
		
		var segment_intersection_distance:float = 0
		
		for seg in segments:
			if sign(ray.dot(seg.position)) != sign(ray.dot(seg.size)):
				
				var cur_intersection_distance:float = (seg.position.distance_to(vec) + seg.size.distance_to(vec))/2
				
				if segment_intersection_distance == 0 or cur_intersection_distance < segment_intersection_distance:
					segment_intersection_distance = cur_intersection_distance
		
		if segment_intersection_distance != 0 and (new_item == null or segment_intersection_distance < new_item_distance):
			new_item = iter
			new_item_distance = segment_intersection_distance
	
	if new_item != null:
		return move_to(new_item)
	
	# fallback
	for iter in items:
		if not is_valid_transfer(iter):
			continue
		var iter_center:Vector2 = iter.get_global_rect_center()
		if abs(Vector2(iter_center-current_center).angle_to(vec)) < PI/2:
			var distance_to_iter:float = current_center.distance_to(iter_center)
			if new_item == null or distance_to_iter < new_item_distance:
				new_item = iter
				new_item_distance = distance_to_iter
	
	if new_item != null:
		return move_to(new_item)
	
	return false


export var focused:bool = true

func input_conditions() -> bool:
	return cursor == null or not cursor.tween.is_active()

func alt_inputs(_event:InputEvent):
	pass

func _unhandled_input(event):
	if focused and input_conditions():
		if event.is_action_pressed("ui_up", true):
			dir_input(Vector2.UP)
		elif event.is_action_pressed("ui_right", true):
			dir_input(Vector2.RIGHT)
		elif event.is_action_pressed("ui_down", true):
			dir_input(Vector2.DOWN)
		elif event.is_action_pressed("ui_left", true):
			dir_input(Vector2.LEFT)
		elif event.is_action_pressed("ui_accept"):
			select_current_item()
		else:
			alt_inputs(event)

func poll_items_hovering() -> bool:
	for i in items:
		if i != current_item and i.operative and i.mouse_enabled and i.hovering:
			return move_to(i)
	return false

func _on_item_mouse_hover(item:UIItem):
	if focused and item != current_item:
		move_to(item)

func _on_item_mouse_select(item:UIItem):
	if focused and item == current_item:
		select_current_item()
