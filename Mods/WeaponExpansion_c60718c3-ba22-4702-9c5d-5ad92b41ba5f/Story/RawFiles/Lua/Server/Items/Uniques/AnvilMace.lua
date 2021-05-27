BasicAttackManager.RegisterOnHit(function(bHitObject, attacker, target, damage, handle)
	if ObjectGetFlag(attacker, "LLWEAPONEX_AnvilMaceEquipped") == 1 then
		if bHitObject then
			--Ding/dizzy on crit
			if damage > 0 and NRD_StatusGetInt(target, handle, "CriticalHit") == 1 then
				PlaySound(target, "LeaderLib_Impacts_Anvil_01")
				ApplyStatus(target, "LLWEAPONEX_DIZZY", 6.0, 0, attacker)
			end
		else
			--Shockwave when attacking the ground
			GameHelpers.ExplodeProjectile(attacker, target, "Projectile_LLWEAPONEX_AnvilMace_GroundImpact")
		end
	end
end)