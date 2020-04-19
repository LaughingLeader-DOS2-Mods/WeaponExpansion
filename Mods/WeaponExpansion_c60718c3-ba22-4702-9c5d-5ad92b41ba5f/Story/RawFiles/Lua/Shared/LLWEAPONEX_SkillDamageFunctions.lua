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
	Ext.Print("Scaling damage by ("..attribute..")")
	return attribute
end

local function GetPistolDamage(skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization)
	local damageList = Ext.NewDamageList()
	damageList:Add("Physical", 10)
	return damageList,1
end

local skillAttributes = {
	"Ability",
	"ActionPoints",
	"AddRangeFromAbility",
	"AddWeaponRange",
	"Chance To Hit Multiplier",
	"Cooldown",
	"Damage Multiplier",
	"Damage Range",
	"Damage",
	"DamageMultiplier",
	"DamageType",
	"DeathType",
	"Distance Damage Multiplier",
	"IsEnemySkill",
	"IsMelee",
	"Level",
	"Magic Cost",
	"Memory Cost",
	"OverrideMinAP",
	"OverrideSkillLevel",
	"Range",
	"SkillType",
	"Stealth Damage Multiplier",
	"Tier",
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

local function GetHandCrossbow(character)
	local item = character:GetItemBySlot("Ring")
	if item == nil then
		item = character:GetItemBySlot("Ring2")
	end
	if item ~= nil then
		local parent = Ext.StatGetAttribute(item.Name, "Using")
		Ext.Print("Parent Stat: "..tostring(Ext.StatGetAttribute(item.Name, "Using")))
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

function GetHandCrossbowDamage(baseSkill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization)
    if attacker ~= nil and level < 0 then
        level = attacker.Level
	end

	Ext.Print("Getting hand crossbow damage")

	local crossbowDamageSkill = "Projectile_LLWEAPONEX_HandCrossbow_Shoot_Default_ScaledDamage"
	local skill = PrepareSkillProperties(crossbowDamageSkill)
	if skill == nil then skill = baseSkill end

	local bolt,boltRuneStat = GetHandCrossbowBolt(attacker)
	if boltRuneStat ~= nil then
		local runeDamageMult = Ext.StatGetAttribute(boltRuneStat, "DamageFromBase")
		local runeDamageRange = Ext.StatGetAttribute(boltRuneStat, "Damage Range")
		local runeDamageType = Ext.StatGetAttribute(boltRuneStat, "Damage Type")
		Ext.Print("Applied Hand Crossbow Bolt Stats ("..boltRuneStat.."): runeDamageMult("..tostring(runeDamageMult)..") runeDamageRange("..tostring(runeDamageRange)..") runeDamageType("..tostring(runeDamageType)..")")
		if runeDamageMult ~= nil then skill["Damage Multiplier"] = runeDamageMult end
		if runeDamageRange ~= nil then skill["Damage Range"] = runeDamageRange end
		if runeDamageType ~= nil then skill["DamageType"] = runeDamageType end
	end

    local damageMultiplier = skill['Damage Multiplier'] * 0.01
    local damageMultipliers = Game.Math.GetDamageMultipliers(skill, stealthed, attackerPos, targetPos)
	local skillDamageType = skill["DamageType"]

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

    local damageType = skillDamageType
	local baseDamage = Game.Math.CalculateBaseDamage(skill.Damage, attacker, 0, level)
	local damageRange = skill['Damage Range']
	local randomMultiplier
	if noRandomization then
		randomMultiplier = 0.0
	else
		randomMultiplier = 1.0 + (Ext.Random(0, damageRange) - damageRange/2) * 0.01
	end

	local attrDamageScale
	local skillDamage = "AverageLevelDamge"--skill.Damage
	if skillDamage == "BaseLevelDamage" or skillDamage == "AverageLevelDamge" then
		local primaryAttr = attacker[GetHighestAttribute(attacker)]
		attrDamageScale = 1.0 + Game.Math.ScaledDamageFromPrimaryAttribute(primaryAttr)
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
	finalDamage = math.max(Ext.Round(finalDamage), 1)
	finalDamage = math.ceil(finalDamage * damageBoost)
	damageList:Add(damageType, finalDamage)

	if attacker ~= nil then
		Game.Math.ApplyDamageBoosts(attacker, damageList)
	end

    return damageList, Game.Math.DamageTypeToDeathType(skillDamageType)
end

WeaponExpansion.SkillDamage = {
	GetHighestAttribute = GetHighestAttribute,
	GetHandCrossbow = GetHandCrossbow,
	PrepareSkillProperties = PrepareSkillProperties,
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

