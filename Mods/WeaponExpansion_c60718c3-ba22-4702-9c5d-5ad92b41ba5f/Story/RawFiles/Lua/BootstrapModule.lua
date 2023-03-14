---@type WeaponExpansionCustomRequirements
local CustomRequirements = Ext.Require("Shared/Stats/CustomRequirements.lua")

Ext.Events.StatsStructureLoaded:Subscribe(function (e)
	CustomRequirements.Register()
end)