LeaderLib = Mods["LeaderLib"]
WeaponExpansion = Mods["WeaponExpansion"]

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

--- @type table<string,string>
Tags = {}

Ext.Require("Shared/GameMathAlternatives.lua")
Ext.Require("Shared/StatOverrides.lua")
Ext.Require("Shared/Data/LocalizedText.lua")
Ext.Require("Shared/Data/MasteryData_Classes.lua")
Ext.Require("Shared/Data/MasteryData_Masteries.lua")
Ext.Require("Shared/Data/MasteryData_BonusParams.lua")
Ext.Require("Shared/Data/WeaponTypesTags.lua")
Ext.Require("Shared/AbilityBasedScaling.lua")
Ext.Require("Shared/SkillDamageFunctions.lua")
Ext.Require("Shared/UnarmedMechanics.lua")

--- @param character EsvCharacter|StatCharacter
--- @param tag string
--- @return boolean
local function TryCheckMasteryRequirement(character, tag)
	if character:HasTag(tag) == true then
		local a,b,mastery = string.find(tag,"(.+)_Mastery")
		--print("TryCheckMasteryRequirement character", character, "tag", tag, "mastery", mastery, character:HasTag(mastery))
		if mastery ~= nil and Mastery.PermanentMasteries[mastery] == true then
			return true
		else
			if Ext.IsClient() then
				return (MasteryMenu.DisplayingSkillTooltip == true and MasteryMenu.SelectedMastery == mastery) or character:HasTag(mastery)
			else
				return character:HasTag(mastery)
			end
		end
		-- local hasTaggedWeapons = false
		-- ---@type StatItem
		-- local weapon = character.Stats:GetItemBySlot("Weapon")
		-- ---@type StatItem
		-- local offhand = character.Stats:GetItemBySlot("Shield")
		-- if weapon ~= nil then
		-- 	Ext.Print(string.format("HasMasteryRequirement[%s] MainWeapon[%s]", tag, weapon.Name))
		-- end
		-- if offhand ~= nil then
		-- 	Ext.Print(string.format("HasMasteryRequirement[%s] OffHandWeapon[%s]", tag, offhand.Name))
		-- end
		-- return hasTaggedWeapons
	end
	return false
end

--- @param character EsvCharacter|StatCharacter
--- @param tag string
--- @return boolean
function HasMasteryRequirement(character, tag)
	local status,result = xpcall(TryCheckMasteryRequirement, debug.traceback, character, tag)
	if not status then
		Ext.PrintError("Error checking mastery requirements:\n", result)
	else
		return result
	end
	return false
end

local defaultExperienceAmounts = {
	[0] = {Amount = 45, Required = 0},
	[1] = {Amount = 30, Required = 1000},
	[2] = {Amount = 20, Required = 3000},
	[3] = {Amount = 12, Required = 6000},
	[4] = {Amount = 0, Required = 12000},
	--[5] = {Amount = 0, Required = 36000},
}

local function LoadExperienceVariables()
	local RankVariables = {}
	local maxRank = LeaderLib.Game.GetExtraData("LLWEAPONEX_Mastery_MaxRank", 4)
	local lastRankExpGain = 45
	local lastRequiredNextLevelExperience = 1000
	for i=0,maxRank+1,1 do
		local rankGain = LeaderLib.Game.GetExtraData("LLWEAPONEX_Mastery_ExperienceGain"..tostring(i), nil)
		if rankGain == nil then
			local defaultRankGain = defaultExperienceAmounts[i]
			if defaultRankGain ~= nil then
				rankGain = defaultRankGain.Amount
			else
				rankGain = lastRankExpGain / 2
			end
		end
		local requiredNextLevelExperience = LeaderLib.Game.GetExtraData("LLWEAPONEX_Mastery_RequiredExperience"..tostring(i), nil)
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
	LeaderLib.PrintDebug("[WeaponExpansion] Loaded mastery experience variables:")
	LeaderLib.PrintDebug("==========================")
	LeaderLib.PrintDebug(LeaderLib.Common.Dump(RankVariables))
	LeaderLib.PrintDebug("==========================")

	Mastery.Variables.MaxRank = maxRank
	Mastery.Variables.RankVariables = RankVariables
end

--Ext.RegisterListener("SessionLoading", LoadExperienceVariables)
Ext.RegisterListener("ModuleResume", LoadExperienceVariables) -- Lua Reset
Ext.RegisterListener("SessionLoaded", LoadExperienceVariables)