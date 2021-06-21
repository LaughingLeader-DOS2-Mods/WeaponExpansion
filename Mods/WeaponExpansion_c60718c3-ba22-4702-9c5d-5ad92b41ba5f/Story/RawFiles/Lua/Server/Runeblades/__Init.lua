if RunebladeManager == nil then
	RunebladeManager = {}
end

if RunebladeManager.Bonuses == nil then
	RunebladeManager.Bonuses = {}
end

RunebladeManager.ImpactRadius = Ext.ExtraData.LLWEAPONEX_Runeblade_BonusImpactRadius or 0.5

Ext.Require("Server/Runeblades/HitBonuses.lua")
Ext.Require("Server/Runeblades/SurfaceAbsorbing.lua")