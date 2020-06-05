local itemDeltaMods = {}

local runebladeDamageBoosts = {
	LLWEAPONEX_Runeblade_Air = {
		Small = "Boost_Weapon_Damage_Air_Small_Sword",
		Medium = "Boost_Weapon_Damage_Air_Medium_Sword",
		Large = "Boost_Weapon_Damage_Air_Large_Sword",
		Default = "Boost_Weapon_Damage_Air_Sword",
	},
	LLWEAPONEX_Runeblade_Chaos = {
		Small = "Boost_LLWEAPONEX_Weapon_Damage_Chaos_Small_Sword",
		Medium = "Boost_LLWEAPONEX_Weapon_Damage_Chaos_Medium_Sword",
		Large = "Boost_LLWEAPONEX_Weapon_Damage_Chaos_Large_Sword",
		Default = "Boost_LLWEAPONEX_Weapon_Damage_Chaos_Sword",
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

local damageBoostName = "Boost_Weapon_Damage_Type_Size_Sword"

local function GetRunebladeDamageBoost(item, deltamod)

end

local DeltamodSwap = {
	LLWEAPONEX_Runeblade = {
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
}

function GetDeltamods(item)
	NRD_ItemIterateDeltaModifiers(item, "LLWEAPONEX_Iterator_GetDeltamod")
end

function SaveDeltamod(item, deltamod, isGenerated)
	if itemDeltaMods[item] == nil then
		itemDeltaMods[item] = {}
	end
	local canAdd = true
	for tag,deltamods in pairs(DeltamodSwap) do
		if IsTagged(item, tag) == 1 then
			local replacement = deltamods[deltamod]
			if replacement ~= nil then
				if replacement == "" then
					print("Disabled deltamod",deltamod,item)
					canAdd = false
				elseif type(replacement) == "function" then
					local b,replacementVal = pcall(replacement, item, deltamod)
					if b then
						print("Swapped deltamod",deltamod,"for",replacementVal,item)
						deltamod = replacementVal
					else
						canAdd = false
					end
				else
					print("Swapped deltamod",deltamod,"for",replacement,item)
					deltamod = replacement
				end
			end
		end
	end
	--table.insert(itemDeltaMods[item], deltamod)
	itemDeltaMods[item][deltamod] = canAdd
end

function TransformRunebladeDeltamods(item)
	if itemDeltaMods[item] == nil then
		NRD_ItemIterateDeltaModifiers(item, "LLWEAPONEX_Iterator_GetDeltamod")
	end
	if itemDeltaMods[item] ~= nil then
		local stat = NRD_ItemGetStatsId(item)
		local baseStat,rarity,level,seed = NRD_ItemGetGenerationParams(item)
		if level == nil then
			level = NRD_ItemGetInt(item, "LevelOverride")
			if level == 0 or level == nil then
				level = CharacterGetLevel(CharacterGetHostCharacter())
			end
		end

		print("TransformRunebladeDeltamods", Ext.JsonStringify(itemDeltaMods[item]))
		local deltamods = itemDeltaMods[item]
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
			NRD_ItemCloneSetInt("IsIdentified", 1)
			NRD_ItemCloneSetString("ItemType", rarity)
			NRD_ItemCloneSetString("GenerationItemType", rarity)

			local clone = NRD_ItemClone()
			print("Swapped item to clone", clone)
			for deltamod,b in pairs(deltamods) do
				if b == true then
					ItemAddDeltaModifier(clone, deltamod)
					print("Added deltamod", deltamod)
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
				ItemToInventory(item,inventory)
			end
			--ItemRemove(item)
			NRD_ItemIterateDeltaModifiers(clone, "LLWEAPONEX_Debug_PrintDeltamod")
		end
		itemDeltaMods[item] = nil
	end
end

Ext.RegisterConsoleCommand("runebladedeltamods", function(command)
	local host = CharacterGetHostCharacter()
	local weapon = CharacterGetEquippedWeapon(host)
	if weapon ~= nil and IsTagged(weapon, "LLWEAPONEX_Runeblade") == 1 then
		TransformRunebladeDeltamods(weapon)
	end
end)