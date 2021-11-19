if RunebladeManager == nil then
	RunebladeManager = {}
end

if RunebladeManager.Bonuses == nil then
	RunebladeManager.Bonuses = {}
end

RunebladeManager.ImpactRadius = GameHelpers.GetExtraData("LLWEAPONEX_Runeblade_BonusImpactRadius", 0.5)

Ext.Require("Server/Runeblades/HitBonuses.lua")
Ext.Require("Server/Runeblades/SurfaceAbsorbing.lua")