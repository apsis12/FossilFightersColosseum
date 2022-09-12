extends Node2D

signal initiate_close()
signal closed()
signal transition_completed()

onready var tween:Tween = $Tween

class Profile:
	var filling_color:Color
	var shadow:bool
	
	var ts:StreamTexture
	var rs:StreamTexture
	var bs:StreamTexture
	var ls:StreamTexture
	
	var tls:StreamTexture
	var trs:StreamTexture
	var brs:StreamTexture
	var bls:StreamTexture

func push_profile(profile:Profile):
	$Filling.color = profile.filling_color
	
	$Border/WTL.texture = profile.tls
	$Border/WTR.texture = profile.trs
	$Border/WBR.texture = profile.brs
	$Border/WBL.texture = profile.bls
	
	$Border/WTL/Top.texture = profile.ts
	$Border/WTR/Right.texture = profile.rs
	$Border/WBR/Bottom.texture = profile.bs
	$Border/WBL/Left.texture = profile.ls
	
	$Border/WTR/Shadow.visible = profile.shadow
	$Border/WBR/Shadow.visible = profile.shadow

enum PROFILES {
	FF1,
	BATTLE,
}

func push_predefined(inp:int):
	assert(inp in PROFILES.values())
	var profile = Profile.new()
	match inp:
		PROFILES.FF1:
			profile.filling_color = Color("ffe79c")
			profile.shadow = true
			
			profile.tls = preload("res://Assets/UI/Window/WTL.png")
			profile.trs = preload("res://Assets/UI/Window/WTR.png")
			profile.brs = preload("res://Assets/UI/Window/WBR.png")
			profile.bls = preload("res://Assets/UI/Window/WBL.png")
			
			profile.ts = preload("res://Assets/UI/Window/LINET.png")
			profile.rs = preload("res://Assets/UI/Window/LINER.png")
			profile.bs = preload("res://Assets/UI/Window/LINEB.png")
			profile.ls = preload("res://Assets/UI/Window/LINEL.png")
		
		PROFILES.BATTLE:
			profile.filling_color = Color("ced6d6")
			profile.shadow = false
			
			profile.tls = preload("res://Assets/UI/BattleWindow/tls.png")
			profile.trs = preload("res://Assets/UI/BattleWindow/trs.png")
			profile.brs = preload("res://Assets/UI/BattleWindow/brs.png")
			profile.bls = preload("res://Assets/UI/BattleWindow/bls.png")
			
			profile.ts = preload("res://Assets/UI/BattleWindow/ts.png")
			profile.rs = preload("res://Assets/UI/BattleWindow/rs.png")
			profile.bs = preload("res://Assets/UI/BattleWindow/bs.png")
			profile.ls = preload("res://Assets/UI/BattleWindow/ls.png")
	
	push_profile(profile)

var true_size:Vector2 = Vector2.ZERO setget set_true_size
var target_size:Vector2 = Vector2(50, 50) setget set_target_size

export var auto_open:bool = true

func readystuff():
	pass


func _ready():
	readystuff()
	if auto_open:
		open()

const CORNER_SPRITE_SIZE:int = 6

func set_true_size(new:Vector2):
	true_size = new
	var corners:Array = get_corners()
	$Filling.polygon = corners
	
	var line_len:Vector2 = true_size - Vector2.ONE * CORNER_SPRITE_SIZE
	
	for i in range(4):
		var border:Sprite = $Border.get_child(i)
		border.position = corners[i]
		for line in border.get_children():
			if line is Line2D:
				if i == 0 or i == 2:
					line.points = [Vector2.ZERO, Vector2(line_len.x, 0)]
				else:
					line.points = [Vector2.ZERO, Vector2(line_len.y, 0)]

func set_target_size(new:Vector2, time:float = 0.125):
	target_size = new
	start_transition(time)

func start_transition(time:float = 0.125):
	if is_inside_tree() and true_size != target_size:
		tween.interpolate_property(self, "true_size", true_size, target_size, time)
		tween.start()
		if tween.is_active():
			yield(tween,"tween_all_completed")
		emit_signal("transition_completed")

func open():
	start_transition()

func close():
	emit_signal("initiate_close")
	set_target_size(Vector2.ZERO)
	if tween.is_active():
		yield(tween,"tween_all_completed")
	emit_signal("closed")
	queue_free()

enum anchor_type {
	CENTER,
	TOP_LEFT,
	TOP,
	TOP_RIGHT,
	RIGHT,
	BOTTOM_RIGHT,
	BOTTOM,
	BOTTOM_LEFT,
	LEFT
}

export var anchor : int = anchor_type.CENTER setget set_anchor

func set_anchor(val:int):
	anchor = int(clamp(val, 0, anchor_type.size()))
	set_true_size(true_size)

func get_corners(target:bool = false) -> Array:
	var vec : Vector2 = target_size if target else true_size
	match anchor:
		anchor_type.CENTER :
			return [-vec/2, Vector2(vec.x, -vec.y)/2, vec/2, Vector2(-vec.x, vec.y)/2]
		anchor_type.TOP_LEFT :
			return [Vector2.ZERO, Vector2(vec.x, 0), vec, Vector2(0, vec.y)]
		anchor_type.TOP_RIGHT :
			return [Vector2(-vec.x, 0), Vector2.ZERO, Vector2(0, vec.y), Vector2(-vec.x, vec.y)]
		anchor_type.BOTTOM_RIGHT :
			return [-vec, Vector2(0, -vec.y), Vector2.ZERO, Vector2(-vec.x, 0)]
		anchor_type.BOTTOM_LEFT :
			return [Vector2(0, -vec.y), Vector2(vec.x, -vec.y), Vector2(vec.x, 0), Vector2.ZERO]
		anchor_type.TOP :
			return [Vector2(-vec.x/2,0), Vector2(vec.x/2,0), Vector2(vec.x/2,vec.y), Vector2(-vec.x/2,vec.y)]
		anchor_type.BOTTOM :
			return [Vector2(-vec.x/2,-vec.y), Vector2(vec.x/2,-vec.y), Vector2(vec.x/2,0), Vector2(-vec.x/2,0)]
		anchor_type.RIGHT :
			return [Vector2(-vec.x,-vec.y/2), Vector2(0,-vec.y/2), Vector2(0,vec.y/2), Vector2(-vec.x,vec.y/2)]
		anchor_type.LEFT :
			return [Vector2(0,-vec.y/2), Vector2(vec.x,-vec.y/2), Vector2(vec.x,vec.y/2), Vector2(0,vec.y/2)]
		_ :
			assert(false)
			# unreachable
			return []

func get_rect(target:bool = false) -> Rect2:
	return Rect2(position + get_corners(target)[0], true_size)

func get_global_rect(target:bool = false) -> Rect2:
	return Rect2(global_position + get_corners(target)[0], true_size)
