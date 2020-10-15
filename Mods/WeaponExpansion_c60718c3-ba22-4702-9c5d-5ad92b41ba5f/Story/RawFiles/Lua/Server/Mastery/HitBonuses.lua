--- @param target string
--- @param source string
--- @param damage integer
--- @param handle integer
local function OnWandHit(target,source,damage,handle)

end

--HitHandler.OnHitCallbacks["LLWEAPONEX_Wand"] = OnWandHit

--- @param target string
--- @param source string
--- @param damage integer
--- @param handle integer
local function OnBookHit(target,source,damage,handle)
	local chance = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_Hit_BattleBook_ConcussionChance", 25.0)
	if chance > 0 then
		--HasActiveStatus(target, "LLWEAPONEX_CONCUSSION") == 0 
		if HasMasteryLevel(source, "LLWEAPONEX_BattleBook", 1) then
			if Ext.Random(0,100) <= chance then
				local turns = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_Hit_BattleBook_ConcussionTurns", 1)
				ApplyStatus(target, "LLWEAPONEX_CONCUSSION", 6.0, turns * 6.0, source)
				PlaySound(target, "LLWEAPONEX_FFT_Dictionary_Book_Hit")
			end
		end
	end
end

RegisterHitListener("OnHit", "LLWEAPONEX_BattleBook", OnBookHit)