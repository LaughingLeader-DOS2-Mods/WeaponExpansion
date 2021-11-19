if not Vars.IsClient then
	local registeredListeners = 0

	---Tiered statuses that apply when enemies with the LLWEAPONEX_SOULHARVEST_REAP status die.
	---@type string[]
	Skills.Data.SoulHarvestDamageTiers  = {
		"LLWEAPONEX_SOULHARVEST_DAMAGE_BONUS1",
		"LLWEAPONEX_SOULHARVEST_DAMAGE_BONUS2",
		"LLWEAPONEX_SOULHARVEST_DAMAGE_BONUS3",
		"LLWEAPONEX_SOULHARVEST_DAMAGE_BONUS4",
		"LLWEAPONEX_SOULHARVEST_DAMAGE_BONUS5",
	}

	DeathManager.RegisterListener("SoulHarvestReaping", function(target, source, targetDied)
		if targetDied then
			PlaySound(target, "LeaderLib_Madness_09")
			local tier,lastTier = GameHelpers.Status.ApplyTieredStatus(source, Skills.Data.SoulHarvestDamageTiers, -1.0)
			if tier ~= lastTier then
				PlayEffect(source, "LLWEAPONEX_FX_Status_SoulHarvest_Impact_01", "Dummy_OverheadFX")
			end
		end
	end)

	RegisterStatusListener("Attempt", "LLWEAPONEX_SOULHARVEST_REAP", function(target, status, source, handle)
		DeathManager.ListenForDeath("SoulHarvestReaping", target, source, 1000)
	end)

	RegisterItemListener("EquipmentChanged", "Tag", "LLWEAPONEX_UniqueHarvestScythe", function(char, item, tag, equipped)
		--printf("EquipmentChanged(%s, %s, %s, %s)", char, item, tag, equipped)
	end)
end