---@class UniqueProgressionEntry
local UniqueProgressionEntry = {
	Type = "UniqueProgressionEntry",
	Attribute = "",
	Value = "",
	Append = false,
	MatchStat = "",
}
UniqueProgressionEntry.__index = UniqueProgressionEntry

---@param attribute string
---@param value integer|string|any
---@param append boolean
---@return UniqueProgressionEntry
function UniqueProgressionEntry:Create(attribute, value, params)
    local this =
    {
		Attribute = attribute,
		Value = value,
		Append = false
	}
	if params ~= nil and type(params) == "table" then
		for k,v in pairs(params) do
			this[k] = v
		end
	end
	setmetatable(this, self)
	return this
end

---@class UniqueProgressionTransform
local UniqueProgressionTransform = {
	Type = "UniqueProgressionTransform",
	Template = "",
	Stat = "",
	MatchStat = "",
}
UniqueProgressionTransform.__index = UniqueProgressionTransform

---@param template string
---@param stat string
---@return UniqueProgressionTransform
function UniqueProgressionTransform:Create(template, stat)
    local this =
    {
		Template = template or "",
		Stat = stat or ""
	}
	setmetatable(this, self)
	return this
end

local ue = UniqueProgressionEntry
local ut = UniqueProgressionTransform

local runeslot1 = {ue:Create("RuneSlots", 1), ue:Create("RuneSlots_V1", 1)}
local runeslot2 = {ue:Create("RuneSlots", 2), ue:Create("RuneSlots_V1", 2)}
local runeslot3 = {ue:Create("RuneSlots", 3), ue:Create("RuneSlots_V1", 3)}

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
	AnvilMace = {},
	ArmCannon = {},
	AssassinHandCrossbow = {},
	BalrinAxe = {},
	BeholderSword = {
		[2] = ue:Create("LifeSteal", 10),
		[4] = ue:Create("WarriorLore", 1),
		[6] = ue:Create("StrengthBoost", 1),
		[7] = runeslot1,
		[6] = ue:Create("DodgeBoost", 7),
		[10] = {ue:Create("CleavePercentage", 50), ue:Create("CleaveAngle", 150)},
		[12] = ue:Create("CriticalChance", 10),
		[14] = ue:Create("ExtraProperties",CreateStatusProps("ACID",0.15,1)),
		[15] = runeslot2,
	},
	Bible = {},
	Blunderbuss = {
		[2] = ue:Create("Skills", "Projectile_LLWEAPONEX_Blunderbuss_LaunchDud"),
		[5] = ue:Create("Skills", "Projectile_LLWEAPONEX_Blunderbuss_LaunchDud;Projectile_LLWEAPONEX_Blunderbuss_Scattershot"),
		[7] = ue:Create("Ranged", 1),
		[9] = runeslot1,
		[10] = ue:Create("Boosts", "_Boost_Weapon_LLWEAPONEX_Blunderbuss_BonusDamage_Physical;_Boost_Weapon_Damage_Fire_Large"),
		[12] = runeslot2,
		[14] = ue:Create("RangerLore", 1),
		[15] = runeslot3,
	},
	Bokken = {},
	--BokkenOneHanded = {},
	ChaosEdge = {},
	DaggerBasilus = {},
	DeathEdge = {
		[3] = ue:Create("TwoHanded", 1),
		[5] = ue:Create("Skills", "Target_HeavyAttack;Target_CripplingBlow"),
		[7] = runeslot1,
		[10] = ue:Create("Necromancy", 2),
		[11] = ue:Create("ExtraProperties",CreateStatusProps("LLWEAPONEX_PHYSICAL_WEAK_CHECK",0.15,1),{Append=true}),
		[12] = runeslot2,
	},
	DemoBackpack = {},
	DemonGauntlet = {},
	DivineBanner = {},
	FireRunebladeKatana = {
		[2] = ue:Create("Skills", "Shout_LLWEAPONEX_ActivateRuneblade_Fire;Projectile_LLWEAPONEX_BackstabbingFlamingDaggers"),
		[4] = ue:Create("DamageFromBase", 67),
		[6] = ue:Create("FireSpecialist", 1),
		[8] = runeslot1,
		[10] = ue:Create("IntelligenceBoost", 2),
		[12] = runeslot2,
		[14] = ue:Create("Boosts", "_Boost_Weapon_Damage_Fire_Small"),
		[15] = runeslot3,
		[16] = ue:Create("CriticalDamage", 150),
	},
	Frostdyne = {
		[3] = ue:Create("Skills", "Shout_LLWEAPONEX_ActivateRuneblade_Ice;Shout_GlobalCooling", {MatchStat="WPN_UNIQUE_LLWEAPONEX_Rapier_Runeblade_Water_1H"}),
		[5] = ut:Create("6a811339-a28f-44a6-980b-0289cc45cffa", "WPN_UNIQUE_LLWEAPONEX_Rapier_Runeblade_Water_1H_2", {MatchStat="WPN_UNIQUE_LLWEAPONEX_Rapier_Runeblade_Water_1H"}),
		[9] = ue:Create("Skills", "Shout_LLWEAPONEX_ActivateRuneblade_Ice;Shout_GlobalCooling;Cone_Shatter;Shout_IceBreaker", {MatchStat="WPN_UNIQUE_LLWEAPONEX_Rapier_Runeblade_Water_1H_2"}),
		[12] = ut:Create("c715d004-5d66-4301-8360-2c6c2e25f678", "WPN_UNIQUE_LLWEAPONEX_Rapier_Runeblade_Water_1H_3", {MatchStat="WPN_UNIQUE_LLWEAPONEX_Rapier_Runeblade_Water_1H_2"}),
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
	LoneWolfBanner = {},
	--MagicMissileRod = {},
	MagicMissileWand = {},
	MonkBlindfold = {},
	Muramasa = {
		[4] = ue:Create("Skills","Target_LLWEAPONEX_HelmSplitter;Target_SerratedEdge"),
		[7] = runeslot1,
		[9] = ue:Create("RogueLore", 1),
		[11] = ue:Create("ExtraProperties",CreateStatusProps("BLEEDING",0.15,1),{Append=true}),
		[12] = runeslot2,
	},
	OgreScroll = {},
	Omnibolt = {
		[2] = ue:Create("AirSpecialist", 1),
		[6] = ue:Create("StrengthBoost", 2),
		[6] = ue:Create("DodgeBoost", 7),
		[8] = runeslot1,
		[10] = ue:Create("DamageFromBase", 120),
		[12] = ue:Create("CriticalChance", 10),
		[14] = ue:Create("ExtraProperties",CreateStatusProps("MUTED",0.15,1),{Append=true}),
		[15] = runeslot2,
		[16] = ue:Create("CriticalDamage", 140),
	},
	PowerPole = {},
	--WarchiefAxe = {},
	WarchiefHalberd = {},
	Wraithblade = {},
}

return bonuses