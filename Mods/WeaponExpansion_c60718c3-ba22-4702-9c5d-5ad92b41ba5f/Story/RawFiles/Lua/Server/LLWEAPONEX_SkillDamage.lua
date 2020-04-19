local function LLWEAPONEX_GetSkillDamage(skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization)
	Ext.Print("Looking for skill damage func for: " .. skill.Name)
	local skill_func = WeaponExpansion.SkillDamage.Skills[skill.Name]
	if skill_func ~= nil then
		local skillDamageDebug = {
			skill = tostring(skill.Name),
			attacker = attacker,
			isFromItem = isFromItem,
			stealthed = stealthed,
			attackerPos = attackerPos,
			targetPos = targetPos,
			level = level,
			noRandomization = noRandomization
		}
		Ext.Print("Getting skill damage:\n" .. LeaderLib.Common.Dump(skillDamageDebug))
		local status,val1,val2 = xpcall(skill_func, debug.traceback, skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization)
		if status then
			if val1 ~= nil then
				Ext.Print("damageList("..tostring(LeaderLib.Common.Dump(val1:ToTable()))..")")
				return val1,val2
			end
		else
			Ext.PrintError("Error getting damage for skill:\n",val1)
		end
	end
end

Ext.RegisterListener("GetSkillDamage", LLWEAPONEX_GetSkillDamage)