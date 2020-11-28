local math = math
local table = table
local debug = debug
local pairs = pairs
local type = type
local setmetatable = setmetatable
local xpcall = xpcall
local Ext = Ext
local Game = Game
local print = print
local printf = LeaderLib.PrintLog

_ENV = Game.Math
if setfenv ~= nil then
    setfenv(1, Game.Math)
end

-- from CDivinityStats_Item::ComputeDamage
--- @param weapon StatItem
function ComputeBaseWeaponDamage(weapon)
    local damages = {}
    local stats = weapon.DynamicStats
    local baseStat = stats[1]
    local baseDmgFromBase = baseStat.DamageFromBase * 0.01
    local baseMinDamage = baseStat.MinDamage
    local baseMaxDamage = baseStat.MaxDamage
    local damageBoost = 0

    printf("[Game.Math.ComputeBaseWeaponDamage][%s] baseMinDamage(%s) baseMaxDamage(%s) baseDmgFromBase(%s) damageBoost(%s)", weapon.Name, baseMinDamage, baseMaxDamage, baseDmgFromBase, damageBoost)

    for i, stat in pairs(stats) do
        printf("[Game.Math.ComputeBaseWeaponDamage][%s] StatsType(%s) DamageType(%s) damageBoost(%s)", i, stat.StatsType, stat.DamageType, stat.DamageBoost)
        if stat.StatsType == "Weapon" then
            damageBoost = damageBoost + stat.DamageBoost

            if stat.DamageType ~= "None" then
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

                printf("[Game.Math.ComputeBaseWeaponDamage][%s] dmgFromBase(%s) minDamage(%s) maxDamage(%s) damageBoost(%s)", i, dmgFromBase, minDamage, maxDamage, damageBoost)

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

    print(Ext.JsonStringify(damages))

    return damages, damageBoost
end

-- from CDivinityStats_Item::ComputeDamage
--- @param weapon StatItem
function CalculateWeaponDamageWithDamageBoost(weapon)
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

    printf("[Game.Math.CalculateWeaponDamageWithDamageBoost] boost(%s) damageBoost(%s)", boost, damageBoost)
    Ext.JsonStringify(damages)

    return damages
end

--- @param character StatCharacter
--- @param skill StatEntrySkillData
--- @param mainWeapon StatItem  Optional mainhand weapon to use in place of the character's.
--- @param offHandWeapon StatItem   Optional offhand weapon to use in place of the character's.
function GetSkillDamageRange(character, skill, mainWeapon, offHandWeapon)
    local damageMultiplier = skill['Damage Multiplier'] * 0.01
    local result

    if skill.UseWeaponDamage == "Yes" then
        local mainWeapon = mainWeapon or character.MainWeapon
        local offHandWeapon = offHandWeapon or character.OffHandWeapon
        local mainDamageRange = CalculateWeaponScaledDamageRanges(character, mainWeapon)

        if offHandWeapon ~= nil and IsRangedWeapon(mainWeapon) == IsRangedWeapon(offHandWeapon) then
            local offHandDamageRange = CalculateWeaponScaledDamageRanges(character, offHandWeapon)

            -- Note: This differs from the way the game applies DualWieldingDamagePenalty.
            -- In the original tooltip code, it is applied for the whole damage value,
            -- not per damage type, so the result may differ from the original tooltip code
            -- if DualWieldingDamagePenalty is not 1.0 or 0.5.
            -- However, this formula is the correct one and the vanilla tooltip returns
            -- buggy values if DualWieldingDamagePenalty ~= 1.0 and ~= 0.5
            local dualWieldPenalty = Ext.ExtraData.DualWieldingDamagePenalty
            for damageType, range in pairs(offHandDamageRange) do
                local min = math.ceil(range.Min * dualWieldPenalty)
                local max = math.ceil(range.Max * dualWieldPenalty)
                local range = mainDamageRange[damageType]
                if mainDamageRange[damageType] ~= nil then
                    range.Min = range.Min + min
                    range.Max = range.Max + max
                else
                    mainDamageRange[damageType] = {Min = min, Max = max}
                end
            end
        end

        for damageType, range in pairs(mainDamageRange) do
            printf("mainDamageRange| damageType(%s) GetDamageBoostByType(%s)", damageType, GetDamageBoostByType(character, damageType))
            local min = Ext.Round(range.Min * damageMultiplier)
            local max = Ext.Round(range.Max * damageMultiplier)
            range.Min = min + math.ceil(min * GetDamageBoostByType(character, damageType))
            range.Max = max + math.ceil(max * GetDamageBoostByType(character, damageType))
        end
        printf("[Game.Math.GetSkillDamageRange] Min(%s) Max(%s)", mainDamageRange.Physical.Min, mainDamageRange.Physical.Max)
        local damageType = skill.DamageType
        if damageType ~= "None" and damageType ~= "Sentinel" then
            local min, max = 0, 0
            local boost = GetDamageBoostByType(character, damageType)
            for _, range in pairs(mainDamageRange) do
                min = min + range.Min + math.ceil(range.Min * boost)
                max = max + range.Max + math.ceil(range.Min * boost)
            end
            printf("[Game.Math.GetSkillDamageRange] damageType(%s) GetDamageBoostByType(%s)", damageType, GetDamageBoostByType(character, damageType))
            mainDamageRange = {}
            mainDamageRange[damageType] = {Min = min, Max = max}
        end

        result = mainDamageRange
    else
        local damageType = skill.DamageType
        if damageMultiplier <= 0 then
            return {}
        end

        local level = character.Level
        if (level < 0 or skill.OverrideSkillLevel == "Yes") and skill.Level > 0 then
            level = skill.Level
        end

        local skillDamageType = skill.Damage
        local attrDamageScale
        if skillDamageType == "BaseLevelDamage" or skillDamageType == "AverageLevelDamge" or skillDamageType == "MonsterWeaponDamage" then
            attrDamageScale = GetSkillAttributeDamageScale(skill, character)
        else
            attrDamageScale = 1.0
        end

        local baseDamage = CalculateBaseDamage(skill.Damage, character, nil, level) * attrDamageScale * damageMultiplier
        local damageRange = skill['Damage Range'] * baseDamage * 0.005

        local damageTypeBoost = 1.0 + GetDamageBoostByType(character, damageType)
        local damageBoost = 1.0 + (character.DamageBoost / 100.0)

        local finalMin = math.ceil(math.ceil(Ext.Round(baseDamage - damageRange) * damageBoost) * damageTypeBoost)
        local finalMax = math.ceil(math.ceil(Ext.Round(baseDamage + damageRange) * damageBoost) * damageTypeBoost)

        if finalMin > 0 then
            finalMax = math.max(finalMin + 1.0, finalMax)
        end

        local damageRanges = {}
        damageRanges[damageType] = {
            Min = finalMin, Max = finalMax
        }
        result = damageRanges
    end

    -- Compatibility hack for old (v50) table format
    for i,range in pairs(result) do
        range[1] = range.Min
        range[2] = range.Max
    end

    return result
end

-- from CDivinityStats_Item::ComputeScaledDamage
--- @param character StatCharacter
--- @param weapon StatItem
function CalculateWeaponScaledDamageRanges(character, weapon)
    local damages = CalculateWeaponDamageWithDamageBoost(weapon)

    local boost = character.DamageBoost 
        + ComputeWeaponCombatAbilityBoost(character, weapon)
        + ComputeWeaponRequirementScaledDamage(character, weapon)
    boost = boost / 100.0

    if character.IsSneaking then
        boost = boost + Ext.ExtraData['Sneak Damage Multiplier']
    end

    local boostMin = math.max(-1.0, boost)

    printf("[Game.Math.CalculateWeaponScaledDamageRanges] ComputeWeaponCombatAbilityBoost(%s) ComputeWeaponRequirementScaledDamage(%s) character.DamageBoost(%s)", ComputeWeaponCombatAbilityBoost(character, weapon), ComputeWeaponRequirementScaledDamage(character, weapon), character.DamageBoost)
    printf("[Game.Math.CalculateWeaponScaledDamageRanges] boost(%s) boostMin(%s) weapon.DamageFromBase(%s) weapon.Damage Range(%s) weapon.MinDamage(%s) weapon.MaxDamage(%s)", boost, boostMin, weapon.DynamicStats[1].DamageFromBase, weapon["Damage Range"], weapon.DynamicStats[1].MinDamage, weapon.DynamicStats[1].MaxDamage)
    print(Ext.JsonStringify(damages))

    for damageType, damage in pairs(damages) do
        damage.Min = damage.Min + math.ceil(damage.Min * boostMin)
        damage.Max = damage.Max + math.ceil(damage.Max * boost)
    end

    printf("[Game.Math.CalculateWeaponScaledDamageRanges] Min(%s) Max(%s)", damages.Physical.Min, damages.Physical.Max)

    return damages
end