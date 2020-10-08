
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

---@param skill string
---@param char string
---@param state SkillState
---@param data HitData
LeaderLib.RegisterSkillListener("Target_LLWEAPONEX_ShieldBash", function(skill, char, state, data)
	if state == SKILL_STATE.HIT and data.Success then
		Osi.LeaderLib_Force_Apply(char, data.Target, 1)
	end
end)

---@param skill string
---@param char string
---@param state SkillState
---@param data SkillEventData
LeaderLib.RegisterSkillListener("Shout_LLWEAPONEX_DualShields_HunkerDown", function(skill, char, state, data)
	if state == SKILL_STATE.CAST then
		-- Armor Overhaul Support
		-- Only restores armor if these statuses still do that.
		local healStat = Ext.StatGetAttribute("SHIELDED_PHYSICAL", "HealStat")
		local healType = Ext.StatGetAttribute("SHIELDED_PHYSICAL", "HealType")
		if healStat == "PhysicalArmor" and healType == "Shield" then
			ApplyStatus(char, "SHIELDED_PHYSICAL", 0.0, 0, char)
		end
		healStat = Ext.StatGetAttribute("SHIELDED_MAGIC", "HealStat")
		healType = Ext.StatGetAttribute("SHIELDED_MAGIC", "HealType")
		if healStat == "MagicArmor" and healType == "Shield" then
			ApplyStatus(char, "SHIELDED_MAGIC", 0.0, 0, char)
		end
		--Ext.IsModLoaded(MODID.DivinityUnleashed) or Ext.IsModLoaded(MODID.ArmorMitigation) then
	end
end)