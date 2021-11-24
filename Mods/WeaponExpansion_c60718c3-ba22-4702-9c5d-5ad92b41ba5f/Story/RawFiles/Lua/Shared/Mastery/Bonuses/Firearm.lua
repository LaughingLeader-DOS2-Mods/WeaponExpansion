local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

MasteryBonusManager.AddRankBonuses(MasteryID.Firearm, 1, {
	rb:Create("FIREARM_TACTICAL_RETREAT", {
		Skills = {"Jump_TacticalRetreat", "Jump_EnemyTacticalRetreat"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Firearm_TacticalRetreat", "<font color='#00FF99'>After jumping, your next action's AP cost is reduced by [Stats:Stats_LLWEAPONEX_MasteryBonus_Firearm_Tactics:APCostBoost].</font>"),
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.CAST then
			ApplyStatus(char, "LLWEAPONEX_MASTERYBONUS_FIREARM_TACTICS", -1.0, 0, char)
		end
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Firearm, 2, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Firearm, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Firearm, 4, {
	
})

if not Vars.IsClient then
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
	
	AttackManager.RegisterOnWeaponTagHit("LLWEAPONEX_Blunderbuss_Equipped", function(tag, source, target, data, bonuses, bHitObject, isFromSkill)
		if not isFromSkill then
			GameHelpers.Skill.Explode(target, "Projectile_LLWEAPONEX_Blunderbuss_Shot_Explode", source)
		end
	end)
end