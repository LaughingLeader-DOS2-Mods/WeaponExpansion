local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

MasteryBonusManager.AddRankBonuses(MasteryID.Firearm, 1, {
	rb:Create("FIREARM_TACTICAL_RETREAT", {
		Skills = {"Jump_TacticalRetreat", "Jump_EnemyTacticalRetreat"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Firearm_TacticalRetreat", "<font color='#00FF99'>After jumping, your next action's AP cost is reduced by [Stats:Stats_LLWEAPONEX_MasteryBonus_Firearm_Tactics:APCostBoost].</font>"),
	}).Register.SkillCast(function(self, e, bonuses)
		local GUID = e.Character.MyGuid
		GameHelpers.Status.Apply(e.Character, "LLWEAPONEX_MASTERYBONUS_FIREARM_TACTICS", -2.0, true, e.Character)

		Events.OnSkillState:Subscribe(function (se)
			GameHelpers.Status.Remove(se.Character, "LLWEAPONEX_MASTERYBONUS_FIREARM_TACTICS")
		end, {Once=true, MatchArgs=function(_e) return _e.State == SKILL_STATE.CAST and _e.Character.MyGuid == GUID end})

		Events.OnBasicAttackStart:Subscribe(function (ae)
			GameHelpers.Status.Remove(ae.Attacker, "LLWEAPONEX_MASTERYBONUS_FIREARM_TACTICS")
		end, {Once=true, MatchArgs=function(_e) return _e.Attacker.MyGuid == GUID end})

	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Firearm, 2, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Firearm, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Firearm, 4, {
	
})