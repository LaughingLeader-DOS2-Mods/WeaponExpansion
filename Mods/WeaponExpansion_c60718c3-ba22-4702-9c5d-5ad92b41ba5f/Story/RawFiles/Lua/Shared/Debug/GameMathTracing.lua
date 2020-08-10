
-- from CDivinityStats_Item::ComputeDamage
--- @param weapon StatItem
function Game.Math.ComputeBaseWeaponDamage(weapon)
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

    print("ComputeBaseWeaponDamage", Ext.JsonStringify(damages))

    return damages, damageBoost
end

-- from CDivinityStats_Item::ComputeDamage
--- @param weapon StatItem
function Game.Math.CalculateWeaponDamageWithDamageBoost(weapon)
    local damages, damageBoost = Game.Math.ComputeBaseWeaponDamage(weapon)
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

    print("CalculateWeaponDamageWithDamageBoost", Ext.JsonStringify(damages))
    return damages
end

-- from CDivinityStats_Item::ComputeScaledDamage
--- @param character StatCharacter
--- @param weapon StatItem
function Game.Math.CalculateWeaponScaledDamageRanges(character, weapon)
    local damages = Game.Math.CalculateWeaponDamageWithDamageBoost(weapon)

    local boost = character.DamageBoost 
        + Game.Math.ComputeWeaponCombatAbilityBoost(character, weapon)
        + Game.Math.ComputeWeaponRequirementScaledDamage(character, weapon)
    boost = boost / 100.0

    if character.IsSneaking then
        boost = boost + Ext.ExtraData['Sneak Damage Multiplier']
    end

    local boostMin = math.max(-1.0, boost)

    for damageType, damage in pairs(damages) do
        damage.Min = damage.Min + math.ceil(damage.Min * boostMin)
        damage.Max = damage.Max + math.ceil(damage.Max * boost)
    end
    print("CalculateWeaponScaledDamageRanges", Ext.JsonStringify(damages))
    return damages
end

function Game.Math.CalculateWeaponScaledDamage(character, weapon, damageList, noRandomization)
    local damages = Game.Math.CalculateWeaponScaledDamageRanges(character, weapon)

    for damageType, damage in pairs(damages) do
        local randRange = math.max(1, damage.Max - damage.Min)
        local finalAmount

        if noRandomization then
            finalAmount = damage.Min + math.floor(randRange / 2)
        else
            finalAmount = damage.Min + Ext.Random(0, randRange)
        end

        damageList:Add(damageType, finalAmount)
    end

    print("CalculateWeaponScaledDamage", Ext.JsonStringify(damages))
end

function Game.Math.GetSkillDamageRange(character, skill)
    local damageMultiplier = skill['Damage Multiplier'] * 0.01
    
    if skill.UseWeaponDamage == "Yes" then
        local mainWeapon = character.MainWeapon
        local offHandWeapon = character.OffHandWeapon
        local mainDamageRange = Game.Math.CalculateWeaponScaledDamageRanges(character, mainWeapon)
		print("GetSkillDamageRange|BeforeOffhand", Ext.JsonStringify(mainDamageRange))
        if offHandWeapon ~= nil and Game.Math.IsRangedWeapon(mainWeapon) == Game.Math.IsRangedWeapon(offHandWeapon) then
            local offHandDamageRange = Game.Math.CalculateWeaponScaledDamageRanges(character, offHandWeapon)
			print("GetSkillDamageRange|offHandDamageRange", Ext.JsonStringify(offHandDamageRange))
            -- Note: This differs from the way the game applies DualWieldingDamagePenalty.
            -- In the original tooltip code, it is applied for the whole damage value,
            -- not per damage type, so the result may differ from the original tooltip code
            -- if DualWieldingDamagePenalty is not 1.0 or 0.5.
            -- However, this formula is the correct one and the vanilla tooltip returns
            -- buggy values if DualWieldingDamagePenalty ~= 1.0 and ~= 0.5
			local dualWieldPenalty = Ext.ExtraData.DualWieldingDamagePenalty
			print("Ext.ExtraData.DualWieldingDamagePenalty", dualWieldPenalty)
            for damageType, range in pairs(offHandDamageRange) do
                local min = math.ceil(range.Min * dualWieldPenalty)
                local max = math.ceil(range.Max * dualWieldPenalty)
				local mainRange = mainDamageRange[damageType]
				print("mainDamageRange",damageType,Ext.JsonStringify(mainRange))
                if mainRange ~= nil then
                    mainRange.Min = mainRange.Min + min
                    mainRange.Max = mainRange.Max + max
                else
                    mainDamageRange[damageType] = {Min = min, Max = max}
				end
				print(damageType, range.Min, range.Max, min, max, Ext.JsonStringify(mainDamageRange[damageType]))
            end
        end
		print("GetSkillDamageRange|AfterOffhand", Ext.JsonStringify(mainDamageRange))
        for damageType, range in pairs(mainDamageRange) do
            local min = Ext.Round(range.Min * damageMultiplier)
            local max = Ext.Round(range.Max * damageMultiplier)
            range.Min = min + math.ceil(min * Game.Math.GetDamageBoostByType(character, damageType))
            range.Max = max + math.ceil(max * Game.Math.GetDamageBoostByType(character, damageType))
        end

        local damageType = skill.DamageType
        if damageType ~= "None" and damageType ~= "Sentinel" then
            local min, max = 0, 0
            local boost = Game.Math.GetDamageBoostByType(character, damageType)
            for _, range in pairs(mainDamageRange) do
                min = min + range.Min + math.ceil(range.Min * Game.Math.GetDamageBoostByType(character, damageType))
                max = max + range.Max + math.ceil(range.Min * Game.Math.GetDamageBoostByType(character, damageType))
            end
    
            mainDamageRange = {}
            mainDamageRange[damageType] = {Min = min, Max = max}
        end
        print("GetSkillDamageRange|Final", Ext.JsonStringify(mainDamageRange))
        return mainDamageRange
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
            attrDamageScale = Game.Math.GetSkillAttributeDamageScale(skill, character)
        else
            attrDamageScale = 1.0
        end

        local baseDamage = Game.Math.CalculateBaseDamage(skill.Damage, character, nil, level) * attrDamageScale * damageMultiplier
        local damageRange = skill['Damage Range'] * baseDamage * 0.005

        local damageTypeBoost = 1.0 + Game.Math.GetDamageBoostByType(character, damageType)
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
        print("GetSkillDamageRange", Ext.JsonStringify(damageRanges))
        return damageRanges
    end
end