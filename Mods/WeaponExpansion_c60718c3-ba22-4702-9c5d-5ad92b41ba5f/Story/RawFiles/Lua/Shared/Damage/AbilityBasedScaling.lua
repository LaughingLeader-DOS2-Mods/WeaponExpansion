local printf = LeaderLib.PrintLog

Math.AbilityScaling = {}

--- @param ability integer
function Math.AbilityScaling.ScaledDamageFromPrimaryAbility(ability)
    local attributeMax = Ext.ExtraData.AttributeSoftCap - Ext.ExtraData.AttributeBaseValue
    local damageBonusMult = attributeMax/Ext.ExtraData.CombatAbilityCap
    local result = (ability - Ext.ExtraData.AbilityBaseValue) * (Ext.ExtraData.DamageBoostFromAttribute * damageBonusMult)
    -- if Vars.DebugEnabled then
    --     print("ScaledDamageFromPrimaryAttribute",ability,result,Game.Math.ScaledDamageFromPrimaryAttribute(40))
    -- end
    return result
end

--- @param skill StatEntrySkillData
--- @param attacker StatCharacter
--- @param ability string
function Math.AbilityScaling.GetSkillAttributeDamageScale(skill, attacker, ability)
    return 1.0 + Math.AbilityScaling.ScaledDamageFromPrimaryAbility(attacker[ability])
end

--- @param character StatCharacter
--- @param weapon StatItem
function Math.AbilityScaling.ComputeWeaponRequirementScaledDamage(character, weapon, ability)
    if ability ~= nil then
        return Math.AbilityScaling.ScaledDamageFromPrimaryAbility(character[ability]) * 100.0
    else
        return 0
    end
end

--- @param character StatCharacter
--- @param weapon StatItem
function Math.AbilityScaling.ComputeWeaponCombatAbilityBoost(character, weapon)
    local abilityType = Game.Math.GetWeaponAbility(character, weapon)

    if abilityType == "SingleHanded" or abilityType == "TwoHanded" or abilityType == "Ranged" or abilityType == "DualWielding" then
        local abilityLevel = character[abilityType]
        return abilityLevel * Ext.ExtraData.CombatAbilityDamageBonus
    else
        return 0
    end
end

--- @param character StatCharacter
--- @param weapon StatItem
--- @param ability string
function Math.AbilityScaling.CalculateWeaponScaledDamageRanges(character, weapon, ability)
    local damages = Game.Math.CalculateWeaponDamageWithDamageBoost(weapon)

    local boost = character.DamageBoost 
        + Math.AbilityScaling.ComputeWeaponCombatAbilityBoost(character, weapon)
        + Math.AbilityScaling.ComputeWeaponRequirementScaledDamage(character, weapon, ability)
    boost = boost / 100.0

    boost = boost + 0.1

    if character.IsSneaking then
        boost = boost + Ext.ExtraData['Sneak Damage Multiplier']
    end

    local boostMin = math.max(-1.0, boost)

    --printf("[AbilityScaling.CalculateWeaponScaledDamageRanges] ComputeWeaponCombatAbilityBoost(%s) ComputeWeaponRequirementScaledDamage(%s) character.DamageBoost(%s)", Math.AbilityScaling.ComputeWeaponCombatAbilityBoost(character, weapon), Math.AbilityScaling.ComputeWeaponRequirementScaledDamage(character, weapon, ability), character.DamageBoost)

    --printf("[AbilityScaling.CalculateWeaponScaledDamageRanges] boost(%s) boostMin(%s) weapon.DamageFromBase(%s) weapon.Damage Range(%s) weapon.MinDamage(%s) weapon.MaxDamage(%s)", boost, boostMin, weapon.DynamicStats[1].DamageFromBase, weapon["Damage Range"], weapon.DynamicStats[1].MinDamage, weapon.DynamicStats[1].MaxDamage)
    --print(Ext.JsonStringify(damages))

    for damageType, damage in pairs(damages) do
        damage.Min = damage.Min + math.ceil(damage.Min * boostMin)
        damage.Max = damage.Max + math.ceil(damage.Max * boost)
    end

    --printf("[AbilityScaling.CalculateWeaponScaledDamageRanges] Min(%s) Max(%s)", damages.Physical.Min, damages.Physical.Max)

    return damages
end

-- from CDivinityStats_Character::CalculateWeaponDamageInner and CDivinityStats_Item::ComputeScaledDamage
--- @param character StatCharacter
--- @param weapon StatItem
--- @param damageList DamageList
--- @param noRandomization boolean
--- @param ability string
function Math.AbilityScaling.CalculateWeaponScaledDamage(character, weapon, damageList, noRandomization, ability)
    local damages = Math.AbilityScaling.CalculateWeaponScaledDamageRanges(character, weapon, ability)

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
end

--- @param attacker StatCharacter
--- @param weapon StatItem
--- @param noRandomization boolean
--- @param ability string
function Math.AbilityScaling.CalculateWeaponDamage(attacker, weapon, offHand, noRandomization, ability)
    local damageList = Ext.NewDamageList()

    Math.AbilityScaling.CalculateWeaponScaledDamage(attacker, weapon, damageList, noRandomization, ability)

    if offHand ~= nil and weapon.InstanceId ~= offHand.InstanceId and false then -- Temporarily off
        local bonusWeapons = attacker.BonusWeapons -- FIXME - enumerate BonusWeapons /multiple/ from character stats!
        for i, bonusWeapon in pairs(bonusWeapons) do
            -- FIXME Create item from bonus weapon stat and apply attack as item???
            error("BonusWeapons not implemented")
            local bonusWeaponStats = Game.Math.CreateBonusWeapon(bonusWeapon)
            Math.AbilityScaling.CalculateWeaponScaledDamage(attacker, bonusWeaponStats, damageList, noRandomization, ability)
        end
    end

    Game.Math.ApplyDamageBoosts(attacker, damageList)

    if offHand ~= nil and weapon.InstanceId == offHand.InstanceId then
        damageList:Multiply(Ext.ExtraData.DualWieldingDamagePenalty)
    end

    return damageList
end


--- @param character StatCharacter
--- @param skill StatEntrySkillData
function Math.AbilityScaling.GetSkillDamageRange(character, skill, mainWeapon, offHandWeapon, ability, useWeaponDamageCalc)
    local damageMultiplier = skill['Damage Multiplier'] * 0.01
    --print(damageMultiplier, skill["Damage Multiplier"])

    if skill.UseWeaponDamage == "Yes" or useWeaponDamageCalc == true then
        local mainDamageRange = Math.AbilityScaling.CalculateWeaponScaledDamageRanges(character, mainWeapon, ability)

        if offHandWeapon ~= nil and Game.Math.IsRangedWeapon(mainWeapon) == Game.Math.IsRangedWeapon(offHandWeapon) then
            local offHandDamageRange = Math.AbilityScaling.CalculateWeaponScaledDamageRanges(character, offHandWeapon, ability)

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
                    mainDamageRange[damageType] = {Min = min, Min = max}
                end
            end
        end

        for damageType, range in pairs(mainDamageRange) do
            --printf("[AbilityScaling.mainDamageRange] damageType(%s) GetDamageBoostByType(%s)", damageType, Game.Math.GetDamageBoostByType(character, damageType))
            local min = Ext.Round(range.Min * damageMultiplier)
            local max = Ext.Round(range.Max * damageMultiplier)
            range.Min = min + math.ceil(min * Game.Math.GetDamageBoostByType(character, damageType))
            range.Max = max + math.ceil(max * Game.Math.GetDamageBoostByType(character, damageType))
        end
        --printf("[AbilityScaling.GetSkillDamageRange] Min(%s) Max(%s)", mainDamageRange.Physical.Min, mainDamageRange.Physical.Max)
        local damageType = skill.DamageType
        if damageType ~= "None" and damageType ~= "Sentinel" then
            local min, max = 0, 0
            local boost = Game.Math.GetDamageBoostByType(character, damageType)
            for _, range in pairs(mainDamageRange) do
                min = min + range.Min + math.ceil(range.Min * boost)
                max = max + range.Max + math.ceil(range.Min * boost)
            end
            --printf("[AbilityScaling.mainDamageRange] damageType(%s) GetDamageBoostByType(%s)", damageType, Game.Math.GetDamageBoostByType(character, damageType))
    
            mainDamageRange = {}
            mainDamageRange[damageType] = {Min = min, Max = max}
        end

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
            attrDamageScale = Math.AbilityScaling.GetSkillAttributeDamageScale(skill, character, ability)
        else
            attrDamageScale = 1.0
        end
        
        local baseDamage = Game.Math.CalculateBaseDamage(skill.Damage, character, nil, level) * attrDamageScale * damageMultiplier
        local damageRange = skill['Damage Range'] * baseDamage * 0.005
        
        local damageTypeBoost = 1.0 + Game.Math.GetDamageBoostByType(character, damageType)
        local damageBoost = 1.0 + (character.DamageBoost / 100.0)
        --print(attrDamageScale, damageMultiplier, Game.Math.CalculateBaseDamage(skill.Damage, character, nil, level), baseDamage, damageTypeBoost, damageBoost)

        local finalMin = math.ceil(math.ceil(Ext.Round(baseDamage - damageRange) * damageBoost) * damageTypeBoost)
        local finalMax = math.ceil(math.ceil(Ext.Round(baseDamage + damageRange) * damageBoost) * damageTypeBoost)

        if finalMin > 0 then
            finalMax = math.max(finalMin + 1.0, finalMax)
        end

        local damageRanges = {}
        damageRanges[damageType] = {
            Min = finalMin, Max = finalMax
        }
        return damageRanges
    end
end