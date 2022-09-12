extends Node2D

class_name StatModIndicator

const positive_theme:Theme = preload("res://Fonts/Resource/SupportEffectsPositiveBattleMap.tres")
const negative_theme:Theme = preload("res://Fonts/Resource/SupportEffectsNegativeBattleMap.tres")

class LabelImpl:
	var label:Label
	
	func _init(init_label:Label = null, init_val:int = 0):
		label = init_label
		set_val(init_val)
	
	var val:int = 0 setget set_val
	
	func set_val(new:int):
		val = new
		if val == 0:
			label.hide()
		elif val >= 0:
			label.show()
			label.theme = positive_theme
			label.text = "+" + str(val) + "%"
		else:
			label.show()
			label.theme = negative_theme
			label.text = str(val) + "%"

onready var tween:Tween = $Tween

var attack:LabelImpl
var defense:LabelImpl
var accuracy:LabelImpl
var evasion:LabelImpl

func _ready():
	attack = LabelImpl.new($Attack, 0)
	defense = LabelImpl.new($Defense, 0)
	accuracy = LabelImpl.new($Accuracy, 0)
	evasion = LabelImpl.new($Evasion, 0)


var mods:PoolIntArray = [0, 0, 0, 0] setget push_mods

const PUSH_DURATION:float = 0.5

func push_mods(arr:PoolIntArray):
	assert(arr.size() == 4, "Mods must be of size 4.")
	
	mods = arr
	
	var cnt:int = 0
	for label in [attack, defense, accuracy, evasion]:
		tween.interpolate_property(label, "val", label.val, mods[cnt], PUSH_DURATION)
		cnt += 1
	
	tween.start()
