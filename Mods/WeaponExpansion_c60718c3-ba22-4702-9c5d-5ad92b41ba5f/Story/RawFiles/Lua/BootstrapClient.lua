Ext.Require("BootstrapShared.lua")
Ext.Require("Client/SkillParams.lua")
Ext.Require("Client/StatusParams.lua")
Ext.Require("Client/MemorizationWindow.lua")
Ext.Require("Client/ClientCommands.lua")
Ext.Require("Client/UI/_InitClientUI.lua")
Ext.Require("Client/UI/TooltipHelpers.lua")
Ext.Require("Shared/Uniques/UniqueManager.lua")
Ext.Require("Shared/Mastery/_Init.lua")

function LLWEAPONEX_Settings_MoveAllUniquesToVendingMachine()
	Ext.PostMessageToServer("LLWEAPONEX_Settings_MoveAllUniquesToVendingMachine", "")
end