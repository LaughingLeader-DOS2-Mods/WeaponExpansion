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

---@param item EsvItem
local function GetRunebladeDamageBoost(item, deltamod)
	for tag,boosts in pairs(runebladeDamageBoosts) do
		if item:HasTag(tag) then
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

---@param item EsvItem
local function GetRodDamageBoost(item, deltamod)
	for damageType,boosts in pairs(rodDamageBoosts) do
		if string.find(item.StatsId, damageType) then
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

---@param item EsvItem
local function GetQuarterstaffAttributeBoost(item, deltamod)
	local b,result = GameHelpers.Stats.TryGetAttribute(item.StatsId, "Requirements", function (stat, attribute, value)
		for i,entry in pairs(value) do
			if entry.Param == "Finesse" then
				return "Boost_Weapon_Primary_Finesse_Medium"
			end
		end
	end)
	if not b then
		return "Boost_Weapon_Primary_Strength_Medium"
	end
	return result
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

DeltamodSwap.LLWEAPONEX_Katana = {
	Boost_Weapon_Primary_Finesse = "Boost_Weapon_Primary_Strength",
	Boost_Weapon_Primary_Finesse_Medium = "Boost_Weapon_Primary_Strength_Medium",
}

DeltamodSwap.LLWEAPONEX_Halberd = {
	Boost_Weapon_Primary_Finesse = "Boost_Weapon_Primary_Strength",
	Boost_Weapon_Primary_Finesse_Medium = "Boost_Weapon_Primary_Strength_Medium",
}

DeltamodSwap.LLWEAPONEX_BattleBook = {
	Boost_Weapon_Primary_Strength_Club = "Boost_LLWEAPONEX_Weapon_Primary_Wits",
	Boost_Weapon_Primary_Strength_Medium_Club = "Boost_LLWEAPONEX_Weapon_Primary_Wits_Medium",
}

DeltamodSwap.LLWEAPONEX_Greatbow = {
	Boost_Weapon_Primary_Finesse = "Boost_Weapon_Primary_Strength_Medium",
	Boost_Weapon_Primary_Finesse_Medium_Bow = "Boost_Weapon_Primary_Strength_Medium",
	Boost_Weapon_Primary_Finesse_Medium_Crossbow = "Boost_Weapon_Primary_Strength_Medium",
}

return DeltamodSwap