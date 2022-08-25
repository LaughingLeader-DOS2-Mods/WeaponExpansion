if not Vars.IsClient then
	Uniques.Muramasa:RegisterEquippedListener(function(e)
		if e.Equipped then
			if e.Character.Stats.CurrentVitality <= (e.Character.Stats.MaxVitality/2) then
				GameHelpers.Status.Apply(e.Character, "LLWEAPONEX_MURAMASA_CURSE_WEAPONFX", -1.0, false, e.Character)
			end
		else
			GameHelpers.Status.Remove(e.CharacterGUID, "LLWEAPONEX_MURAMASA_CURSE_WEAPONFX")
		end
	end)
	
	RegisterProtectedOsirisListener("CharacterVitalityChanged", 2, "after", function(char, percentage)
		if GameHelpers.CharacterOrEquipmentHasTag(char, "LLWEAPONEX_UniqueMuramasaKatana") then
			local hasWeaponEffect = HasActiveStatus(char, "LLWEAPONEX_MURAMASA_CURSE_WEAPONFX") == 1
			if percentage <= 50 and not hasWeaponEffect then
				GameHelpers.Status.Apply(char, "LLWEAPONEX_MURAMASA_CURSE_WEAPONFX", -1.0, false, char)
			elseif percentage > 50 and hasWeaponEffect then
				GameHelpers.Status.Remove(char, "LLWEAPONEX_MURAMASA_CURSE_WEAPONFX")
			end
		end
	end, false)
end