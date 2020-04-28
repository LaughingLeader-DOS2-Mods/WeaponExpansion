--- @param skill StatEntrySkillData
--- @param attacker StatCharacter
--- @param isFromItem boolean
--- @param stealthed boolean
--- @param attackerPos number[]
--- @param targetPos number[]
--- @param level integer
--- @param noRandomization boolean
local function LLWEAPONEX_GetSkillDamage(skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization)
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