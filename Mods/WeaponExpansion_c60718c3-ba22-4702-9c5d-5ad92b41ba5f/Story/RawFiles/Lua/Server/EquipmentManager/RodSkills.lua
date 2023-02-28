local self = EquipmentManager

local rodSkills = {
	Air = {"Projectile_LLWEAPONEX_ShootRod_Air", "Projectile_LLWEAPONEX_ShootRod_Air_Offhand"},
	Chaos = {"Projectile_LLWEAPONEX_ShootRod_Chaos", "Projectile_LLWEAPONEX_ShootRod_Chaos_Offhand"},
	Earth = {"Projectile_LLWEAPONEX_ShootRod_Earth", "Projectile_LLWEAPONEX_ShootRod_Earth_Offhand"},
	Fire = {"Projectile_LLWEAPONEX_ShootRod_Fire", "Projectile_LLWEAPONEX_ShootRod_Fire_Offhand"},
	Poison = {"Projectile_LLWEAPONEX_ShootRod_Poison", "Projectile_LLWEAPONEX_ShootRod_Poison_Offhand"},
	Water = {"Projectile_LLWEAPONEX_ShootRod_Water", "Projectile_LLWEAPONEX_ShootRod_Water_Offhand"},
	Magic = {"Projectile_LLWEAPONEX_ShootRod_MagicMissile", "Projectile_LLWEAPONEX_ShootRod_MagicMissile_Offhand"},
}

local uniqueRodSkills = {
	WPN_UNIQUE_LLWEAPONEX_Rod_1H_MagicMissile_A = { "Projectile_LLWEAPONEX_ShootRod_MagicMissile", "Projectile_LLWEAPONEX_ShootRod_MagicMissile_Offhand" },
}

function AddRodSkill(charGUID, itemGUID)
	local character = GameHelpers.GetCharacter(charGUID)
	local item = GameHelpers.GetItem(itemGUID)
	if character and item then
		local itemStat = item.StatsFromName.StatsEntry
		---@cast itemStat +StatEntryWeapon,-StatsObject
		if itemStat.WeaponType ~= "Wand" then
			local mainhandSkill, offhandSkill = nil, nil
			local skills = uniqueRodSkills[itemStat.Name]
			if skills == nil then
				local damageType = itemStat["Damage Type"]
				skills = rodSkills[damageType]
				if skills ~= nil then
					mainhandSkill,offhandSkill = table.unpack(skills)
				end
			else
				mainhandSkill,offhandSkill = table.unpack(skills)
			end
	
			if mainhandSkill ~= nil and offhandSkill ~= nil then
				local slot = GameHelpers.Item.GetEquippedSlot(character,item)
				if slot == "Weapon" then
					CharacterAddSkill(charGUID, mainhandSkill, 0)
					SetVarFixedString(item.MyGuid, "LLWEAPONEX_Rod_ShootSkill", mainhandSkill)
				elseif slot == "Shield" then
					CharacterAddSkill(charGUID, offhandSkill, 0)
					SetVarFixedString(item.MyGuid, "LLWEAPONEX_Rod_ShootSkill", offhandSkill)
				else
					CharacterRemoveSkill(charGUID, mainhandSkill)
					CharacterRemoveSkill(charGUID, offhandSkill)
				end
			end
		end
	end
end

local function WeaponHasRodSkill(weapon, skill)
	if weapon ~= nil and GetVarFixedString(weapon, "LLWEAPONEX_Rod_ShootSkill") == skill then
		return true
	end
	return false
end

function RemoveRodSkill(char, item)
	local skill = GetVarFixedString(item, "LLWEAPONEX_Rod_ShootSkill")
	if not StringHelpers.IsNullOrEmpty(skill) then
		local mainhand = CharacterGetEquippedItem(char, "Weapon")
		local offhand = CharacterGetEquippedItem(char, "Shield")
		if not WeaponHasRodSkill(mainhand, skill) and not WeaponHasRodSkill(offhand, skill) then
			CharacterRemoveSkill(char, skill)
		end
	end
end

EquipmentManager.Events.EquipmentChanged:Subscribe(function (e)
	if e.Equipped then
		AddRodSkill(e.Character, e.Item)
	else
		RemoveRodSkill(e.Character, e.Item)
	end
end, {MatchArgs={Tag="LLWEAPONEX_Rod"}})

Timer.Subscribe("LeaderLib_Timers_PresetMenu_OnPresetApplied", function (e)
	if e.Data.Object and e.Data.Object:HasTag("LLWEAPONEX_Rod_Equipped") then
		Osi.LeaderLib_Helper_RefreshWeapons(e.Data.UUID)
	end
end)