if not Vars.IsClient then
	Ext.Osiris.RegisterListener("CharacterCriticalHitBy", 3, "after", function (target, source, sourceOwner)
		GameHelpers.Status.Remove(source, "LLWEAPONEX_DEMON_GAUNTLET_BONUS_CRIT")
	end)

	EquipmentManager.Events.EquipmentChanged:Subscribe(function(e)
		if e.Equipped then
			GameHelpers.Status.Apply(e.Character, "LLWEAPONEX_DEMON_GAUNTLET_DEFENSE", -1, true, e.Character)
		else
			GameHelpers.Status.Remove(e.Character, "LLWEAPONEX_DEMON_GAUNTLET_DEFENSE")
		end
	end, {MatchArgs={Tag = "LLWEAPONEX_DemonHand_Equipped"}})

	StatusManager.Subscribe.Applied("LLWEAPONEX_DEMON_GAUNTLET_HIT", function (e)
		DeathManager.ListenForDeath("LLWEAPONEX_DemonHand", e.Target, e.Source, 500)
	end)

	DeathManager.OnDeath:Subscribe(function (e)
		EffectManager.PlayEffect("LLWEAPONEX_FX_Status_DemonGauntletDefense_Impact_Back_01", e.Source, {Bone="Dummy_BackFX_R"})
		GameHelpers.Status.Apply(e.Source, "LLWEAPONEX_DEMON_GAUNTLET_BONUS_CRIT", -1, true, e.Source)
	end, {MatchArgs={ID="LLWEAPONEX_DemonHand", Success=true}})
end