extends Sprite
class_name UICursor

var tween:Tween
var tween2:Tween

func _init():
	tween = Tween.new()
	tween2 = Tween.new()
	add_child(tween)
	add_child(tween2)

export var center_on_item:bool = false
export var move_time:float = 0.1

func to_item(item:UIItem, ignore_hints:bool = false, manual_pos_offset:Vector2 = Vector2.ZERO, manual_rot_offset:float = 0.0):
	tween.stop_all()
	if item.show_cursor:
		var new_pos:Vector2
		if center_on_item:
			new_pos = item.get_global_rect_center() + item.cursor_offset + manual_pos_offset
		else:
			new_pos = item.get_global_rect().position + item.cursor_offset + manual_pos_offset
		
		var new_rot:float = manual_rot_offset
		
		if not ignore_hints:
			new_pos += item.cursor_offset
			new_rot += item.cursor_rotation
		
		if scale == Vector2.ONE:
			tween.interpolate_property(self, "global_position", global_position, new_pos, move_time, Tween.TRANS_CIRC, Tween.EASE_OUT)
			tween.interpolate_property(self, "rotation", rotation, new_rot, move_time)
			tween.start()
		else:
			global_position = new_pos
			rotation = new_rot
			emerge()
	elif visible:
		vanish()

export var vanish_emerge_time:float = 0.1
var opening:bool

func vanish():
	opening = false
	tween2.stop_all()
	tween2.interpolate_property(self, "scale", scale, Vector2.ZERO, vanish_emerge_time)
	tween2.start()

func emerge():
	opening = true
	tween2.stop_all()
	tween2.interpolate_property(self, "scale", scale, Vector2.ONE, vanish_emerge_time)
	tween2.start()
