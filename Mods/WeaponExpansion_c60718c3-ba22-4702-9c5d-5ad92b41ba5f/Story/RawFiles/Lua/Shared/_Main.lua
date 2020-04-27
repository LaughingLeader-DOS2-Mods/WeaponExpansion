if WeaponExpansion == nil then WeaponExpansion = {} end

LeaderLib = Mods["LeaderLib"]

WeaponExpansion.Main = {}
WeaponExpansion.Debug = {}
WeaponExpansion.Math = { AbilityScaling = {}}
WeaponExpansion.Text = {}
WeaponExpansion.MasteryParams = {}
WeaponExpansion.MasteryVariables = {}
WeaponExpansion.PermanentMasteries = {
	LLWEAPONEX_ThrowingAbility = true
}

--- @param character EsvCharacter|StatCharacter
--- @param tag string
--- @return boolean
local function TryCheckMasteryRequirement(character, tag)
	print("TryCheckMasteryRequirement character", character, "tag", tag)
	if character:HasTag(tag) == true then
		local mastery = string.sub(tag,0,-2)
		if WeaponExpansion.PermanentMasteries(mastery) == true then
			return true
		else
			return character:HasTag(mastery)
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
local function HasMasteryRequirement(character, tag)
	local status,result = xpcall(TryCheckMasteryRequirement, debug.traceback, character, tag)
	if not status then
		Ext.PrintError("Error checking mastery requirements:\n", result)
	else
		return result
	end
	return false
end

WeaponExpansion.HasMasteryRequirement = HasMasteryRequirement

Ext.Require("Shared/Data/MasteryData_Masteries.lua")
Ext.Require("Shared/Data/MasteryBonusParams.lua")

---@class TranslatedString
local TranslatedString = LeaderLib.Classes["TranslatedString"]

---@type table<string,TranslatedString>
local RuneNames = Ext.Require("Shared/Data/RuneNameHandles.lua")
WeaponExpansion.Text.RuneNames = RuneNames

---@type table<string,TranslatedString>
local MasteryRankTagText = Ext.Require("Shared/Data/MasteryRankTagText.lua")
WeaponExpansion.Text.MasteryRankTagText = MasteryRankTagText

Ext.Require("Shared/AbilityBasedScaling.lua")
Ext.Require("Shared/SkillDamageFunctions.lua")

local defaultExperienceAmounts = {
	[0] = {Amount = 45, NextLevel = 1000},
	[1] = {Amount = 30, NextLevel = 3000},
	[2] = {Amount = 20, NextLevel = 6000},
	[3] = {Amount = 12, NextLevel = 12000},
	[4] = {Amount = 0, NextLevel = -1},
	--[5] = {Amount = 0, NextLevel = 0},
}

local function LoadExperienceVariables()
	local RankVariables = {}
	local maxRank = LeaderLib.Game.GetExtraData("LLWEAPONEX_Mastery_MaxRank", 4)
	local lastRankExpGain = 45
	local lastRequiredNextLevelExperience = 1000
	for i=0,maxRank,1 do
		local rankGain = LeaderLib.Game.GetExtraData("LLWEAPONEX_Mastery_ExperienceGain"..tostring(i), nil)
		if rankGain == nil then
			local defaultRankGain = defaultExperienceAmounts[i]
			if defaultRankGain ~= nil then
				rankGain = defaultRankGain
			else
				rankGain = lastRankExpGain / 2
			end
		end
		local requiredNextLevelExperience = LeaderLib.Game.GetExtraData("LLWEAPONEX_Mastery_RequiredExperience"..tostring(i), nil)
		if requiredNextLevelExperience == nil then
			local defaultRequiredNextLevelExperience = defaultExperienceAmounts[i]
			if defaultRequiredNextLevelExperience ~= nil then
				requiredNextLevelExperience = defaultRequiredNextLevelExperience
			else
				lastRequiredNextLevelExperience = lastRequiredNextLevelExperience * 1.5
			end
		end
		RankVariables[i] = {
			Amount = rankGain,
			NextLevel = requiredNextLevelExperience
		}
		lastRankExpGain = rankGain
		lastRequiredNextLevelExperience = requiredNextLevelExperience
	end
	LeaderLib.PrintDebug("[WeaponExpansion] Loaded mastery experience variables:")
	LeaderLib.PrintDebug("==========================")
	LeaderLib.PrintDebug(LeaderLib.Common.Dump(RankVariables))
	LeaderLib.PrintDebug("==========================")

	WeaponExpansion.MasteryVariables.MaxRank = maxRank
	WeaponExpansion.MasteryVariables.RankVariables = RankVariables
end

local function SessionLoading()
	LoadExperienceVariables()
end
Ext.RegisterListener("SessionLoading", SessionLoading)

--Ext.AddPathOverride("Public/Game/GUI/tooltip.swf", "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/LLWEAPONEX_ToolTip.swf")
--Ext.Print("[WeaponExpansion] Enabled tooltip.swf override.")
--Ext.AddPathOverride("Public/Game/GUI/tooltip.swf", "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/serverlist.swf")
--Ext.AddPathOverride("Public/Game/GUI/tooltipHelper_kb.swf", "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/serverlist.swf")
--Ext.AddPathOverride("Public/Game/GUI/tooltipHelper.swf", "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/serverlist.swf")