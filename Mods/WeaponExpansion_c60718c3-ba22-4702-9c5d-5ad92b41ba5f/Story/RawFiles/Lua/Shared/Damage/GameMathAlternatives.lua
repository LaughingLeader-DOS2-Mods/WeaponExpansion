-- from CDivinityStats_Character::Game.Math.CalculateWeaponDamageInner
--- @param character StatCharacter
--- @param weapon StatItem
--- @param damageList DamageList
--- @param noRandomization boolean
local function CalculateWeaponScaledDamage(character, weapon, damageList, noRandomization)
    local damages = Game.Math.CalculateWeaponScaledDamageRanges(character, weapon)

    for damageType, damage in pairs(damages) do
        --FIX for low damage range inaccuracy - Missing a +1
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

        damageList:Add(damageType, finalAmount)
    end
end

--- @param attacker StatCharacter
--- @param weapon StatItem
--- @param noRandomization boolean
local function CalculateWeaponDamage(attacker, weapon, noRandomization)
    local damageList = Ext.NewDamageList()

    CalculateWeaponScaledDamage(attacker, weapon, damageList, noRandomization)

    local offHand = attacker.OffHandWeapon
    if offHand ~= nil and weapon.InstanceId ~= offHand.InstanceId and false then -- Temporarily off
        local bonusWeapons = {}
        for i, bonusWeapon in pairs(bonusWeapons) do
            -- FIXME Create item from bonus weapon stat and apply attack as item???
            error("BonusWeapons not implemented")
            local bonusWeaponStats = Game.Math.CreateBonusWeapon(bonusWeapon)
            CalculateWeaponScaledDamage(attacker, bonusWeaponStats, damageList, noRandomization)
        end
    end

    Game.Math.ApplyDamageBoosts(attacker, damageList)

    if offHand ~= nil and weapon.InstanceId == offHand.InstanceId then
        damageList:Multiply(Ext.ExtraData.DualWieldingDamagePenalty)
    end

    return damageList
end

--- @param skill StatEntrySkillData
--- @param attacker StatCharacter
--- @param isFromItem boolean
--- @param stealthed boolean
--- @param attackerPos number[]
--- @param targetPos number[]
--- @param level integer
--- @param noRandomization boolean
--- @param weapon StatItem
--- @param offHand StatItem
local function GetSkillDamage(skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization, weapon, offHand)
    if attacker ~= nil and level < 0 then
        level = attacker.Level
    end

    local damageMultiplier = skill['Damage Multiplier'] * 0.01
    local damageMultipliers = Game.Math.GetDamageMultipliers(skill, stealthed, attackerPos, targetPos)
    local skillDamageType = nil

    if level == 0 then
        level = skill.OverrideSkillLevel
        if level == 0 then
            level = skill.Level
        end
    end

    local damageList = Ext.NewDamageList()

    if damageMultiplier <= 0 then
        return
    end

    if skill.UseWeaponDamage == "Yes" then
        local damageType = skill.DamageType
        if damageType == "None" or damageType == "Sentinel" then
            damageType = nil
        end

		if weapon == nil then weapon = attacker.MainWeapon end
		if offHand == nil then offHand = attacker.OffHandWeapon end

        if weapon ~= nil then
            local mainDmgs = CalculateWeaponDamage(attacker, weapon, noRandomization)
            mainDmgs:Multiply(damageMultipliers)
            if damageType ~= nil then
                mainDmgs:ConvertDamageType(damageType)
            end
            damageList:Merge(mainDmgs)
        end

        if offHand ~= nil and (weapon ~= nil and Game.Math.IsRangedWeapon(weapon) == Game.Math.IsRangedWeapon(offHand)) or (weapon == nil and Game.Math.IsRangedWeapon(offHand)) then
            local offHandDmgs = CalculateWeaponDamage(attacker, offHand, noRandomization)
            offHandDmgs:Multiply(damageMultipliers)
            if damageType ~= nil then
                offHandDmgs:ConvertDamageType(damageType)
                skillDamageType = damageType
            end
            damageList:Merge(offHandDmgs)
        end

        damageList:AggregateSameTypeDamages()
    else
        local damageType = skill.DamageType

        local baseDamage = Game.Math.CalculateBaseDamage(skill.Damage, attacker, 0, level)
        local damageRange = skill['Damage Range']
        local randomMultiplier
        if noRandomization then
            randomMultiplier = 0.0
        else
            randomMultiplier = 1.0 + (Ext.Random(0, damageRange) - damageRange/2) * 0.01
        end

        local attrDamageScale
        local skillDamage = skill.Damage
        if skillDamage == "BaseLevelDamage" or skillDamage == "AverageLevelDamge" then
            attrDamageScale = Game.Math.GetSkillAttributeDamageScale(skill, attacker)
        else
            attrDamageScale = 1.0
        end

        local damageBoost
        if attacker ~= nil then
            damageBoost = attacker.DamageBoost / 100.0 + 1.0
        else
            damageBoost = 1.0
        end
		
        local finalDamage = baseDamage * randomMultiplier * attrDamageScale * damageMultipliers
        finalDamage = math.max(Ext.Utils.Round(finalDamage), 1)
        finalDamage = math.ceil(finalDamage * damageBoost)
        damageList:Add(damageType, finalDamage)

        if attacker ~= nil then
            Game.Math.ApplyDamageBoosts(attacker, damageList)
        end
    end

    local deathType = skill.DeathType
    if deathType == "None" then
        if skill.UseWeaponDamage == "Yes" then
            deathType = Game.Math.GetDamageListDeathType(damageList)
        else
            if skillDamageType == nil then
                skillDamageType = skill.DamageType
            end

            deathType = Game.Math.DamageTypeToDeathType(skillDamageType)
        end
    end


    return damageList, deathType
end

--- @param character StatCharacter
--- @param skill StatEntrySkillData
--- @param mainWeapon StatItem
--- @param offHandWeapon StatItem
local function GetSkillDamageRange(character, skill, mainWeapon, offHandWeapon)
    local damageMultiplier = skill['Damage Multiplier'] * 0.01

    if skill.UseWeaponDamage == "Yes" then
        local mainWeapon = mainWeapon or character.MainWeapon
        local offHandWeapon = offHandWeapon or character.OffHandWeapon
        local mainDamageRange = Game.Math.CalculateWeaponScaledDamageRanges(character, mainWeapon)
        if offHandWeapon ~= nil and Game.Math.IsRangedWeapon(mainWeapon) == Game.Math.IsRangedWeapon(offHandWeapon) then
            local offHandDamageRange = Game.Math.CalculateWeaponScaledDamageRanges(character, offHandWeapon)

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
            --if range.Min == nil then range.Min = range.Max or 1 end
            --if range.Max == nil then range.Max = range.Min or 1 end
            local min = Ext.Utils.Round(range.Min * damageMultiplier)
            local max = Ext.Utils.Round(range.Max * damageMultiplier)
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

        local finalMin = math.ceil(math.ceil(Ext.Utils.Round(baseDamage - damageRange) * damageBoost) * damageTypeBoost)
        local finalMax = math.ceil(math.ceil(Ext.Utils.Round(baseDamage + damageRange) * damageBoost) * damageTypeBoost)

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

--- @param character StatCharacter
--- @param weapon StatItem
--- @return table,table
function Math.GetBaseAndCalculatedWeaponDamageRange(character, weapon)
    local damages, damageBoost = Game.Math.ComputeBaseWeaponDamage(weapon)

    local abilityBoosts = character.DamageBoost 
        + Game.Math.ComputeWeaponCombatAbilityBoost(character, weapon)
        + Game.Math.ComputeWeaponRequirementScaledDamage(character, weapon)
    abilityBoosts = math.max(abilityBoosts + 100.0, 0.0) / 100.0

    local boost = 1.0 + damageBoost * 0.01
    if not character.NotSneaking then
        boost = boost + Ext.ExtraData['Sneak Damage Multiplier']
    end

    local ranges = {}
    for damageType, damage in pairs(damages) do
        local min = math.ceil(damage.Min * boost * abilityBoosts)
        local max = math.ceil(damage.Max * boost * abilityBoosts)

        if min > max then
            max = min
        end

        ranges[damageType] = {min, max}
    end

    return damages,ranges
end

--- @param character StatCharacter
--- @param weapon StatItem
--- @param applyDualWieldingPenalty boolean
--- @return integer,integer,integer,integer
function Math.GetTotalBaseAndCalculatedWeaponDamage(character, weapon, applyDualWieldingPenalty)
    local baseMin = 0
    local baseMax = 0
    local totalMin = 0
    local totalMax = 0

    local mainDamageRange = Game.Math.CalculateWeaponScaledDamageRanges(character, weapon)

    return math.floor(baseMin),math.floor(baseMax),math.floor(totalMin),math.floor(totalMax)
end

-- function Math.GetTotalBaseAndCalculatedWeaponDamage(character, weapon, applyDualWieldingPenalty)
--     local baseMin = 0
--     local baseMax = 0
--     local totalMin = 0
--     local totalMax = 0

--     local damages, damageBoost = Game.Math.ComputeBaseWeaponDamage(weapon)
--     local penalty = applyDualWieldingPenalty == true and GameHelpers.GetExtraData("DualWieldingDamagePenalty", 1)

--     --CalculateWeaponDamageWithDamageBoost
--     local boost = 1.0 + damageBoost * 0.01
--     for damageType, damage in pairs(damages) do
--         baseMin = baseMin + Ext.Utils.Round(damage.Min * penalty)
--         baseMax = baseMax + Ext.Utils.Round(damage.Max * penalty)
--         if damageBoost ~= 0 then
--             damage.Min = math.ceil(damage.Min * boost)
--             damage.Max = math.ceil(damage.Max * boost)
--         else
--             damage.Min = Ext.Utils.Round(damage.Min)
--             damage.Max = Ext.Utils.Round(damage.Max)
--         end
--         totalMin = totalMin + damage.Min
--         totalMax = totalMax + damage.Max
--     end

--     --Game.Math.CalculateWeaponScaledDamageRanges
--     -- local boost = character.DamageBoost 
--     --     + Game.Math.ComputeWeaponCombatAbilityBoost(character, weapon)
--     --     + Game.Math.ComputeWeaponRequirementScaledDamage(character, weapon)
--     -- boost = boost / 100.0

--     -- if character.IsSneaking then
--     --     --boost = boost + Ext.ExtraData['Sneak Damage Multiplier']
--     -- end

--     -- local boostMin = math.max(-1.0, boost)

--     -- for damageType, damage in pairs(damages) do
--     --     damage.Min = damage.Min + math.ceil(damage.Min * boostMin)
--     --     damage.Max = damage.Max + math.ceil(damage.Max * boost)
--     --     totalMin = totalMin + damage.Min
--     --     totalMax = totalMax + damage.Max
--     -- end

--     return math.floor(baseMin),math.floor(baseMax),math.floor(totalMin),math.floor(totalMax)
-- end

Math.GetSkillDamage = GetSkillDamage
Math.GetSkillDamageRange = GetSkillDamageRange