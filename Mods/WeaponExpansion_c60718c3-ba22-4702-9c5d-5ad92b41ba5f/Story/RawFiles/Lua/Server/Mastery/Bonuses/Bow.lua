
---@type SkillEventDataForEachCallback
local function OnPinDownTarget(v, targetType, char, skill, forwardVector, radius)
	--print("OnPinDownTarget", v, targetType, char, skill, forwardVector, radius)
	local target = nil
	if targetType == "string" then
		local targets = nil
		
		if ObjectIsCharacter(v) == 1 then
			targets = MasteryBonusManager.GetClosestEnemiesToObject(char, Ext.GetCharacter(v), radius, true, 3, v)
		elseif ObjectIsItem(v) == 1 then
			targets = MasteryBonusManager.GetClosestEnemiesToObject(char, Ext.GetItem(v), radius, true, 3, v)
		end
		
		if targets ~= nil and #targets > 0 then
			target = Common.GetRandomTableEntry(targets)
		end

		if target == nil then
			target = v
		end

		if target ~= nil then
			GameHelpers.ShootProjectile(char, target.UUID, "Projectile_LLWEAPONEX_MasteryBonus_PinDown_BonusShot", false, nil, target.UUID, true)
		else
			local x,y,z = GetPosition(v)
			y = y + 1.0
			GameHelpers.ShootProjectileAtPosition(char, x,y,z, "Projectile_LLWEAPONEX_MasteryBonus_PinDown_BonusShot")
		end
		return true
	elseif targetType == "table" then
		local x,y,z = table.unpack(v)
		local targets = MasteryBonusManager.GetClosestCombatEnemies(v, radius, true, 3, v)
		if #targets > 0 then
			target = Common.GetRandomTableEntry(targets)
		end

		if target ~= nil then
			GameHelpers.ShootProjectile(char, target.UUID, "Projectile_LLWEAPONEX_MasteryBonus_PinDown_BonusShot", false, nil, target.UUID, true)
		else
			x = x + forwardVector[1]
			z = z + forwardVector[3]
			GameHelpers.ShootProjectileAtPosition(char, x,y,z, "Projectile_LLWEAPONEX_MasteryBonus_PinDown_BonusShot")
		end
		return true
	end
	return false
end

---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param skillData SkillEventData|HitData
MasteryBonusManager.RegisterSkillListener(Mastery.Bonuses.LLWEAPONEX_Bow_Mastery1.BOW_DOUBLE_SHOT.Skills, "BOW_DOUBLE_SHOT", function(bonuses, skill, char, state, skillData)
	if state == SKILL_STATE.CAST then
		-- Support for a mod making Pin Down shoot multiple arrows through the use of iterating tables.
		local maxBonusShots = Ext.ExtraData.LLWEAPONEX_MasteryBonus_Bow_PinDownBonusShots or 1
		if maxBonusShots > 0 then
			local bonusShots = 0
			local character = Ext.GetCharacter(char)
			local rot = character.Stats.Rotation
			local forwardVector = {
				-rot[7] * 1.25,
				0,
				-rot[9] * 1.25,
			}
			local radius = (Ext.StatGetAttribute(skill, "TargetRadius") or 6.0) / 2
			skillData:ForEach(function(v, targetType, skillEventData)
				if bonusShots < maxBonusShots then
					local success,b = xpcall(OnPinDownTarget, debug.traceback, v, targetType, char, skill, forwardVector, radius)
					if b == true then
						bonusShots = bonusShots + 1
					elseif not success then
						Ext.PrintError(b)
					end
				end
			end)
		end

	end
end)

---@param data HitData
MasteryBonusManager.RegisterSkillListener({"Projectile_Snipe", "Projectile_EnemySnipe"}, "BOW_ASSASSINATE_MARKED", function(bonuses, skill, char, state, data)
	if state == SKILL_STATE.HIT then
		if HasActiveStatus(data.Target, "MARKED") == 1 then
			if NRD_StatusGetInt(data.Target, data.Handle, "CriticalHit") == 0 or data.Damage <= 0 then
				local attacker = Ext.GetCharacter(char).Stats
				local target = Ext.GetCharacter(data.Target).Stats
				NRD_HitStatusClearAllDamage(data.Target, data.Handle)
				local hit = GameHelpers.Damage.CalculateSkillDamage(skill, attacker, target, data.Handle, false, true, true)
				GameHelpers.Damage.ApplyHitRequestFlags(hit, data.Target, data.Handle)
				for i,damage in pairs(hit.DamageList:ToTable()) do
					NRD_HitStatusAddDamage(data.Target, data.Handle, damage.DamageType, damage.Amount)
				end
				NRD_StatusSetInt(data.Target, data.Handle, "CriticalHit", 1)
			end
			RemoveStatus(data.Target, "MARKED")
		end
	end
end)