if not Vars.IsClient then
	RegisterSkillListener({"Projectile_SkyShot", "Projectile_EnemySkyShot"}, function(skill, char, state, data)
		if GameHelpers.CharacterOrEquipmentHasTag(char, "LLWEAPONEX_Omnibolt_Equipped") then
			if state == SKILL_STATE.HIT and data.Success then
				GameHelpers.Skill.Explode(data.Target, "Projectile_LLWEAPONEX_Greatbow_LightningStrike", char)
			elseif state == SKILL_STATE.CAST then
				if data.TotalTargetPositions > 0 and data.TotalTargetObjects == 0 then
					local x,y,z = table.unpack(data.TargetPositions[1])
					Timer.Start("Timers_LLWEAPONEX_ProcGreatbowLightningStrike", 750, {
						Pos={x,y,z},
						Source=char
					})
				end
			end
		end
	end)

	Timer.RegisterListener("Timers_LLWEAPONEX_ProcGreatbowLightningStrike", function(timerName, char)
		if char and ObjectGetFlag(char, "LLWEAPONEX_Omnibolt_SkyShotWorldBonus") == 1 then
			local x,y,z = GetVarFloat3(char, "LLWEAPONEX_Omnibolt_SkyShotWorldPosition")
			GameHelpers.Skill.Explode({x,y,z}, "Projectile_LLWEAPONEX_Greatbow_LightningStrike", char)
		end
	end)

	AttackManager.OnWeaponTagHit.Register("LLWEAPONEX_Omnibolt_Equipped", function(tag, attacker, target, data, targetIsObject, skill)
		if not skill and BonusRoll(GameHelpers.GetExtraData("LLWEAPONEX_Omnibolt_LightningChance", 201, true)) then
			GameHelpers.Skill.Explode(target, "Projectile_LLWEAPONEX_Greatbow_LightningStrike", attacker, {EnemiesOnly = true})
		end
	end)
end