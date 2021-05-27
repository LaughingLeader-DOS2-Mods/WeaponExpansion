BasicAttackManager.RegisterListener("OnHit", function(hitObject, attacker, target, handle, damage)
	if damage > 0 and ObjectGetFlag(attacker, "LLWEAPONEX_AnvilMaceEquipped") == 1 then
		if hitObject then
			if NRD_StatusGetInt(target, handle, "CriticalHit") == 1 then
				PlaySound(target, "LeaderLib_Impacts_Anvil_01")
				ApplyStatus(target, "LLWEAPONEX_DIZZY", 6.0, 0, attacker)
			end
		else
			GameHelpers.ExplodeProjectile(attacker, target, "Projectile_LLWEAPONEX_AnvilMace_GroundImpact")
		end
	end
end)