if WeaponExpansion == nil then WeaponExpansion = {} end

WeaponExpansion.Main = {}
WeaponExpansion.Debug = {}

WeaponExpansion.Text = {}

---@class TranslatedString
local TranslatedString = LeaderLib.Classes["TranslatedString"]

---@type table<string,TranslatedString>
local RuneNames = Ext.Require("WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f", "Shared/LLWEAPONEX_RuneNameHandles.lua")
WeaponExpansion.Text.RuneNames = RuneNames


Ext.Require("WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f", "Shared/LLWEAPONEX_SkillDamageFunctions.lua")

--Ext.AddPathOverride("Public/Game/GUI/tooltip.swf", "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/LLWEAPONEX_ToolTip.swf")
--Ext.Print("[WeaponExpansion] Enabled tooltip.swf override.")
--Ext.AddPathOverride("Public/Game/GUI/tooltip.swf", "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/serverlist.swf")
--Ext.AddPathOverride("Public/Game/GUI/tooltipHelper_kb.swf", "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/serverlist.swf")
--Ext.AddPathOverride("Public/Game/GUI/tooltipHelper.swf", "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/serverlist.swf")