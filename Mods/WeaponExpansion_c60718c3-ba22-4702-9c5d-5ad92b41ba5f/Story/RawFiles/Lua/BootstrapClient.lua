ClientVars = {
	---@type table<NetId, integer>
	RunicCannonEnergy = {},
}

Ext.Require("BootstrapShared.lua")
Ext.Require("Client/SkillParams.lua")
Ext.Require("Client/MemorizationWindow.lua")
Ext.Require("Client/ClientCommands.lua")
Ext.Require("Client/UI/_InitClientUI.lua")
Ext.Require("Shared/Uniques/UniqueManager.lua")
Ext.Require("Shared/Mastery/_Init.lua")
Ext.Require("Client/Visuals.lua")

function LLWEAPONEX_Settings_MoveAllUniquesToVendingMachine()
	Ext.Net.PostMessageToServer("LLWEAPONEX_Settings_MoveAllUniquesToVendingMachine", "")
end