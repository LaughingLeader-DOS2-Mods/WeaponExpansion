if not Vars.IsClient then
	---@param attacker string
	---@param target number[]
	---@param hitObject EsvCharacter|EsvItem
	function MagicMissileWand_RollForBonusMissiles(attacker, target, hitObject)
		local chance1 = GameHelpers.GetExtraData("LLWEAPONEX_MagicMissile_BonusChance1", 45)
		local chance2 = GameHelpers.GetExtraData("LLWEAPONEX_MagicMissile_BonusChance2", 30)
		local chance3 = GameHelpers.GetExtraData("LLWEAPONEX_MagicMissile_BonusChance3", 10)
		local sourcePos = GameHelpers.Math.GetForwardPosition(attacker, 4.0)
		sourcePos[2] = sourcePos[2] + 2.0
		--local targetPos = GameHelpers.Math.ExtendPositionWithForwardDirection(attacker, 1.01, target[1], target[2], target[3])
		local targetPos = target
		if GameHelpers.Math.Roll(chance1) then
			GameHelpers.Skill.ShootProjectileAt(attacker, "Projectile_LLWEAPONEX_Status_MagicMissile_Bonus1", targetPos, {SourcePosition=sourcePos, HitObject=hitObject})
		end
		if GameHelpers.Math.Roll(chance2) then
			GameHelpers.Skill.ShootProjectileAt(attacker, "Projectile_LLWEAPONEX_Status_MagicMissile_Bonus2", targetPos, {SourcePosition=sourcePos, HitObject=hitObject})
		end
		if GameHelpers.Math.Roll(chance3) then
			GameHelpers.Skill.ShootProjectileAt(attacker, "Projectile_LLWEAPONEX_Status_MagicMissile_Bonus3", targetPos, {SourcePosition=sourcePos, HitObject=hitObject})
		end
	end

	Ext.Events.ProjectileHit:Subscribe(function (e)
		local projectile = e.Projectile
		if projectile.RootTemplate ~= nil 
			and projectile.RootTemplate.TrailFX == "LLWEAPONEX_FX_Projectiles_Wand_MagicMissile_01"
			and projectile.SourceHandle ~= nil
			and projectile.RootTemplate.PathShift == 0.5
		then
			local attacker = GameHelpers.TryGetObject(projectile.SourceHandle, "EsvCharacter")
			if attacker ~= nil and attacker:HasTag("LLWEAPONEX_MagicMissileWand_Equipped") then
				local target = e.HitObject --[[@as EsvCharacter|EsvItem]]
				MagicMissileWand_RollForBonusMissiles(attacker.MyGuid, e.Position, target)
			end
		end
	end)

	SkillManager.Register.Cast("Shout_LLWEAPONEX_Rods_MagicMissile_ToggleMode", function (e)
		SwapUnique(e.CharacterGUID, Uniques.MagicMissileWand.ID)
	end)
end