
---@param bonuses table<string,bool>
---@param char string
---@param state SKILL_STATE
---@param skill string
---@param skillType string
---@param element string
MasteryBonusManager.RegisterSkillTypeListener("rush", {"DUALSHIELDS_RUSHPROTECTION"}, function(bonuses, char, state, skill, skillType, element)
	if state == SKILL_STATE.USED then
		ObjectSetFlag(char, "LLWEAPONEX_MasteryBonus_RushProtection", 0)
	elseif state == SKILL_STATE.CAST then
		Osi.LeaderLib_Timers_StartObjectTimer(char, 1500, "Timers_LLWEAPONEX_ResetDualShieldsRushProtection", "LLWEAPONEX_ResetDualShieldsRushProtection")
	end
end)