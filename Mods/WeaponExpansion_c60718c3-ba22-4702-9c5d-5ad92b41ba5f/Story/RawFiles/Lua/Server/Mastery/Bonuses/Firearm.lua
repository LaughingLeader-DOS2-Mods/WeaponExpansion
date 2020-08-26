---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param skillData SkillEventData|HitData
MasteryBonusManager.RegisterSkillListener({"Jump_TacticalRetreat", "Jump_EnemyTacticalRetreat"}, {"FIREARM_TACTICAL_RETREAT"}, function(bonuses, skill, char, state, skillData)
	if state == SKILL_STATE.CAST then
		ApplyStatus(char, "LLWEAPONEX_MASTERYBONUS_FIREARM_TACTICS", -1.0, 0, char)
	end
end)

SkillManager.RegisterAnySkillListener(function(char, state, skill, skillType, element)
	if state == SKILL_STATE.CAST and HasActiveStatus(char, "LLWEAPONEX_MASTERYBONUS_FIREARM_TACTICS") == 1 then
		RemoveStatus(char, "LLWEAPONEX_MASTERYBONUS_FIREARM_TACTICS")
	end
end)

---@param attacker string
---@param owner string
---@param target string|number[]
BasicAttackManager.RegisterListener("OnStart", function(attacker,owner,target)
	if HasActiveStatus(attacker, "LLWEAPONEX_MASTERYBONUS_FIREARM_TACTICS") == 1 then
		RemoveStatus(attacker, "LLWEAPONEX_MASTERYBONUS_FIREARM_TACTICS")
	end
end)