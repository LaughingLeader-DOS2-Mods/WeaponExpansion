Uniques.AnvilMace:RegisterOnWeaponTagHit(function(tag, attacker, target, data, targetIsObject, skill)
	if targetIsObject then
		--Ding/dizzy on crit
		if data.Damage > 0 and data:HasHitFlag("CriticalHit", true) then
			PlaySound(target.MyGuid, "LeaderLib_Impacts_Anvil_01")
			GameHelpers.Status.Apply(target, "LLWEAPONEX_DIZZY", 6.0, false, attacker)
		end
	elseif not skill then
		if target then
			--Shockwave when attacking the ground
			GameHelpers.Skill.Explode(target, "Projectile_LLWEAPONEX_AnvilMace_GroundImpact", attacker, {EnemiesOnly = true})
			PlayEffectAtPosition("LLWEAPONEX_FX_AnvilMace_Impact_01", table.unpack(target))
		else
			Ext.PrintError("target is nil?", tag, attacker, target, data, targetIsObject, skill)
		end
	end
end)

Uniques.AnvilMace:RegisterSkillListener({"Target_LLWEAPONEX_AnvilMace_GroundSmash", "Rush_LLWEAPONEX_AnvilMace_GroundSmash", "Projectile_LLWEAPONEX_AnvilMace_RushSmash_GroundImpact"},
function(skill, char, state, data)
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
			local target = data:GetSkillTargetPosition()
			if target then
				local x,y,z = table.unpack(target)
				local dist = GetDistanceToPosition(char, x,y,z)
				local delay = GameHelpers.Math.ScaleToRange(dist, 0, maxRange, 350, 680)
				Timer.Start("LLWEAPONEX_RushSmashFinished", delay, char)
			end
		end
	elseif skill == "Projectile_LLWEAPONEX_AnvilMace_RushSmash_GroundImpact" then
		if state == SKILL_STATE.HIT and data.Success and data.Target then
			if char ~= data.Target and HasActiveStatus(data.Target, "LLWEAPONEX_ANVILMACE_KNOCKUP") == 0 then
				ApplyStatus(data.Target, "LLWEAPONEX_ANVILMACE_KNOCKUP", 0.0, 0, char)
			end
		end
	end
end)

Uniques.AnvilMace:RegisterTimerListener("LLWEAPONEX_RushSmashFinished", function(_, char)
	local pos = GameHelpers.Math.ExtendPositionWithForwardDirection(char, 2.0)
	GameHelpers.Skill.Explode(pos, "Projectile_LLWEAPONEX_AnvilMace_RushSmash_GroundImpact", char, {EnemiesOnly = true})
end, true)