--- @param target string
--- @param source string
--- @param damage integer
--- @param handle integer
local function OnWandHit(target,source,damage,handle)

end

BasicAttackManager.RegisterOnWeaponTypeHit("LLWEAPONEX_BattleBook", function(IsFromSkill, source, target, damage, data, bonuses, skill)
	if not IsFromSkill then
		local chance = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_Hit_BattleBook_ConcussionChance", 25.0)
		if chance > 0 then
			--HasActiveStatus(target, "LLWEAPONEX_CONCUSSION") == 0 
			if HasMasteryLevel(source.MyGuid, "LLWEAPONEX_BattleBook", 1) then
				if Ext.Random(0,100) <= chance then
					local turns = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_Hit_BattleBook_ConcussionTurns", 1)
					ApplyStatus(target.MyGuid, "LLWEAPONEX_CONCUSSION", 6.0, turns * 6.0, source.MyGuid)
					PlaySound(target.MyGuid, "LLWEAPONEX_FFT_Dictionary_Book_Hit")
				end
			end
		end
	end
end)