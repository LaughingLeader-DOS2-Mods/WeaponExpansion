
local TranslatedString = LeaderLib.Classes["TranslatedString"]

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

local boltAmmoTypeText = TranslatedString:Create("hfc6af8f2gdd0ag40a0g8d9egc63f5cad0a3e", "Ammo Type: [1]")

local function GetHandCrossbowBoltEffects(skill, character, isFromItem, param)
	local rune,weaponBoostStat = Skills.GetRuneBoost(character, "_LLWEAPONEX_HandCrossbow_Bolts", "_LLWEAPONEX_HandCrossbows", {"Ring", "Ring2"})
	if rune ~= nil then
		--local runeNameText = Text.RuneNames[rune.BoostName]
		local runeNameText = Ext.GetTranslatedStringFromKey(rune.BoostName)
		if runeNameText ~= nil then
			return boltAmmoTypeText.Value:gsub("%[1%]", runeNameText)
		else
			Ext.PrintError("No text for rune: ", rune.BoostName)
		end
	end
	return ""
end

Skills.Params["LLWEAPONEX_HandCrossbowRuneEffects"] = GetHandCrossbowBoltEffects

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


local bulletAmmoTypeText = TranslatedString:Create("h7eee4e3dg9eb0g4a6fg825egc0981d7c0cad", "Ammo Type: [1]")

local function GetPistolBulletEffects(skill, character, isFromItem, param)
	local rune,weaponBoostStat = Skills.GetRuneBoost(character, "_LLWEAPONEX_Pistol_Bullets", "_LLWEAPONEX_Pistols", "Belt")
	if rune ~= nil then
		--local runeNameText = Text.RuneNames[rune.BoostName]
		local runeNameText = Ext.GetTranslatedStringFromKey(rune.BoostName)
		if runeNameText ~= nil then
			return bulletAmmoTypeText.Value:gsub("%[1%]", runeNameText)
		else
			Ext.PrintError("No text for rune: ", rune.BoostName)
		end
	end
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
Skills.Params["LLWEAPONEX_PistolRuneEffects"] = GetPistolBulletEffects

--- @param skill StatEntrySkillData
--- @param character StatCharacter
--- @param isFromItem boolean
--- @param param string
local function GetMasteryBonuses(skill, character, isFromItem, param)
	local data = Mastery.Params.SkillData[skill.Name]
	--Ext.Print(LeaderLib.Common.Dump(data))
	if data ~= nil then
		local paramText = ""
		if data.Tags ~= nil then
			for tagName,tagData in pairs(data.Tags) do
				if tagData.GetParam ~= nil and HasMasteryRequirement(character.Character, tagName) then
					--local tagLocalizedName = Text.MasteryRankTagText[tagName]
					local tagLocalizedName = Ext.GetTranslatedStringFromKey(tagName)
					if tagLocalizedName == nil then 
						tagLocalizedName = ""
					end
					local nextText = tagData.GetParam(character, tagLocalizedName, tagData.Param.Value)
					paramText = paramText.."<br>"..nextText
				end
			end
		end
		return paramText
	end
	return ""
end

Skills.Params["LLWEAPONEX_MasteryBonuses"] = GetMasteryBonuses

local damageScaleWeaponText = TranslatedString:Create("ha4cfd852g52f1g4079g8919gd392ac8ade1a", "Damage is based on your basic attack and receives a bonus from [1].")
local damageScaleLevelText = TranslatedString:Create("h71b09f9fg285fg4532gab16g1c7640864141", "Damage is based on your level and receives bonus from [1].")

local skillAbility = {
	Target_LLWEAPONEX_Pistol_Shoot = "RogueLore",
	Target_LLWEAPONEX_Pistol_Shoot_Enemy = "RogueLore",
	Projectile_LLWEAPONEX_HandCrossbow_Shoot = "RogueLore",
	Projectile_LLWEAPONEX_HandCrossbow_Shoot_Enemy = "RogueLore",
}

local function GetSkillAbility(skill, character, isFromItem, param)
	local ability = skillAbility[skill.Name]
	if ability ~= nil then
		local text = string.gsub(damageScaleLevelText.Value, "%[1%]", LeaderLib.Game.GetAbilityName(ability))
		if text ~= nil then
			return "<br><font color='#078FC8'>"..text.."</font>"
		end
	end
	return ""
end

Skills.Params["LLWEAPONEX_ScalingStat"] = GetSkillAbility

local function GetHighestAttribute(skill, character, isFromItem, param)
	local att = Skills.GetHighestAttribute(character)
	local text = string.gsub(damageScaleLevelText.Value, "%[1%]", att)
	return "<br><font color='#078FC8'>"..text.."</font>"
end

Skills.Params["GetHighestAttribute"] = GetScaling

local defaultPos = {[1] = 0.0, [2] = 0.0, [3] = 0.0,}

--- @param skill StatEntrySkillData
--- @param character StatCharacter
--- @param isFromItem boolean
--- @param param string
local function LLWEAPONEX_SkillGetDescriptionParam(skill, character, isFromItem, param)
	--Ext.Print("Looking for skill param ("..tostring(param)..") for: " .. skill.Name)
	--Ext.Print("skill("..tostring(skill)..") character("..tostring(character)..") isFromItem("..tostring(isFromItem)..")")
	local param_func = Skills.Damage.Params[param]
	if param_func ~= nil then
		local status,mainDamageRange = xpcall(param_func, debug.traceback, skill, character, isFromItem, false, defaultPos, defaultPos, -1, 0, true)
		if status and mainDamageRange ~= nil then
			local resultString = ""
			--Ext.Print("Skill damage param: " .. LeaderLib.Common.Dump(mainDamageRange))
			for damageType,damage in pairs(mainDamageRange) do
				local min = damage[1]
				local max = damage[2]
				if min == max then
					resultString = resultString .. LeaderLib.Game.GetDamageText(damageType, string.format("%i", max))
				else
					resultString = resultString .. LeaderLib.Game.GetDamageText(damageType, string.format("%i-%i", min, max))
				end
			end
			return resultString
		else
			Ext.PrintError("Error getting param ("..param..") for skill:\n",mainDamageRange)
			return ""
		end
	end
	param_func = Skills.Params[param]
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