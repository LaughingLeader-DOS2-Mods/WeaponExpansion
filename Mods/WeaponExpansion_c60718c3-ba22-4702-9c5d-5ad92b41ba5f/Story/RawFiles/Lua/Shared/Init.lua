LeaderLib = Mods["LeaderLib"]
---@type GameHelpers
GameHelpers = LeaderLib.GameHelpers
Common = LeaderLib.Common
StringHelpers = LeaderLib.StringHelpers
--WeaponExpansion = Mods["WeaponExpansion"]

SKILL_STATE = LeaderLib.SKILL_STATE

Main = {}
Debug = {}
Math = { AbilityScaling = {}}
Text = {}
Mastery = {
	Params = {},
	Variables = {},
	PermanentMasteries = {
		LLWEAPONEX_ThrowingAbility = true
	}
}
LeaveActionData = {}
Temp = {
	StatusSource = {}
}
Vars = {
	GAME_STARTED = false,
	SEND_USER_ID = false,
	isInCharacterCreation = false,
}

Skills = {
	Params = {},
	DamageParam = {},
	Damage = {},
	DamageFunctions = {},
	WarfareMeleeSkills = {},
	ScoundrelMeleeSkills = {},
}

AttributeScaleTables = {
	NoMemory = {"Strength", "Finesse", "Intelligence", "Wits", "Constitution"},
	Default = {"Strength", "Finesse", "Intelligence"},
}

--- @type table<string,string>
Tags = {}

UI = {}

Ext.Require("Shared/MasteryHelpers.lua")
Ext.Require("Shared/GameMathAlternatives.lua")
Ext.Require("Shared/StatOverrides.lua")
Ext.Require("Shared/Data/LocalizedText.lua")
Ext.Require("Shared/Data/MasteryData_Classes.lua")
Ext.Require("Shared/Data/MasteryData_Masteries.lua")
Ext.Require("Shared/Data/MasteryData_RankBonuses.lua")
Ext.Require("Shared/Data/WeaponTypesTags.lua")
Ext.Require("Shared/Data/UnarmedWeaponStats.lua")
Ext.Require("Shared/Data/PresetEntries.lua")
Ext.Require("Shared/AbilityBasedScaling.lua")
Ext.Require("Shared/SkillDamageFunctions.lua")
Ext.Require("Shared/UnarmedMechanics.lua")
Ext.Require("Shared/ExtenderHelpers.lua")

if Ext.IsDeveloperMode() then
	--Ext.Require("Shared/Debug/GameMathTracing.lua")
end

local defaultExperienceAmounts = {
	[0] = {Amount = 45, Required = 0},
	[1] = {Amount = 30, Required = 1000},
	[2] = {Amount = 20, Required = 3000},
	[3] = {Amount = 12, Required = 6000},
	[4] = {Amount = 0, Required = 12000},
	--[5] = {Amount = 0, Required = 36000},
}

local initHarkenVoiceMetaData = Ext.Require("Shared/Data/VoiceMetaData_Harken.lua")
local initKorvashVoiceMetaData = Ext.Require("Shared/Data/VoiceMetaData_Korvash.lua")

Ext.RegisterListener("ModuleLoading", function()
	initHarkenVoiceMetaData()
	initKorvashVoiceMetaData()
end)

local function LoadExperienceVariables()	
	local RankVariables = {}
	local maxRank = math.tointeger(Ext.ExtraData["LLWEAPONEX_Mastery_MaxRank"] or 4.0)
	local lastRankExpGain = 45
	local lastRequiredNextLevelExperience = 1000
	for i=0,maxRank+1,1 do
		local rankGain = Ext.ExtraData["LLWEAPONEX_Mastery_ExperienceGain"..tostring(i)] or nil
		if rankGain == nil then
			local defaultRankGain = defaultExperienceAmounts[i]
			if defaultRankGain ~= nil then
				rankGain = defaultRankGain.Amount
			else
				rankGain = lastRankExpGain / 2
			end
		end
		local requiredNextLevelExperience = Ext.ExtraData["LLWEAPONEX_Mastery_RequiredExperience"..tostring(i)] or nil
		if requiredNextLevelExperience == nil then
			local defaultRequiredNextLevelExperience = defaultExperienceAmounts[i]
			if defaultRequiredNextLevelExperience ~= nil then
				requiredNextLevelExperience = defaultRequiredNextLevelExperience.Required
			else
				lastRequiredNextLevelExperience = lastRequiredNextLevelExperience * 1.5
			end
		end
		RankVariables[i] = {
			Amount = rankGain,
			Required = requiredNextLevelExperience
		}
		lastRankExpGain = rankGain
		lastRequiredNextLevelExperience = requiredNextLevelExperience
	end
	--LeaderLib.PrintDebug("[WeaponExpansion] Loaded mastery experience variables:")
	--LeaderLib.PrintDebug("==========================")
	--LeaderLib.PrintDebug(LeaderLib.Common.Dump(RankVariables))
	--LeaderLib.PrintDebug("==========================")

	Mastery.Variables.MaxRank = math.floor(maxRank)
	Mastery.Variables.RankVariables = RankVariables

	for i,skill in pairs(Ext.GetStatEntries("SkillData")) do
		---@type StatRequirement[]
		local requirements = Ext.StatGetAttribute(skill, "Requirements")
		if requirements ~= nil then
			for i,v in pairs(requirements) do
				if v.Param == "LLWEAPONEX_NoMeleeWeaponEquipped" then
					Skills.WarfareMeleeSkills[skill] = true
					break
				elseif v.Param == "LLWEAPONEX_CannotUseScoundrelSkills" then
					Skills.ScoundrelMeleeSkills[skill] = true
					break
				end
			end
		end
	end
end

local function OnInit()
	LoadExperienceVariables()
	LeaderLib.EnableFeature("ApplyBonusWeaponStatuses")
    LeaderLib.EnableFeature("ExtraDataSkillParamReplacement")
	LeaderLib.EnableFeature("TooltipGrammarHelper")
	LeaderLib.EnableFeature("FixChaosDamageDisplay")
	LeaderLib.EnableFeature("StatusParamSkillDamage")
end

--Ext.RegisterListener("ModuleResume", OnInit) -- Lua Reset
Ext.RegisterListener("SessionLoaded", OnInit)

Ext.AddPathOverride("Mods/Helaene_Class_Marauder_53ed8826-71d6-452a-b9e5-faef35da8628/CharacterCreation/ClassPresets/Class_Marauder.lsx", "Mods/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/Overrides/LLWEAPONEX_Helaene_Marauder.lsx")

if Ext.IsDeveloperMode() then
    Ext.RegisterListener("GetHitChance", function(attacker, target)
		return 100
	end)
end