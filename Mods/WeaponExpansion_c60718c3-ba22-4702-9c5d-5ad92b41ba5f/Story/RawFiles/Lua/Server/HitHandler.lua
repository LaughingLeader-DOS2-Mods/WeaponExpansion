---@type MessageData
local MessageData = LeaderLib.Classes["MessageData"]

local armorDamageTypes = {
	Magic = "CurrentMagicArmor",
	Corrosive = "CurrentArmor"
}

---Reduces magic/corrosive damage by armor before it gets converted to vitality damage in BeforeCharacterApplyDamage
local function ConvertArmorDamage(target,handle)
	if ObjectIsCharacter(target) == 1 then
		for damageType,stat in pairs(armorDamageTypes) do
			local damage = NRD_HitGetDamage(handle, damageType)
			if damage > 0 then
				local armor = NRD_CharacterGetStatInt(target, stat)
				if armor > 0 then
					local nextArmor = armor - damage
					local nextDamage = damage
					if nextArmor < 0 then
						nextDamage = -1 * nextArmor
						NRD_HitClearDamage(handle, damageType)
						NRD_HitAddDamage(handle, damageType, nextDamage)
						nextArmor = 0
					else
						nextDamage = 0
						NRD_HitClearDamage(handle, damageType)
						local damageText = GameHelpers.GetDamageText(damageType, damage)
						local messageData = MessageData:CreateFromTable("LLWEAPONEX_DamageText", {
							Handle = Ext.GetCharacter(target).NetID,
							Text = damageText
						})
						Ext.BroadcastMessage("LLWEAPONEX_DisplayOverheadDamage", messageData:ToString(), nil)
						--CharacterStatusText(target, GameHelpers.GetDamageText(damageType, damage))
					end
					NRD_CharacterSetStatInt(target, stat, nextArmor)
				end
			end
		end
	end
end

--- @param target string
--- @param source string
--- @param damage integer
--- @param handle integer
local function OnPrepareHit(target,source,damage,handle)
	if not StringHelpers.IsNullOrEmpty(source) then
		local attacker = Ext.GetCharacter(source)
		if damage > 0 and GameHelpers.HitSucceeded(target, handle, true) then
			if UnarmedHelpers.HasUnarmedWeaponStats(attacker.Stats) then
				UnarmedHelpers.ScaleUnarmedHitDamage(source,target,damage,handle)
			end

			if HasActiveStatus(source, "LLWEAPONEX_MURAMASA_CURSE") == 1 then
				local isCrit = NRD_HitGetInt(handle, "Backstab") == 1 or NRD_HitGetInt(handle, "CriticalHit") == 1
				if isCrit then
					local max = Ext.ExtraData.LLWEAPONEX_Muramasa_MaxCriticalDamageIncrease or 50
					local damageBoost = (((100 - CharacterGetHitpointsPercentage(source))/100) * max)/100
					GameHelpers.Damage.IncreaseDamage(target, source, handle, damageBoost, true)
				end
			end
			local coverData = PersistentVars.SkillData.ShieldCover.Blocking[target]
			if coverData ~= nil and coverData.CanCounterAttack == true then
				local blocker = coverData.Blocker
				if blocker ~= nil 
				and CharacterIsDead(blocker) == 0
				and CharacterIsEnemy(blocker, source) == 1
				and CharacterCanSee(blocker, source) == 1
				and NRD_HitGetInt(handle, "HitType") <= 3 then -- Everything but Surface,DoT,Reflected
					damage = 0
					NRD_HitClearAllDamage(handle)
					NRD_HitSetInt(handle,"SimulateHit",0)
					NRD_HitSetInt(handle,"Dodged",0)
					NRD_HitSetInt(handle,"Missed",0)
					NRD_HitSetInt(handle,"Blocked",1)
					NRD_HitSetInt(handle,"Hit",0)
					NRD_HitSetInt(handle,"DontCreateBloodSurface",1)
					PersistentVars.SkillData.ShieldCover.BlockedHit[target] = {
						Blocker = blocker,
						Attacker = source
					}
					coverData.CanCounterAttack = false
				end
			end
		end
	end

	if damage > 0 and ObjectGetFlag(target, "LLWEAPONEX_MasteryBonus_RushProtection") == 1 then
		local hitType = NRD_HitGetString(handle, "HitType")
		if hitType == "Surface" and GameHelpers.HitSucceeded(target, handle, 1) then
			NRD_HitSetInt(handle, "Blocked", 1)
			NRD_HitClearAllDamage(handle)
			damage = 0
			Osi.LeaderLib_Timers_StartObjectTimer(StringHelpers.GetUUID(target), 750, "Timers_LLWEAPONEX_ResetDualShieldsRushProtection", "LLWEAPONEX_ResetDualShieldsRushProtection")
		end
	end

	if damage > 0 and HasActiveStatus(target, "LLWEAPONEX_MASTERYBONUS_SHIELD_BLOCK") == 1 then
		local hitType = NRD_HitGetInt(handle, "HitType")
		if hitType < 4 then
			local alreadyBlocked = NRD_HitGetInt(handle, "Blocked")
			local dodged = NRD_HitGetInt(handle, "Dodged")
			local missed = NRD_HitGetInt(handle, "Missed")
			if alreadyBlocked == 0 and dodged == 0 and missed == 0 then
				NRD_HitSetInt(handle, "Blocked", 1)
				NRD_HitClearAllDamage(handle)
				RemoveStatus(target, "LLWEAPONEX_MASTERYBONUS_SHIELD_BLOCK")
				CharacterStatusText(target, string.format("<font color='#CCFF00'>%s</font>", Ext.GetTranslatedString("h175f5a66g78d1g41a8g9530g004e19a5db8a", "Blocked!")))
			end
		end
	end
end
RegisterListener("OnPrepareHit", OnPrepareHit)

local function WeaponIsTagged(char, weapon, tag)
	if (weapon ~= nil and IsTagged(weapon, tag) == 1) then
		return true
	end
	return false
end

--- @param target string
--- @param source string
--- @param damage integer
--- @param handle integer
RegisterListener("OnHit", function(target,source,damage,handle)
	if Vars.DebugMode then
		PrintDebug(string.format("[LLWEAPONEX:OnHit] skill(%s) target(%s) source(%s)", NRD_StatusGetString(target, handle, "SkillId"), target, source))
	end
	if not StringHelpers.IsNullOrEmpty(source) then
		local blockedHit = PersistentVars.SkillData.ShieldCover.BlockedHit[target]
		if blockedHit ~= nil then
			NRD_StatusSetInt(target,handle,"AllowInterruptAction",0)
			NRD_StatusSetInt(target,handle,"ForceInterrupt",0)
			NRD_StatusSetInt(target,handle,"Interruption",0)
			DualShields_Cover_OnCounter(target, blockedHit.Blocker, blockedHit.Attacker)
			PersistentVars.SkillData.ShieldCover.BlockedHit[target] = nil
		end
		local hitSucceeded = GameHelpers.HitSucceeded(target, handle, false)
		local skill = string.gsub(NRD_StatusGetString(target, handle, "SkillId") or "", "_%-?%d+$", "")
		if skill == "Zone_LLWEAPONEX_ArmCannon_Disperse" or skill == "Projectile_LLWEAPONEX_ArmCannon_Shoot" or skill == "Projectile_LLWEAPONEX_ArmCannon_Disperse_Explosion" then
			NRD_StatusSetInt(target, handle, "Hit", 1)
			NRD_StatusSetInt(target, handle, "Dodged", 0)
			NRD_StatusSetInt(target, handle, "Missed", 0)
			hitSucceeded = true
		end
		if hitSucceeded and not StringHelpers.IsNullOrEmpty(target) then
			local coverData = PersistentVars.SkillData.ShieldCover.Blocking[target]
			if coverData ~= nil then
				DualShields_Cover_RedirectDamage(target, coverData.Blocker, source, handle)
			end
			local bonuses = MasteryBonusManager.GetMasteryBonuses(source)
			local mainhand = CharacterGetEquippedItem(source, "Weapon")
			local offhand = CharacterGetEquippedItem(source, "Shield")
			if skill == "" and GameHelpers.HitWithWeapon(target, handle, false, false) then
				-- Unarmed
				if UnarmedHelpers.WeaponsAreUnarmed(mainhand, offhand) then
					local unarmedCallback = Listeners.OnHit["LLWEAPONEX_Unarmed"]
					if unarmedCallback ~= nil then
						local status,err = xpcall(unarmedCallback, debug.traceback, target, source, damage, handle, bonuses, "LLWEAPONEX_Unarmed")
						if not status then
							Ext.PrintError("Error calling function for 'Listeners.OnHit':\n", err)
						end
					end
					if damage > 0 and IsPlayer(source) then
						MasterySystem.GrantBasicAttackExperience(source, target, "LLWEAPONEX_Unarmed")
					end
				else
					if damage > 0 and IsPlayer(source) then
						MasterySystem.GrantBasicAttackExperience(source, target)
					end
					for tag,callbacks in pairs(Listeners.OnHit) do
						if #callbacks > 0 and WeaponIsTagged(source,mainhand,tag) or WeaponIsTagged(source,offhand,tag) then
							for i,callback in pairs(callbacks) do
								local status,err = xpcall(callback, debug.traceback, target, source, damage, handle, bonuses, tag)
								if not status then
									Ext.PrintError("Error calling function for 'Listeners.OnHit':\n", err)
								end
							end
						end
					end
				end
				for i,callback in pairs(BasicAttackManager.Listeners.OnHit) do
					local b,err = xpcall(callback, debug.traceback, true, StringHelpers.GetUUID(source), StringHelpers.GetUUID(target), handle, damage)
					if not b then
						Ext.PrintError(err)
					end
				end
			elseif skill ~= "" then
				if IsTagged(source, "LLWEAPONEX_RunicCannonEquipped") == 1 
				and not string.find(skill, "Cannon")
				and IsMeleeWeaponSkill(skill)
				then
					ArmCannon_OnWeaponSkillHit(source, target, skill)
				end
				if IsWeaponSkill(skill) then
					MasterySystem.GrantWeaponSkillExperience(source, target)
					for tag,callbacks in pairs(Listeners.OnWeaponSkillHit) do
						if #callbacks > 0 and WeaponIsTagged(source,mainhand,tag) or WeaponIsTagged(source,offhand,tag) then
							for i,callback in pairs(callbacks) do
								local status,err = xpcall(callback, debug.traceback, target, source, damage, handle, bonuses, tag, skill)
								if not status then
									Ext.PrintError("Error calling function for 'Listeners.OnWeaponSkillHit':\n", err)
								end
							end
						end
					end
				end
			end
		end
	end
end)