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
local function OnGetSkillDamage(skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization)
	local skill_func = Skills.Damage[skill.Name]
	if skill_func ~= nil then
		local b,damageList,deathType = xpcall(skill_func, debug.traceback, skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization)
		if b and damageList ~= nil then
			return damageList,deathType
		elseif not b then
			Ext.PrintError("Error getting damage for skill ",skill.Name)
			Ext.PrintError(damageList)
		end
	else
		-- Unarmed weapon damage scaling
		if skill.UseWeaponDamage == "Yes" and UnarmedHelpers.HasUnarmedWeaponStats(attacker) then
			--attacker:HasTag("LLWEAPONEX_MeleeWeaponEquipped") and 
			local weapon = UnarmedHelpers.GetUnarmedWeapon(attacker)
			return Math.GetSkillDamage(skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization, weapon)
		end
	end
end

Ext.RegisterListener("GetSkillDamage", OnGetSkillDamage)