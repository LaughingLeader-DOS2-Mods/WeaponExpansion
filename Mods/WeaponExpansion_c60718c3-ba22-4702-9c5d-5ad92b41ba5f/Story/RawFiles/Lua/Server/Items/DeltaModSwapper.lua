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
DeltamodSwap.LLWEAPONEX_Banner = DeltamodSwap.LLWEAPONEX_Quarterstaff

DeltamodSwap.LLWEAPONEX_Firearm = {
	-- Larian has this and the crossbow ones reversed on the weapon type value
	Boost_Weapon_Primary_Finesse_Medium_Bow = "Boost_LLWEAPONEX_Weapon_Primary_Wits_Medium",
	Boost_Weapon_Primary_Finesse_Medium_Crossbow = "Boost_LLWEAPONEX_Weapon_Primary_Wits_Medium"
}

local PistolReplacementMediumAbilityBoosts = {
	"Boost_Armor_Belt_Ability_Hunting",
	"Boost_Armor_Belt_Ability_Rogues",
	"Boost_Armor_Belt_Ability_Warfare",
}

local PistolReplacementLargeAbilityBoosts = {
	"Boost_Armor_Belt_Ability_Hunting_Large",
	"Boost_Armor_Belt_Ability_Hunting_Medium",
	"Boost_Armor_Belt_Ability_Rogues_Large",
	"Boost_Armor_Belt_Ability_Rogues_Medium",
	"Boost_Armor_Belt_Ability_Warfare_Large",
	"Boost_Armor_Belt_Ability_Warfare_Medium",
}

local PistolReplacementCivilBoosts = {
	"Boost_Armor_Belt_Ability_Lockpicking_Medium",
	"Boost_Armor_Belt_Ability_Luck_Medium",
	"Boost_Armor_Belt_Ability_Sneaking_Medium",
	"Boost_Armor_Belt_Ability_Telekinesis_Medium"
}

local PistolReplacementBoosts = {
	"Boost_Armor_Belt_Secondary_CriticalChance_Medium",
	"Boost_Armor_Belt_Secondary_CriticalChance_Small",
}

local function GetRandomPistolAbilityBoost(item, deltamod)
	return Common.GetRandomTableEntry(PistolReplacementMediumAbilityBoosts)
end

local function GetRandomPistolLargeAbilityBoost(item, deltamod)
	return Common.GetRandomTableEntry(PistolReplacementLargeAbilityBoosts)
end

local function GetRandomPistolCivilBoost(item, deltamod)
	return Common.GetRandomTableEntry(PistolReplacementCivilBoosts)
end

DeltamodSwap.LLWEAPONEX_Pistol = {
	Boost_Armor_Belt_Armour_Physical = "Boost_Armor_Belt_Secondary_CriticalChance_Small",
	Boost_Armor_Belt_Armour_Physical_Medium = "Boost_Armor_Belt_Secondary_CriticalChance_Medium",
	Boost_Armor_Belt_Armour_Physical_Large = "Boost_Armor_Belt_Secondary_CriticalChance_Medium",
	Boost_Armor_Belt_Ability_PainReflection = GetRandomPistolAbilityBoost,
	Boost_Armor_Belt_Ability_PainReflection_Large = GetRandomPistolLargeAbilityBoost,
	Boost_Armor_Belt_Ability_Perseverance = GetRandomPistolAbilityBoost,
	Boost_Armor_Belt_Ability_Perseverance_Large = GetRandomPistolLargeAbilityBoost,
	Boost_Armor_Belt_Primary_Constitution = GetRandomPistolCivilBoost,
	Boost_Armor_Belt_Primary_Constitution_Large = GetRandomPistolCivilBoost,
	Boost_Armor_Belt_Secondary_Vitality = "Boost_Armor_Belt_Secondary_CriticalChance_Small",
	Boost_Armor_Belt_Secondary_Vitality_Large = "Boost_Armor_Belt_Secondary_CriticalChance_Small",
}

---@param item EsvItem
---@return table<string,boolean>
local function GetAllBoosts(item)
	local finalBoosts = {}
	local swapped = false

	local boostType = "DeltaMod"

	for i,v in pairs(item:GetGeneratedBoosts()) do
		for tag,deltamods in pairs(DeltamodSwap) do
			if item:HasTag(tag) then
				local replacement = deltamods[v]
				if replacement ~= nil then
					if replacement == "" then
						printd("Disabled deltamod",v,item)
						swapped = true
					elseif type(replacement) == "function" then
						local b,replacementVal = pcall(replacement, item, v)
						if b then
							printd("Swapped deltamod",v,"for",replacementVal,item)
							finalBoosts[replacementVal] = boostType
							swapped = true
						end
					else
						printd("Swapped deltamod",v,"for",replacement,item)
						finalBoosts[replacement] = boostType
						swapped = true
					end
				else
					finalBoosts[v] = boostType
				end
			end
		end
	end

	for i,deltamodName in pairs(item:GetDeltaMods()) do
		local deltamodData = Ext.GetDeltaMod(deltamodName, item.ItemType)
		if deltamodData ~= nil then
			for i2,boostEntry in pairs(deltamodData.Boosts) do
				local v = boostEntry.Boost
				if finalBoosts[v] ~= true then
					for tag,deltamods in pairs(DeltamodSwap) do
						if item:HasTag(tag) then
							local replacement = deltamods[v]
							printd(v, replacement)
							if replacement ~= nil then
								if replacement == "" then
									printd("Disabled deltamod",v,item)
									swapped = true
								elseif type(replacement) == "function" then
									local b,replacementVal = pcall(replacement, item, v)
									if b then
										printd("Swapped deltamod",v,"for",replacementVal,item)
										finalBoosts[replacementVal] = boostType
										swapped = true
									end
								else
									printd("Swapped deltamod",v,"for",replacement,item)
									finalBoosts[replacement] = boostType
									swapped = true
								end
							else
								finalBoosts[v] = boostType
							end
						end
					end
				end
			end
		end
	end
	if swapped then
		return finalBoosts
	else
		return nil
	end
end

---@param item string
function SwapDeltaMods(item)
	if ObjectExists(item) == 1 and ObjectGetFlag(item, "LLWEAPONEX_ProcessedDeltamods") == 0 then
		---@type EsvItem
		local itemObject = Ext.GetItem(item)

		if itemObject.Stats == nil then
			ObjectSetFlag(item, "LLWEAPONEX_ProcessedDeltamods", 0)
			return
		end

		local stat,itemType,rarity,level = nil
		stat = itemObject.StatsId
		---@type StatItem
		local itemStatObject = itemObject.Stats
		itemType = itemObject.ItemType
		if itemStatObject ~= nil then
			rarity = itemStatObject.ItemTypeReal
			level = itemStatObject.Level
		end

		if StringHelpers.IsNullOrEmpty(rarity) then
			rarity = GetVarFixedString(item, "LeaderLib_Rarity")
			if StringHelpers.IsNullOrEmpty(rarity) then
				SetStoryEvent(item, "LeaderLib_Commands_SetItemVariables")
			end
		end
		if rarity ~= nil and rarity ~= "Common" and rarity ~= "Unique" then
			if level == nil then
				level = NRD_ItemGetInt(item, "LevelOverride")
				if level == 0 or level == nil then
					level = CharacterGetLevel(CharacterGetHostCharacter())
				end
			end

			--print("SwapDeltaMods", Ext.JsonStringify(itemEntry.DeltaMods))
			local boosts = GetAllBoosts(itemObject)
			if boosts ~= nil then
				local template = GetTemplate(item)
				NRD_ItemConstructBegin(template)
				--NRD_ItemCloneBegin(item)
				if item.ItemType == "Weapon" then
					local damageTypeString = Ext.StatGetAttribute(stat, "Damage Type")
					if damageTypeString == nil then damageTypeString = "Physical" end
					local damageTypeEnum = LeaderLib.Data.DamageTypeEnums[damageTypeString]
					NRD_ItemCloneSetInt("DamageTypeOverwrite", damageTypeEnum)
				end

				NRD_ItemCloneSetString("GenerationStatsId", stat)
				NRD_ItemCloneSetString("StatsEntryName", stat)
				NRD_ItemCloneSetString("RootTemplate", template)
				NRD_ItemCloneSetString("OriginalRootTemplate", template)
				NRD_ItemCloneSetInt("HasGeneratedStats", 0)
				NRD_ItemCloneSetInt("GenerationLevel", level)
				NRD_ItemCloneSetInt("StatsLevel", level)
				NRD_ItemCloneSetInt("IsIdentified", itemObject.Stats.IsIdentified)
				NRD_ItemCloneSetString("ItemType", rarity)
				NRD_ItemCloneSetString("GenerationItemType", rarity)

				for boost,boostType in pairs(boosts) do
					NRD_ItemCloneAddBoost(boostType, boost)
					printd("Adding boost", boostType, boost)
				end

				local clone = NRD_ItemClone()
				local inventory = GetInventoryOwner(item) or nil
				--NRD_ItemSetIdentified(clone, itemObject.Stats.IsIdentified)
				NRD_ItemSetIdentified(clone, 1)
				RollForBonusSkill(clone, stat, itemType, rarity)
				ObjectSetFlag(clone, "LLWEAPONEX_ProcessedDeltamods", 0)
				SetVarFixedString(clone, "LeaderLib_Rarity", rarity)
				SetVarInteger(clone, "LeaderLib_Level", level)
				local cloneItem = Ext.GetItem(clone)
				cloneItem.TreasureGenerated = itemObject.TreasureGenerated
				cloneItem.UnsoldGenerated = itemObject.UnsoldGenerated

				local slot = nil
				if inventory == nil then
					inventory = CharacterGetHostCharacter()
				end
				if inventory ~= nil and ObjectIsCharacter(inventory) == 1 then
					slot = GameHelpers.Item.GetEquippedSlot(inventory,item)
				end
				ItemRemove(item)
				if inventory ~= nil then
					if slot ~= nil then
						GameHelpers.Item.EquipInSlot(inventory, clone, slot)
					else
						ItemToInventory(clone, inventory, 1, 0, 0)
					end
					if CharacterIsPlayer(inventory) == 1 and CharacterGetReservedUserID(inventory) ~= nil then
						local id = CharacterGetReservedUserID(inventory)
						Ext.PostMessageToUser(id, "LeaderLib_AutoSortPlayerInventory", inventory)
					end
				end
				--NRD_ItemIterateDeltaModifiers(clone, "LLWEAPONEX_Debug_PrintDeltamod")
			else
				ObjectSetFlag(item, "LLWEAPONEX_ProcessedDeltamods", 0)
				if RollForBonusSkill(item, stat, itemType, rarity) then
					NRD_ItemCloneBegin(item)
					local damageTypeString = Ext.StatGetAttribute(stat, "Damage Type")
					if damageTypeString == nil then damageTypeString = "Physical" end
					local damageTypeEnum = LeaderLib.Data.DamageTypeEnums[damageTypeString]
					NRD_ItemCloneSetInt("DamageTypeOverwrite", damageTypeEnum)
					local clone = NRD_ItemClone()
					ItemRemove(item)
					local inventory = GetInventoryOwner(item)
					local slot = nil
					if ObjectIsCharacter(inventory) == 1 then
						slot = GameHelpers.Item.GetEquippedSlot(inventory,item)
						if CharacterIsPlayer(inventory) == 1 and CharacterGetReservedUserID(inventory) ~= nil then
							local id = CharacterGetReservedUserID(inventory)
							Ext.PostMessageToUser(id, "LeaderLib_AutoSortPlayerInventory", inventory)
						end
					end
					if inventory ~= nil then
						if slot ~= nil then
							GameHelpers.Item.EquipInSlot(inventory, clone, slot)
						else
							ItemToInventory(clone, inventory, 1, 0, 0)
						end
					end
				end
			end
		else
			ObjectSetFlag(item, "LLWEAPONEX_ProcessedDeltamods", 0)
		end
	end
end

local equipmentTypes = {
	Armor = true,
	Weapon = true,
	Shield = true
}

---@param item EsvItem
function OnTreasureItemGenerate(item)
	if item == nil or item.MyGuid == nil or item.Stats == nil then
		return
	end
	if equipmentTypes[item.ItemType] == true then
		Osi.LLWEAPONEX_Items_SaveGeneratedItem(item.MyGuid)
		TimerCancel("Timers_LLWEAPONEX_SwapGeneratedItemBoosts")
		TimerLaunch("Timers_LLWEAPONEX_SwapGeneratedItemBoosts", 10)
		--SwapDeltaMods(item.MyGuid)
	end
end

---@param item EsvItem
Ext.RegisterListener("TreasureItemGenerated", OnTreasureItemGenerate)

if Vars.DebugEnabled then
	Ext.RegisterConsoleCommand("swapdeltamods", function(command)
		local host = CharacterGetHostCharacter()
		local weapon = CharacterGetEquippedWeapon(host)
		if weapon ~= nil then
			SwapDeltaMods(weapon)
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