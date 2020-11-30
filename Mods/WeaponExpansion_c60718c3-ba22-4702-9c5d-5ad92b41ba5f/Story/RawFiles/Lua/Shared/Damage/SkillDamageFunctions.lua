local function SkillPropsIsTable(skill)
	return type(skill) == "table" and skill.IsTable == true
end

--- @param character StatCharacter
--- @param skill StatEntrySkillData
--- @param mainWeapon table
--- @param offHandWeapon table
--- @return number[]
function GetSkillDamageRangeWithFakeWeapon(character, skill, mainWeapon, offHandWeapon, ability)
    local damageMultiplier = skill['Damage Multiplier'] * 0.01

    if skill.UseWeaponDamage == "Yes" then
        local mainDamageRange = Skills.CalculateWeaponAbilityDamageRange(character, mainWeapon, ability)
        if offHandWeapon ~= nil and Game.Math.IsRangedWeapon(mainWeapon) == Game.Math.IsRangedWeapon(offHandWeapon) then
            local offHandDamageRange = Skills.CalculateWeaponAbilityDamageRange(character, offHandWeapon)

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
            attrDamageScale = Skills.GetSkillAbilityDamageScale(skill, character, ability)
        else
            attrDamageScale = 1.0
        end

        local baseDamage = Game.Math.CalculateBaseDamage(skill.Damage, character, 0, level) * attrDamageScale * damageMultiplier
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

local attributes = {
	"Strength",
	"Finesse",
	"Intelligence",
	"Constitution",
	"Memory",
	"Wits",
}

---@param character StatCharacter
---@param validAttributes string[]
local function GetHighestAttribute(character, validAttributes)
	if validAttributes == nil then validAttributes = attributes end
	local attribute = "Strength"
	local last = 0
	for i,att in pairs(validAttributes) do
		local val = character[att]
		if val ~= nil and val > last then
			attribute = att
			last = val
		end
	end
	--Ext.Print("Scaling damage by ("..attribute..")")
	return attribute
end

-- from CDivinityStats_Character::CalculateWeaponDamageInner and CDivinityStats_Item::ComputeScaledDamage
--- @param character StatCharacter
--- @param weapon StatItem
--- @param damageList DamageList
--- @param noRandomization boolean
local function CalculateWeaponScaledDamage(character, weapon, damageList, noRandomization, attribute)
    local damages, damageBoost = Game.Math.ComputeBaseWeaponDamage(weapon)

    local abilityBoosts = character.DamageBoost 
        + Game.Math.ComputeWeaponCombatAbilityBoost(character, weapon)
        + (Game.Math.ScaledDamageFromPrimaryAttribute(character[attribute]) * 100.0)
    abilityBoosts = math.max(abilityBoosts + 100.0, 0.0) / 100.0

    local boost = 1.0 + damageBoost * 0.01
    if not character.Sneaking then
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
--- @param highestAttribute string
--- @return DamageList
local function CalculateWeaponDamage(attacker, weapon, noRandomization, highestAttribute)
    local damageList = Ext.NewDamageList()
    CalculateWeaponScaledDamage(attacker, weapon, damageList, noRandomization, highestAttribute)
    Game.Math.ApplyDamageBoosts(attacker, damageList)
    return damageList
end

--- @param character StatCharacter
--- @param weapon StatItem
--- @param highestAttribute string
--- @return number[]
local function CalculateWeaponScaledDamageRanges(character, weapon, highestAttribute)
    local damages, damageBoost = Game.Math.ComputeBaseWeaponDamage(weapon)

    local abilityBoosts = character.DamageBoost 
        + Game.Math.ComputeWeaponCombatAbilityBoost(character, weapon)
        + (Game.Math.ScaledDamageFromPrimaryAttribute(character[highestAttribute]) * 100.0)
    abilityBoosts = math.max(abilityBoosts + 100.0, 0.0) / 100.0

    local boost = 1.0 + damageBoost * 0.01
    if not character.Sneaking then
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

---Recursively see if a stat has a parent stat.
---@param stat string
---@param statToFind string
---@return boolean
local function HasParent(stat, statToFind)
	if stat == statToFind then
		return true
	elseif stat == nil then
		return false
	end
	local parent = Ext.StatGetAttribute(stat, "Using")
	if parent == nil or parent == "" then
		return false
	elseif parent == statToFind then
		return true
	else
		return HasParent(parent, statToFind)
	end
end

---@param item StatItem
---@param tags string[]
local function HasSharedBaseTags(item, tags)
	if #tags > 0 and not StringHelpers.IsNullOrEmpty(item.Tags) then
		for _,tag in pairs(tags) do
			if string.find(item.Tags, tag) then
				return true
			end
		end
	end
	return false
end

---@param character StatCharacter
---@param parentStatName string
---@param slots string[]
---@return StatItem
local function GetItem(character, parentStatName, slots)
	---@type StatItem
	local item = nil
	local tagsStr = Ext.StatGetAttribute(parentStatName, "Tags")
	local tags = {}
	if not StringHelpers.IsNullOrEmpty(tagsStr) then
		tags = StringHelpers.Split(tagsStr, ";")
	end
	local slotsType = type(slots)
	if slotsType == "string" then
		item = character:GetItemBySlot(slots)
		if item ~= nil and HasParent(item.Name, parentStatName) or HasSharedBaseTags(item, tags) then
			return item
		end
	elseif slotsType == "table" then
		for i,slot in pairs(slots) do
			item = character:GetItemBySlot(slot)
			if item ~= nil and HasParent(item.Name, parentStatName) or HasSharedBaseTags(item, tags) then
				return item
			end
		end
	elseif slots == nil then
	
	end
	return nil
end

local ringSlots = {"Ring", "Ring2"}
---@param character StatCharacter
---@param runeParentStat string
---@param itemParentStat string
---@param slots string[]
---@param currentItem StatItem An existing item (skips trying to find one).
---@return StatItemDynamic,string,StatItem
local function GetRuneBoost(character, runeParentStat, itemParentStat, slots, currentItem)
	if slots == nil then
		local slot = Ext.StatGetAttribute(itemParentStat, "Slot")
		if slot == "Ring" then
			slots = ringSlots
		else
			slots = slot
		end
	end
	local item = currentItem or GetItem(character, itemParentStat, slots)
	if item ~= nil then
		for i=3,5,1 do
			local boost = item.DynamicStats[i]
			if boost ~= nil and boost.BoostName ~= "" then
				if HasParent(boost.BoostName, runeParentStat) then
					local boostStat = Ext.StatGetAttribute(boost.BoostName, "RuneEffectWeapon")
					if boostStat ~= nil then
						return boost,boostStat,item.ItemTypeReal
					end
				end
			end
		end
		return nil,nil,item.ItemTypeReal
	end
	return nil,nil,"Common"
end

---@param character StatCharacter
---@param itemParentStat string
---@param slots string[]
---@param currentItem StatItem An existing item (skips trying to find one).
---@return boolean
function Skills.HasTaggedRuneBoost(character, tag, itemParentStat, slots, currentItem)
	if slots == nil and itemParentStat ~= nil then
		local slot = Ext.StatGetAttribute(itemParentStat, "Slot")
		if slot == "Ring" then
			slots = ringSlots
		else
			slots = slot
		end
	end
	local item = currentItem or GetItem(character, itemParentStat, slots)
	if item ~= nil then
		for i=3,5,1 do
			local boost = item.DynamicStats[i]
			if boost ~= nil and boost.BoostName ~= "" then
				local boostStat = Ext.StatGetAttribute(boost.BoostName, "RuneEffectWeapon")
				if boostStat ~= nil then
					local tags = Ext.StatGetAttribute(boostStat, "Tags")
					if not StringHelpers.IsNullOrEmpty(tags) and string.find(tags, tag) then
						return true
					end
				end
			end
		end
	end
	return false
end

---@param character StatCharacter
---@return table<string,number[]>|DamageList
local function GetAbilityBasedWeaponDamage(character, isTooltip, noRandomization, weaponBoostStat, masteryBoost, ability, weaponType, rarity)
	if noRandomization == nil then 
		noRandomization = false 
	end
	local highestAttribute = GetHighestAttribute(character)
	local weapon = ExtenderHelpers.CreateWeaponTable(weaponBoostStat, character.Level, highestAttribute, weaponType, masteryBoost, nil, nil, rarity)
	if isTooltip == true then
		return Math.AbilityScaling.CalculateWeaponScaledDamageRanges(character, weapon, ability)
	else
		return Math.AbilityScaling.CalculateWeaponDamage(character, weapon, nil, noRandomization, ability)
	end
end

---@param character EsvCharacter
---@param isTooltip boolean
---@param noRandomization boolean
---@return StatItem
local function GetPistolWeaponStatTable(character, isTooltip, noRandomization)
	local masteryBoost = 0
	local masteryLevel = Mastery.GetHighestMasteryRank(character, "LLWEAPONEX_Pistol")
	if masteryLevel > 0 then
		local boost = GameHelpers.GetExtraData("LLWEAPONEX_PistolMasteryBoost"..masteryLevel, 0)
		if boost > 0 then
			masteryBoost = boost
		end
	end
	local rune,weaponBoostStat,rarity = GetRuneBoost(character.Stats, "_LLWEAPONEX_Pistol_Bullets", "_LLWEAPONEX_Pistols")
	if weaponBoostStat == nil then 
		weaponBoostStat = "_Boost_LLWEAPONEX_Pistol_Bullets_Normal" 
	end
	if noRandomization == nil then 
		noRandomization = false 
	end
	local highestAttribute = GetHighestAttribute(character)
	return ExtenderHelpers.CreateWeaponTable(weaponBoostStat, character.Level, highestAttribute, "Rifle", masteryBoost, nil, nil, rarity)
end

---@param character EsvCharacter
---@param isTooltip boolean
---@param noRandomization boolean
---@param item StatItem
---@return table<string,number[]>|DamageList
local function GetPistolDamage(character, isTooltip, noRandomization, item)
	local masteryBoost = 0
	local masteryLevel = Mastery.GetHighestMasteryRank(character, "LLWEAPONEX_Pistol")
	if masteryLevel > 0 then
		local boost = GameHelpers.GetExtraData("LLWEAPONEX_PistolMasteryBoost"..masteryLevel, 0)
		if boost > 0 then
			masteryBoost = boost
		end
	end
	local rune,weaponBoostStat,rarity = GetRuneBoost(character.Stats, "_LLWEAPONEX_Pistol_Bullets", "_LLWEAPONEX_Pistols", nil, item)
	if weaponBoostStat == nil then 
		weaponBoostStat = "_Boost_LLWEAPONEX_Pistol_Bullets_Normal" 
	end
	return GetAbilityBasedWeaponDamage(character.Stats, isTooltip, noRandomization, weaponBoostStat, masteryBoost, "RogueLore", "Rifle", rarity)
end

---@param character EsvCharacter
---@param isTooltip boolean
---@param noRandomization boolean
---@param item StatItem
---@return table<string,number[]>|DamageList
local function GetHandCrossbowDamage(character, isTooltip, noRandomization, item)
	local masteryBoost = 0
	local masteryLevel = Mastery.GetHighestMasteryRank(character, "LLWEAPONEX_HandCrossbow")
	if masteryLevel > 0 then
		local boost = GameHelpers.GetExtraData("LLWEAPONEX_HandCrossbowMasteryBoost"..masteryLevel, 0)
		if boost > 0 then
			masteryBoost = boost
		end
	end
	local rune,weaponBoostStat,rarity = GetRuneBoost(character.Stats, "_LLWEAPONEX_HandCrossbow_Bolts", "_LLWEAPONEX_HandCrossbows", nil, item)
	if weaponBoostStat == nil then 
		weaponBoostStat = "_Boost_LLWEAPONEX_HandCrossbow_Bolts_Normal" 
	end
	return GetAbilityBasedWeaponDamage(character.Stats, isTooltip, noRandomization, weaponBoostStat, masteryBoost, "RogueLore", "Crossbow", rarity)
end

--- @param baseSkill StatEntrySkillData
--- @param attacker StatCharacter
--- @param isFromItem boolean
--- @param stealthed boolean
--- @param attackerPos number[]
--- @param targetPos number[]
--- @param level integer
--- @param noRandomization boolean
--- @param isTooltip boolean
local function GetHandCrossbowSkillDamage(baseSkill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization, isTooltip)
    if attacker ~= nil and level < 0 then
        level = attacker.Level
	end
    if level == 0 then
        level = baseSkill.OverrideSkillLevel
        if level == 0 then
            level = baseSkill.Level
        end
	end
	
	local highestAttribute = GetHighestAttribute(attacker)

	---@type StatItem
	local weapon = nil
	local skill = baseSkill
	if not SkillPropsIsTable(baseSkill) then
		skill = ExtenderHelpers.CreateSkillTable(baseSkill.Name, true)
	end
	if skill == nil then skill = baseSkill end

	local rune,weaponBoostStat,rarity = GetRuneBoost(attacker, "_LLWEAPONEX_HandCrossbow_Bolts", "_LLWEAPONEX_HandCrossbows")
	if weaponBoostStat == nil then weaponBoostStat = "_Boost_LLWEAPONEX_HandCrossbow_Bolts_Normal" end
	if weaponBoostStat ~= nil then
		local masteryBoost = 0
		local masteryLevel = Mastery.GetHighestMasteryRank(attacker.Character, "LLWEAPONEX_HandCrossbow")
		if masteryLevel > 0 then
			local boost = GameHelpers.GetExtraData("LLWEAPONEX_HandCrossbowMasteryBoost"..masteryLevel, 0)
			if boost > 0 then
				masteryBoost = boost
			end
		end

		masteryBoost = masteryBoost + 5
		--print("LLWEAPONEX_HandCrossbow mastery boost:", masteryLevel, masteryBoost)
		--print(LeaderLib.Common.Dump(attacker.Character:GetTags()))
		weapon = ExtenderHelpers.CreateWeaponTable(weaponBoostStat, attacker.Level, highestAttribute, "Crossbow", masteryBoost, nil, nil, rarity)
		--Ext.Print("Applied Hand Crossbow Bolt Stats ("..weaponBoostStat..")")
		--Ext.Print(LeaderLib.Common.Dump(weapon))
		skill["DamageType"] = weapon.DynamicStats[1]["Damage Type"]
		--skill["Damage Multiplier"] = weapon.DynamicStats[1]["DamageFromBase"]
		--skill["Damage Range"] = weapon.DynamicStats[1]["Damage Range"]
	end

    local damageMultipliers = Game.Math.GetDamageMultipliers(skill, stealthed, attackerPos, targetPos)
	local skillDamageType = skill["DamageType"]
	if isTooltip ~= true then
		local damageList = Ext.NewDamageList()
		local mainDmgs = Math.AbilityScaling.CalculateWeaponDamage(attacker, weapon, nil, noRandomization, "RogueLore")
		mainDmgs:Multiply(damageMultipliers)
		if skillDamageType ~= nil then
			mainDmgs:ConvertDamageType(skillDamageType)
		end
		damageList:Merge(mainDmgs)
		damageList:AggregateSameTypeDamages()
		--Ext.Print("damageList:",Ext.JsonStringify(damageList:ToTable()))
		return damageList,Game.Math.DamageTypeToDeathType(skillDamageType)
	else
		local mainDamageRange = Math.AbilityScaling.GetSkillDamageRange(attacker, skill, weapon, nil, "RogueLore")
		--local mainDamageRange = Game.Math.GetSkillDamageRange(attacker, skill, weapon)
		Ext.Print("mainDamageRange final:",Ext.JsonStringify(mainDamageRange))
		Ext.Print("mainDamageRange test:",Ext.JsonStringify(Game.Math.GetSkillDamageRange(attacker, skill, attacker.MainWeapon)))
        return mainDamageRange
	end
end

--- @param baseSkill StatEntrySkillData
--- @param attacker StatCharacter
--- @param isFromItem boolean
--- @param stealthed boolean
--- @param attackerPos number[]
--- @param targetPos number[]
--- @param level integer
--- @param noRandomization boolean
--- @param isTooltip boolean
local function GetPistolSkillDamage(baseSkill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization, isTooltip)
	--print("GetPistolSkillDamage", baseSkill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization, isTooltip)
	if level == nil then
		level = -1
	end
    if attacker ~= nil and level < 0 then
        level = attacker.Level
	end
    if level == 0 then
        level = baseSkill.OverrideSkillLevel
        if level == 0 then
            level = baseSkill.Level
        end
	end

	local highestAttribute = GetHighestAttribute(attacker)

	local weapon = nil
	local skill = baseSkill
	if not SkillPropsIsTable(baseSkill) then
		skill = ExtenderHelpers.CreateSkillTable("Projectile_LLWEAPONEX_Pistol_Shoot_Base", true)
	end

	if skill == nil then
		Ext.PrintError("Failed to prepare skill data for Projectile_LLWEAPONEX_Pistol_Shoot_Base?")
		skill = baseSkill
		skill["UseWeaponDamage"] = "Yes"
	end

	local rune,weaponBoostStat,rarity = GetRuneBoost(attacker, "_LLWEAPONEX_Pistol_Bullets", "_LLWEAPONEX_Pistols")
	if weaponBoostStat == nil then weaponBoostStat = "_Boost_LLWEAPONEX_Pistol_Bullets_Normal" end
	if weaponBoostStat ~= nil then
		local masteryBoost = 0
		local masteryLevel = Mastery.GetHighestMasteryRank(attacker.Character, "LLWEAPONEX_Pistol")
		if masteryLevel > 0 then
			local boost = GameHelpers.GetExtraData("LLWEAPONEX_PistolMasteryBoost"..masteryLevel, 0)
			if boost > 0 then
				masteryBoost = boost
			end
		end
		--print("LLWEAPONEX_Pistol mastery boost:", masteryLevel, masteryBoost)
		weapon = ExtenderHelpers.CreateWeaponTable(weaponBoostStat, attacker.Level, highestAttribute, "Rifle", masteryBoost, nil, nil, rarity)
		--Ext.Print("Bullet Stats ("..weaponBoostStat..")")
		--Ext.Print(LeaderLib.Common.Dump(weapon))
		skill["DamageType"] = weapon.DynamicStats[1]["Damage Type"]
		--skill["Damage Multiplier"] = weapon.DynamicStats[1]["DamageFromBase"]
		--skill["Damage Range"] = weapon.DynamicStats[1]["Damage Range"]
	end

    local damageMultiplier = skill["Damage Multiplier"] * 0.01
    local damageMultipliers = Game.Math.GetDamageMultipliers(skill, stealthed, attackerPos, targetPos)
	local skillDamageType = skill["DamageType"]

	-- Ext.Print("Skill Stats:")
	-- Ext.Print("================================")
	-- Ext.Print(LeaderLib.Common.Dump(skill))
	-- Ext.Print("================================")
	-- Ext.Print("Fake Weapon Stats:")
	-- Ext.Print("================================")
	-- Ext.Print(LeaderLib.Common.Dump(weapon))
	-- Ext.Print("================================")
	-- Ext.Print("Real Weapon Stats:")
	-- Ext.Print("================================")
	-- for k,v in pairs(weapon) do
	-- 	Ext.Print(k..":"..tostring(attacker.MainWeapon[k]))
	-- end
	-- PrintDynamicStats(attacker.MainWeapon.DynamicStats)
	-- Ext.Print("================================")

	if isTooltip ~= true then
		local damageList = Ext.NewDamageList()
		local mainDmgs = Math.AbilityScaling.CalculateWeaponDamage(attacker, weapon, nil, noRandomization, "RogueLore")
		mainDmgs:Multiply(damageMultipliers)
		if skillDamageType ~= nil then
			mainDmgs:ConvertDamageType(skillDamageType)
		end
		damageList:Merge(mainDmgs)
		damageList:AggregateSameTypeDamages()
		return damageList,Game.Math.DamageTypeToDeathType(skillDamageType)
	else
		local mainDamageRange = Math.AbilityScaling.GetSkillDamageRange(attacker, skill, weapon, nil, "RogueLore")
		--print(Ext.JsonStringify(mainDamageRange))
        return mainDamageRange
	end
end

--- @param skill StatEntrySkillData
--- @param attacker StatCharacter
--- @param isFromItem boolean
--- @param stealthed boolean
--- @param attackerPos number[]
--- @param targetPos number[]
--- @param level integer
--- @param noRandomization boolean
--- @param isTooltip boolean
local function GetAimedShotAverageDamage(skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization, isTooltip)
	local skillProps = skill
	if not SkillPropsIsTable(skillProps) then
		skillProps = ExtenderHelpers.CreateSkillTable(skill.Name)
	end
	local distanceDamageMult = skill["Distance Damage Multiplier"]
	skillProps["Distance Damage Multiplier"] = 0 -- Used for manual calculation
	skillProps["Damage Multiplier"] = distanceDamageMult * 10
	local damageMin = Game.Math.GetSkillDamage(skillProps, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization):ToTable()
	local minDamageTexts = {}
	local totalDamageTypes = 0
	for i,damage in pairs(damageMin) do
		local min = math.max(damage.Amount, 1)
		if min ~= nil then
			table.insert(minDamageTexts, GameHelpers.GetDamageText(damage.DamageType, min))
			totalDamageTypes = totalDamageTypes + 1
		end
	end
	if totalDamageTypes > 0 then
		local output = ""
		if #minDamageTexts > 1 then
			output = StringHelpers.Join(", ", minDamageTexts)
		else
			output = minDamageTexts[1]
		end
		output = output .. " (10m)"
		return output
	end
end

--- @param skill StatEntrySkillData
--- @param attacker StatCharacter
--- @param isFromItem boolean
--- @param stealthed boolean
--- @param attackerPos number[]
--- @param targetPos number[]
--- @param level integer
--- @param noRandomization boolean
--- @param isTooltip boolean
local function GetAimedShotMaxDamage(skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization, isTooltip)
	local skillProps = skill
	if not SkillPropsIsTable(skillProps) then
		skillProps = ExtenderHelpers.CreateSkillTable(skill.Name)
	end
	local distanceDamageMult = skill["Distance Damage Multiplier"]
	skillProps["Distance Damage Multiplier"] = 0 -- Used for manual calculation
	skillProps["Damage Multiplier"] = distanceDamageMult * 20
	local damageMax = Game.Math.GetSkillDamage(skillProps, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization):ToTable()
	local maxDamageTexts = {}
	local totalDamageTypes = 0
	for i,damage in pairs(damageMax) do
		local max = damage.Amount
		if max ~= nil then
			table.insert(maxDamageTexts, GameHelpers.GetDamageText(damage.DamageType, math.tointeger(max)))
		end
		totalDamageTypes = totalDamageTypes + 1
	end

	if totalDamageTypes > 0 then
		local output = ""
		if #maxDamageTexts > 1 then
			output = output .. StringHelpers.Join(", ", maxDamageTexts)
		else
			output = output .. maxDamageTexts[1]
		end
		output = output .. " (20m)"
		return output
	end
end

--- @param skill StatEntrySkillData
--- @param attacker StatCharacter
--- @param isFromItem boolean
--- @param stealthed boolean
--- @param attackerPos number[]
--- @param targetPos number[]
--- @param level integer
--- @param noRandomization boolean
--- @param isTooltip boolean
local function GetAimedShotDamage(skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization, isTooltip)
	local skillProps = skill
	if not SkillPropsIsTable(skillProps) then
		skillProps = ExtenderHelpers.CreateSkillTable(skill.Name)
	end
	local distanceDamageMult = skill["Distance Damage Multiplier"]
	skillProps["Distance Damage Multiplier"] = 0 -- Used for manual calculation
	skillProps["Damage Multiplier"] = 0

	if isTooltip ~= true then
		local targetDistance = math.sqrt((attackerPos[1] - targetPos[1])^2 + (attackerPos[3] - targetPos[3])^2)
		-- 10% damage mult min, 200% damage mult max
		local damageMult = math.min(distanceDamageMult * 20, math.max(distanceDamageMult, targetDistance * distanceDamageMult))
		skillProps["Damage Multiplier"] = damageMult
		return Game.Math.GetSkillDamage(skillProps, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization)
	end
end

--- @param ability string
--- @param weaponStat string
--- @param validAttributes string[]
--- @param skill StatEntrySkillData
--- @param attacker StatCharacter
--- @param isFromItem boolean
--- @param stealthed boolean
--- @param attackerPos number[]
--- @param targetPos number[]
--- @param level integer
--- @param noRandomization boolean
--- @param isTooltip boolean
local function ScaleByHighestAttributeAndAbility(ability, weaponStat, validAttributes, skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization, isTooltip)
    if attacker ~= nil and level < 0 then
        level = attacker.Level
	end
    if level == 0 then
        level = skill.OverrideSkillLevel
        if level == 0 then
            level = skill.Level
        end
	end

	local highestAttribute = GetHighestAttribute(attacker, validAttributes)
	local weapon = ExtenderHelpers.CreateWeaponTable(weaponStat, attacker.Level, highestAttribute, "None")

    local damageMultiplier = skill["Damage Multiplier"] * 0.01
    local damageMultipliers = Game.Math.GetDamageMultipliers(skill, stealthed, attackerPos, targetPos)
	local skillDamageType = skill["DamageType"]

	if isTooltip ~= true then
		local damageList = Ext.NewDamageList()
		local mainDmgs = Math.AbilityScaling.CalculateWeaponDamage(attacker, weapon, nil, noRandomization, "RogueLore")
		mainDmgs:Multiply(damageMultipliers)
		if skillDamageType ~= nil then
			mainDmgs:ConvertDamageType(skillDamageType)
		end
		damageList:Merge(mainDmgs)
		damageList:AggregateSameTypeDamages()
		return damageList,Game.Math.DamageTypeToDeathType(skillDamageType)
	else
		local mainDamageRange = Math.AbilityScaling.GetSkillDamageRange(attacker, skill, weapon, nil, "RogueLore", true)
        return mainDamageRange
	end
end

--- @param skill StatEntrySkillData
--- @param attacker StatCharacter
--- @param isFromItem boolean
--- @param stealthed boolean
--- @param attackerPos number[]
--- @param targetPos number[]
--- @param level integer
--- @param noRandomization boolean
--- @param isTooltip boolean
local function GetDarkFireballDamage(baseSkill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization, isTooltip)
	local skill = baseSkill
	local countMult = 0
	countMult = PersistentVars.SkillData.DarkFireballCount[attacker.NetID] or 0
	if countMult > 0 then
		if not SkillPropsIsTable(skill) then
			skill = ExtenderHelpers.CreateSkillTable(baseSkill.Name)
		end
		local damageBonus = Ext.ExtraData["LLWEAPONEX_DarkFireball_DamageBonusPerCount"] or 20.0
		-- key "LLWEAPONEX_DarkFireball_DamageBonusPerCount","20.0"
		-- key "LLWEAPONEX_DarkFireball_RangePerCount","1.0"
		-- key "LLWEAPONEX_DarkFireball_ExplosionRadiusPerCount","0.4"
		local damageMult = (countMult+1) * damageBonus
		skill["Damage Multiplier"] = math.min(200.0, skill["Damage Multiplier"] + damageMult)
	end
	if isTooltip ~= true then
		return Game.Math.GetSkillDamage(skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization)
	else
		return Game.Math.GetSkillDamageRange(attacker, skill)
	end
end

--- @param skill StatEntrySkillData
--- @param attacker StatCharacter
--- @param isFromItem boolean
--- @param stealthed boolean
--- @param attackerPos number[]
--- @param targetPos number[]
--- @param level integer
--- @param noRandomization boolean
--- @param isTooltip boolean
local function GetDarkFlamebreathDamage(baseSkill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization, isTooltip)
	local missingHealthMult = math.floor((1 - (attacker.CurrentVitality / attacker.MaxVitality)) * 100.0) + 1
	if missingHealthMult > 0 then
		local damageBonus = Ext.ExtraData["LLWEAPONEX_DarkFlamebreath_DamageBonusPerPercent"] or 1.3
		local skill = baseSkill
		if not SkillPropsIsTable(skill) then
			skill = ExtenderHelpers.CreateSkillTable(baseSkill.Name)
		end
		skill["Damage Multiplier"] = math.ceil(skill["Damage Multiplier"] + (missingHealthMult * damageBonus))
		if isTooltip ~= true then
			return Game.Math.GetSkillDamage(skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization)
		else
			return Game.Math.GetSkillDamageRange(attacker, skill)
		end
	end
end

Skills.GetHighestAttribute = GetHighestAttribute
Skills.GetItem = GetItem
Skills.GetRuneBoost = GetRuneBoost

Skills.DamageParam.LLWEAPONEX_PistolDamage = GetPistolSkillDamage
Skills.DamageParam.LLWEAPONEX_HandCrossbow_ShootDamage = GetHandCrossbowSkillDamage
Skills.DamageParam.LLWEAPONEX_AimedShot_AverageDamage = GetAimedShotAverageDamage
Skills.DamageParam.LLWEAPONEX_AimedShot_MaxDamage = GetAimedShotMaxDamage
Skills.GetPistolWeaponStatTable = GetPistolWeaponStatTable

Skills.Damage.Projectile_LLWEAPONEX_Pistol_Shoot_Base = GetPistolSkillDamage
Skills.Damage.Projectile_LLWEAPONEX_Pistol_Shoot_LeftHand = GetPistolSkillDamage
Skills.Damage.Projectile_LLWEAPONEX_Pistol_Shoot_RightHand = GetPistolSkillDamage
Skills.Damage.Projectile_LLWEAPONEX_HandCrossbow_Shoot = GetHandCrossbowSkillDamage
Skills.Damage.Projectile_LLWEAPONEX_Rifle_AimedShot = GetAimedShotDamage
Skills.Damage.Projectile_LLWEAPONEX_MasteryBonus_Whirlwind_HandCrossbow_Shoot = GetHandCrossbowSkillDamage
Skills.Damage.Target_LLWEAPONEX_Steal = function(...) return ScaleByHighestAttributeAndAbility("RogueLore", "_Daggers", AttributeScaleTables.NoMemory, ...) end
Skills.Damage.Projectile_LLWEAPONEX_DarkFireball = GetDarkFireballDamage
Skills.Damage.Cone_LLWEAPONEX_DarkFlamebreath = GetDarkFlamebreathDamage

local function GetRunicCannonSkillDamage(skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization, isTooltip)
	-- We're making the offhand weapon a rifle here so the functions ignore it for damage calculations.
	---@type StatItem
	local weapon = attacker.MainWeapon
	if isTooltip ~= true then
		return Game.Math.GetSkillDamage(skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization, weapon, {WeaponType="Rifle"})
	else
		--return Game.Math.GetSkillDamageRange(attacker, skill, weapon, {WeaponType="Rifle"})
		return Game.Math.GetSkillDamageRange(attacker, skill, weapon, {WeaponType="Rifle"})
	end
end

Skills.Damage.Projectile_LLWEAPONEX_ArmCannon_Shoot = GetRunicCannonSkillDamage
Skills.Damage.Zone_LLWEAPONEX_ArmCannon_Disperse = GetRunicCannonSkillDamage

local function BalrinSkillDamage(skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization, isTooltip)
	-- We're making the offhand weapon a rifle here so the functions ignore it for damage calculations.
	---@type StatItem
	local weapon = attacker.MainWeapon
	if attacker.OffHandWeapon ~= nil and string.find(attacker.OffHandWeapon.Tags, "LLWEAPONEX_BalrinAxe_Equipped") then
		weapon = attacker.OffHandWeapon
	end
	if isTooltip ~= true then
		return Game.Math.GetSkillDamage(skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization, weapon, {WeaponType="Rifle"})
	else
		--return Game.Math.GetSkillDamageRange(attacker, skill, weapon, {WeaponType="Rifle"})
		return Game.Math.GetSkillDamageRange(attacker, skill, weapon, {WeaponType="Rifle"})
	end
end

Skills.Damage.Projectile_LLWEAPONEX_Status_BalrinDebuff_Damage = BalrinSkillDamage
Skills.Damage.Projectile_LLWEAPONEX_Throw_UniqueAxe_A = BalrinSkillDamage
Skills.Damage.Projectile_LLWEAPONEX_Throw_UniqueAxe_A_Offhand = BalrinSkillDamage

---@param attacker StatCharacter
Skills.Damage.Projectile_LLWEAPONEX_BasilusDagger_HauntedDamage = function(skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization, isTooltip)
	-- We're making the offhand weapon a rifle here so the functions ignore it for damage calculations.
	---@type StatItem
	local weapon = nil
	if attacker.MainWeapon ~= nil and string.find(attacker.MainWeapon.Tags, "LLWEAPONEX_BasilusDagger_Equipped") then
		weapon = attacker.MainWeapon
	end
	if attacker.OffHandWeapon ~= nil and string.find(attacker.OffHandWeapon.Tags, "LLWEAPONEX_BasilusDagger_Equipped") then
		weapon = attacker.OffHandWeapon
	end
	if weapon == nil then
		weapon = GameHelpers.Ext.CreateWeaponTable("WPN_UNIQUE_LLWEAPONEX_Dagger_Basilus_A", attacker.Level)
	end
	if isTooltip ~= true then
		return Game.Math.GetSkillDamage(skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization, weapon, {WeaponType="Rifle"})
	else
		return Game.Math.GetSkillDamageRange(attacker, skill, weapon, {WeaponType="Rifle"})
	end
end

Skills.DamageFunctions.PistolDamage = GetPistolDamage
Skills.DamageFunctions.HandCrossbowDamage = GetHandCrossbowDamage
Skills.DamageFunctions.PistolSkillDamage = GetPistolSkillDamage
Skills.DamageFunctions.HandCrossbowSkillDamage = GetHandCrossbowSkillDamage
