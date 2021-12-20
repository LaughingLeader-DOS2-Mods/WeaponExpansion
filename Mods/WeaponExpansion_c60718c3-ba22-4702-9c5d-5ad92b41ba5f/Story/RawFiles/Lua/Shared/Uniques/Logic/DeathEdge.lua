if not Vars.IsClient then
	local BONE_TOTEM = "4cd5defc-5d36-4d76-b606-b6ca69a13617"
	
	Uniques.DeathEdge:RegisterDeathManagerListener("DeathEdgeBonus", function(target, source, success)
		if success then
			local target = GameHelpers.GetCharacter(target)
			local source = GameHelpers.GetCharacter(source)
			if target and source then
				local x,y,z = table.unpack(target.WorldPos)
				local level = CharacterGetLevel(source)
				local duration = GameHelpers.GetExtraData("LLWEAPONEX_DeathEdge_BoneTotemDuration", 6.0, false)
				if duration ~= 0 then
					if duration < 0 then
						duration = -1.0
					end
					local boneTotem = NRD_Summon(source, BONE_TOTEM, x, y, z, duration, level, 1, 1)
					PlayEffectAtPosition("RS3_FX_GP_Impacts_Bones_01", x, y, z)
					PlayEffectAtPosition("RS3_FX_Skills_Voodoo_Totem_Target_BonePile_01", x, y + 2, z)
					local text = GameHelpers.Tooltip.ReplacePlaceholders(Text.CombatLog.DeathEdgeBonus:ReplacePlaceholders(target.DisplayName), source)
					CombatLog.AddTextToAllPlayers(CombatLog.Filters.Combat, text)
				end
			end
		end
	end)

	Uniques.DeathEdge:RegisterOnWeaponTagHit(function(tag, attacker, target, data, targetIsObject, skill)
		if targetIsObject then
			DeathManager.ListenForDeath("DeathEdgeBonus", target, attacker, 1000)
		end
	end)
end