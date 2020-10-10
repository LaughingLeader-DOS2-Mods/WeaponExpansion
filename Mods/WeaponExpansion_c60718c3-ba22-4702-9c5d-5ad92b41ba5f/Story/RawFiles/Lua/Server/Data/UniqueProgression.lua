---@class UniqueProgressionEntry
local UniqueProgressionEntry = {
	Attribute = "",
	Value = "",
	Append = true,
	Type = "UniqueProgressionEntry"
}
UniqueProgressionEntry.__index = UniqueProgressionEntry

---@param attribute string
---@param value integer|string|any
---@param append boolean
---@return UniqueProgressionEntry
function UniqueProgressionEntry:Create(attribute, value, append)
    local this =
    {
		Attribute = attribute,
		Value = value,
		Append = append
	}
	if this.Append == nil then
		this.Append = true
	end
	setmetatable(this, self)
	return this
end

local ue = UniqueProgressionEntry

local runeslot1 = {ue:Create("RuneSlots", 1, false), ue:Create("RuneSlots_V1", 1, false)}
local runeslot2 = {ue:Create("RuneSlots", 2, false), ue:Create("RuneSlots_V1", 2, false)}
local runeslot3 = {ue:Create("RuneSlots", 3, false), ue:Create("RuneSlots_V1", 3, false)}

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
		[2] = ue:Create("Skills", "Projectile_LLWEAPONEX_Blunderbuss_LaunchDud", false),
		[5] = ue:Create("Skills", "Projectile_LLWEAPONEX_Blunderbuss_LaunchDud;Projectile_LLWEAPONEX_Blunderbuss_Scattershot", false),
		[7] = ue:Create("Ranged", 1),
		[9] = runeslot1,
		[10] = ue:Create("Boosts", "_Boost_Weapon_Damage_Fire_Large"),
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
		[5] = ue:Create("Skills", "Target_CripplingBlow"),
		[7] = runeslot1,
		[10] = ue:Create("Necromancy", 1),
		[11] = ue:Create("ExtraProperties",CreateStatusProps("LLWEAPONEX_PHYSICAL_WEAK_CHECK",0.15,1)),
		[12] = runeslot2,
	},
	DemoBackpack = {},
	DemonGauntlet = {},
	DivineBanner = {},
	FireRunebladeKatana = {
		[2] = ue:Create("Skills", "Shout_LLWEAPONEX_ActivateRuneblade_Fire;Projectile_LLWEAPONEX_BackstabbingFlamingDaggers", false),
		[4] = ue:Create("CriticalDamage", 5),
		[6] = ue:Create("FireSpecialist", 1),
		[8] = runeslot1,
		[10] = ue:Create("IntelligenceBoost", 2),
		[12] = runeslot2,
		[14] = ue:Create("Boosts", "_Boost_Weapon_Damage_Fire_Small"),
		[15] = runeslot3,
	},
	Frostdyne = {
		[2] = ue:Create("WaterSpecialist", 1),
		[3] = ue:Create("Skills", "Shout_GlobalCooling"),
		[5] = ue:Create("RootTemplate", "6a811339-a28f-44a6-980b-0289cc45cffa"),
		[9] = ue:Create("Skills", "Shout_IceBreaker"),
		[12] = ue:Create("RootTemplate", "c715d004-5d66-4301-8360-2c6c2e25f678"),
	},
	HarkenPowerGloves = {},
	HarkenTattoos = {},
	Harvest = {
		[3] = ue:Create("VitalityBoost", 20),
		[5] = ue:Create("CriticalChance", 20),
		[7] = runeslot1,
		[10] = ue:Create("Initiative", 9),
		[11] = ue:Create("Skills", "Target_BlackShroud"),
		[12] = runeslot2,
	},
	LoneWolfBanner = {},
	--MagicMissileRod = {},
	MagicMissileWand = {},
	MonkBlindfold = {},
	Muramasa = {
		[4] = ue:Create("Skills","Target_SerratedEdge", true),
		[7] = runeslot1,
		[9] = ue:Create("RogueLore", 1),
		[11] = ue:Create("ExtraProperties",CreateStatusProps("BLEEDING",0.15,1)),
		[12] = runeslot2,
	},
	OgreScroll = {},
	Omnibolt = {
		[2] = ue:Create("AirSpecialist", 1),
		[6] = ue:Create("IntelligenceBoost", 2),
		[6] = ue:Create("DodgeBoost", 7),
		[8] = runeslot1,
		[10] = ue:Create("Boosts", "_Boost_Weapon_Damage_Air_Medium"),
		[12] = ue:Create("CriticalChance", 10),
		[14] = ue:Create("ExtraProperties",CreateStatusProps("MUTED",0.15,1)),
		[15] = runeslot2,
	},
	PowerPole = {},
	--WarchiefAxe = {},
	WarchiefHalberd = {},
	Wraithblade = {},
}

return bonuses