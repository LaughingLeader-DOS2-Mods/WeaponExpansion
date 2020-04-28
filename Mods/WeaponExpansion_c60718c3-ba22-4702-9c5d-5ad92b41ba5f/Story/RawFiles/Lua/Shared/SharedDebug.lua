local dynamicStatsVars = {
	Durability = "integer",
	DurabilityDegradeSpeed = "integer",
	StrengthBoost = "integer",
	FinesseBoost = "integer",
	IntelligenceBoost = "integer",
	ConstitutionBoost = "integer",
	MemoryBoost = "integer",
	WitsBoost = "integer",
	SightBoost = "integer",
	HearingBoost = "integer",
	VitalityBoost = "integer",
	SourcePointsBoost = "integer",
	MaxAP = "integer",
	StartAP = "integer",
	APRecovery = "integer",
	AccuracyBoost = "integer",
	DodgeBoost = "integer",
	LifeSteal = "integer",
	CriticalChance = "integer",
	ChanceToHitBoost = "integer",
	MovementSpeedBoost = "integer",
	RuneSlots = "integer",
	RuneSlots_V1 = "integer",
	FireResistance = "integer",
	AirResistance = "integer",
	WaterResistance = "integer",
	EarthResistance = "integer",
	PoisonResistance = "integer",
	ShadowResistance = "integer",
	PiercingResistance = "integer",
	CorrosiveResistance = "integer",
	PhysicalResistance = "integer",
	MagicResistance = "integer",
	CustomResistance = "integer",
	Movement = "integer",
	Initiative = "integer",
	Willpower = "integer",
	Bodybuilding = "integer",
	MaxSummons = "integer",
	Value = "integer",
	Weight = "integer",
	Skills = "string",
	ItemColor = "string",
	ModifierType = "integer",
	ObjectInstanceName = "string",
	BoostName = "string",
	StatsType = "string",
	DamageType = "integer",
	MinDamage = "integer",
	MaxDamage = "integer",
	DamageBoost = "integer",
	DamageFromBase = "integer",
	CriticalDamage = "integer",
	WeaponRange = "integer",
	CleaveAngle = "integer",
	CleavePercentage = "integer",
	AttackAPCost = "integer",
	ArmorValue = "integer",
	ArmorBoost = "integer",
	MagicArmorValue = "integer",
	MagicArmorBoost = "integer",
	Blocking = "integer",
	}

function PrintDynamicStats(dynamicStats)
	for i,v in pairs(dynamicStats) do
		Ext.Print("["..tostring(i) .. "]{")
		if v ~= nil and v.DamageFromBase > 0 then
			for attribute,attributeType in pairs(dynamicStatsVars) do
				Ext.Print("    "..attribute..":"..tostring(v[attribute]))
			end
		end
		Ext.Print("}")
	end
end