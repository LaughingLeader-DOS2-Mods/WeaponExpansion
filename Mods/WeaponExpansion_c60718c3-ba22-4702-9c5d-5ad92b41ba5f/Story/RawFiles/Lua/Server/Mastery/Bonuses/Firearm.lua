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

AttackManager.RegisterOnStart(function(attacker, target)
	if HasActiveStatus(attacker.MyGuid, "LLWEAPONEX_MASTERYBONUS_FIREARM_TACTICS") == 1 then
		RemoveStatus(attacker.MyGuid, "LLWEAPONEX_MASTERYBONUS_FIREARM_TACTICS")
	end
end)

--Blunderbuss bonus on hit
AttackManager.RegisterOnHit(function(bHitObject,attacker,target,damage,data)
	if bHitObject and GameHelpers.CharacterOrEquipmentHasTag(attacker, "LLWEAPONEX_Blunderbuss_Equipped") then
		GameHelpers.Skill.Explode(target, "Projectile_LLWEAPONEX_Blunderbuss_Shot_Explode", attacker)
	end
end)