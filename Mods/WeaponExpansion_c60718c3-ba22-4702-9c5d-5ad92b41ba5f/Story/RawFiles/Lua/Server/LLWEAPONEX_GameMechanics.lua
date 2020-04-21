local unarmedAttributes = {
	"Strength",
	"Finesse",
	"Constitution"
}

local function ComputeBaseUnarmedWeaponDamage(weapon, unarmedMastery)
    local damages = {}
    local stats = weapon.DynamicStats
	local baseStat = stats[1]
	local unarmedMasteryBoost = 0
	-- if unarmedMastery > 0 then
	-- 	if unarmedMastery == 1 then
	-- 		unarmedMasteryBoost = 10
	-- 	elseif unarmedMastery == 2 then
	-- 		unarmedMasteryBoost = 15
	-- 	elseif unarmedMastery == 3 then
	-- 		unarmedMasteryBoost = 20
	-- 	elseif unarmedMastery >= 4 then
	-- 		unarmedMasteryBoost = 35
	-- 	end
	-- end
    --local baseDmgFromBase = (baseStat.DamageFromBase + unarmedMasteryBoost) * 0.01
    local baseMinDamage = baseStat.MinDamage
    local baseMaxDamage = baseStat.MaxDamage
    local damageBoost = 0

    for i, stat in pairs(stats) do
        if stat.StatsType == "Weapon" and stat.DamageType ~= "None" then
            local dmgType = stat.DamageType
            local dmgFromBase = (stat.DamageFromBase + unarmedMasteryBoost) * 0.01
            local minDamage = stat.MinDamage
            local maxDamage = stat.MaxDamage

            if dmgFromBase ~= 0 then
                if stat == baseStat then
                    if baseMinDamage ~= 0 then
                        minDamage = math.max(dmgFromBase * baseMinDamage, 1)
                    end
                    if baseMaxDamage ~= 0 then
                        maxDamage = math.max(dmgFromBase * baseMaxDamage, 1.0)
                    end
                else
                    minDamage = math.max(dmgFromBase * dmgFromBase * baseMinDamage, 1.0)
                    maxDamage = math.max(dmgFromBase * dmgFromBase * baseMaxDamage, 1.0)
                end
            end

            if minDamage > 0 then
                maxDamage = math.max(maxDamage, minDamage + 1.0)
            end

            damageBoost = damageBoost + stat.DamageBoost

            if damages[dmgType] == nil then
                damages[dmgType] = {
                    Min = minDamage,
                    Max = maxDamage
                }
            else
                local damage = damages[dmgType]
                damage.Min = damage.Min + minDamage
                damage.Max = damage.Max + maxDamage
			end
			
			Ext.Print("Weapon Damage ("..tostring(stat)..") DamageFromBase("..tostring(stat.DamageFromBase)..") MinDamage("..tostring(stat.MinDamage)..") MaxDamage("..tostring(stat.MaxDamage)..") DamageBoost("..tostring(damageBoost)..") stat.DamageBoost("..tostring(stat.DamageBoost)..")")
        end
    end

    return damages, damageBoost
end

local function GetPrimaryUnarmedAttribute(character)
	local attribute = "Strength"
	local last = 0
	for i,att in pairs(unarmedAttributes) do
		local val = character[att]
		if val ~= nil and val > last then
			attribute = att
			last = val
		end
	end
	Ext.Print("Scaling unarmed damage by ("..attribute..")")
	return attribute
end

local function GetScaledUnarmedWeaponDamage(character, weapon, noRandomization, unarmedMastery)
	local damageList = Ext.NewDamageList()
	local primaryAttribute = GetPrimaryUnarmedAttribute(character)
	local damages, damageBoost = ComputeBaseUnarmedWeaponDamage(weapon, unarmedMastery)

    local abilityBoosts = character.DamageBoost 
        + Game.Math.ComputeWeaponCombatAbilityBoost(character, weapon)
        + Game.Math.ScaledDamageFromPrimaryAttribute(character[primaryAttribute]) * 100.0
    abilityBoosts = math.max(abilityBoosts + 100.0, 0.0) / 100.0

    local boost = 1.0 + damageBoost * 0.01
    if not character.NotSneaking then
        boost = boost + Ext.ExtraData['Sneak Damage Multiplier']
    end

    for damageType, damage in pairs(damages) do
        local min = math.ceil(damage.Min * boost * abilityBoosts)
        local max = math.ceil(damage.Max * boost * abilityBoosts)

        local randRange = 1
        if max - min >= 1 then
            randRange = max - min
        end

        local finalAmount
        if noRandomization then
            finalAmount = min + math.floor(randRange / 2)
        else
            finalAmount = min + Ext.Random(0, randRange)
        end

        damageList:Add(damageType, finalAmount)
	end

	Game.Math.ApplyDamageBoosts(character, damageList)
	return damageList
end

local UnarmedHitMatchProperties = {
	DamageType = 0,
	DamagedMagicArmor = 0,
	Equipment = 0,
	DeathType = 0,
	Bleeding = 0,
	DamagedPhysicalArmor = 0,
	PropagatedFromOwner = 0,
	-- NoWeapon doesn't set HitWithWeapon until after preparation
	HitWithWeapon = 0,
	Surface = 0,
	NoEvents = 0,
	Hit = 0,
	Poisoned = 0,
	--CounterAttack = 0,
	ProcWindWalker = 1,
	NoDamageOnOwner = 0,
	Burning = 0,
	--DamagedVitality = 0,
	--LifeSteal = 0,
	--ArmorAbsorption = 0,
	--AttackDirection = 0,
	Missed = 0,
	--CriticalHit = 0,
	--Backstab = 0,
	Reflection = 0,
	DoT = 0,
	Dodged = 0,
	--DontCreateBloodSurface = 0,
	FromSetHP = 0,
	FromShacklesOfPain = 0,
	Blocked = 0,
}

local function IsUnarmedDamage(handle)
	for prop,val in pairs(UnarmedHitMatchProperties) do
		if NRD_HitGetInt(handle, prop) ~= val then
			return false
		end
	end
	return true
end

function LLWEAPONEX_Ext_ScaleUnarmedDamage(attacker, target, damage, handle)
	if damage > 0 and IsUnarmedDamage(handle) then
		local unarmedMastery = 0
		local masteryEntry = Osi.DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience:Get(attacker, "LLWEAPONEX_Unarmed", nil, nil)
		if masteryEntry ~= nil and #masteryEntry > 0 and masteryEntry[1][3] ~= nil then
			unarmedMastery = masteryEntry[1][3]
		end

		local character = Ext.GetCharacter(attacker)
		--S_WPN_LLWEAPONEX_NoWeapon_UnarmedDamageHelper_c3110353-d794-4899-a383-36c8e5421d09
		local weapon = Ext.GetItem("c3110353-d794-4899-a383-36c8e5421d09")
		
		-- TODO: How to make the helper weapons always the level of the character?
		local level = character.Stats.Level
		local itemLevel = weapon.Stats.Level
		if itemLevel ~= level then
			Transform("c3110353-d794-4899-a383-36c8e5421d09", "WPN_LLWEAPONEX_NoWeapon_UnarmedDamageHelper_fce2a108-ad06-4f4c-aad4-0f55d763afa0", 0, 0, 1)
			ItemLevelUpTo("S_WPN_LLWEAPONEX_NoWeapon_DamageHelper_c3110353-d794-4899-a383-36c8e5421d09", level)
			itemLevel = weapon.Stats.Level
		end
		
		Ext.Print("Unarmed hit: damage("..tostring(damage)..") unarmedMastery("..tostring(unarmedMastery)..") attacker("..tostring(attacker)..") target("..tostring(target)..") attackerLevel("..tostring(level)..") itemLevel("..tostring(itemLevel)..")")

		local damageList = GetScaledUnarmedWeaponDamage(character.Stats, weapon.Stats, false, unarmedMastery)
		local damages = damageList:ToTable()
		NRD_HitClearAllDamage(handle)
		--NRD_HitStatusClearAllDamage(target, handle)
		for i,damage in pairs(damages) do
			--NRD_HitAddDamage(handle, damage.DamageType, damage.Amount)
			NRD_HitAddDamage(handle, damage.DamageType, damage.Amount)
			--NRD_HitStatusAddDamage(target, handle, damage.DamageType, damage.Amount)
		end
		--Ext.Print("Unarmed damage: ("..LeaderLib.Common.Dump(damages)..")")
	end
end

Ext.NewCall(LLWEAPONEX_Ext_ScaleUnarmedDamage, "LLWEAPONEX_Ext_ScaleUnarmedDamage", "(CHARACTERGUID)_Attacker, (GUIDSTRING)_Target, (INTEGER)_Damage, (INTEGER64)_Handle")