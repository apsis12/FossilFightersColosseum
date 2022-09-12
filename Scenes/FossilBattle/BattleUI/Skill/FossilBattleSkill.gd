extends ShadowedItem

func set_operative(new:bool):
	operative = new
	position.x = 0

var skill:Skill setget set_skill
func set_skill(new:Skill):
	skill = new
	$Name.text = skill.label
	$FP.text = str(skill.fp)
	if skill.effect == Skill.EFFECT.STATUS:
		$Sprite.texture = Skill.get_status_effect_icon(skill.status_effect, skill.effect_severity)
	else:
		$Sprite.texture = null
	determine_sprite()

func determine_sprite(focus:bool = false):
	if focus:
		match skill.shown_type:
			Skill.SKILL_TYPE.ATTACK: texture = preload("res://Assets/Battle/skills/normal_selected.png")
			Skill.SKILL_TYPE.SPECIAL: texture = preload("res://Assets/Battle/skills/special_selected.png")
			Skill.SKILL_TYPE.TEAM: texture = preload("res://Assets/Battle/skills/team_selected.png")
	else:
		match skill.shown_type:
			Skill.SKILL_TYPE.ATTACK: texture = preload("res://Assets/Battle/skills/normal.png")
			Skill.SKILL_TYPE.SPECIAL: texture = preload("res://Assets/Battle/skills/special.png")
			Skill.SKILL_TYPE.TEAM: texture = preload("res://Assets/Battle/skills/team.png")

func enter():
	emit_signal("entered", self)
	determine_sprite(true)
	$Tween.interpolate_property(self, "position:x", position.x, -15, 0.1)
	$Tween.start()

func leave():
	determine_sprite()
	$Tween.interpolate_property(self, "position:x", position.x, 0, 0.1)
	$Tween.start()
