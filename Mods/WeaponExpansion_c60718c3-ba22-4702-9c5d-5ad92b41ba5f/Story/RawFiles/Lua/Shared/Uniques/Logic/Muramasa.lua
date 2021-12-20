Uniques.Muramasa:RegisterEquippedListener(function(unique, character, item, equipped)
	if equipped then
		if character.Stats.CurrentVitality <= (character.Stats.MaxVitality/2) then
			GameHelpers.Status.Apply(character, "LLWEAPONEX_MURAMASA_CURSE_WEAPONFX", -1.0, false, character)
		end
	else
		RemoveStatus(character.MyGuid, "LLWEAPONEX_MURAMASA_CURSE_WEAPONFX")
	end
end)

if not Vars.IsClient then
	RegisterProtectedOsirisListener("CharacterVitalityChanged", 2, "after", function(char, percentage)
		if GameHelpers.CharacterOrEquipmentHasTag(char, "LLWEAPONEX_UniqueMuramasaKatana") then
			local hasWeaponEffect = HasActiveStatus(char, "LLWEAPONEX_MURAMASA_CURSE_WEAPONFX") == 1
			if percentage <= 50 and not hasWeaponEffect then
				GameHelpers.Status.Apply(char, "LLWEAPONEX_MURAMASA_CURSE_WEAPONFX", -1.0, false, char)
			elseif percentage > 50 and hasWeaponEffect then
				RemoveStatus(char, "LLWEAPONEX_MURAMASA_CURSE_WEAPONFX")
			end
		end
	end, false)
end