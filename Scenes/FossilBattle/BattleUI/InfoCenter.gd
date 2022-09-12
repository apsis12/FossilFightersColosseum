extends Node2D

func recieve(msg:String, now:bool = false):
	$Sprite/RichTextLabel.text = msg
	if now:
		$Sprite/RichTextLabel.percent_visible = 1
	else:
		$Tween.interpolate_property($Sprite/RichTextLabel, "percent_visible", 0, 1, 0.4)
		$Tween.start()
