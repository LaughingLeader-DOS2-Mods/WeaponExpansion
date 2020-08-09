MasteryBonusManager.RegisterSkillListener({"Target_CripplingBlow", "Target_EnemyCripplingBlow"}, {"BLUDGEON_SUNDER"}, function(bonuses, skill, char, state, skillData)
	if state == SKILL_STATE.HIT and hitData.Success then
		local duration = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_CripplingBlow_SunderTurns", 2) * 6.0
		if HasActiveStatus(skillData.Target, "LLWEAPONEX_MASTERYBONUS_SUNDER") == 1 then
			local handle = NRD_StatusGetHandle(skillData.Target, "LLWEAPONEX_MASTERYBONUS_SUNDER")
			NRD_StatusSetReal(skillData.Target, handle, "CurrentLifeTime", duration)
		else
			ApplyStatus(skillData.Target, "LLWEAPONEX_MASTERYBONUS_SUNDER", duration, 0, char)
		end
	end
end)