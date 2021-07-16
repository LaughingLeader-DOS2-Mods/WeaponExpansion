--- @param target string
--- @param source string
--- @param damage integer
--- @param handle integer
local function OnWandHit(target,source,damage,handle)

end

AttackManager.RegisterOnWeaponTagHit("LLWEAPONEX_BattleBook", function(tag, source, target, data, bonuses, bHitObject, isFromSkill)
	if not isFromSkill then
		local chance = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_Hit_BattleBook_ConcussionChance", 25.0)
		if chance > 0 then
			--HasActiveStatus(target, "LLWEAPONEX_CONCUSSION") == 0 
			if HasMasteryLevel(source.MyGuid, "LLWEAPONEX_BattleBook", 1) then
				if chance >= 100 or Ext.Random(0,100) <= chance then
					local turns = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_Hit_BattleBook_ConcussionTurns", 1)
					GameHelpers.Status.Apply(target, "LLWEAPONEX_CONCUSSION", turns*6.0, 0, source, 1.0, false)
					PlaySound(target.MyGuid, "LLWEAPONEX_FFT_Dictionary_Book_Hit")
				end
			end
		end
	end
end)