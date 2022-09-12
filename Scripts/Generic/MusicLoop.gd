extends AudioStreamPlayer

func _ready():
	while true:
		play()
		yield(self, "finished")
