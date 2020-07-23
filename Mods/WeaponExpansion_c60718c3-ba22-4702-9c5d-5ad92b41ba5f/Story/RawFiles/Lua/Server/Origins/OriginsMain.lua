OriginCharacters = {
	-- S_Player_LLWEAPONEX_Harken_e446752a-13cc-4a88-a32e-5df244c90d8b
	Harken = "e446752a-13cc-4a88-a32e-5df244c90d8b",
	-- S_Player_LLWEAPONEX_Korvash_3f20ae14-5339-4913-98f1-24476861ebd6
	Korvash = "3f20ae14-5339-4913-98f1-24476861ebd6",
}

function Origins_InitCharacters(region, isEditorMode)
	--IsCharacterCreationLevel(region) == 0
	if CharacterIsPlayer(OriginCharacters.Harken) == 0 or isEditorMode == 1 then
		CharacterApplyPreset(OriginCharacters.Harken, "Knight_Act2")
		GameHelpers.UnequipItemInSlot(OriginCharacters.Harken, "Weapon")
		Uniques.AnvilMace:Transfer(OriginCharacters.Harken, true)
	end
	Uniques.HarkenPowerGloves:Transfer(OriginCharacters.Harken, true)
	
	if CharacterIsPlayer(OriginCharacters.Korvash) == 0 or isEditorMode == 1 then
		CharacterApplyPreset(OriginCharacters.Korvash, "Inquisitor_Act2")
		GameHelpers.UnequipItemInSlot(OriginCharacters.Korvash, "Weapon")
		Uniques.DeathEdge:Transfer(OriginCharacters.Korvash, true)
	end
	Uniques.DemonHand:Transfer(OriginCharacters.Korvash, true)
end