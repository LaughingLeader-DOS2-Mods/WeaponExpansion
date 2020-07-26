
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
				if Mastery.HasMasteryRequirement(character.Character, tagName) then
					--local tagLocalizedName = Text.MasteryRankTagText[tagName]
					local tagLocalizedName = Ext.GetTranslatedStringFromKey(tagName)
					if tagLocalizedName == nil then 
						tagLocalizedName = ""
					end
					local paramText = ""
					if tagLocalizedName ~= "" then
						paramText = tagLocalizedName.."<br>"..tagData.Param.Value
					else
						paramText = tagData.Param.Value
					end
					paramText = Tooltip.ReplacePlaceholders(paramText)
					if tagData.GetParam ~= nil then
						local b,result = xpcall(tagData.GetParam, debug.traceback, character, tagName, paramText)
						if b and result ~= nil then
							paramText = paramText.."<br>"..result
						end
					end
				end
			end
		end
		return paramText
	end
	return ""
end

Skills.Params["LLWEAPONEX_MasteryBonuses"] = GetMasteryBonuses

local skillAbility = {
	Target_LLWEAPONEX_Pistol_Shoot = "RogueLore",
	Target_LLWEAPONEX_Pistol_Shoot_Enemy = "RogueLore",
	Projectile_LLWEAPONEX_HandCrossbow_Shoot = "RogueLore",
	Projectile_LLWEAPONEX_HandCrossbow_Shoot_Enemy = "RogueLore",
}

local function GetSkillAbility(skill, character, isFromItem, param)
	local ability = skillAbility[skill.Name]
	if ability ~= nil then
		local text = string.gsub(Text.DefaultSkillScaling.LevelBased.Value, "%[1%]", GameHelpers.GetAbilityName(ability))
		if text ~= nil then
			return "<br><font color='#078FC8'>"..text.."</font>"
		end
	end
	return ""
end

Skills.Params["LLWEAPONEX_ScalingStat"] = GetSkillAbility

local function GetHighestAttribute(skill, character, isFromItem, param)
	local att = Skills.GetHighestAttribute(character)
	local text = string.gsub(Text.DefaultSkillScaling.LevelBased.Value, "%[1%]", att)
	return "<br><font color='#078FC8'>"..text.."</font>"
end

Skills.Params["GetHighestAttribute"] = GetHighestAttribute

--- @param skill StatEntrySkillData
--- @param character StatCharacter
--- @param isFromItem boolean
--- @param param string
local function GetUnarmedBasicAttackDamage(skill, character, isFromItem, param)
	local weapon = GetUnarmedWeapon(character)
	local damageRange = Math.GetSkillDamageRange(character, skill, weapon)
	if damageRange ~= nil then
		local damageTexts = {}
		local totalDamageTypes = 0
		for damageType,damage in pairs(damageRange) do
			local min = damage[1]
			local max = damage[2]

			if min == nil then min = 0 end
			if max == nil then max = 0 end

			if min > 0 and max > 0 then
				if max == min then
					table.insert(damageTexts, GameHelpers.GetDamageText(damageType, string.format("%i", max)))
				else
					table.insert(damageTexts, GameHelpers.GetDamageText(damageType, string.format("%i-%i", min, max)))
				end
			end
			totalDamageTypes = totalDamageTypes + 1
		end
		if totalDamageTypes > 0 then
			if totalDamageTypes > 1 then
				return LeaderLib.Common.StringJoin(", ", damageTexts)
			else
				return damageTexts[1]
			end
		end
	end
	return ""
end

Skills.Params["LLWEAPONEX_UnarmedBasicAttackDamage"] = GetUnarmedBasicAttackDamage

--- @param skill StatEntrySkillData
--- @param character StatCharacter
--- @param isFromItem boolean
--- @param param string
local function GetStealChance(skill, character, isFromItem, param)
	local chance = Ext.ExtraData["LLWEAPONEX_Steal_BaseChance"] or 50.0
	if character.Character:HasTag("LLWEAPONEX_ThiefGloves_Equipped") then
		local glovesBonusChance = Ext.ExtraData["LLWEAPONEX_Steal_GlovesBonusChance"] or 30.0
		chance = chance + glovesBonusChance
	end
	return string.format("%i", chance)
end

Skills.Params["LLWEAPONEX_StealChance"] = GetStealChance

local defaultPos = {[1] = 0.0, [2] = 0.0, [3] = 0.0,}

local function GetDamageParamResult(param_func, skill, character, isFromItem)
	local status,damageRange = xpcall(param_func, debug.traceback, skill, character, isFromItem, false, defaultPos, defaultPos, -1, 0, true)
	if status then
		if damageRange ~= nil then
			if type(damageRange) == "table" then
				local damageTexts = {}
				local totalDamageTypes = 0
				for damageType,damage in pairs(damageRange) do
					local min = damage[1]
					local max = damage[2]
					if min == nil then min = 0 end
					if max == nil then max = 0 end
		
					if min > 0 and max > 0 then
						if max == min then
							table.insert(damageTexts, GameHelpers.GetDamageText(damageType, string.format("%i", max)))
						else
							table.insert(damageTexts, GameHelpers.GetDamageText(damageType, string.format("%i-%i", min, max)))
						end
					end
					totalDamageTypes = totalDamageTypes + 1
				end
				if totalDamageTypes > 0 then
					if totalDamageTypes > 1 then
						return LeaderLib.Common.StringJoin(", ", damageTexts)
					else
						return damageTexts[1]
					end
				end
			else
				return damageRange
			end
		end
	else
		Ext.PrintError("Error getting param ("..param..") for skill:\n",damageRange)
	end
end

--- @param skill StatEntrySkillData
--- @param character StatCharacter
--- @param isFromItem boolean
--- @param param string
function SkillGetDescriptionParam(skill, character, isFromItem, param)
	if param == "Damage" then
		if skill.UseWeaponDamage == "Yes" and IsUnarmed(character) then
			return GetUnarmedBasicAttackDamage(skill, character, isFromItem, param)
		else
			local param_func = Skills.Damage[skill.Name]
			if param_func ~= nil then
				return GetDamageParamResult(param_func, skill, character, isFromItem)
			end
		end
	elseif Skills.DamageParam[param] ~= nil then
		local param_func = Skills.DamageParam[param]
		if param_func ~= nil then
			return GetDamageParamResult(param_func, skill, character, isFromItem)
		end
	else
		local param_func = Skills.Params[param]
		if param_func ~= nil then
			local status,txt = xpcall(param_func, debug.traceback, skill, character, isFromItem, param)
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
end

Ext.RegisterListener("SkillGetDescriptionParam", SkillGetDescriptionParam)