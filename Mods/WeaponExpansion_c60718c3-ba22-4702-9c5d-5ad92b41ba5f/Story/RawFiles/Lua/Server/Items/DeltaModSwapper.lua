local itemDeltaMods = {}

local DeltamodSwap = {}

local runebladeDamageBoosts = {
	LLWEAPONEX_Runeblade_Air = {
		Small = "Boost_Weapon_Damage_Air_Small_Sword",
		Medium = "Boost_Weapon_Damage_Air_Medium_Sword",
		Large = "Boost_Weapon_Damage_Air_Large_Sword",
		Default = "Boost_Weapon_Damage_Air_Sword",
	},
	LLWEAPONEX_Runeblade_Chaos = {
		Small = "Boost_LLWEAPONEX_Weapon_Damage_Chaos_Small",
		Medium = "Boost_LLWEAPONEX_Weapon_Damage_Chaos_Medium",
		Large = "Boost_LLWEAPONEX_Weapon_Damage_Chaos_Large",
		Default = "Boost_LLWEAPONEX_Weapon_Damage_Chaos",
	},
	LLWEAPONEX_Runeblade_Earth = {
		Small = "Boost_Weapon_Damage_Earth_Small_Sword",
		Medium = "Boost_Weapon_Damage_Earth_Medium_Sword",
		Large = "Boost_Weapon_Damage_Earth_Large_Sword",
		Default = "Boost_Weapon_Damage_Earth_Sword",
	},
	LLWEAPONEX_Runeblade_Fire = {
		Small = "Boost_Weapon_Damage_Fire_Small_Sword",
		Medium = "Boost_Weapon_Damage_Fire_Medium_Sword",
		Large = "Boost_Weapon_Damage_Fire_Large_Sword",
		Default = "Boost_Weapon_Damage_Fire_Sword",
	},
	LLWEAPONEX_Runeblade_Poison = {
		Small = "Boost_Weapon_Damage_Poison_Small_Sword",
		Medium = "Boost_Weapon_Damage_Poison_Medium_Sword",
		Large = "Boost_Weapon_Damage_Poison_Large_Sword",
		Default = "Boost_Weapon_Damage_Poison_Sword",
	},
	LLWEAPONEX_Runeblade_Water = {
		Small = "Boost_Weapon_Damage_Water_Small_Sword",
		Medium = "Boost_Weapon_Damage_Water_Medium_Sword",
		Large = "Boost_Weapon_Damage_Water_Large_Sword",
		Default = "Boost_Weapon_Damage_Water_Sword",
	},
}

local function GetRunebladeDamageBoost(item, deltamod)
	for tag,boosts in pairs(runebladeDamageBoosts) do
		if IsTagged(item, tag) == 1 then
			for boostWord,replacement in pairs(boosts) do
				if string.find(deltamod,boostWord) then
					return replacement
				end
			end
			return boosts.Default
		end
	end
end
DeltamodSwap.LLWEAPONEX_Runeblade = {
	Boost_Weapon_Primary_Strength = "Boost_Weapon_Primary_Intelligence",
	Boost_Weapon_Primary_Strength_Medium = "Boost_Weapon_Primary_Intelligence_Medium",
	Boost_Weapon_Damage_Air_Large_Sword = GetRunebladeDamageBoost,
	Boost_Weapon_Damage_Air_Medium_Sword = GetRunebladeDamageBoost,
	Boost_Weapon_Damage_Air_Small_Sword = GetRunebladeDamageBoost,
	Boost_Weapon_Damage_Air_Sword = GetRunebladeDamageBoost,
	Boost_Weapon_Damage_ArmourPiercing_Small_Sword = GetRunebladeDamageBoost,
	Boost_Weapon_Damage_Earth_Large_Sword = GetRunebladeDamageBoost,
	Boost_Weapon_Damage_Earth_Medium_Sword = GetRunebladeDamageBoost,
	Boost_Weapon_Damage_Earth_Small_Sword = GetRunebladeDamageBoost,
	Boost_Weapon_Damage_Earth_Sword = GetRunebladeDamageBoost,
	Boost_Weapon_Damage_Fire_Large_Sword = GetRunebladeDamageBoost,
	Boost_Weapon_Damage_Fire_Medium_Sword = GetRunebladeDamageBoost,
	Boost_Weapon_Damage_Fire_Small_Sword = GetRunebladeDamageBoost,
	Boost_Weapon_Damage_Fire_Sword = GetRunebladeDamageBoost,
	Boost_Weapon_Damage_Poison_Large_Sword = GetRunebladeDamageBoost,
	Boost_Weapon_Damage_Poison_Medium_Sword = GetRunebladeDamageBoost,
	Boost_Weapon_Damage_Poison_Small_Sword = GetRunebladeDamageBoost,
	Boost_Weapon_Damage_Poison_Sword = GetRunebladeDamageBoost,
	Boost_Weapon_Damage_Water_Large_Sword = GetRunebladeDamageBoost,
	Boost_Weapon_Damage_Water_Medium_Sword = GetRunebladeDamageBoost,
	Boost_Weapon_Damage_Water_Small_Sword = GetRunebladeDamageBoost,
	Boost_Weapon_Damage_Water_Sword = GetRunebladeDamageBoost,
	--Boost_Weapon_Primary_Strength_PrimaryAsLarge = "Boost_Weapon_Primary_Intelligence_PrimaryAsLarge",
	--Boost_Weapon_Primary_Strength_Medium_PrimaryAsLarge = "Boost_Weapon_Primary_Intelligence_Medium_PrimaryAsLarge",
}

local rodDamageBoosts = {
	Air = {
		Small = "Boost_Weapon_Damage_Air_Small_Club",
		Medium = "Boost_Weapon_Damage_Air_Medium_Club",
		Large = "Boost_Weapon_Damage_Air_Large_Club",
		Default = "Boost_Weapon_Damage_Air_Club",
	},
	Chaos = {
		Small = "Boost_LLWEAPONEX_Weapon_Damage_Chaos_Small",
		Medium = "Boost_LLWEAPONEX_Weapon_Damage_Chaos_Medium",
		Large = "Boost_LLWEAPONEX_Weapon_Damage_Chaos_Large",
		Default = "Boost_LLWEAPONEX_Weapon_Damage_Chaos",
	},
	Earth = {
		Small = "Boost_Weapon_Damage_Earth_Small_Club",
		Medium = "Boost_Weapon_Damage_Earth_Medium_Club",
		Large = "Boost_Weapon_Damage_Earth_Large_Club",
		Default = "Boost_Weapon_Damage_Earth_Club",
	},
	Fire = {
		Small = "Boost_Weapon_Damage_Fire_Small_Club",
		Medium = "Boost_Weapon_Damage_Fire_Medium_Club",
		Large = "Boost_Weapon_Damage_Fire_Large_Club",
		Default = "Boost_Weapon_Damage_Fire_Club",
	},
	Poison = {
		Small = "Boost_Weapon_Damage_Poison_Small_Club",
		Medium = "Boost_Weapon_Damage_Poison_Medium_Club",
		Large = "Boost_Weapon_Damage_Poison_Large_Club",
		Default = "Boost_Weapon_Damage_Poison_Club",
	},
	Water = {
		Small = "Boost_Weapon_Damage_Water_Small_Club",
		Medium = "Boost_Weapon_Damage_Water_Medium_Club",
		Large = "Boost_Weapon_Damage_Water_Large_Club",
		Default = "Boost_Weapon_Damage_Water_Club",
	},
}

local function GetRodDamageBoost(item, deltamod)
	local stat = NRD_ItemGetStatsId(item)
	for damageType,boosts in pairs(rodDamageBoosts) do
		if string.find(stat, damageType) then
			for boostWord,replacement in pairs(boosts) do
				if string.find(deltamod,boostWord) then
					return replacement
				end
			end
			return boosts.Default
		end
	end
end
DeltamodSwap.LLWEAPONEX_Rod = {
	Boost_Weapon_Primary_Strength_Club = "Boost_Weapon_Primary_Intelligence",
	Boost_Weapon_Primary_Strength_Medium_Club = "Boost_Weapon_Primary_Intelligence_Medium",
	Boost_Weapon_Damage_Air_Large_Club = GetRodDamageBoost,
	Boost_Weapon_Damage_Air_Medium_Club = GetRodDamageBoost,
	Boost_Weapon_Damage_Air_Small_Club = GetRodDamageBoost,
	Boost_Weapon_Damage_Air_Club = GetRodDamageBoost,
	Boost_Weapon_Damage_ArmourPiercing_Small_Club = GetRodDamageBoost,
	Boost_Weapon_Damage_Earth_Large_Club = GetRodDamageBoost,
	Boost_Weapon_Damage_Earth_Medium_Club = GetRodDamageBoost,
	Boost_Weapon_Damage_Earth_Small_Club = GetRodDamageBoost,
	Boost_Weapon_Damage_Earth_Club = GetRodDamageBoost,
	Boost_Weapon_Damage_Fire_Large_Club = GetRodDamageBoost,
	Boost_Weapon_Damage_Fire_Medium_Club = GetRodDamageBoost,
	Boost_Weapon_Damage_Fire_Small_Club = GetRodDamageBoost,
	Boost_Weapon_Damage_Fire_Club = GetRodDamageBoost,
	Boost_Weapon_Damage_Poison_Large_Club = GetRodDamageBoost,
	Boost_Weapon_Damage_Poison_Medium_Club = GetRodDamageBoost,
	Boost_Weapon_Damage_Poison_Small_Club = GetRodDamageBoost,
	Boost_Weapon_Damage_Poison_Club = GetRodDamageBoost,
	Boost_Weapon_Damage_Water_Large_Club = GetRodDamageBoost,
	Boost_Weapon_Damage_Water_Medium_Club = GetRodDamageBoost,
	Boost_Weapon_Damage_Water_Small_Club = GetRodDamageBoost,
	Boost_Weapon_Damage_Water_Club = GetRodDamageBoost,
}

local function GetQuarterstaffAttributeBoost(item, deltamod)
	local stat = NRD_ItemGetStatsId(item)
	local requirements = Ext.StatGetAttribute(stat, "Requirements")
	if requirements ~= nil then
		for i,entry in pairs(requirements) do
			if entry.Param == "Finesse" then
				return "Boost_Weapon_Primary_Finesse_Medium"
			end
		end
	end
	return "Boost_Weapon_Primary_Strength_Medium"
end
DeltamodSwap.LLWEAPONEX_Quarterstaff = {
	Boost_Weapon_Ability_FireSpecialist_Staff = "Boost_Weapon_Ability_WarriorLore_Spear",
	Boost_Weapon_Ability_WaterSpecialist_Staff = "Boost_Weapon_Ability_WarriorLore_Spear",
	Boost_Weapon_Ability_AirSpecialist_Staff = "Boost_Weapon_Ability_WarriorLore_Spear",
	Boost_Weapon_Ability_EarthSpecialist_Staff = "Boost_Weapon_Ability_WarriorLore_Spear",
	Boost_Weapon_Ability_Necromancy_Staff = "Boost_Weapon_Ability_WarriorLore_Spear",
	Boost_Weapon_Ability_Summoning_Staff = "Boost_Weapon_Ability_WarriorLore_Spear",
	Boost_Weapon_Primary_Intelligence_Medium = GetQuarterstaffAttributeBoost,
}

DeltamodSwap.LLWEAPONEX_Firearm = {
	-- Larian has this and the crossbow ones reversed on the weapon type value
	Boost_Weapon_Primary_Finesse_Medium_Bow = "Boost_LLWEAPONEX_Weapon_Primary_Wits_Medium",
	Boost_Weapon_Primary_Finesse_Medium_Crossbow = "Boost_LLWEAPONEX_Weapon_Primary_Wits_Medium"
}

function GetDeltamods(item)
	NRD_ItemIterateDeltaModifiers(item, "LLWEAPONEX_Iterator_GetDeltamod")
end

function SaveDeltamod(item, deltamod, isGenerated)
	if itemDeltaMods[item] == nil then
		itemDeltaMods[item] = {DeltaMods = {}, Swapped = false}
	end
	local itemEntry = itemDeltaMods[item]
	local canAdd = true
	for tag,deltamods in pairs(DeltamodSwap) do
		if IsTagged(item, tag) == 1 then
			local replacement = deltamods[deltamod]
			if replacement ~= nil then
				if replacement == "" then
					print("Disabled deltamod",deltamod,item)
					canAdd = false
					itemEntry.Swapped = true
				elseif type(replacement) == "function" then
					local b,replacementVal = pcall(replacement, item, deltamod)
					if b then
						print("Swapped deltamod",deltamod,"for",replacementVal,item)
						deltamod = replacementVal
					else
						canAdd = false
					end
					itemEntry.Swapped = true
				else
					print("Swapped deltamod",deltamod,"for",replacement,item)
					deltamod = replacement
					itemEntry.Swapped = true
				end
			end
		end
	end
	--table.insert(itemDeltaMods[item], deltamod)
	itemEntry.DeltaMods[deltamod] = canAdd
end

function SwapDeltamods(item,baseStat,itemType,rarity,level,seed)
	if ObjectGetFlag(item, "LLWEAPONEX_ProcessedDeltamods") == 0 then
		if baseStat == nil then
			---@type EsvItem
			local itemObject = Ext.GetItem(item)
			---@type StatItem
			local itemStatObject = itemObject.Stats
			baseStat = itemStatObject.Name
			itemType = itemObject.ItemType
			rarity = itemStatObject.ItemTypeReal
			level = itemStatObject.Level
			--baseStat,itemType,rarity,level,seed = NRD_ItemGetGenerationParams(item)
		end
		local stat = NRD_ItemGetStatsId(item)
		if StringHelpers.IsNullOrEmpty(rarity) then
			rarity = GetVarFixedString(item, "LeaderLib_Rarity")
			if StringHelpers.IsNullOrEmpty(rarity) then
				SetStoryEvent(item, "LeaderLib_Commands_SetItemVariables")
			end
		end
		if StringHelpers.IsNullOrEmpty(itemType) then
			itemType = Ext.StatGetAttribute(stat, "type")
		end
		if rarity ~= nil and rarity ~= "Common" and rarity ~= "Unique" then
			if itemDeltaMods[item] == nil then
				NRD_ItemIterateDeltaModifiers(item, "LLWEAPONEX_Iterator_GetDeltamod")
			end
			local itemEntry = itemDeltaMods[item]
			if itemEntry ~= nil then
				if itemEntry.Swapped == true then
					if level == nil then
						level = NRD_ItemGetInt(item, "LevelOverride")
						if level == 0 or level == nil then
							level = CharacterGetLevel(CharacterGetHostCharacter())
						end
					end

					local isIdentified = NRD_ItemGetInt(item, "IsIdentified")
					if isIdentified == nil then
						isIdentified = 1
					end

					--print("SwapDeltamods", Ext.JsonStringify(itemEntry.DeltaMods))
					local deltamods = itemEntry.DeltaMods
					if deltamods ~= nil then
						NRD_ItemCloneBegin(item)
						-- for deltamod,b in pairs(deltamods) do
						-- 	if b == true then
						-- 		NRD_ItemCloneAddBoost("DeltaMod", deltamod)
						-- 	end
						local damageTypeString = Ext.StatGetAttribute(stat, "Damage Type")
						if damageTypeString == nil then damageTypeString = "Physical" end
						local damageTypeEnum = LeaderLib.Data.DamageTypeEnums[damageTypeString]
						NRD_ItemCloneSetInt("DamageTypeOverwrite", damageTypeEnum)

						NRD_ItemCloneSetString("GenerationStatsId", stat)
						NRD_ItemCloneSetString("StatsEntryName", stat)
						NRD_ItemCloneSetInt("HasGeneratedStats", 0)
						NRD_ItemCloneSetInt("GenerationLevel", level)
						NRD_ItemCloneSetInt("StatsLevel", level)
						NRD_ItemCloneSetInt("IsIdentified", isIdentified)
						NRD_ItemCloneSetString("ItemType", rarity)
						NRD_ItemCloneSetString("GenerationItemType", rarity)

						local clone = NRD_ItemClone()
						RollForBonusSkill(clone, stat, itemType, rarity)
						ObjectSetFlag(clone, "LLWEAPONEX_ProcessedDeltamods", 0)
						SetVarFixedString(item, "LeaderLib_Rarity", rarity)
						SetVarInteger(item, "LeaderLib_Level", level)
						for deltamod,b in pairs(deltamods) do
							if b == true then
								ItemAddDeltaModifier(clone, deltamod)
								LeaderLib.PrintDebug("[WeaponExpansion:SwapDeltamods] Added deltamod", deltamod, "to item clone",clone)
							end
						end

						local inventory = GetInventoryOwner(item)
						local slot = nil
						if ObjectIsCharacter(inventory) == 1 then
							slot = GameHelpers.GetEquippedSlot(inventory,item)
						end
						if inventory ~= nil then
							if slot ~= nil then
								GameHelpers.EquipInSlot(inventory, clone, slot)
							else
								ItemToInventory(clone, inventory, 1, 0, 0)
							end
						end
						ItemRemove(item)
						--NRD_ItemIterateDeltaModifiers(clone, "LLWEAPONEX_Debug_PrintDeltamod")
					end
				else
					ObjectSetFlag(item, "LLWEAPONEX_ProcessedDeltamods", 0)
					if RollForBonusSkill(item, stat, itemType, rarity) then
						NRD_ItemCloneBegin(item)
						local damageTypeString = Ext.StatGetAttribute(stat, "Damage Type")
						if damageTypeString == nil then damageTypeString = "Physical" end
						local damageTypeEnum = LeaderLib.Data.DamageTypeEnums[damageTypeString]
						NRD_ItemCloneSetInt("DamageTypeOverwrite", damageTypeEnum)
						local clone = NRD_ItemClone()
						local inventory = GetInventoryOwner(item)
						local slot = nil
						if ObjectIsCharacter(inventory) == 1 then
							slot = GameHelpers.GetEquippedSlot(inventory,item)
						end
						if inventory ~= nil then
							if slot ~= nil then
								GameHelpers.EquipInSlot(inventory, clone, slot)
							else
								ItemToInventory(clone, inventory, 1, 0, 0)
							end
						end
						ItemRemove(item)
					end
				end
			else
				ObjectSetFlag(item, "LLWEAPONEX_ProcessedDeltamods", 0)
				--print("Skipping deltamod swap for",item)
			end
			itemDeltaMods[item] = nil
		else
			ObjectSetFlag(item, "LLWEAPONEX_ProcessedDeltamods", 0)
		end
	end
end

if Ext.IsDeveloperMode() then
	Ext.RegisterConsoleCommand("swapdeltamods", function(command)
		local host = CharacterGetHostCharacter()
		local weapon = CharacterGetEquippedWeapon(host)
		if weapon ~= nil then
			SwapDeltamods(weapon)
		end
	end)
end

-- TODO: More generalized attribute boost swapping?
-- local attributeBoosts = {
-- 	Strength = {
-- 		"Boost_Weapon_Primary_Strength",
-- 		"Boost_Weapon_Primary_Strength_Axe",
-- 		"Boost_Weapon_Primary_Strength_Axe_Legendary",
-- 		"Boost_Weapon_Primary_Strength_Axe_PrimaryAsSmall",
-- 		"Boost_Weapon_Primary_Strength_Club",
-- 		"Boost_Weapon_Primary_Strength_Club_Legendary",
-- 		"Boost_Weapon_Primary_Strength_Club_PrimaryAsSmall",
-- 		"Boost_Weapon_Primary_Strength_Medium",
-- 		"Boost_Weapon_Primary_Strength_Medium_Axe",
-- 		"Boost_Weapon_Primary_Strength_Medium_Club",
-- 		"Boost_Weapon_Primary_Strength_Medium_PrimaryAsLarge",
-- 		"Boost_Weapon_Primary_Strength_PrimaryAsLarge",
-- 		"Boost_Weapon_Primary_Strength_Sword_Legendary",
-- 		"Boost_Weapon_Primary_Strength_Sword_PrimaryAsSmall",
-- 	},
-- 	Finesse = {
-- 		"Boost_Weapon_Primary_Finesse",
-- 		"Boost_Weapon_Primary_Finesse_Bow_Legendary",
-- 		"Boost_Weapon_Primary_Finesse_Bow_PrimaryAsSmall",
-- 		"Boost_Weapon_Primary_Finesse_Crossbow_Legendary",
-- 		"Boost_Weapon_Primary_Finesse_Crossbow_PrimaryAsSmall",
-- 		"Boost_Weapon_Primary_Finesse_Knife_Legendary",
-- 		"Boost_Weapon_Primary_Finesse_Knife_PrimaryAsSmall",
-- 		"Boost_Weapon_Primary_Finesse_Medium",
-- 		"Boost_Weapon_Primary_Finesse_Medium_Bow",
-- 		"Boost_Weapon_Primary_Finesse_Medium_Crossbow",
-- 		"Boost_Weapon_Primary_Finesse_Medium_PrimaryAsLarge",
-- 		"Boost_Weapon_Primary_Finesse_PrimaryAsLarge",
-- 		"Boost_Weapon_Primary_Finesse_Spear_Legendary",
-- 		"Boost_Weapon_Primary_Finesse_Spear_PrimaryAsSmall",
-- 	},
-- 	Intelligence = {
-- 		"Boost_Weapon_Primary_Intelligence",
-- 		"Boost_Weapon_Primary_Intelligence_Medium",
-- 		"Boost_Weapon_Primary_Intelligence_Medium_PrimaryAsLarge",
-- 		"Boost_Weapon_Primary_Intelligence_PrimaryAsLarge",
-- 		"Boost_Weapon_Primary_Intelligence_Staff_Legendary",
-- 		"Boost_Weapon_Primary_Intelligence_Staff_PrimaryAsNormal",
-- 		"Boost_Weapon_Primary_Intelligence_Staff_PrimaryAsSmall",
-- 		"Boost_Weapon_Primary_Intelligence_Wand_Legendary",
-- 		"Boost_Weapon_Primary_Intelligence_Wand_PrimaryAsNormal",
-- 		"Boost_Weapon_Primary_Intelligence_Wand_PrimaryAsSmall",
-- 	},
-- 	Wits = {
-- 		"Boost_LLWEAPONEX_Weapon_Primary_Wits",
-- 		"Boost_LLWEAPONEX_Weapon_Primary_Wits_Medium",
-- 		"Boost_LLWEAPONEX_Weapon_Primary_Wits_Large",
-- 	},
-- }

-- local function SwapAttributeBoosts(item, deltamods)
-- 	local stat = NRD_ItemGetStatsId(item)
-- 	local requirements = Ext.StatGetAttribute(stat, "Requirements")
-- 	local primaryAttribute = nil
-- 	if requirements ~= nil then
-- 		local largestRequirement = 0
-- 		for i,requirement in pairs(requirements) do
-- 			local reqName = requirement.Requirement
-- 			if not requirement.Not and requirement.Param > largestRequirement and
-- 				(reqName == "Strength" or reqName == "Finesse" or reqName == "Constitution" or
-- 				reqName == "Memory" or reqName == "Wits") then
-- 				primaryAttribute = reqName
-- 				largestRequirement = requirement.Param
-- 			end
-- 		end
-- 	end
-- 	if primaryAttribute ~= nil then
-- 		for attribute,deltamods in pairs(attributeBoosts) do
-- 			if attribute ~= primaryAttribute then
-- 				for i,entry in pairs(deltamods) do
-- 					if deltamods[entry] == true then

-- 					end
-- 				end
-- 			end
-- 		end
-- 	end
-- end