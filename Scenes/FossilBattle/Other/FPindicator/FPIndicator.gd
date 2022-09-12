extends Node2D

class_name FPIndicator

onready var label:Label = $Label
onready var label2:Label = $DeltaInd
onready var tween:Tween = $Tween
onready var animations:AnimationPlayer = $AnimationPlayer
onready var audio:AudioStreamPlayer = $AudioStreamPlayer
onready var background:Sprite = $Background

func set_label_int(inp:int):
	label.text = str(inp)

func push_change(new_fp:int, dfp:int):
	tween.interpolate_method(self, "set_label_int", int(label.text), new_fp, 1)
	tween.start()
	label2.text = str(dfp)
	animations.stop()
	animations.play("show_ind")
	if dfp >= 0:
		audio.stream = preload("res://Assets/SFX/Battle/add_fp.wav")
	else:
		audio.stream = preload("res://Assets/SFX/Battle/minus_fp.wav")
	audio.play()
