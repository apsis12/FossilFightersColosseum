extends Node2D

const stat_normal_theme:Theme = preload("res://Fonts/Resource/FFStatNumbers.tres")
const stat_positive_theme:Theme = preload("res://Fonts/Resource/FFStatNumbersPositive.tres")
const stat_negative_theme:Theme = preload("res://Fonts/Resource/FFStatNumbersNegative.tres")

func update_team_information(team:Team):
	var Stat_Totals:PoolIntArray = PoolIntArray([0, 0, 0, 0, 0])
	var Own_AZ_Stat_Modifiers:PoolIntArray = PoolIntArray([0, 0, 0, 0])
	var Enemy_AZ_Stat_Modifiers:PoolIntArray = PoolIntArray([0, 0, 0, 0])
	
	var SZ1:Vivosaur = team.SZ1
	var SZ2:Vivosaur = team.SZ2
	var AZ :Vivosaur = team.AZ
	
	# SZ
	for SZ in [[SZ1, "SZ1"], [SZ2, "SZ2"]]:
		if SZ[0] == null:
			for iter in get_node(SZ[1] as String).get_children():
				(iter as Label).text = "---"
		else:
			var stats = (SZ[0] as Vivosaur).get_stats()
			for iter in get_node(SZ[1] as String).get_children():
				var ind:int = iter.get_index()
				var stat = stats[ind]
				Stat_Totals[ind] += stat
				(iter as Label).text = str(stat)
			
			var se = (SZ[0] as Vivosaur).get_support_effects()
			match (SZ[0] as Vivosaur).dbentry.support_type:
				VivoDBEntry.SUPPORT_TYPE.OWN:
					for iter in range(4):
						Own_AZ_Stat_Modifiers[iter] += se[iter]
				VivoDBEntry.SUPPORT_TYPE.ENEMY:
					for iter in range(4):
						Enemy_AZ_Stat_Modifiers[iter] += se[iter]
	# Enemy SupportFx
	for iter in $SE_E.get_children():
		set_label_sfx_adjusted(iter as Label, Enemy_AZ_Stat_Modifiers[iter.get_index()])
	
	# AZ Modifiers
	for iter in $AZ_Modifiers.get_children():
		var ind:int = iter.get_index()
		set_label_sfx_adjusted(iter as Label, Own_AZ_Stat_Modifiers[ind])
		# set AZ text themes in advance
		# add 1 since LP is not modfified
		($AZ.get_child(ind + 1) as Label).theme = (iter as Label).theme
	
	# AZ
	if AZ == null:
		for iter in $AZ.get_children():
			(iter as Label).theme = stat_normal_theme
			(iter as Label).text = "---"
	else:
		var stats = AZ.get_stats()
		for iter in $AZ.get_children():
			var ind:int = iter.get_index()
			var stat = stats[ind]
			Stat_Totals[ind] += stat
			# LP is not modified
			if iter.get_index() > 0:
				stat = int(float(stat) * (1.0 + float(Own_AZ_Stat_Modifiers[ind - 1]) / 100))
			(iter as Label).text = str(stat)
	
	#TOTALS
	for iter in $Total.get_children():
		(iter as Label).text = str(Stat_Totals[iter.get_index()])

func set_label_sfx_adjusted(label:Label, val:int):
	var themetemp:Theme = stat_normal_theme
	var texttemp:String = str(val)
	
	if val < 0:
		themetemp = stat_negative_theme
	elif val > 0:
		themetemp = stat_positive_theme
		texttemp = "+" + texttemp
	
	label.theme = themetemp
	label.text = texttemp
