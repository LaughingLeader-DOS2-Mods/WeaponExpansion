if not Vars.IsClient then
	---@param attacker string
	---@param target number[]
	---@param hitObject EsvGameObject
	function MagicMissileWand_RollForBonusMissiles(attacker, target, hitObject)
		local chance1 = GameHelpers.GetExtraData("LLWEAPONEX_MagicMissile_BonusChance1", 45)
		local chance2 = GameHelpers.GetExtraData("LLWEAPONEX_MagicMissile_BonusChance2", 30)
		local chance3 = GameHelpers.GetExtraData("LLWEAPONEX_MagicMissile_BonusChance3", 10)
		local sourcePos = GameHelpers.Math.GetForwardPosition(attacker, 4.0)
		sourcePos[2] = sourcePos[2] + 2.0
		--local targetPos = GameHelpers.Math.ExtendPositionWithForwardDirection(attacker, 1.01, target[1], target[2], target[3])
		local targetPos = target
		if Ext.Random(0,100) <= chance1 then
			GameHelpers.ShootProjectile(attacker, targetPos, "Projectile_LLWEAPONEX_Status_MagicMissile_Bonus1", true, sourcePos, hitObject.MyGuid)
		end
		if Ext.Random(0,100) <= chance2 then
			GameHelpers.ShootProjectile(attacker, targetPos, "Projectile_LLWEAPONEX_Status_MagicMissile_Bonus2", true, sourcePos, hitObject.MyGuid)
		end
		if Ext.Random(0,100) <= chance3 then
			GameHelpers.ShootProjectile(attacker, targetPos, "Projectile_LLWEAPONEX_Status_MagicMissile_Bonus3", true, sourcePos, hitObject.MyGuid)
		end
	end

	---@param projectile EsvProjectile
	---@param hitObject EsvGameObject
	---@param position number[]
	RegisterProtectedExtenderListener("ProjectileHit", function(projectile, hitObject, position)
		if projectile.RootTemplate ~= nil 
			and projectile.RootTemplate.TrailFX == "LLWEAPONEX_FX_Projectiles_Wand_MagicMissile_01" 
			and projectile.SourceHandle ~= nil 
			and projectile.RootTemplate.PathShift == 0.5
		then
			local attacker = Ext.GetGameObject(projectile.SourceHandle)
			if attacker ~= nil and attacker:HasTag("LLWEAPONEX_MagicMissileWand_Equipped") then
				MagicMissileWand_RollForBonusMissiles(attacker.MyGuid, position, hitObject)
			end
		end
	end)
end