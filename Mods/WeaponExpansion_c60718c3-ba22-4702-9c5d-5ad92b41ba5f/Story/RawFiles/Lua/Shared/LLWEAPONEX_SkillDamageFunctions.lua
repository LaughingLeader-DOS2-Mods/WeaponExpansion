local attributes = {
	"Strength",
	"Finesse",
	"Intelligence",
	"Constitution",
	"Memory",
	"Wits",
}

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

local function PrepareSkillProperties(skillName)
	if skillName ~= nil and skillName ~= "" then
		local skill = {Name = skillName}
		for i,v in pairs(skillAttributes) do
			skill[v] = Ext.StatGetAttribute(skillName, v)
		end
		Ext.Print(LeaderLib.Common.Dump(skill))
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

local function PrepareWeaponStat(stat,level,attribute)
	local weapon = {}
	for i,v in pairs(weaponAttributes) do
		weapon[v] = Ext.StatGetAttribute(stat, v)
	end
	weapon.ItemType = "Weapon"
	weapon.Name = stat
	weapon.Requirements = {
		{
			Name = attribute,
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

local function CalculateWeaponScaledDamage(character, weapon, damageList, noRandomization, attribute)
    local damages, damageBoost = Game.Math.ComputeBaseWeaponDamage(weapon)

    local abilityBoosts = character.DamageBoost 
        + Game.Math.ComputeWeaponCombatAbilityBoost(character, weapon)
        + Game.Math.ScaledDamageFromPrimaryAttribute(character[attribute]) * 100.0
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
end

local function CalculateWeaponDamage(attacker, weapon, noRandomization, highestAttribute)
    local damageList = Ext.NewDamageList()

    CalculateWeaponScaledDamage(attacker, weapon, damageList, noRandomization, highestAttribute)

    Game.Math.ApplyDamageBoosts(attacker, damageList)

    return damageList
end

local function CalculateWeaponDamageRange(character, weapon, highestAttribute)
    local damages, damageBoost = Game.Math.ComputeBaseWeaponDamage(weapon)

    local abilityBoosts = character.DamageBoost 
        + Game.Math.ComputeWeaponCombatAbilityBoost(character, weapon)
        + Game.Math.ScaledDamageFromPrimaryAttribute(character[highestAttribute]) * 100.0
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

    return ranges
end

local function GetHandCrossbow(character)
	local item = character:GetItemBySlot("Ring")
	if item == nil then
		item = character:GetItemBySlot("Ring2")
	end
	if item ~= nil then
		local parent = Ext.StatGetAttribute(item.Name, "Using")
		--Ext.Print("Parent Stat: "..tostring(Ext.StatGetAttribute(item.Name, "Using")))
		if parent == "_LLWEAPONEX_HandCrossbows" then
			print(tostring(item))
			return item
		end
	end
	return nil
end

local function GetHandCrossbowBolt(character)
	local item = GetHandCrossbow(character)
	if item ~= nil then
		for i=3,5,1 do
			local boost = item.DynamicStats[i]
			if boost ~= nil and boost.BoostName ~= "" and string.find(boost.BoostName, "Crossbow_Bolt") > -1 then
				Ext.Print("Hand Crossbow Rune["..tostring(i).."]: ".. tostring(boost.BoostName))
				local boostStat = Ext.StatGetAttribute(boost.BoostName, "RuneEffectWeapon")
				if boostStat ~= nil then
					return boost,boostStat
				end
			end
		end
	end
	return item,nil
end

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
	local skill = PrepareSkillProperties(baseSkill.Name)
	if skill == nil then skill = baseSkill end

	local bolt,boltRuneStat = GetHandCrossbowBolt(attacker)
	if boltRuneStat == nil then boltRuneStat = "_Boost_LLWEAPONEX_Crossbow_Bolt_Normal" end
	if boltRuneStat ~= nil then
		weapon = PrepareWeaponStat(boltRuneStat, attacker.Level, highestAttribute)
		Ext.Print("Applied Hand Crossbow Bolt Stats ("..boltRuneStat..")")
		Ext.Print(LeaderLib.Common.Dump(weapon))
		skill["DamageType"] = weapon.DynamicStats[1]["Damage Type"]
		skill["Damage Multiplier"] = weapon.DynamicStats[1]["DamageFromBase"]
		skill["Damage Range"] = weapon.DynamicStats[1]["Damage Range"]
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

		return damageList,Game.Math.DamageTypeToDeathType(skillDamageType)
	else
		local mainDamageRange = CalculateWeaponDamageRange(attacker, weapon, highestAttribute)
        for damageType, range in pairs(mainDamageRange) do
            local min = Ext.Round(range[1] * damageMultiplier)
            local max = Ext.Round(range[2] * damageMultiplier)
            range[1] = min + math.ceil(min * Game.Math.GetDamageBoostByType(attacker, damageType))
            range[2] = max + math.ceil(max * Game.Math.GetDamageBoostByType(attacker, damageType))
        end

        local damageType = skill.DamageType
        local min, max = 0, 0
		for _, range in pairs(mainDamageRange) do
			min = min + range[1]
			max = max + range[2]
		end
		mainDamageRange = {}
		mainDamageRange[damageType] = {Min=math.tointeger(min), Max=math.tointeger(max)}
        return mainDamageRange
	end
end

local function GetPistol(character)
	local item = character:GetItemBySlot("Belt")
	if item ~= nil then
		local parent = Ext.StatGetAttribute(item.Name, "Using")
		--Ext.Print("Parent Stat: "..tostring(Ext.StatGetAttribute(item.Name, "Using")))
		if parent == "_LLWEAPONEX_Pistols" then
			return item
		end
	end
	return nil
end

local function GetPistolBullets(character)
	local item = GetPistol(character)
	if item ~= nil then
		for i=3,5,1 do
			local boost = item.DynamicStats[i]
			if boost ~= nil and boost.BoostName ~= "" and string.find(boost.BoostName, "Pistol_Bullets") > -1 then
				Ext.Print("Pistol Rune["..tostring(i).."]: ".. tostring(boost.BoostName))
				local boostStat = Ext.StatGetAttribute(boost.BoostName, "RuneEffectWeapon")
				if boostStat ~= nil then
					return boost,boostStat
				end
			end
		end
	end
	return item,nil
end

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
	
	-- local rot = attacker.Rotation
	-- Ext.Print("Rotation:",Ext.JsonStringify(rot))
	-- local forwardVector = {
	-- 	-rot[7] * 15.0,
	-- 	-rot[8] * 15.0,
	-- 	-rot[9] * 15.0,
	-- }
	-- Ext.Print("forwardVector:",Ext.JsonStringify(forwardVector))
	-- local pos = attacker.Position
	-- Ext.Print("attacker.Position:",Ext.JsonStringify(pos))
	-- local targetPos = {
	-- 	pos[1] + forwardVector[1],
	-- 	pos[2] + forwardVector[2],
	-- 	pos[3] + forwardVector[3],
	-- }
	-- Ext.Print("targetPos:",Ext.JsonStringify(targetPos))

	local highestAttribute = GetHighestAttribute(attacker)

	local weapon = nil
	local skill = PrepareSkillProperties(baseSkill.Name)
	if skill == nil then skill = baseSkill end

	local bullet,bulletRuneStat = GetPistolBullets(attacker)
	if bulletRuneStat == nil then bulletRuneStat = "_Boost_LLWEAPONEX_Pistol_Bullets_Normal" end
	if bulletRuneStat ~= nil then
		weapon = PrepareWeaponStat(bulletRuneStat, attacker.Level, highestAttribute)
		--Ext.Print("Bullet Stats ("..bulletRuneStat..")")
		--Ext.Print(LeaderLib.Common.Dump(weapon))
		skill["DamageType"] = weapon.DynamicStats[1]["Damage Type"]
		skill["Damage Multiplier"] = weapon.DynamicStats[1]["DamageFromBase"]
		skill["Damage Range"] = weapon.DynamicStats[1]["Damage Range"]
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

		return damageList,Game.Math.DamageTypeToDeathType(skillDamageType)
	else
		local mainDamageRange = CalculateWeaponDamageRange(attacker, weapon, highestAttribute)
        for damageType, range in pairs(mainDamageRange) do
            local min = Ext.Round(range[1] * damageMultiplier)
            local max = Ext.Round(range[2] * damageMultiplier)
            range[1] = min + math.ceil(min * Game.Math.GetDamageBoostByType(attacker, damageType))
            range[2] = max + math.ceil(max * Game.Math.GetDamageBoostByType(attacker, damageType))
        end

        local damageType = skill.DamageType
        local min, max = 0, 0
		for _, range in pairs(mainDamageRange) do
			min = min + range[1]
			max = max + range[2]
		end
		mainDamageRange = {}
		mainDamageRange[damageType] = {Min=math.tointeger(min), Max=math.tointeger(max)}
        return mainDamageRange
	end
end

WeaponExpansion.Skills = {
	GetHighestAttribute = GetHighestAttribute,
	GetHandCrossbow = GetHandCrossbow,
	GetHandCrossbowBolt = GetHandCrossbowBolt,
	GetPistol = GetPistol,
	GetPistolBullets = GetPistolBullets,
	PrepareSkillProperties = PrepareSkillProperties,
	Params = {},
	Damage = {
		Params = {
			LLWEAPONEX_PistolDamage = GetPistolDamage,
			LLWEAPONEX_HandCrossbow_ShootDamage = GetHandCrossbowDamage
		},
		Skills = {
			Projectile_LLWEAPONEX_Pistol_A_Shoot_LeftHand = GetPistolDamage,
			Projectile_LLWEAPONEX_Pistol_A_Shoot_RightHand = GetPistolDamage,
			Projectile_LLWEAPONEX_HandCrossbow_Shoot = GetHandCrossbowDamage,
		}
	}
}
