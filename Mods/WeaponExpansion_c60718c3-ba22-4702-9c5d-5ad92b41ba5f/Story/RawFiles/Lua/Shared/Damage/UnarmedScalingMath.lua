--- @param character StatCharacter
--- @param weapon StatItem
local function ComputeWeaponCombatAbilityBoost(character, weapon, isDualWielding)
    local abilityType = isDualWielding == true and "DualWielding" or "SingleHanded"
	local abilityLevel = character[abilityType]
	return abilityLevel * Ext.ExtraData.CombatAbilityDamageBonus
end

--- @param weapon StatItem
local function GetWeaponScalingRequirement(weapon, attribute)
    local requirementName
    local largestRequirement = -1

    for i, requirement in pairs(weapon.Requirements) do
        local reqName = requirement.Requirement
        if not requirement.Not and requirement.Param > largestRequirement and
            (reqName == "Strength" or reqName == "Finesse" or reqName == "Intelligence" or
            reqName == "Constitution" or reqName == "Memory" or reqName == "Wits") then
            requirementName = reqName
            largestRequirement = requirement.Param
        end
    end

    return requirementName
end

--- @param character StatCharacter
--- @param weapon StatItem
local function ComputeWeaponRequirementScaledDamage(character, weapon, attribute)
    return Game.Math.ScaledDamageFromPrimaryAttribute(character[attribute]) * 100.0
end

-- from CDivinityStats_Item::ComputeDamage
--- @param weapon StatItem
local function ComputeBaseWeaponDamage(weapon)
    local damages = {}
    local stats = weapon.DynamicStats
    local baseStat = stats[1]
    local baseDmgFromBase = baseStat.DamageFromBase * 0.01
    local baseMinDamage = baseStat.MinDamage
    local baseMaxDamage = baseStat.MaxDamage
    local damageBoost = 0

    for i, stat in pairs(stats) do
        if stat.StatsType == "Weapon" then
            damageBoost = damageBoost + stat.DamageBoost

            --Changed to allow "Pure" damage
            if stat.DamageFromBase > 0 then
                local dmgType = stat.DamageType
                local dmgFromBase = stat.DamageFromBase * 0.01
                local minDamage = stat.MinDamage
                local maxDamage = stat.MaxDamage

                if dmgFromBase ~= 0 then
                    if stat == baseStat then
                        if baseMinDamage ~= 0 then
                            minDamage = math.max(dmgFromBase * baseMinDamage, 1.0)
                        end
                        if baseMaxDamage ~= 0 then
                            maxDamage = math.max(dmgFromBase * baseMaxDamage, 1.0)
                        end
                    else
                        minDamage = math.max(baseDmgFromBase * dmgFromBase * baseMinDamage, 1.0)
                        maxDamage = math.max(baseDmgFromBase * dmgFromBase * baseMaxDamage, 1.0)
                    end
                end

                if minDamage > 0 then
                    maxDamage = math.max(maxDamage, minDamage + 1.0)
                end

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
            end
        end
    end

    return damages, damageBoost
end

--- @param weapon StatItem
local function CalculateWeaponDamageWithDamageBoost(weapon)
    local damages, damageBoost = ComputeBaseWeaponDamage(weapon)
    local boost = 1.0 + damageBoost * 0.01

    for damageType, damage in pairs(damages) do
        if damageBoost ~= 0 then
            damage.Min = math.ceil(damage.Min * boost)
            damage.Max = math.ceil(damage.Max * boost)
        else
            damage.Min = Ext.Round(damage.Min)
            damage.Max = Ext.Round(damage.Max)
        end
    end

    return damages
end

local function CalculateWeaponScaledDamageRanges(character, weapon, isDualWielding, attribute)
	local baseMin,baseMax = 0,0
	local damages = CalculateWeaponDamageWithDamageBoost(weapon)
	
	for damageType, damage in pairs(damages) do
		baseMin = baseMin + damage.Min
		baseMax = baseMax + damage.Max
    end

    local boost = character.DamageBoost
        + ComputeWeaponCombatAbilityBoost(character, weapon, isDualWielding)
        + ComputeWeaponRequirementScaledDamage(character, weapon, attribute)
    boost = boost / 100.0

    if character.IsSneaking then
        boost = boost + Ext.ExtraData['Sneak Damage Multiplier']
    end

    local boostMin = math.max(-1.0, boost)

	for damageType, damage in pairs(damages) do
        damage.Min = damage.Min + math.ceil(damage.Min * boostMin)
        damage.Max = damage.Max + math.ceil(damage.Max * boost)
    end

    return damages,baseMin,baseMax
end

-- from CDivinityStats_Character::CalculateWeaponDamageInner
--- @param character StatCharacter
--- @param weapon StatItem
--- @param damageList DamageList
--- @param noRandomization boolean
local function CalculateWeaponScaledDamage(character, weapon, damageList, noRandomization, isDualWielding, attribute)
	local damages,baseMin,baseMax = CalculateWeaponScaledDamageRanges(character, weapon, isDualWielding, attribute)
	local totalMin,totalMax = 0,0

	for damageType, damage in pairs(damages) do
        totalMin = totalMin + damage.Min
        local randRange = 1
        if damage.Max - damage.Min + 1 >= 1 then
            randRange = damage.Max - damage.Min + 1
        end
        local finalAmount = 0
		
        if noRandomization then
            finalAmount = damage.Min + math.floor(randRange / 2)
        else
            finalAmount = damage.Min + Ext.Random(0, randRange)
        end

		totalMax = totalMax + finalAmount
        damageList:Add(damageType, finalAmount)
	end
	
	return baseMin,baseMax,totalMin,totalMax
end

--- @param character StatCharacter
--- @param damageList DamageList
local function ApplyDamageBoosts(character, damageList)
    for i, damage in pairs(damageList:ToTable()) do
        local boost = Game.Math.GetDamageBoostByType(character, damage.DamageType)
        if boost > 0.0 then
            damageList:Add(damage.DamageType, Ext.Round(damage.Amount * boost))
        end
    end
end

--- @param attacker StatCharacter
--- @param weapon StatItem
--- @param noRandomization boolean
--- @param attribute string
--- @param isDualWielding boolean
--- @param isOffhand boolean
function UnarmedHelpers.CalculateWeaponDamage(attacker, weapon, noRandomization, attribute, isDualWielding, isOffhand)
    local damageList = Ext.NewDamageList()

    local baseMin,baseMax,totalMin,totalMax = CalculateWeaponScaledDamage(attacker, weapon, damageList, noRandomization, isDualWielding, attribute)

    ApplyDamageBoosts(attacker, damageList)

    if isOffhand then
        damageList:Multiply(Ext.ExtraData.DualWieldingDamagePenalty)
		baseMin = Ext.Round(baseMin * Ext.ExtraData.DualWieldingDamagePenalty)
		baseMax = Ext.Round(baseMax * Ext.ExtraData.DualWieldingDamagePenalty)
		totalMin = Ext.Round(totalMin * Ext.ExtraData.DualWieldingDamagePenalty)
		totalMax = Ext.Round(totalMax * Ext.ExtraData.DualWieldingDamagePenalty)
    end

    return damageList,baseMin,baseMax,totalMin,totalMax
end



---@alias LLWEAPONEXDamageRange table<DAMAGE_TYPE, LLWEAPONEXDamageRangeEntry>

---@class LLWEAPONEXDamageRangeEntry
---@field Min integer
---@field Max integer


--- @param weapon StatItem
--- @return LLWEAPONEXDamageRange
function UnarmedHelpers.CalculateBaseWeaponDamageRange(weapon)
    local damages = ComputeBaseWeaponDamage(weapon)

    for damageType, damage in pairs(damages) do
        damage.Min = Ext.Round(damage.Min)
        damage.Max = Ext.Round(damage.Max)
    end

    return damages
end

--- @param character StatCharacter
--- @param weapon StatItem
--- @param attribute string The scaling attribute.
--- @param isDualWielding boolean|nil
--- @return LLWEAPONEXDamageRange
function UnarmedHelpers.CalculateWeaponDamageRange(character, weapon, attribute, isDualWielding)
    return CalculateWeaponScaledDamageRanges(character, weapon, isDualWielding, attribute)
end