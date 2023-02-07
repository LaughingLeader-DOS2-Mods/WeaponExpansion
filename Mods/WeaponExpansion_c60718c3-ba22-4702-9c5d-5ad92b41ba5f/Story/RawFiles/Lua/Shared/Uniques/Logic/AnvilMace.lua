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
			local pos,b = GameHelpers.Grid.GetValidPositionTableInRadius(rushTarget, 1.0)
			GameHelpers.Action.UseSkill(e.Character, "Rush_LLWEAPONEX_AnvilMace_GroundSmash", pos)
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

	---@param target EsvCharacter|EsvItem
	---@param source EsvCharacter
	local function _Knockup(target, source)
		EffectManager.PlayEffectAt("LLWEAPONEX_FX_Status_Launched_Apply_Root_01", target.WorldPos, {Scale=0.25})
		local height = Ext.Utils.Random(2500, 8000) / 1000
		GameHelpers.Utils.KnockUpObject(target, height, {Source=source, ID="LLWEAPONEX_AnvilMace_RushSmash", Skill="Projectile_LLWEAPONEX_AnvilMace_RushSmash_GroundImpact"})
	end

	Events.ForceMoveFinished:Subscribe(function (e)
		local effectScale = math.max(0.15, math.min(0.75, e.Distance / 8))
		EffectManager.PlayEffectAt("LLWEAPONEX_FX_Skills_AnvilMace_GroundSmash_Land_Impact_01", e.Target.WorldPos, {Scale=effectScale})
		Timer.Cancel("LLWEAPONEX_GroundSlam_FallbackAnimOverrideClear", e.TargetGUID)
		Osi.LeaderLib_Hacks_ClearAnimationOverride(e.TargetGUID, "Play_Anim_knockdown_getup")
		GameHelpers.Status.Remove(e.Target, "LLWEAPONEX_ANVILMACE_KNOCKUP_DISABLED")
		if not GameHelpers.ObjectIsDead(e.Target) then
			local damageMult = Ext.Utils.Round(math.max(0.25, math.min(1.0, e.Distance/8)) * 100)
			GameHelpers.Damage.ApplySkillDamage(e.Source, e.Target, "Projectile_LLWEAPONEX_AnvilMace_RushSmash_FallDamage", {SkillDataParamModifiers={["Damage Multiplier"] = damageMult}, HitParams=HitFlagPresets.GuaranteedWeaponHit})
		end
	end, {MatchArgs={ID="LLWEAPONEX_AnvilMace_RushSmash"}})

	StatusManager.Subscribe.Applied("LLWEAPONEX_ANVILMACE_KNOCKUP", function (e)
		if GameHelpers.Ext.ObjectIsCharacter(e.Target) then
			GameHelpers.Status.Apply(e.Target, "LLWEAPONEX_ANVILMACE_KNOCKUP_DISABLED", -2, true, e.Source)
			local targetGUID = e.TargetGUID
			GameHelpers.Action.PlayAnimation(e.Target, "knockdown_fall", {FinishedCallback=function (character, animation)
				CharacterSetStill(targetGUID)
				CharacterSetAnimationOverride(targetGUID, "knockdown_loop")
				Timer.StartObjectTimer("LLWEAPONEX_GroundSlam_FallbackAnimOverrideClear", targetGUID, 3000)
			end})
		end
		_Knockup(e.Target, e.Source)
	end)

	Timer.Subscribe("LLWEAPONEX_GroundSlam_FallbackAnimOverrideClear", function (e)
		Osi.LeaderLib_Hacks_ClearAnimationOverride(e.Data.UUID, "Play_Anim_knockdown_getup")
	end)
	
	Timer.Subscribe("LLWEAPONEX_RushSmashFinished", function (e)
		if e.Data.UUID then
			local pos = GameHelpers.Math.ExtendPositionWithForwardDirection(e.Data.Object, 2.0)
			GameHelpers.Skill.Explode(pos, "Projectile_LLWEAPONEX_AnvilMace_RushSmash_GroundImpact", e.Data.Object, {EnemiesOnly = true})
		end
	end)

	EquipmentManager.Events.UnsheathedChanged:Subscribe(function (e)
		if GameHelpers.Character.GetBaseRace(e.Character) == "Dwarf" then
			--EffectManager.PlayClientEffect("LLWEAPONEX_FX_AnvilMace_Unsheathed_Impact_01", e.Character, {WeaponBones="Dummy_FX_01"})
			GameHelpers.Status.Apply(e.Character, "LLWEAPONEX_ANVIL_UNSHEATHED_FX", 0, true, e.Character)
		end
	end, {MatchArgs={Tag="LLWEAPONEX_AnvilMace_Equipped", Unsheathed=true}})
end