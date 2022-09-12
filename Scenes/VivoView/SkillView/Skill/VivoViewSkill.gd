extends Sprite


var type:int setget set_type

func set_type(new:int):
	type = new
	match type:
		Skill.SKILL_TYPE.ATTACK:
			texture = preload("res://Assets/VivoView/skill/Skill_Normal.png")
		Skill.SKILL_TYPE.SPECIAL:
			texture = preload("res://Assets/VivoView/skill/Skill_Special.png")
		Skill.SKILL_TYPE.TEAM:
			texture = preload("res://Assets/VivoView/skill/Skill_Team.png")

func set_data(skill:Skill):
	set_type(skill.shown_type)
	
	$Name.text = skill.label
	$Power.text = str(skill.power) if skill.power > 0 else "---"
	$FP.text = str(skill.fp)
	
	if skill.effect == Skill.EFFECT.NONE:
		$Effect.text = ""
		$Rate.text = ""
	else:
		if skill.effect == Skill.EFFECT.STATUS:
			$Effect.text = Skill.str_status_info(skill.status_effect).capitalize()
		elif skill.effect == Skill.EFFECT.TRANSFORM:
			if skill.effect_descriptor.length() > 0:
				$Effect.text = "Transform: " + skill.effect_descriptor
			else:
				$Effect.text = "Transform: " + Vivodata.metadb[skill.effect_severity - 1].label
		else:
			$Effect.text = Skill.str_effect(skill.effect).capitalize()
		$Rate.text = "Success Rate: " + str(100 * skill.effect_chance) + "%"
