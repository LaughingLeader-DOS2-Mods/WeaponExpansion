---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param skillData SkillEventData|HitData
MasteryBonusManager.RegisterSkillListener({"Jump_TacticalRetreat", "Jump_EnemyTacticalRetreat"}, "FIREARM_TACTICAL_RETREAT", function(bonuses, skill, char, state, skillData)
	if state == SKILL_STATE.CAST then
		ApplyStatus(char, "LLWEAPONEX_MASTERYBONUS_FIREARM_TACTICS", -1.0, 0, char)
	end
end)

SkillManager.RegisterAnySkillListener(function(char, state, skill, skillType, element)
	if state == SKILL_STATE.CAST and HasActiveStatus(char, "LLWEAPONEX_MASTERYBONUS_FIREARM_TACTICS") == 1 then
		RemoveStatus(char, "LLWEAPONEX_MASTERYBONUS_FIREARM_TACTICS")
	end
end)

BasicAttackManager.RegisterOnStart(function(attacker, target)
	if HasActiveStatus(attacker, "LLWEAPONEX_MASTERYBONUS_FIREARM_TACTICS") == 1 then
		RemoveStatus(attacker, "LLWEAPONEX_MASTERYBONUS_FIREARM_TACTICS")
	end
end)

--Blunderbuss bonus on hit
BasicAttackManager.RegisterOnHit(function(bHitObject,attacker,target,damage,handle)
	if bHitObject and IsTagged(attacker, "LLWEAPONEX_Blunderbuss_Equipped") == 1 then
		GameHelpers.ExplodeProjectile(attacker, target, "Projectile_LLWEAPONEX_Blunderbuss_Shot_Explode")
	end
end)