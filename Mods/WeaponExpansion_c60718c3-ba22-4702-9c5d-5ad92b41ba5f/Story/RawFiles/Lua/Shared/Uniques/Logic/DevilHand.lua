if not Vars.IsClient then
	Ext.Osiris.RegisterListener("CharacterCriticalHitBy", 3, "after", function (target, source, sourceOwner)
		GameHelpers.Status.Remove(source, "LLWEAPONEX_DEVIL_HAND_BONUS")
	end)

	EquipmentManager.Events.EquipmentChanged:Subscribe(function(e)
		if e.Equipped then
			GameHelpers.Status.Apply(e.Character, "LLWEAPONEX_DEVIL_HAND_DEFENSE", -1, true, e.Character)
		else
			GameHelpers.Status.Remove(e.Character, "LLWEAPONEX_DEVIL_HAND_DEFENSE")
		end
	end, {MatchArgs={Tag="LLWEAPONEX_DevilHand_Equipped"}})

	DeathManager.OnDeath:Subscribe(function (e)
		EffectManager.PlayEffect("LLWEAPONEX_FX_Status_DemonGauntletDefense_Impact_Back_01", e.Source, {Bone="Dummy_BackFX_R"})
		GameHelpers.Status.Apply(e.Source, "LLWEAPONEX_DEVIL_HAND_BONUS", -1, true, e.Source)
	end, {MatchArgs={ID="DevilHand", Success=true}})

	SkillManager.Register.Hit("Projectile_LLWEAPONEX_Status_DevilHandDefense_Target", function (e)
		if e.Data.Success then
			EffectManager.PlayEffect("RS3_FX_Char_Creature_Demon_Caster_Cast_Target_Cast_LastRites_Hand_01", e.Character, {Bone="Dummy_R_HandFX"})

			local chance = GameHelpers.GetExtraData("LLWEAPONEX_DevilHand_DemonicProtection_HitChance", 30)
			if chance > 0 and GameHelpers.Math.Roll(chance) then
				DeathManager.ListenForDeath("DevilHand", e.Data.Target, e.CharacterGUID, 500)
				
				local soulBurnChance = GameHelpers.GetExtraData("LLWEAPONEX_DevilHand_DemonicProtection_SoulBurnChance", 50)
				if soulBurnChance > 0 and GameHelpers.Math.Roll(soulBurnChance) then
					GameHelpers.Status.Apply(e.Data.TargetObject, "LLWEAPONEX_SOUL_BURN_PROC", 0, false, e.Character)
				end

				GameHelpers.Damage.ApplySkillDamage(e.Character, e.Data.TargetObject, "Projectile_LLWEAPONEX_Status_DevilHandDefense_Damage", {HitParams=HitFlagPresets.DevilHandActiveDefense})

				GameHelpers.Status.Apply(e.Data.TargetObject, "LLWEAPONEX_DEVIL_HAND_BEAMFX", 0, true, e.Character)
			end
		end
	end)
end