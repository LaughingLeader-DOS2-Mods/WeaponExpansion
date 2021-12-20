if not Vars.IsClient then
	--- @param target EsvCharacter|EsvItem
	--- @param attacker EsvCharacter|EsvItem
	--- @param data HitData
	function SwordofVictory_OnHit(target, attacker, data)
		local leadership = target:GetStatus("LEADERSHIP")
		if leadership then
			local leader = GameHelpers.TryGetObject(leadership.StatusSourceHandle)
			if leader and GameHelpers.Ext.ObjectIsCharacter(leader) then
				if GameHelpers.CharacterOrEquipmentHasTag(leader, "LLWEAPONEX_SwordofVictory_Equipped") then
					local damageMult = math.min(1.0, GameHelpers.GetExtraData("LLWEAPONEX_SwordofVictory_DamageRedirectionAmount", 15) * 0.01)
					if damageMult > 0 then
						data:RedirectDamage(leader.MyGuid, damageMult)
					end
				end
			end
		end
	end
end