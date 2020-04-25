--- @param ability integer
local function ScaledDamageFromPrimaryAttribute(ability)
	local attributeMax = Ext.ExtraData.AttributeSoftCap - Ext.ExtraData.AttributeBaseValue
    return (ability - Ext.ExtraData.AbilityBaseValue) * (Ext.ExtraData.DamageBoostFromAttribute * (attributeMax/Ext.ExtraData.CombatAbilityCap))
end

--- @param skill StatEntrySkillData
--- @param attacker StatCharacter
local function GetSkillAttributeDamageScale(skill, attacker, ability)
    if attacker == nil or skill.UseWeaponDamage == "Yes" or skill.Ability == 0 then
        return 1.0
    else
        return 1.0 + ScaledDamageFromAbility(ability)
    end
end

--- @param character StatCharacter
--- @param weapon StatItem
local function ComputeWeaponRequirementScaledDamage(character, weapon, ability)
	--Ext.Print("Character ability: ", ability, character, "Character("..tostring(character)..")")
    if ability ~= nil then
        return ScaledDamageFromPrimaryAttribute(character[ability]) * 100.0
    else
        return 0
    end
end

--- @param character StatCharacter
--- @param weapon StatItem
local function ComputeWeaponCombatAbilityBoost(character, weapon)
    local abilityType = Game.Math.GetWeaponAbility(character, weapon)

    if abilityType == "SingleHanded" or abilityType == "TwoHanded" or abilityType == "Ranged" or abilityType == "DualWielding" then
        local abilityLevel = character[abilityType]
        return abilityLevel * Ext.ExtraData.CombatAbilityDamageBonus
    else
        return 0
    end
end


-- from CDivinityStats_Character::CalculateWeaponDamageInner and CDivinityStats_Item::ComputeScaledDamage
--- @param character StatCharacter
--- @param weapon StatItem
--- @param damageList DamageList
--- @param noRandomization boolean
--- @param ability string
local function CalculateWeaponScaledDamage(character, weapon, damageList, noRandomization, ability)
    local damages, damageBoost = Game.Math.ComputeBaseWeaponDamage(weapon)

    local abilityBoosts = character.DamageBoost 
        + ComputeWeaponCombatAbilityBoost(character, weapon)
        + ComputeWeaponRequirementScaledDamage(character, weapon, ability)
    abilityBoosts = math.max(abilityBoosts + 100.0, 0.0) / 100.0

    local boost = 1.0 + damageBoost * 0.01
    if character.NotSneaking then
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
end

--- @param attacker StatCharacter
--- @param weapon StatItem
--- @param noRandomization boolean
--- @param ability string
local function CalculateWeaponDamage(attacker, weapon, offHand, noRandomization, ability)
    local damageList = Ext.NewDamageList()

    CalculateWeaponScaledDamage(attacker, weapon, damageList, noRandomization, ability)

    if offHand ~= nil and weapon.InstanceId ~= offHand.InstanceId and false then -- Temporarily off
        local bonusWeapons = attacker.BonusWeapons -- FIXME - enumerate BonusWeapons /multiple/ from character stats!
        for i, bonusWeapon in pairs(bonusWeapons) do
            -- FIXME Create item from bonus weapon stat and apply attack as item???
            error("BonusWeapons not implemented")
            local bonusWeaponStats = Game.Math.CreateBonusWeapon(bonusWeapon)
            CalculateWeaponScaledDamage(attacker, bonusWeaponStats, damageList, noRandomization, ability)
        end
    end

    Game.Math.ApplyDamageBoosts(attacker, damageList)

    if offHand ~= nil and weapon.InstanceId == offHand.InstanceId then
        damageList:Multiply(Ext.ExtraData.DualWieldingDamagePenalty)
    end

    return damageList
end

--- @param character StatCharacter
--- @param weapon StatItem
--- @param ability string
--- @return number[]
local function CalculateWeaponDamageRange(character, weapon, ability)
    local damages, damageBoost = Game.Math.ComputeBaseWeaponDamage(weapon)

    local abilityBoosts = character.DamageBoost 
        + ComputeWeaponCombatAbilityBoost(character, weapon)
        + ComputeWeaponRequirementScaledDamage(character, weapon, ability)
    abilityBoosts = math.max(abilityBoosts + 100.0, 0.0) / 100.0

    local boost = 1.0 + damageBoost * 0.01
    if character.NotSneaking then
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

    return ranges
end

--- @param character StatCharacter
--- @param skill StatEntrySkillData
--- @param ability string
local function GetSkillDamageRange(character, skill, mainWeapon, offHandWeapon, ability)
    local damageMultiplier = skill['Damage Multiplier'] * 0.01

    if skill.UseWeaponDamage == "Yes" then
        local mainDamageRange = CalculateWeaponDamageRange(character, mainWeapon, ability)

        if offHandWeapon ~= nil and IsRangedWeapon(mainWeapon) == IsRangedWeapon(offHandWeapon) then
            local offHandDamageRange = CalculateWeaponDamageRange(character, offHandWeapon, ability)

            local dualWieldPenalty = Ext.ExtraData.DualWieldingDamagePenalty
            for damageType, range in pairs(offHandDamageRange) do
                local min = range[1] * dualWieldPenalty
                local max = range[2] * dualWieldPenalty
                if mainDamageRange[damageType] ~= nil then
                    mainDamageRange[damageType][1] = mainDamageRange[damageType][1] + min
                    mainDamageRange[damageType][2] = mainDamageRange[damageType][2] + max
                else
                    mainDamageRange[damageType] = {min, max}
                end
            end
        end

        for damageType, range in pairs(mainDamageRange) do
            local min = Ext.Round(range[1] * damageMultiplier)
            local max = Ext.Round(range[2] * damageMultiplier)
            range[1] = min + math.ceil(min * Game.Math.GetDamageBoostByType(character, damageType))
            range[2] = max + math.ceil(max * Game.Math.GetDamageBoostByType(character, damageType))
        end

        local damageType = skill.DamageType
        if damageType ~= "None" and damageType ~= "Sentinel" then
            local min, max = 0, 0
            for _, range in pairs(mainDamageRange) do
                min = min + range[1]
                max = max + range[2]
            end
    
            mainDamageRange = {}
            mainDamageRange[damageType] = {min, max}
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
        if skillDamageType == "BaseLevelDamage" or skillDamageType == "AverageLevelDamge" then
            attrDamageScale = GetSkillAttributeDamageScale(skill, character, ability)
        else
            attrDamageScale = 1.0
        end

        local baseDamage = CalculateBaseDamage(skill.Damage, character, 0, level) * attrDamageScale * damageMultiplier
        local damageRange = skill['Damage Range'] * baseDamage * 0.005

        local damageType = skill.DamageType
        local damageTypeBoost = 1.0 + Game.Math.GetDamageBoostByType(character, damageType)
        local damageBoost = 1.0 + (character.DamageBoost / 100.0)
        local damageRanges = {}
        damageRanges[damageType] = {
            math.ceil(math.ceil(Ext.Round(baseDamage - damageRange) * damageBoost) * damageTypeBoost),
            math.ceil(math.ceil(Ext.Round(baseDamage + damageRange) * damageBoost) * damageTypeBoost)
        }
        return damageRanges
    end
end

WeaponExpansion.Math.AbilityScaling = {
	GetSkillDamageRange = GetSkillDamageRange,
	CalculateWeaponDamage = CalculateWeaponDamage,
	CalculateWeaponDamageRange = CalculateWeaponDamageRange,
	GetSkillAttributeDamageScale = GetSkillAttributeDamageScale,
}