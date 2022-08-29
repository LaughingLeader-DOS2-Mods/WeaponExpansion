if not Vars.IsClient then
	local BONE_TOTEM = "4cd5defc-5d36-4d76-b606-b6ca69a13617"

	DeathManager.RegisterListener("DeathEdgeBonus", function (target, attacker, success)
		if success then
			local target = GameHelpers.GetCharacter(target)
			local source = GameHelpers.GetCharacter(attacker)
			if target and source then
				local x,y,z = table.unpack(target.WorldPos)
				local level = CharacterGetLevel(attacker)
				local duration = GameHelpers.GetExtraData("LLWEAPONEX_DeathEdge_BoneTotemDuration", 6.0, false)
				if duration ~= 0 then
					if duration < 0 then
						duration = -1.0
					end
					local text = GameHelpers.Tooltip.ReplacePlaceholders(Text.CombatLog.DeathEdgeBonus:ReplacePlaceholders(target.DisplayName), source)
					CombatLog.AddCombatText(text)
					local boneTotem = NRD_Summon(attacker, BONE_TOTEM, x, y, z, duration, level, 1, 1)
					if boneTotem then
						EffectManager.PlayEffectAt("RS3_FX_GP_Impacts_Bones_01", {x, y, z})
						EffectManager.PlayEffectAt("RS3_FX_Skills_Voodoo_Totem_Target_BonePile_01", {x, y + 2, z})
					end
				end
			end
		end
	end)

	Uniques.DeathEdge:RegisterOnWeaponTagHit(function(e, self)
		if e.TargetIsObject then
			DeathManager.ListenForDeath("DeathEdgeBonus", e.Target, e.Attacker, 1000)
		end
	end)
end