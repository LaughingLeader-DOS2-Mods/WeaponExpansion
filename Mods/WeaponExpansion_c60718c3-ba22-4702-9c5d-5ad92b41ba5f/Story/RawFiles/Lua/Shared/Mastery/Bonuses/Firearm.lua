local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

MasteryBonusManager.AddRankBonuses(MasteryID.Firearm, 1, {
	rb:Create("FIREARM_TACTICAL_RETREAT", {
		Skills = {"Jump_TacticalRetreat", "Jump_EnemyTacticalRetreat"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Firearm_TacticalRetreat", "<font color='#00FF99'>After jumping, your next action's AP cost is reduced by [Stats:Stats_LLWEAPONEX_MasteryBonus_Firearm_Tactics:APCostBoost].</font>"),
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.CAST then
			GameHelpers.Status.Apply(char, "LLWEAPONEX_MASTERYBONUS_FIREARM_TACTICS", -1.0, 0, char)
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
			GameHelpers.Status.Remove(char, "LLWEAPONEX_MASTERYBONUS_FIREARM_TACTICS")
		end
	end)
	
	AttackManager.OnStart.Register(function(attacker, target)
		if HasActiveStatus(attacker.MyGuid, "LLWEAPONEX_MASTERYBONUS_FIREARM_TACTICS") == 1 then
			GameHelpers.Status.Remove(attacker.MyGuid, "LLWEAPONEX_MASTERYBONUS_FIREARM_TACTICS")
		end
	end)
	
	AttackManager.OnWeaponTagHit.Register("LLWEAPONEX_Blunderbuss_Equipped", function(tag, attacker, target, data, targetIsObject, skill)
		if not skill then
			GameHelpers.Skill.Explode(target, "Projectile_LLWEAPONEX_Blunderbuss_Shot_Explode", attacker)
		end
	end)
end