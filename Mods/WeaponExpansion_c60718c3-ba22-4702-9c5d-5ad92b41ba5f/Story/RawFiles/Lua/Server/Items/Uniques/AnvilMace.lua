AttackManager.RegisterOnHit(function(bHitObject, attacker, target, damage, data)
	if attacker ~= target and Uniques.AnvilMace:IsOwner(attacker) then
		if bHitObject then
			--Ding/dizzy on crit
			if damage > 0 and data:HasHitFlag("CriticalHit", true) then
				PlaySound(target, "LeaderLib_Impacts_Anvil_01")
				ApplyStatus(target, "LLWEAPONEX_DIZZY", 6.0, 0, attacker)
			end
		else
			--Shockwave when attacking the ground
			GameHelpers.Skill.Explode(target, "Projectile_LLWEAPONEX_AnvilMace_GroundImpact", attacker)
			PlayEffectAtPosition("LLWEAPONEX_FX_AnvilMace_Impact_01",table.unpack(target))
		end
	end
end)

RegisterSkillListener({"Target_LLWEAPONEX_AnvilMace_GroundSmash", "Rush_LLWEAPONEX_AnvilMace_GroundSmash", "Projectile_LLWEAPONEX_AnvilMace_RushSmash_GroundImpact"}, function(skill, char, state, data)
	print(skill, char, state, (data and data.Print) and data:Print() or "")
	if skill == "Target_LLWEAPONEX_AnvilMace_GroundSmash" then
		if state == SKILL_STATE.CAST then
			local target = data:GetSkillTargetPosition()
			if target then
				GameHelpers.ClearActionQueue(char)
				local x,y,z = table.unpack(target)
				CharacterUseSkillAtPosition(char, "Rush_LLWEAPONEX_AnvilMace_GroundSmash", x,y,z, 0, 1)
			end
		end
	elseif skill == "Rush_LLWEAPONEX_AnvilMace_GroundSmash" then
		if state == SKILL_STATE.CAST then
			local maxRange = Ext.StatGetAttribute(skill, "TargetRadius")
			local x,y,z = table.unpack(data.TargetPositions[1])
			local dist = GetDistanceToPosition(char, x,y,z)
			local delay = GameHelpers.Math.ScaleToRange(dist, 0, maxRange, 350, 680)
			print(maxRange, delay, dist)
			Timer.Start("LLWEAPONEX_RushSmashFinished", delay, char)
		end
	elseif skill == "Projectile_LLWEAPONEX_AnvilMace_RushSmash_GroundImpact" then
		if state == SKILL_STATE.HIT and data.Success and data.Target then
			if char ~= data.Target and HasActiveStatus(data.Target, "LLWEAPONEX_ANVILMACE_KNOCKUP") == 0 then
				ApplyStatus(data.Target, "LLWEAPONEX_ANVILMACE_KNOCKUP", 0.0, 0, char)
			end
		end
	end
end)

Timer.RegisterListener("LLWEAPONEX_RushSmashFinished", function(_, char)
	local pos = GameHelpers.Math.ExtendPositionWithForwardDirection(char, 2.0)
	GameHelpers.Skill.Explode(pos, "Projectile_LLWEAPONEX_AnvilMace_RushSmash_GroundImpact", char, char.Stats.Level, true)
end, true)