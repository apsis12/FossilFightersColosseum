extends Node2D

var stat_normal_theme:Theme = preload("res://Fonts/Resource/FFStatNumbers.tres")
var stat_positive_theme:Theme = preload("res://Fonts/Resource/FFStatNumbersPositive.tres")
var stat_negative_theme:Theme = preload("res://Fonts/Resource/FFStatNumbersNegative.tres")

func push_vivo(vivo:Vivosaur):
	for i in $Stats.get_children():
		i.get_child(0).text = str(vivo.dbentry.get(i.name))
	
	$Description.text = vivo.dbentry.description
	match vivo.dbentry.gen:
		0: $Art.scale = Vector2(0.5, 0.5)
		1: $Art.scale = Vector2(0.3, 0.3)
		2: $Art.scale = Vector2(0.2, 0.2)
	
	$Art.texture = load(vivo.get_asset_path() + "RevivalArt/" + vivo.dbentry.label + ".png")
	
	if vivo.dbentry.support_type == VivoDBEntry.SUPPORT_TYPE.NONE:
		$SupportEffectsType.text = ""
		for i in $SupportEffects.get_children():
			var label:Label = i.get_child(0)
			label.theme = stat_normal_theme
			label.text = "---"
	else:
		$SupportEffectsType.set_text("Applied to " + VivoDBEntry.str_support_type(vivo.dbentry.support_type) + " AZ")
		for i in $SupportEffects.get_children():
			var value = vivo.dbentry.get(i.name)
			var label:Label = i.get_child(0)
			
			if value == 0:
				label.theme = stat_normal_theme
				label.text = "0%"
			elif value > 0:
				label.theme = stat_positive_theme
				label.text = "+" + str(value) + "%"
			elif value < 0:
				label.theme = stat_negative_theme
				label.set_text(str(value) + "%")
	
	$RadialStatIndicator.element = vivo.dbentry.element
	$RadialStatIndicator.push_stats([vivo.lp, vivo.attack, vivo.defense, vivo.accuracy, vivo.evasion])

func switch_art_with_wheel():
	$Art.visible = not $Art.visible
	$RadialStatIndicator.visible = not $Art.visible
