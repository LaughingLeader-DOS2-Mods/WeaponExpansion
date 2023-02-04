if not Vars.IsClient then
	local BONE_TOTEM = "4cd5defc-5d36-4d76-b606-b6ca69a13617"

	DeathManager.OnDeath:Subscribe(function (e)
		if not e.Target or not e.Source then
			return
		end
		local x,y,z = table.unpack(e.Target.WorldPos)
		local level = e.Source.Stats.Level
		local duration = GameHelpers.GetExtraData("LLWEAPONEX_DeathEdge_BoneTotemDuration", 6.0, false)
		if duration ~= 0 then
			if duration < 0 then
				duration = -1.0
			end
			local targetName = GameHelpers.GetDisplayName(e.Target)
			CombatLog.AddCombatText(Text.CombatLog.DeathEdgeBonus:ReplacePlaceholders(targetName))
			local boneTotem = NRD_Summon(e.SourceGUID, BONE_TOTEM, x, y, z, duration, level, 1, 1)
			if boneTotem then
				EffectManager.PlayEffectAt("RS3_FX_GP_Impacts_Bones_01", {x, y, z})
				EffectManager.PlayEffectAt("RS3_FX_Skills_Voodoo_Totem_Target_BonePile_01", {x, y + 2, z})
			end
		end
	end, {MatchArgs={ID="DeathEdgeBonus", Success=true}})

	Uniques.DeathEdge:RegisterOnWeaponTagHit(function(e, self)
		if e.TargetIsObject then
			DeathManager.ListenForDeath("DeathEdgeBonus", e.Target, e.Attacker, 1000)
		end
	end)

	EquipmentManager.Events.UnsheathedChanged:Subscribe(function (e)
		if e.Unsheathed then
			GameHelpers.Status.Apply(e.Character, "LLWEAPONEX_DEATHEDGE_UNSHEATHED_FX", -1, true, e.Character)
		else
			GameHelpers.Status.Remove(e.Character, "LLWEAPONEX_DEATHEDGE_UNSHEATHED_FX")
		end
	end, {MatchArgs={Tag="LLWEAPONEX_DeathEdge_Equipped"}})
end