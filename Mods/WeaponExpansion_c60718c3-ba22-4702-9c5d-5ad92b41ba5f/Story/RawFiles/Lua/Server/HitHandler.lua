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
--- @param data HitPrepareData
local function OnPrepareHit(target,source,damage,handle,data)
	if not StringHelpers.IsNullOrEmpty(source) then
		if data.TotalDamageDone > 0 and data:Succeeded() then
			if ObjectGetFlag(target, "LLWEAPONEX_MasteryBonus_RushProtection") == 1 and data.HitType == "Surface" then
				data.Blocked = true
				data:ClearAllDamage()
				Osi.LeaderLib_Timers_StartObjectTimer(target, 750, "Timers_LLWEAPONEX_ResetDualShieldsRushProtection", "LLWEAPONEX_ResetDualShieldsRushProtection")
				return
			end

			if HasActiveStatus(target, "LLWEAPONEX_MASTERYBONUS_SHIELD_BLOCK") == 1 and NRD_HitGetInt(handle, "HitType") < 4 then
				data.Blocked = true
				data:ClearAllDamage()
				RemoveStatus(target, "LLWEAPONEX_MASTERYBONUS_SHIELD_BLOCK")
				local blockedText = Ext.GetTranslatedString("h175f5a66g78d1g41a8g9530g004e19a5db8a", "Blocked!")
				CharacterStatusText(target, string.format("<font color='#CCFF00'>%s</font>", blockedText))
				return
			end

			local coverData = PersistentVars.SkillData.ShieldCover.Blocking[target]
			if coverData ~= nil and coverData.CanCounterAttack == true then
				local blocker = coverData.Blocker
				if blocker ~= nil 
				and CharacterIsDead(blocker) == 0
				and CharacterIsEnemy(blocker, source) == 1
				and CharacterCanSee(blocker, source) == 1
				and NRD_HitGetInt(handle, "HitType") <= 3 then -- Everything but Surface,DoT,Reflected
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

			if ObjectIsCharacter(source) == 1 then
				if UnarmedHelpers.HasUnarmedWeaponStats(Ext.GetCharacter(source).Stats) then
					UnarmedHelpers.ScaleUnarmedHitDamage(source,target,damage,handle)
				end
			end

			if HasActiveStatus(source, "LLWEAPONEX_MURAMASA_CURSE") == 1 then
				--Muramasa bonus of increasing crit damage with missing vitality percentage
				local isCrit = data.Backstab or data.CriticalHit
				if isCrit then
					local max = Ext.ExtraData.LLWEAPONEX_Muramasa_MaxCriticalDamageIncrease or 50
					local damageBoost = (((100 - CharacterGetHitpointsPercentage(source))/100) * max)/100
					GameHelpers.Damage.IncreaseDamage(target, source, handle, damageBoost, true)
				end
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

local armCannonSkills = {
	Zone_LLWEAPONEX_ArmCannon_Disperse = true,
	Projectile_LLWEAPONEX_ArmCannon_Shoot = true,
	Projectile_LLWEAPONEX_ArmCannon_Disperse_Explosion = true,
}

--- @param target EsvCharacter|EsvItem
--- @param source EsvCharacter|EsvItem
--- @param data HitData
RegisterListener("StatusHitEnter", function(target, source, data)
	-- if Vars.DebugMode then
	-- 	fprint("[LLWEAPONEX:OnHit] skill(%s) target.MyGuid(%s) source.MyGuid(%s)", NRD_StatusGetString(target.MyGuid, handle, "SkillId"), target.MyGuid, source.MyGuid)
	-- end
	if source then
		local sourceIsPlayer = IsPlayer(source.MyGuid)
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
		if data.SkillData and armCannonSkills[skill] then
			data:SetHitFlag("Hit", true)
			data:SetHitFlag({"Dodged", "Missed"}, false)
			hitSucceeded = true
		end

		if hitSucceeded and not StringHelpers.IsNullOrEmpty(target.MyGuid) then
			local coverData = PersistentVars.SkillData.ShieldCover.Blocking[target.MyGuid]
			if coverData ~= nil then
				DualShields_Cover_RedirectDamage(target.MyGuid, coverData.Blocker, source.MyGuid, data.HitStatus.StatusHandle)
			end
			local bonuses = MasteryBonusManager.GetMasteryBonuses(source)
			if not data.SkillData and data:IsFromWeapon() then
				local mainhand = CharacterGetEquippedItem(source.MyGuid, "Weapon")
				local offhand = CharacterGetEquippedItem(source.MyGuid, "Shield")
				-- Unarmed
				if UnarmedHelpers.WeaponsAreUnarmed(mainhand, offhand) then
					if data.Damage > 0 and sourceIsPlayer then
						MasterySystem.GrantBasicAttackExperience(source.MyGuid, target.MyGuid, "LLWEAPONEX_Unarmed")
					end
				else
					if data.Damage > 0 and sourceIsPlayer then
						MasterySystem.GrantBasicAttackExperience(source.MyGuid, target.MyGuid)
					end
				end
				AttackManager.InvokeOnHit(true, source, target, data.Damage, data, bonuses, false)
			elseif skill then
				if GameHelpers.CharacterOrEquipmentHasTag(source, "LLWEAPONEX_RunicCannonEquipped")
				and not armCannonSkills[skill]
				and IsMeleeWeaponSkill(skill)
				then
					ArmCannon_OnWeaponSkillHit(source.MyGuid, target.MyGuid, skill)
				end
				if IsWeaponSkill(data.SkillData) then
					MasterySystem.GrantWeaponSkillExperience(source.MyGuid, target.MyGuid)
					AttackManager.InvokeOnHit(true, source, target, data.Damage, data, bonuses, true)
				end
			end
		end
	end
end)