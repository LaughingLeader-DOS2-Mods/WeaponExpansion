local isClient = Ext.IsClient()

--- @param skill StatEntrySkillData
--- @param attacker StatCharacter
--- @param isFromItem boolean
--- @param stealthed boolean
--- @param attackerPos number[]
--- @param targetPos number[]
--- @param level integer
--- @param noRandomization boolean
local function OnGetSkillDamage(skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization)
	if skill.UseWeaponDamage == "Yes"
	and GameHelpers.Ext.ObjectIsStatCharacter(attacker)
	and attacker.Character:HasTag("LLWEAPONEX_PacifistsWrath_Equipped") then
		local damageList = Ext.NewDamageList()
		damageList:Add("Physical", 1)
		return damageList,"Physical"
	end
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
			local weapon = UnarmedHelpers.GetUnarmedWeapon(attacker)
			local damageList,deathType = Math.GetSkillDamage(skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization, weapon)
			if not isClient then
				local hasDamage = false
				for i,v in pairs(damageList:ToTable()) do
					if v.Amount > 0 then
						hasDamage = true
						break
					end
				end
				if hasDamage then
					SkillConfiguration.TempData.RecalculatedUnarmedSkillDamage[attacker.MyGuid] = skill.Name
				end
			end
			return damageList,deathType
		end
	end
end

Ext.RegisterListener("GetSkillDamage", OnGetSkillDamage)