if RunebladeManager == nil then
	RunebladeManager = {}
end

if RunebladeManager.Bonuses == nil then
	RunebladeManager.Bonuses = {}
end

RunebladeManager.ImpactRadius = GameHelpers.GetExtraData("LLWEAPONEX_Runeblade_BonusImpactRadius", 0.5)

Ext.Require("Server/Runeblades/HitBonuses.lua")
Ext.Require("Server/Runeblades/SurfaceAbsorbing.lua")

StatusManager.Subscribe.Applied("LLWEAPONEX_RUNEBLADE_CONTAMINATION_CHECK", function (e)
	if e.Source then
		EffectManager.PlayEffect("RS3_FX_GP_Beams_AcidBeam_01", e.Source, {BeamTarget=e.Target.Handle, BeamTargetBone="Dummy_BodyFX", Bone="Dummy_BodyFX"})
	end
end)

StatusManager.Subscribe.Applied("LLWEAPONEX_SHOCKED_RESISTANCE_RUNEBLADE_CHECK", function (e)
	Timer.StartObjectTimer("LLWEAPONEX_ShockedResistanceCheck", e.Target, 250, {Duration = e.Status.CurrentLifeTime, SourceGUID = e.SourceGUID})
end)

Timer.Subscribe("LLWEAPONEX_ShockedResistanceCheck", function (e)
	if ObjectExists(e.Data.UUID) == 1 and e.Data.Object then
		local target = e.Data.Object
		---@cast target EsvCharacter
		if not target:GetStatus("LLWEAPONEX_SHOCKED_RESISTANCE_RUNEBLADE") and target:GetStatus("STUNNED") then
			GameHelpers.Status.Apply(target, "LLWEAPONEX_SHOCKED_RESISTANCE_RUNEBLADE", e.Data.Duration, false, e.Data.SourceGUID or target)
		end
		GameHelpers.Status.Remove(target, "LLWEAPONEX_SHOCKED_RESISTANCE_RUNEBLADE_CHECK")
	end
end)