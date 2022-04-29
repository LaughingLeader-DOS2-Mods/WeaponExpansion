if not Vars.IsClient then
	--1 Damage Max
	AttackManager.OnWeaponTagHit.Register("LLWEAPONEX_PacifistsWrath_Equipped", function(tag, attacker, target, data, targetIsObject, skill)
		if data.Damage >= 1 then
			data:ClearAllDamage()
			--No killing if at 1 hp
			if GameHelpers.Ext.ObjectIsCharacter(target) and target.Stats.CurrentVitality == 1 then
				return
			end
			data:AddDamage("Physical", 1)
		end
	end)
end