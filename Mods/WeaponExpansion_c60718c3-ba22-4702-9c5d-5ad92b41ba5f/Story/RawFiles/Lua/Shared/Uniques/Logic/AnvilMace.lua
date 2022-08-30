if not Vars.IsClient then
	Uniques.AnvilMace:RegisterOnWeaponTagHit(function(e, self)
		if e.TargetIsObject then
			--Ding/dizzy on crit
			if e.Data.Success and e.Data.Damage > 0 and e.Data:HasHitFlag("CriticalHit", true) then
				PlaySound(e.TargetGUID, "LeaderLib_Impacts_Anvil_01")
				GameHelpers.Status.Apply(e.Target, "LLWEAPONEX_DIZZY", 6.0, false, e.Attacker)
			end
		elseif not e.Skill and e.Target then
			--Shockwave when attacking the ground
			GameHelpers.Skill.Explode(e.Target, "Projectile_LLWEAPONEX_AnvilMace_GroundImpact", e.Attacker, {EnemiesOnly = true})
			EffectManager.PlayEffectAt("LLWEAPONEX_FX_AnvilMace_Impact_01", e.Target)
		end
	end)

	SkillManager.Register.Cast("Target_LLWEAPONEX_AnvilMace_GroundSmash", function (e)
		local rushTarget = nil
		e.Data:ForEach(function (target, targetType, self)
			rushTarget = GameHelpers.Math.GetPosition(target)
		end, e.Data.TargetMode.All)
		if not rushTarget then
			rushTarget = GameHelpers.Math.ExtendPositionWithForwardDirection(e.Character, e.Data.SkillData.TargetRadius)
		end
		if rushTarget then
			GameHelpers.ClearActionQueue(e.Character)
			local x,y,z,b = GameHelpers.Grid.GetValidPositionInRadius(rushTarget, 1.0)
			CharacterUseSkillAtPosition(e.CharacterGUID, "Rush_LLWEAPONEX_AnvilMace_GroundSmash", x,y,z, 0, 1)
		end
	end)

	SkillManager.Register.Cast("Rush_LLWEAPONEX_AnvilMace_GroundSmash", function (e)
		local maxRange = e.Data.SkillData.TargetRadius
		e.Data:ForEach(function (target, targetType, self)
			local dist = GameHelpers.Math.GetDistance(e.Character, target)
			local delay = GameHelpers.Math.ScaleToRange(dist, 0, maxRange, 350, 680)
			Timer.Cancel("LLWEAPONEX_RushSmashFinished", e.Character)
			Timer.StartObjectTimer("LLWEAPONEX_RushSmashFinished", e.Character, delay)
		end, e.Data.TargetMode.All)
	end)

	SkillManager.Register.Hit("Projectile_LLWEAPONEX_AnvilMace_RushSmash_GroundImpact", function (e)
		if e.Data.Success and not GameHelpers.Status.IsActive(e.Data.TargetObject, "LLWEAPONEX_ANVILMACE_KNOCKUP") then
			GameHelpers.Status.Apply(e.Data.TargetObject, "LLWEAPONEX_ANVILMACE_KNOCKUP", 0.0, false, e.Character)
		end
	end)
	
	Timer.Subscribe("LLWEAPONEX_RushSmashFinished", function (e)
		if e.Data.UUID then
			local pos = GameHelpers.Math.ExtendPositionWithForwardDirection(e.Data.Object, 2.0)
			GameHelpers.Skill.Explode(pos, "Projectile_LLWEAPONEX_AnvilMace_RushSmash_GroundImpact", e.Data.Object, {EnemiesOnly = true})
		end
	end)
	EquipmentManager.Events.UnsheathedChanged:Subscribe(function (e)
		if GameHelpers.Character.GetBaseRace(e.Character) == "Dwarf" then
			EffectManager.PlayClientEffect("LLWEAPONEX_FX_AnvilMace_Unsheathed_Impact_01", e.Character, {WeaponBones="Dummy_FX_01"})
			--GameHelpers.Status.Apply(e.Target, "LLWEAPONEX_ANVIL_UNSHEATHED_FX", 0, true, e.Target)
		end
	end, {MatchArgs={Tag="LLWEAPONEX_AnvilMace_Equipped", Unsheathed=true}})
end