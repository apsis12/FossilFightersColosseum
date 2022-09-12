extends Node2D

func _ready():
	$AniLeft.play("Idle")
	$AniRight.play("Idle")

func _on_ShiftLeft_selected(_node):
	$AniLeft.stop()
	$AniLeft.play("Select")
	$Sound.play()

func _on_ShiftRight_selected(_node):
	$AniRight.stop()
	$AniRight.play("Select")
	$Sound.play()

func _on_AniLeft_animation_finished(anim_name):
	$AniLeft.play("Idle")
	if anim_name == "Select":
		$AniRight.stop()
		$AniRight.play("Idle")

func _on_AniRight_animation_finished(anim_name):
	$AniRight.play("Idle")
	if anim_name == "Select":
		$AniLeft.stop()
		$AniLeft.play("Idle")

func _unhandled_input(event):
	if event.is_action_pressed("ui_page_up"):
		$ShiftRight.select()
	elif event.is_action_pressed("ui_page_down"):
		$ShiftLeft.select()
