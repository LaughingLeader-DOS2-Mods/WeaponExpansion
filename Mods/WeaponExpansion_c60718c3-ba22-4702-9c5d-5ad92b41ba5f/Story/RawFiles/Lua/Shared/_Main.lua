if WeaponExpansion == nil then WeaponExpansion = {} end

WeaponExpansion.Main = {}
WeaponExpansion.Debug = {}
WeaponExpansion.Math = { AbilityScaling = {}}
WeaponExpansion.Text = {}
WeaponExpansion.MasteryParams = {}

--- @param character EsvCharacter|StatCharacter
--- @param tag string
--- @return boolean
local function TryCheckMasteryRequirement(character, tag)
	print("TryCheckMasteryRequirement character", character, "tag", tag)
	if character:HasTag(tag) == true then
		---@type StatItem
		local weapon = character.Stats:GetItemBySlot("Weapon")
		---@type StatItem
		local offhand = character.Stats:GetItemBySlot("Shield")
		if weapon ~= nil then
			Ext.Print(string.format("HasMasteryRequirement[%s] MainWeapon[%s]", tag, weapon.Name))
		end
		if offhand ~= nil then
			Ext.Print(string.format("HasMasteryRequirement[%s] OffHandWeapon[%s]", tag, offhand.Name))
		end
		return true
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

--Ext.AddPathOverride("Public/Game/GUI/tooltip.swf", "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/LLWEAPONEX_ToolTip.swf")
--Ext.Print("[WeaponExpansion] Enabled tooltip.swf override.")
--Ext.AddPathOverride("Public/Game/GUI/tooltip.swf", "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/serverlist.swf")
--Ext.AddPathOverride("Public/Game/GUI/tooltipHelper_kb.swf", "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/serverlist.swf")
--Ext.AddPathOverride("Public/Game/GUI/tooltipHelper.swf", "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/serverlist.swf")