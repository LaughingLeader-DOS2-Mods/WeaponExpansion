--- @param character StatCharacter
--- @param damageType string DamageType enumeration
--- @param resistancePenetration integer
--- @param currentResistance integer
local function GetHitResistanceBonus(character, damageType, resistancePenetration, currentResistance)
	if damageType == "Physical" then
		-- Unrelenting Rage grants up to a max of 20% Physical Resistance, but anything over that isn't added to.
		local maxResBonus = GameHelpers.GetExtraData("LLWEAPONEX_UnrelentingRage_MaxPhysicalResistanceBonus", 20)
		if currentResistance < maxResBonus and character.Character:GetStatus("LLWEAPONEX_UNRELENTING_RAGE") then
			return maxResBonus - currentResistance
		end
	end
end

RegisterListener("GetHitResistanceBonus", GetHitResistanceBonus)

-- function OnSuckerPunchApplied(target, source)
-- 	local turns = GetStatusTurns(target, "LLWEAPONEX_SUCKER_PUNCH")
-- 	if turns > 0 then
-- 		ApplyStatus(target, "KNOCKED_DOWN", _Duration, 0, source)
-- 		RemoveStatus(target, "LLWEAPONEX_SUCKER_PUNCH")
-- 	end
-- end