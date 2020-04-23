local RuneTags = {
	DamageType = {
		"LLWEAPONEX_Rune_HandCrossbow_DamageType",
		"LLWEAPONEX_Rune_Pistol_DamageType",
	}
}

local boltRuneBoosts = {
	["_Boost_LLWEAPONEX_HandCrossbow_Bolts_Normal"] = {Transform="", Apply=""},
	["_Boost_LLWEAPONEX_HandCrossbow_Bolts_Air"] = {Transform="Electrify", Apply=""},
	["_Boost_LLWEAPONEX_HandCrossbow_Bolts_Corrosive"] = {Apply="ACID",Transform="Melt"},
	["_Boost_LLWEAPONEX_HandCrossbow_Bolts_Earth"] = {Apply="SLOWED", Transform="Oilify"},
	["_Boost_LLWEAPONEX_HandCrossbow_Bolts_Fire"] = {Apply="BURNING", Transform="Ignite"},
	["_Boost_LLWEAPONEX_HandCrossbow_Bolts_Ice"] = {Apply="CHILLED", Transform="Freeze"},
	["_Boost_LLWEAPONEX_HandCrossbow_Bolts_Poison"] = {Apply="POISONED", Transform="Contaminate"},
	["_Boost_LLWEAPONEX_HandCrossbow_Bolts_Piercing"] = {Transform="", Apply="BLEEDING", Chance=100, Turns=1},
	["_Boost_LLWEAPONEX_HandCrossbow_Bolts_Shadow"] = {Apply="CURSED", Transform="Curse"},
	["_Boost_LLWEAPONEX_HandCrossbow_Bolts_Silver"] = {Transform="", Apply=""},
}

local function GetHandCrossbowBoltEffects(skill, character, isFromItem, param)
	local bolt,boltRuneStat = WeaponExpansion.Skills.GetHandCrossbowBolt(character)
	--Ext.Print("Hand Crossbow Bolt/RuneStat: ", bolt,boltRuneStat)
	if boltRuneStat ~= nil then
		local boostEffects = boltRuneBoosts[boltRuneStat]
		if boostEffects ~= nil and (boostEffects.Apply ~= nil or boostEffects.Transform ~= nil) then
			return string.format("<br><font color='#FFBB22'>%s%s</font>", boostEffects.Apply, boostEffects.Transform)
		end
	end
	return ""
end

WeaponExpansion.Skills.Params["LLWEAPONEX_HandHandCrossbow_BoltsEffects"] = GetHandCrossbowBoltEffects

local PistolRuneBoosts = {
	["_Boost_LLWEAPONEX_Pistol_Bullets_Normal"] = {Transform="", Apply=""},
	["_Boost_LLWEAPONEX_Pistol_Bullets_Air"] = {Transform="Electrify", Apply=""},
	["_Boost_LLWEAPONEX_Pistol_Bullets_Corrosive"] = {Apply="ACID",Transform="Melt"},
	["_Boost_LLWEAPONEX_Pistol_Bullets_Earth"] = {Transform="", Apply="SLOWED", Chance=25, Turns=1},
	["_Boost_LLWEAPONEX_Pistol_Bullets_Fire"] = {Transform="Ignite", Apply="BURNING", Chance=100, Turns=1},
	["_Boost_LLWEAPONEX_Pistol_Bullets_Ice"] = {Transform="Freeze", Apply="CHILLED", Chance=100, Turns=1},
	["_Boost_LLWEAPONEX_Pistol_Bullets_Poison"] = {Transform="", Apply="POISONED", Chance=100, Turns=1},
	["_Boost_LLWEAPONEX_Pistol_Bullets_Piercing"] = {Transform="", Apply="BLEEDING", Chance=100, Turns=1},
	["_Boost_LLWEAPONEX_Pistol_Bullets_Shadow"] = {Apply="CURSED", Transform="Curse"},
	["_Boost_LLWEAPONEX_Pistol_Bullets_Silver"] = {Apply="", Transform=""},
}


local function GetPistolBulletEffects(skill, character, isFromItem, param)
	local bullet,bulletRuneStat = WeaponExpansion.Skills.GetPistolBullets(character)
	-- Ext.Print(bullet,bulletRuneStat)
	-- if bulletRuneStat ~= nil then
	-- 	local boostEffects = bulletRuneBoosts[bulletRuneStat]
	-- 	Ext.Print(boostEffects.Apply)
	-- 	if boostEffects ~= nil and (boostEffects.Apply ~= nil or boostEffects.Transform ~= nil) then
	-- 		return string.format("<br><font color='#FFBB22'>%s%s</font>", boostEffects.Apply, boostEffects.Transform)
	-- 	end
	-- end
	return ""
end
WeaponExpansion.Skills.Params["LLWEAPONEX_PistolBulletEffects"] = GetPistolBulletEffects

local TranslatedString = LeaderLib.Classes["TranslatedString"]

local damageScaleWeaponText = TranslatedString:Create("ha4cfd852g52f1g4079g8919gd392ac8ade1a", "Damage is based on your basic attack and receives a bonus from [1].")
local damageScaleLevelText = TranslatedString:Create("h71b09f9fg285fg4532gab16g1c7640864141", "Damage is based on your level and receives bonus from [1].")

local function GetScaling(skill, character, isFromItem, param)
	local att = WeaponExpansion.Skills.GetHighestAttribute(character)
	local text = string.gsub(damageScaleLevelText.Value, "%[1%]", att)
	return "<br><font color='#078FC8'>"..text.."</font>"
end

WeaponExpansion.Skills.Params["LLWEAPONEX_HighestAttributeScale"] = GetScaling

local defaultPos = {[1] = 0.0, [2] = 0.0, [3] = 0.0,}

local function LLWEAPONEX_SkillGetDescriptionParam(skill, character, isFromItem, param)
	--Ext.Print("Looking for skill param ("..tostring(param)..") for: " .. skill.Name)
	--Ext.Print("skill("..tostring(skill)..") character("..tostring(character)..") isFromItem("..tostring(isFromItem)..")")
	local param_func = WeaponExpansion.Skills.Damage.Params[param]
	if param_func ~= nil then
		local status,mainDamageRange = xpcall(param_func, debug.traceback, skill, character, isFromItem, false, defaultPos, defaultPos, -1, 0, true)
		if status and mainDamageRange ~= nil then
			local resultString = ""
			--Ext.Print("Skill damage param: " .. LeaderLib.Common.Dump(mainDamageRange))
			for damageType,damage in pairs(mainDamageRange) do
				resultString = resultString .. LeaderLib.Game.GetDamageText(damageType, string.format("%s-%s", math.tointeger(damage[1]), math.tointeger(damage[2])))
			end
			return resultString
		else
			Ext.PrintError("Error getting param ("..param..") for skill:\n",mainDamageRange)
			return ""
		end
	end
	param_func = WeaponExpansion.Skills.Params[param]
	if param_func ~= nil then
		local status,txt = xpcall(param_func, debug.traceback, skill, character, isFromItem, false, defaultPos, defaultPos, -1, 0)
		if status then
			if txt ~= nil then
				return txt
			end
		else
			Ext.PrintError("Error getting param ("..param..") for skill:\n",txt)
			return ""
		end
	end
end

Ext.RegisterListener("SkillGetDescriptionParam", LLWEAPONEX_SkillGetDescriptionParam)