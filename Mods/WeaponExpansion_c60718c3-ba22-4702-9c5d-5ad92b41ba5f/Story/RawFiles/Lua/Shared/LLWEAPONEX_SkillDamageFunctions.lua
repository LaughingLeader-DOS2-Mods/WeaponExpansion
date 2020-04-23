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

local skillAttributes = {
	"Ability",
	--"ActionPoints",
	--"Cooldown",
	"Damage Multiplier",
	"Damage Range",
	"Damage",
	"DamageType",
	"DeathType",
	"Distance Damage Multiplier",
	--"IsEnemySkill",
	--"IsMelee",
	"Level",
	--"Magic Cost",
	--"Memory Cost",
	--"OverrideMinAP",
	"OverrideSkillLevel",
	--"Range",
	--"SkillType",
	"Stealth Damage Multiplier",
	--"Tier",
	"UseCharacterStats",
	"UseWeaponDamage",
	"UseWeaponProperties",
}

---@param skillName string
---@return StatEntrySkillData
local function PrepareSkillProperties(skillName, useWeaponDamage)
	if skillName ~= nil and skillName ~= "" then
		local skill = {Name = skillName}
		for i,v in pairs(skillAttributes) do
			skill[v] = Ext.StatGetAttribute(skillName, v)
		end
		if useWeaponDamage == true then skill["UseWeaponDamage"] = "Yes" end
		--Ext.Print(Ext.JsonStringify(skill))
		return skill
	end
	return nil
end

local weaponAttributes = {
	"ModifierType",
	"IsTwoHanded",
	"WeaponType",
}

local weaponStatAttributes = {
	"ModifierType",
	"Damage",
	"DamageFromBase",
	"Damage Range",
	"Damage Type",
	"DamageBoost",
	"CriticalDamage",
	"CriticalChance",
	"IsTwoHanded",
	"WeaponType",
}

---@param stat string
---@param level integer
---@param attribute string
---@param weaponType string
---@return StatItem
local function PrepareWeaponStat(stat,level,attribute,weaponType)
	local weapon = {}
	for i,v in pairs(weaponAttributes) do
		weapon[v] = Ext.StatGetAttribute(stat, v)
	end
	weapon.ItemType = "Weapon"
	weapon.WeaponType = weaponType
	weapon.Name = stat
	weapon.Requirements = {
		{
			Requirement = attribute,
			Param = 0,
			Not = false
		}
	}
	local weaponStat = {}
	for i,v in pairs(weaponStatAttributes) do
		weaponStat[v] = Ext.StatGetAttribute(stat, v)
	end
	local damage = Game.Math.GetLevelScaledWeaponDamage(level)
	local baseDamage = damage / (weaponStat.DamageFromBase * 0.01)
	local range = baseDamage * (weaponStat["Damage Range"] * 0.01)
	weaponStat.MinDamage = Ext.Round(baseDamage - (range/2))
	weaponStat.MaxDamage = Ext.Round(baseDamage + (range/2))
	weaponStat.DamageType = weaponStat["Damage Type"]
	weaponStat.StatsType = "Weapon"
	weapon.DynamicStats = {weaponStat}
	return weapon
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
local function CalculateWeaponDamageRange(character, weapon, highestAttribute)
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

---@param character EsvCharacter
---@param parentStatName string
---@param slots string[]
---@return StatItem
local function GetItem(character, parentStatName, slots)
	---@type StatItem
	local item = nil
	if type(slots) == "string" then
		item = character:GetItemBySlot(slots)
		if item ~= nil and HasParent(item.Name, parentStatName) then
			return item
		end
	else
		for i,slot in pairs(slots) do
			item = character:GetItemBySlot(slot)
			if item ~= nil and HasParent(item.Name, parentStatName) then
				return item
			end
		end
	end
	return nil
end

---@param character EsvCharacter
---@param runeParentStat string
---@param itemParentStat string
---@param slots string[]
---@return StatItemDynamic,string
local function GetRuneBoost(character, runeParentStat, itemParentStat, slots)
	local item = GetItem(character, itemParentStat, slots)
	if item ~= nil then
		for i=3,5,1 do
			local boost = item.DynamicStats[i]
			if boost ~= nil and boost.BoostName ~= "" then
				if HasParent(boost.BoostName, runeParentStat) then
					local boostStat = Ext.StatGetAttribute(boost.BoostName, "RuneEffectWeapon")
					if boostStat ~= nil then
						return boost,boostStat
					end
				end
			end
		end
	end
	return item,nil
end

--- @param baseSkill StatEntrySkillData
--- @param attacker StatCharacter
--- @param isFromItem boolean
--- @param stealthed boolean
--- @param attackerPos number[]
--- @param targetPos number[]
--- @param level integer
--- @param noRandomization boolean
local function GetHandCrossbowDamage(baseSkill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization, isTooltip)
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
	local skill = PrepareSkillProperties(baseSkill.Name, true)
	if skill == nil then skill = baseSkill end

	local bolt,boltRuneStat = GetRuneBoost(attacker, "_LLWEAPONEX_HandCrossbow_Bolts", "_LLWEAPONEX_HandCrossbows", {"Ring", "Ring2"})
	if boltRuneStat == nil then boltRuneStat = "_Boost_LLWEAPONEX_HandCrossbow_Bolts_Normal" end
	if boltRuneStat ~= nil then
		weapon = PrepareWeaponStat(boltRuneStat, attacker.Level, highestAttribute, "Crossbow")
		--Ext.Print("Applied Hand Crossbow Bolt Stats ("..boltRuneStat..")")
		--Ext.Print(LeaderLib.Common.Dump(weapon))
		skill["DamageType"] = weapon.DynamicStats[1]["Damage Type"]
		--skill["Damage Multiplier"] = weapon.DynamicStats[1]["DamageFromBase"]
		--skill["Damage Range"] = weapon.DynamicStats[1]["Damage Range"]
	end

    local damageMultiplier = skill['Damage Multiplier'] * 0.01
    local damageMultipliers = Game.Math.GetDamageMultipliers(skill, stealthed, attackerPos, targetPos)
	local skillDamageType = skill["DamageType"]

	if isTooltip ~= true then
		local damageList = Ext.NewDamageList()
		local mainDmgs = CalculateWeaponDamage(attacker, weapon, noRandomization, highestAttribute)
		mainDmgs:Multiply(damageMultipliers)
		if skillDamageType ~= nil then
			mainDmgs:ConvertDamageType(skillDamageType)
		end
		damageList:Merge(mainDmgs)
		damageList:AggregateSameTypeDamages()
		--Ext.Print("damageList:",Ext.JsonStringify(damageList:ToTable()))
		return damageList,Game.Math.DamageTypeToDeathType(skillDamageType)
	else
		local mainDamageRange = Game.Math.GetSkillDamageRange(attacker, skill)
		--Ext.Print("mainDamageRange final:",Ext.JsonStringify(mainDamageRange))
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
local function GetPistolDamage(baseSkill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization, isTooltip)
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
	local skill = PrepareSkillProperties("Projectile_LLWEAPONEX_Pistol_Shoot_Base", true)
	
	if skill == nil then skill = baseSkill end

	local bullet,bulletRuneStat = GetRuneBoost(attacker, "_LLWEAPONEX_Pistol_Bullets", "_LLWEAPONEX_Pistols", "Belt")
	if bulletRuneStat == nil then bulletRuneStat = "_Boost_LLWEAPONEX_Pistol_Bullets_Normal" end
	if bulletRuneStat ~= nil then
		weapon = PrepareWeaponStat(bulletRuneStat, attacker.Level, highestAttribute, "Rifle")
		--Ext.Print("Bullet Stats ("..bulletRuneStat..")")
		--Ext.Print(LeaderLib.Common.Dump(weapon))
		skill["DamageType"] = weapon.DynamicStats[1]["Damage Type"]
		--skill["Damage Multiplier"] = weapon.DynamicStats[1]["DamageFromBase"]
		--skill["Damage Range"] = weapon.DynamicStats[1]["Damage Range"]
	end

    local damageMultiplier = skill["Damage Multiplier"] * 0.01
    local damageMultipliers = Game.Math.GetDamageMultipliers(skill, stealthed, attackerPos, targetPos)
	local skillDamageType = skill["DamageType"]

	if isTooltip ~= true then
		local damageList = Ext.NewDamageList()
		local mainDmgs = CalculateWeaponDamage(attacker, weapon, noRandomization, highestAttribute)
		mainDmgs:Multiply(damageMultipliers)
		if skillDamageType ~= nil then
			mainDmgs:ConvertDamageType(skillDamageType)
		end
		damageList:Merge(mainDmgs)
		damageList:AggregateSameTypeDamages()
		--Ext.Print("damageList:",Ext.JsonStringify(damageList:ToTable()))
		return damageList,Game.Math.DamageTypeToDeathType(skillDamageType)
	else
		local mainDamageRange = Game.Math.GetSkillDamageRange(attacker, skill)
		--Ext.Print("mainDamageRange final:",Ext.JsonStringify(mainDamageRange))
        return mainDamageRange
	end
end

WeaponExpansion.Skills = {
	GetHighestAttribute = GetHighestAttribute,
	GetItem = GetItem,
	GetRuneBoost = GetRuneBoost,
	PrepareSkillProperties = PrepareSkillProperties,
	PrepareWeaponStat = PrepareWeaponStat,
	Params = {},
	Damage = {
		Params = {
			LLWEAPONEX_PistolDamage = GetPistolDamage,
			LLWEAPONEX_HandCrossbow_ShootDamage = GetHandCrossbowDamage
		},
		Skills = {
			Projectile_LLWEAPONEX_Pistol_Shoot_Base = GetPistolDamage,
			Projectile_LLWEAPONEX_Pistol_Shoot_LeftHand = GetPistolDamage,
			Projectile_LLWEAPONEX_Pistol_Shoot_RightHand = GetPistolDamage,
			Projectile_LLWEAPONEX_HandCrossbow_Shoot = GetHandCrossbowDamage,
		}
	}
}
