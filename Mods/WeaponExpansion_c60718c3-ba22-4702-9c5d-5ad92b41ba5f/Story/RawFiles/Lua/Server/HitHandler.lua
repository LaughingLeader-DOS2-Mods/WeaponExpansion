---@type MessageData
local MessageData = LeaderLib.Classes["MessageData"]

if HitHandler == nil then
	HitHandler = {
		---@type table<string,function>
		OnHitCallbacks = {},
		TotalOnHitCallbacks = 0
	}
end

local totalOnHitCallbacks = 0

HitHandler.RegisterOnHit = function(tag, callback)
	HitHandler.OnHitCallbacks[tag] = callback
	totalOnHitCallbacks = totalOnHitCallbacks + 1
end

local function CanGrantMasteryExperience(target,player)
	if IsTagged(target, "LLDUMMY_TrainingDummy") then
		return true,0.1
	else
		local isSummon = CharacterIsSummon(target) == 1
		local isEnemy = CharacterIsEnemy(target,player) == 1
		local ignoreCharacter = Osi.LeaderLib_Helper_QRY_IgnoreCharacter(target) == true
		local combatID = CombatGetIDForCharacter(player)
		if not isSummon and isEnemy and not ignoreCharacter then
			return true,0.5
		end
	end
	return false,0.0
end

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
	if source ~= nil and CharacterGetEquippedWeapon(source) == nil then
		ScaleUnarmedDamage(source,target,damage,handle)
	end
	if damage > 0 then
		--ConvertArmorDamage(target,handle)
	end
	if HasActiveStatus(target, "LLWEAPONEX_MASTERYBONUS_SHIELD_BLOCK") == 1 then
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
LeaderLib.RegisterListener("OnPrepareHit", OnPrepareHit)

local function WeaponIsTagged(char, weapon, tag)
	if (weapon ~= nil and IsTagged(weapon, tag) == 1) then
		return true
	end
	return false
end

local function GetMasteryBonuses(char)
	local character = Ext.GetCharacter(char)
	local bonuses = {}
	local data = Mastery.Params.Passives
	if data ~= nil and data.Tags ~= nil then
		for tagName,tagData in pairs(data.Tags) do
			if Mastery.HasMasteryRequirement(character, tagName) then
				bonuses[tagData.ID] = true
			end
		end
	end
	return bonuses
end
--- @param target string
--- @param source string
--- @param damage integer
--- @param handle integer
local function OnHit(target,source,damage,handle)
	if source ~= nil then
		if GameHelpers.HitWithWeapon(target, handle, false, true) then
			LeaderLib.PrintDebug("[WeaponExpansion:HitHandler:OnHit] target("..target..") was hit with a weapon from source("..tostring(source)..").")
			if HasActiveStatus(target, "LLWEAPONEX_MASTERYBONUS_VULNERABLE") == 1 then
				RemoveStatus(target, "LLWEAPONEX_MASTERYBONUS_VULNERABLE")
				GameHelpers.ExplodeProjectile(source, target, "Projectile_LLWEAPONEX_MasteryBonus_VulnerableDamage")
			end
			local b,expGain = CanGrantMasteryExperience(target,source)
			if b and expGain > 0 then
				AddMasteryExperienceForAllActive(source, expGain)
			end
			if totalOnHitCallbacks > 0 then
				local bonuses = GetMasteryBonuses(source)
				-- Unarmed
				if CharacterGetEquippedWeapon(source) == nil then
					local unarmedCallback = HitHandler.OnHitCallbacks["LLWEAPONEX_Unarmed"]
					if unarmedCallback ~= nil then
						local status,err = xpcall(unarmedCallback, debug.traceback, target, source, damage, handle, bonuses)
						if not status then
							Ext.PrintError("Error calling function for 'HitHandler.OnHitCallbacks':\n", err)
						end
					end
				else
					local mainhand = CharacterGetEquippedItem(source, "Weapon")
					local offhand = CharacterGetEquippedItem(source, "Shield")
					for tag,callback in pairs(HitHandler.OnHitCallbacks) do
						if WeaponIsTagged(source,mainhand,tag) or WeaponIsTagged(source,offhand,tag) then
							local status,err = xpcall(callback, debug.traceback, target, source, damage, handle, bonuses)
							if not status then
								Ext.PrintError("Error calling function for 'HitHandler.OnHitCallbacks':\n", err)
							end
						end
					end
				end
			end
		end
	end
end
LeaderLib.RegisterListener("OnHit", OnHit)