if not Vars.IsClient then
	---Tiered statuses that apply when enemies hit by Cone_LLWEAPONEX_SoulHarvest_Reap die.
	---@type string[]
	Skills.Data.SoulHarvestDamageTiers = {
		"LLWEAPONEX_SOULHARVEST_DAMAGE_BONUS1",
		"LLWEAPONEX_SOULHARVEST_DAMAGE_BONUS2",
		"LLWEAPONEX_SOULHARVEST_DAMAGE_BONUS3",
		"LLWEAPONEX_SOULHARVEST_DAMAGE_BONUS4",
		"LLWEAPONEX_SOULHARVEST_DAMAGE_BONUS5",
	}

	SkillManager.Register.Hit("Cone_LLWEAPONEX_SoulHarvest_Reap", function (e)
		if e.Data.Success then
			EffectManager.PlayEffect("RS3_FX_Skills_Soul_Cast_Target_Cast_LastRites_Body_01", e.Data.Target, {Bone="Dummy_BodyFX"})
			DeathManager.ListenForDeath("SoulHarvestReaping", e.Data.Target, e.Character.MyGuid, 1000)
		end
	end)

	DeathManager.RegisterListener("SoulHarvestReaping", function(target, source, targetDied)
		if targetDied then
			PlaySound(target, "LeaderLib_Madness_09")
			local tier,lastTier = GameHelpers.Status.ApplyTieredStatus(source, Skills.Data.SoulHarvestDamageTiers, -1.0, nil, source, true)
			if tier ~= lastTier then
				EffectManager.PlayEffect("LLWEAPONEX_FX_Status_SoulHarvest_Impact_01", source, {Bone="Dummy_OverheadFX"})
			end
		end
	end)

	Events.CharacterDied:Subscribe(function(e)
		if GameHelpers.Status.IsActive(e.Character, Skills.Data.SoulHarvestDamageTiers) then
			StatusManager.RemovePermanentStatus(e.Character, Skills.Data.SoulHarvestDamageTiers)
		end
	end)
end