local cleansedStatuses = {
	FEAR = "#7F00FF",
	MADNESS = "#D040D0",
	SLEEPING = "#7D71D9",
}

function Banner_ApplyEncouragedBonus(target, source)
	local cleansed = {}
	for status,color in pairs(cleansedStatuses) do
		if HasActiveStatus(target, status) == 1 then
			RemoveStatus(target, status)
			cleansed[#cleansed+1] = string.format("<font color='%s'>%s</font>", color, Ext.GetTranslatedStringFromKey(Ext.StatGetAttribute(status, "DisplayName")))
		end
	end
	if #cleansed > 0 then
		--PlayBeamEffect(source, target, "RS3_FX_GP_Status_Retaliation_Beam_01", "Dummy_R_HandFX", "Dummy_BodyFX")
		ApplyStatus(target, "LLWEAPONEX_ENCOURAGED_CLEANSE_BEAM_FX", 0.0, 1, source)
		local text = Ext.GetTranslatedStringFromKey("LLWEAPONEX_StatusText_Encourage_Cleansed"):gsub("%[1%]", Common.StringJoin("/", cleansed))
		CharacterStatusText(target,text)
	end
end

--- @param character StatCharacter
--- @param damageType string DamageType enumeration
--- @param resistancePenetration integer
--- @param currentResistance integer
local function GetHitResistanceBonus(character, damageType, resistancePenetration, currentResistance)
	if damageType == "Physical" then
		-- Unrelenting Rage grants up to a max of 20% Physical Resistance, but anything over that isn't added to.
		local maxResBonus = Ext.ExtraData["LLWEAPONEX_UnrelentingRage_MaxPhysicalResistanceBonus"] or 20
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