local function LLWEAPONEX_GetSkillDamage(skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization)
	local skill_func = WeaponExpansion.Skills.Damage.Skills[skill.Name]
	if skill_func ~= nil then
		local status,damageList,deathType = xpcall(skill_func, debug.traceback, skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization)
		if status and damageList ~= nil then
			Ext.Print("GetSkillDamage damageList("..tostring(LeaderLib.Common.Dump(damageList:ToTable()))..")")
			return damageList,deathType
		else
			Ext.PrintError("Error getting damage for skill:\n",damageList)
		end
	end
end

Ext.RegisterListener("GetSkillDamage", LLWEAPONEX_GetSkillDamage)