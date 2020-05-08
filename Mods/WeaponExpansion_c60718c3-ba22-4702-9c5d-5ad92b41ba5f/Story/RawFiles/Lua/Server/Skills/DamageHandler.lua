local function TryPrintName(obj, prop)
	local b,result = pcall(function()
		return tostring(obj[prop])
	end)
	if b then return result end
	return tostring(obj)
end

--- @param skill StatEntrySkillData
--- @param attacker StatCharacter
--- @param isFromItem boolean
--- @param stealthed boolean
--- @param attackerPos number[]
--- @param targetPos number[]
--- @param level integer
--- @param noRandomization boolean
local function LLWEAPONEX_GetSkillDamage(skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization)
	LeaderLib.PrintDebug("[LLWEAPONEX_GetSkillDamage] skill("..TryPrintName(skill, "Name")..") character("..TryPrintName(attacker, "Name")..") isFromItem("..tostring(isFromItem)..") stealthed("..tostring(stealthed)..") attackerPos("..LeaderLib.Common.Dump(attackerPos)..") targetPos("..LeaderLib.Common.Dump(attackerPos)..") level("..tostring(level)..") noRandomization("..tostring(noRandomization)..")")
	--Mods.LeaderLib.Debug_TraceCharacter(attacker)
	local skill_func = Skills.Damage.Skills[skill.Name]
	if skill_func ~= nil then
		local status,damageList,deathType = xpcall(skill_func, debug.traceback, skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization)
		if status and damageList ~= nil then
			--LeaderLib.PrintDebug("GetSkillDamage damageList("..tostring(LeaderLib.Common.Dump(damageList:ToTable()))..")")
			return damageList,deathType
		else
			Ext.PrintError("Error getting damage for skill:\n",damageList)
		end
	end
	if string.find(skill.Name, "Trap") then
		local dump = {
			isFromItem = isFromItem,
			stealthed = stealthed,
			attackerPos = attackerPos,
			targetPos = targetPos,
			level = level,
			noRandomization = noRandomization,
		}
		Ext.Print("[GetSkillDamage("..skill.Name..")] skill(",skill,") attacker(",attacker,")",Ext.JsonStringify(dump))
		Mods.LeaderLib.Debug_TraceCharacter(attacker)
	end
end

Ext.RegisterListener("GetSkillDamage", LLWEAPONEX_GetSkillDamage)