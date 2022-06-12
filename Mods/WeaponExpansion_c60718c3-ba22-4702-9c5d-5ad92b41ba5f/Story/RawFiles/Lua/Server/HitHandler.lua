--- @param target string
--- @param source string
--- @param damage integer
--- @param handle integer
--- @param data HitPrepareData
local function OnPrepareHit(target,source,damage,handle,data)
	if data.TotalDamageDone > 0 and data:Succeeded() then
		if ObjectGetFlag(target, "LLWEAPONEX_MasteryBonus_RushProtection") == 1 and data.HitType == "Surface" then
			data.Blocked = true
			data:ClearAllDamage()
			Timer.StartObjectTimer("LLWEAPONEX_ResetDualShieldsRushProtection", target, 750)
			return
		end

		local hitType = NRD_HitGetInt(handle, "HitType")

		if HasActiveStatus(target, "LLWEAPONEX_MASTERYBONUS_SHIELD_BLOCK") == 1 and hitType < 4 then
			data.Blocked = true
			data:ClearAllDamage()
			GameHelpers.Status.Remove(target, "LLWEAPONEX_MASTERYBONUS_SHIELD_BLOCK")
			if ObjectIsCharacter(target) == 1 then
				local blockedText = Ext.GetTranslatedString("h175f5a66g78d1g41a8g9530g004e19a5db8a", "Blocked!")
				CharacterStatusText(target, string.format("<font color='#CCFF00'>%s</font>", blockedText))
			end
			return
		end
		if not StringHelpers.IsNullOrEmpty(source) and ObjectIsCharacter(source) == 1 then
			local coverData = PersistentVars.SkillData.ShieldCover.Blocking[target]
			if coverData ~= nil and coverData.CanCounterAttack == true then
				local blocker = coverData.Blocker
				if blocker ~= nil
				and CharacterIsDead(blocker) == 0
				and CharacterIsEnemy(blocker, source) == 1
				and CharacterCanSee(blocker, source) == 1
				and hitType <= 3 then -- Everything but Surface,DoT,Reflected
					data:ClearAllDamage()
					data.SimulateHit = false
					data.Dodged = false
					data.Missed = false
					data.Blocked = true
					data.Hit = false
					data.DontCreateBloodSurface = true
					PersistentVars.SkillData.ShieldCover.BlockedHit[target] = {
						Blocker = blocker,
						Attacker = source
					}
					coverData.CanCounterAttack = false
					return
				end
			end

			if not SkillConfiguration.TempData.RecalculatedUnarmedSkillDamage[source] then
				if data:IsFromWeapon(false, false) then
					local sourceCharacter = GameHelpers.GetCharacter(source)
					if sourceCharacter and UnarmedHelpers.HasUnarmedWeaponStats(sourceCharacter.Stats) then
						UnarmedHelpers.ScaleUnarmedHitDamage(source,target,damage,handle,data,true)
					end
				end
			else
				SkillConfiguration.TempData.RecalculatedUnarmedSkillDamage[source] = nil
			end

			if HasActiveStatus(source, "LLWEAPONEX_MURAMASA_CURSE") == 1 then
				--Muramasa bonus of increasing crit damage with missing vitality percentage
				local isCrit = data.Backstab or data.CriticalHit
				if isCrit then
					local max = GameHelpers.GetExtraData("LLWEAPONEX_Muramasa_MaxCriticalDamageIncrease", 50)
					local damageBoost = (((100 - CharacterGetHitpointsPercentage(source))/100) * max)/100
					GameHelpers.Damage.IncreaseDamage(target, source, handle, damageBoost, true)
				end
			end
		end
	end
end

SkillConfiguration.ArmCannonSkills = {
	Zone_LLWEAPONEX_ArmCannon_Disperse = true,
	Projectile_LLWEAPONEX_ArmCannon_Shoot = true,
	Projectile_LLWEAPONEX_ArmCannon_Disperse_Explosion = true,
}

--- @param target EsvCharacter|EsvItem
--- @param source EsvCharacter|EsvItem
--- @param data HitData
local function OnStatusHitEnter(target, source, data)
-- if Vars.DebugMode then
	-- 	fprint("[LLWEAPONEX:OnHit] skill(%s) target.MyGuid(%s) source.MyGuid(%s)", NRD_StatusGetString(target.MyGuid, handle, "SkillId"), target.MyGuid, source.MyGuid)
	-- end
	local skill = data.Skill
	
	local blockedHit = PersistentVars.SkillData.ShieldCover.BlockedHit[target.MyGuid]
	if blockedHit ~= nil then
		data.HitStatus.AllowInterruptAction = false
		data.HitStatus.ForceInterrupt = false
		data.HitStatus.Interruption = false
		DualShields_Cover_OnCounter(target.MyGuid, blockedHit.Blocker, blockedHit.Attacker)
		PersistentVars.SkillData.ShieldCover.BlockedHit[target.MyGuid] = nil
	end
	local hitSucceeded = data.Success
	if data.SkillData and SkillConfiguration.ArmCannonSkills[skill] then
		data:SetHitFlag("Hit", true)
		data:SetHitFlag({"Dodged", "Missed"}, false)
		hitSucceeded = true
	end

	if hitSucceeded and target and GameHelpers.Ext.ObjectIsCharacter(source) then
		SwordofVictory_OnHit(target, source, data)
		local coverData = PersistentVars.SkillData.ShieldCover.Blocking[target.MyGuid]
		if coverData ~= nil then
			DualShields_Cover_RedirectDamage(target.MyGuid, coverData.Blocker, source.MyGuid, data.HitStatus.StatusHandle)
		end
		local canGrantMasteryXP = data.Damage > 0 and MasterySystem.CanGainExperience(source)
		if not data.SkillData and data:IsFromWeapon() then
			local xpMastery = nil
			-- if canGrantMasteryXP then
			-- 	Ext.PrintError("canGrantMasteryXP", source.DisplayName, source.MyGuid, Lib.serpent.block(Osi.DB_IsPlayer:Get(nil)))
			-- end
			--local mainhand,offhand = GameHelpers.Character.GetEquippedWeapons(source)
			if UnarmedHelpers.HasUnarmedWeaponStats(source.Stats) then
				local weapon,unarmedMasteryBoost,unarmedMasteryRank,highestAttribute,hasUnarmedWeapon = UnarmedHelpers.GetUnarmedWeapon(source.Stats)
				if weapon and weapon.ExtraProperties then
					Ext.PropertyList.ExecuteExtraPropertiesOnTarget(weapon.Name, "ExtraProperties", source, target, target.WorldPos, "Target", false, nil)
				end
				xpMastery = "LLWEAPONEX_Unarmed"
			end
			if canGrantMasteryXP then
				MasterySystem.GrantBasicAttackExperience(source.MyGuid, target.MyGuid, xpMastery)
			end
		elseif skill then
			if GameHelpers.CharacterOrEquipmentHasTag(source, "LLWEAPONEX_RunicCannonEquipped")
			and not SkillConfiguration.ArmCannonSkills[skill]
			and IsMeleeWeaponSkill(skill)
			then
				ArmCannon_OnWeaponSkillHit(source.MyGuid, target.MyGuid, skill)
			end
			if canGrantMasteryXP and IsWeaponSkill(data.SkillData) then
				MasterySystem.GrantWeaponSkillExperience(source.MyGuid, target.MyGuid)
			end
		end
	end
end

RegisterListener("OnPrepareHit", OnPrepareHit)
RegisterListener("StatusHitEnter", OnStatusHitEnter)

AttackManager.OnHit.Register(function (attacker, target, data, targetIsObject, skill)
	if not targetIsObject then
		
	end
end)