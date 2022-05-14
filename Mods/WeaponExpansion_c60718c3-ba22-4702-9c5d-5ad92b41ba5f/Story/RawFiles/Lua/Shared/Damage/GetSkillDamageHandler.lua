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
	local attackerIsCharacter = GameHelpers.Ext.ObjectIsStatCharacter(attacker)
	if skill.UseWeaponDamage == "Yes"
	and attackerIsCharacter
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
	elseif attackerIsCharacter then
		-- Unarmed weapon damage scaling
		if skill.UseWeaponDamage == "Yes" and UnarmedHelpers.HasUnarmedWeaponStats(attacker) then
			local damageList,deathType = Skills.DamageFunctions.UnarmedSkillDamage(skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization, isClient)
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

Ext.Events.GetSkillDamage:Subscribe(function(e)
	local damageList,deathType = OnGetSkillDamage(e.Skill, e.Attacker, e.IsFromItem, e.Stealthed, e.AttackerPosition, e.TargetPosition, e.Level, e.NoRandomization)
	if not isClient and damageList then
		e.DamageList:CopyFrom(damageList)
		if deathType then
			e.DeathType = deathType
		end
		e:StopPropagation()
	end
end)