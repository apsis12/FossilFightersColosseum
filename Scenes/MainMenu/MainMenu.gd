extends Node2D

var opt_tree:Dictionary = {
	"Fossil Fighters Colosseum": false,
	"Battle": {
		"Battle": false,
		"Single Player Battle": true,
		"Back": 1,
	},
	"Teambuilder": true,
	"Options": {
		"Options": false,
		"Window Scale": {
			"Window Scale": false,
			"1x": false,
			"2x": false,
			"3x": false,
			"4x": false,
			"Back": 1,
		},
		"Back": 1,
	},
	"About": {
		"About": false,
		"Authors":
			"Apsis12, ZestyZino",
		"Back": 1,
	},
	"Exit": true,
}

var dialogue:FFDialogue

func _ready():
	Canvas.root_canvas_node = self
	
	modulate = Color.black
	yield(Canvas.interpolate_screen_modulation(Color.white, 0.5), "tween_all_completed")
	
	dialogue = SubWindow.push_dialogue(opt_tree, self, "_on_dialogue_option_selected", FFMenu.PROFILES.FF1, Vector2.ZERO, true, true, false)

func _on_dialogue_option_selected(path:PoolStringArray, val):
	# for some reason .back() does not exist in psa
	match path[path.size()-1]:
		"1x": Window.set_window_scale(Vector2.ONE)
		"2x": Window.set_window_scale(Vector2.ONE * 2)
		"3x": Window.set_window_scale(Vector2.ONE * 3)
		"4x": Window.set_window_scale(Vector2.ONE * 4)
		"Music Volume":
			if val != null:
				Settings.music_volume = val as int
		"Sound FX Volume":
			if val != null:
				Settings.sfx_volume = val as int
		"Single Player Battle":
			yield(dialogue, "closed")
			$AudioStreamPlayer.stream = preload("res://Assets/SFX/Battle/battle_challenge.wav")
			$AudioStreamPlayer.play()
			yield(Canvas.interpolate_screen_modulation(Color.black, 2), "tween_all_completed")
			get_tree().change_scene("res://Scenes/PreBattle/PreBattle.tscn")
		"Teambuilder":
			yield(dialogue, "closed")
			$AudioStreamPlayer.stream = preload("res://Assets/SFX/VMM/open.wav")
			$AudioStreamPlayer.play()
			yield(Canvas.interpolate_screen_modulation(Color.black, 1), "tween_all_completed")
			get_tree().change_scene("res://Scenes/VMM/VMM.tscn")
		"Exit":
			yield(dialogue, "closed")
			get_tree().quit()
