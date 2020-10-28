local classes = Ext.Require("Server/Data/UniqueProgression.lua")

---@type UniqueProgressionEntry
local ue = classes.UniqueProgressionEntry
---@type UniqueProgressionTransform
local ut = classes.UniqueProgressionTransform

local runeslot1 = {ue:Create("RuneSlots", 1), ue:Create("RuneSlots_V1", 1)}
local runeslot2 = {ue:Create("RuneSlots", 2), ue:Create("RuneSlots_V1", 2)}
local runeslot3 = {ue:Create("RuneSlots", 3), ue:Create("RuneSlots_V1", 3)}

local Attributes = {
	Strength = true,
	Finesse = true,
	Intelligence = true,
	Constitution = true,
	Memory = true,
	Wits = true,
}

---@param stat StatEntryWeapon
local function GetRequirementAttributeBoost(stat, fallback)
	local attribute = ""
	if stat.Requirements ~= nil then
		for i,v in pairs(stat.Requirements) do
			if Attributes[v.Requirement] == true then
				attribute = v.Requirement
				break
			end
		end
	end
	print(stat.Name, "GetRequirementAttributeBoost", attribute)
	if not StringHelpers.IsNullOrEmpty(attribute) then
		if not string.find(attribute, "Boost") then
			return attribute.."Boost"
		else
			return attribute
		end
	else
		return fallback
	end
end

local GetReqAttributeParams = {GetAttribute=GetRequirementAttributeBoost}

local function CreateStatusProps(status,chance,turns)
	local prop = {
		Type = "Status",
		Action = status,
		Context = {"Target"},
		Duration = turns * 6.0,
		StatusChance = chance,
		StatsId = "",
		Arg4 = -1,
		Arg5 = -1,
		SurfaceBoost = false
	}
	return prop
end

---@class AllUniqueProgressionData
local bonuses = {
	AnvilMace = {
		[2] = ue:Create("WarriorLore", 1),
		[6] = ue:Create("StrengthBoost", "1", GetReqAttributeParams),
		[7] = runeslot1,
		[8] = ue:Create("TwoHanded", 1),
		[12] = ue:Create("DamageFromBase", 20),
		[15] = runeslot2,
	},
	ArmCannon = {
		[2] = ue:Create("WitsBoost", "1", GetReqAttributeParams),
		[4] = ue:Create("ArmorBoost", 10),
		[6] = ue:Create("ConstitutionBoost", "1"),
		[8] = ue:Create("MagicArmorBoost", 20),
		[10] = runeslot2,
		[12] = ue:Create("Fire", 10),
		[14] = ue:Create("Air", 20),
		[15] = runeslot3,
	},
	ArmCannonWeapon = {},
	AssassinHandCrossbow = {
		[2] = ue:Create("Sneaking", 1),
		[4] = ue:Create("WitsBoost", "1"),
		[7] = runeslot1,
		[8] = ue:Create("RogueLore", 1),
		[10] = ue:Create("CriticalChance", 10),
		[12] = ue:Create("Sneaking", 1),
		[15] = runeslot2,
	},
	BalrinAxe = {
		[2] = ue:Create("CriticalChance", 5),
		[4] = ue:Create("CriticalChance", 5),
		[6] = ue:Create("DamageFromBase", 5),
		[7] = runeslot1,
		[8] = ue:Create("Boosts", "_Boost_Weapon_Damage_ArmourPiercing_Medium"),
		[10] = ue:Create("CriticalChance", 5),
		[12] = ue:Create("DamageFromBase", 5),
		[14] = ue:Create("DamageFromBase", 10),
		[15] = runeslot2,
	},
	BeholderSword = {
		[2] = ue:Create("StrengthBoost", "1", GetReqAttributeParams),
		[4] = ue:Create("WarriorLore", 1),
		[6] = ue:Create("CriticalChance", 5),
		[7] = runeslot1,
		[8] = ue:Create("StrengthBoost", "1", GetReqAttributeParams),
		[10] = ue:Create("Boosts", "_LLWEAPONEX_Boost_Weapon_Damage_Corrosive_Beholder;_Boost_Weapon_Cleave_Large_TwoHanded"),
		[12] = ue:Create("CriticalChance", 10),
		[14] = ue:Create("Boosts", "_LLWEAPONEX_Boost_Weapon_Damage_Corrosive_Beholder_Rank2;_Boost_Weapon_Cleave_Large_TwoHanded"),
		[15] = runeslot2,
	},
	Bible = {
		[2] = ue:Create("TwoHanded", 1),
		[6] = ue:Create("StrengthBoost", "2", GetReqAttributeParams),
		[7] = runeslot1,
		[8] = ue:Create("TwoHanded", 2),
		[12] = ue:Create("DamageFromBase", 10),
		[15] = runeslot2,
	},
	Blunderbuss = {
		[4] = ue:Create("Skills", "Projectile_LLWEAPONEX_Blunderbuss_LaunchDud"),
		[6] = ue:Create("Ranged", 1),
		[7] = runeslot1,
		[8] = ue:Create("Boosts", "_Boost_Weapon_LLWEAPONEX_Blunderbuss_BonusDamage_Physical;_Boost_Weapon_Damage_Fire_Large"),
		[10] = ue:Create("RangerLore", 1),
		[13] = runeslot2,
		[15] = runeslot3,
	},
	Bokken = {},
	--BokkenOneHanded = {},
	ChaosEdge = {
		[2] = ue:Create("TwoHanded", 1),
		[3] = ue:Create("Luck", 1),
		[7] = runeslot2,
		[8] = ue:Create("IntelligenceBoost", "2", GetReqAttributeParams),
		[10] = ue:Create("CriticalDamage", 10),
		[12] = runeslot3,
		[14] = ue:Create("DamageBoost", 10),
	},
	BasilusDagger = {
		[2] = ue:Create("RogueLore", 1),
		[4] = ue:Create("Skills", "Projectile_ThrowingKnife"),
		[7] = runeslot1,
		[8] = ue:Create("DamageFromBase", 10),
		[10] = ue:Create("CriticalDamage", 10),
		[12] = ue:Create("DamageFromBase", 10),
		[14] = ue:Create("Skills", "Projectile_ThrowingKnife;Projectile_FanOfKnives"),
		[15] = runeslot2,
	},
	DeathEdge = {
		[2] = ue:Create("TwoHanded", 1),
		[4] = ue:Create("Skills", "Target_HeavyAttack;Target_CripplingBlow"),
		[7] = runeslot1,
		[8] = ue:Create("DamageFromBase", 110),
		[10] = ue:Create("Necromancy", 2),
		[12] = ue:Create("Boosts", "_Boost_Weapon_LLWEAPONEX_Status_Set_PhysicalWeak2"),
		[15] = runeslot2,
	},
	DemoBackpack = {},
	DemonGauntlet = {},
	DivineBanner = {
		[2] = ue:Create("StrengthBoost", "1", GetReqAttributeParams),
		[6] = ue:Create("Leadership", 2),
		[7] = runeslot1,
		[8] = ue:Create("Leadership", 3),
		[12] = ue:Create("DamageFromBase", 10),
		[15] = runeslot2,
	},
	FireRunebladeKatana = {
		[2] = ue:Create("Skills", "Shout_LLWEAPONEX_ActivateRuneblade_Fire;Projectile_LLWEAPONEX_BackstabbingFlamingDaggers"),
		[4] = ue:Create("DamageFromBase", 10),
		[6] = ue:Create("FireSpecialist", 1),
		[8] = runeslot1,
		[10] = ue:Create("IntelligenceBoost", "2", GetReqAttributeParams),
		[12] = runeslot2,
		[14] = ue:Create("Boosts", "_Boost_Weapon_Damage_Fire_Small"),
		[15] = runeslot3,
		[16] = ue:Create("CriticalDamage", 10),
	},
	Frostdyne = {
		[3] = ue:Create("Skills", "Shout_LLWEAPONEX_ActivateRuneblade_Ice;Shout_GlobalCooling", {MatchStat="WPN_UNIQUE_LLWEAPONEX_Rapier_Runeblade_Water_1H"}),
		[5] = ut:Create("6a811339-a28f-44a6-980b-0289cc45cffa", "WPN_UNIQUE_LLWEAPONEX_Rapier_Runeblade_Water_1H_2", {MatchTemplate="d82bc239-4782-484c-88ab-e1fa571c9f6a"}),
		[9] = ue:Create("Skills", "Shout_LLWEAPONEX_ActivateRuneblade_Ice;Shout_GlobalCooling;Cone_Shatter", {MatchStat="WPN_UNIQUE_LLWEAPONEX_Rapier_Runeblade_Water_1H_2"}),
		[12] = ut:Create("c715d004-5d66-4301-8360-2c6c2e25f678", "WPN_UNIQUE_LLWEAPONEX_Rapier_Runeblade_Water_1H_3"),
	},
	HarkenPowerGloves = {},
	HarkenTattoos = {},
	Harvest = {
		[2] = ue:Create("TwoHanded", 1),
		[3] = ue:Create("VitalityBoost", 20),
		[5] = ue:Create("CriticalChance", 20),
		[7] = runeslot1,
		[10] = ue:Create("Initiative", 9),
		[11] = ue:Create("Skills", "Target_HeavyAttack;Cone_LLWEAPONEX_SoulHarvest_Reap;Target_BlackShroud"),
		[12] = runeslot2,
	},
	LoneWolfBanner = {
		[2] = ue:Create("LifeSteal", 10),
		[6] = ue:Create("Leadership", 2),
		[7] = runeslot1,
		[8] = ue:Create("Leadership", 3),
		[12] = ue:Create("DamageFromBase", 10),
		[15] = runeslot2,
	},
	MagicMissileRod = {
		[2] = ue:Create("IntelligenceBoost", "1", GetReqAttributeParams),
		[4] = ue:Create("DamageRange", 10),
		[6] = ue:Create("CriticalDamage", 10),
		[7] = runeslot1,
		[8] = ue:Create("IntelligenceBoost", "2", GetReqAttributeParams),
		[10] = ue:Create("DamageFromBase", 10),
		[12] = ue:Create("IntelligenceBoost", "3", GetReqAttributeParams),
		[15] = runeslot2,
	},
	MagicMissileWand = {
		[2] = ue:Create("IntelligenceBoost", "1", GetReqAttributeParams),
		[4] = ue:Create("DamageRange", 10),
		[6] = ue:Create("CriticalDamage", 5),
		[7] = runeslot1,
		[8] = ue:Create("IntelligenceBoost", "2", GetReqAttributeParams),
		[10] = ue:Create("DamageFromBase", 10),
		[12] = ue:Create("IntelligenceBoost", "3", GetReqAttributeParams),
		[15] = runeslot2,
	},
	MonkBlindfold = {},
	Muramasa = {
		[2] = {ue:Create("StrengthBoost", "1", GetReqAttributeParams), ue:Create("LifeSteal", 10)},
		[4] = ue:Create("Skills","Target_LLWEAPONEX_HelmSplitter;Target_SerratedEdge"),
		[6] = ue:Create("WitsBoost", "1"),
		[7] = runeslot1,
		[8] = ue:Create("WarriorLore", 1),
		[10] = ue:Create("Boosts", "_Boost_Weapon_Status_Set_Bleeding_TwoHanded"),
		[12] = ue:Create("WarriorLore", 2),
		[14] = ue:Create("TwoHanded", 1),
		[15] = runeslot2,
	},
	OgreScroll = {
		[2] = ue:Create("StrengthBoost", "1", GetReqAttributeParams),
		[4] = ue:Create("DamageFromBase", 10),
		[6] = ue:Create("StrengthBoost", "2", GetReqAttributeParams),
		[7] = runeslot1,
		[8] = ue:Create("TwoHanded", 1),
		[10] = ue:Create("StrengthBoost", "3", GetReqAttributeParams),
		[12] = ue:Create("DamageFromBase", 10),
		[15] = runeslot2,
	},
	Omnibolt = {
		[2] = ue:Create("AirSpecialist", 1),
		[6] = ue:Create("StrengthBoost", "2", GetReqAttributeParams),
		[6] = ue:Create("DodgeBoost", 7),
		[8] = runeslot1,
		[10] = ue:Create("DamageFromBase", 10),
		[12] = ue:Create("CriticalChance", 10),
		[14] = ue:Create("Boosts", "_Boost_Weapon_LLWEAPONEX_Status_Set_Muted"),
		[15] = runeslot2,
		[16] = ue:Create("CriticalDamage", 10),
	},
	PowerPole = {
		[2] = ue:Create("FinesseBoost", "1", GetReqAttributeParams),
		[4] = ue:Create("WarriorLore", 1),
		[7] = runeslot1,
		[8] = ue:Create("DamageFromBase", 10),
		[10] = ue:Create("FinesseBoost", "2", GetReqAttributeParams),
		[12] = ue:Create("WarriorLore", 2),
		[15] = runeslot2,
	},
	WarchiefAxe = {
		[2] = ue:Create("StrengthBoost", "1", GetReqAttributeParams),
		[4] = ue:Create("TwoHanded", 1),
		[7] = runeslot1,
		[8] = ue:Create("DamageFromBase", 10),
		[10] = ue:Create("StrengthBoost", "2", GetReqAttributeParams),
		[12] = ue:Create("WarriorLore", 2),
		[15] = runeslot2,
	},
	WarchiefHalberd = {
		[2] = ue:Create("StrengthBoost", "1", GetReqAttributeParams),
		[4] = ue:Create("TwoHanded", 1),
		[7] = runeslot1,
		[8] = ue:Create("DamageFromBase", 10),
		[10] = ue:Create("StrengthBoost", "2", GetReqAttributeParams),
		[12] = ue:Create("WarriorLore", 2),
		[15] = runeslot2,
	},
	Wraithblade = {
		[2] = ue:Create("FinesseBoost", "1", GetReqAttributeParams),
		[4] = ue:Create("CriticalChance", 10),
		[7] = runeslot1,
		[8] = ue:Create("DamageFromBase", 10),
		[10] = ue:Create("FinesseBoost", "2", GetReqAttributeParams),
		[12] = ue:Create("WitsBoost", "2"),
		[15] = runeslot2,
	},
}

return bonuses