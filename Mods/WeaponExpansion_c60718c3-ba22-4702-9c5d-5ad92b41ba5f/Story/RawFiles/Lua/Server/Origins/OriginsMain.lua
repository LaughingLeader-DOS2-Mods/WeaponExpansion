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
		GameHelpers.UnequipItemInSlot(OriginCharacters.Harken, "Weapon", true)
		GameHelpers.UnequipItemInSlot(OriginCharacters.Harken, "Helmet", true)
		Uniques.AnvilMace:Transfer(OriginCharacters.Harken, true)
	end
	Uniques.HarkenPowerGloves:Transfer(OriginCharacters.Harken, true)
	
	if CharacterIsPlayer(OriginCharacters.Korvash) == 0 or isEditorMode == 1 then
		CharacterApplyPreset(OriginCharacters.Korvash, "Inquisitor_Act2")
		GameHelpers.UnequipItemInSlot(OriginCharacters.Korvash, "Weapon", true)
		GameHelpers.UnequipItemInSlot(OriginCharacters.Korvash, "Helmet", true)
		Uniques.DeathEdge:Transfer(OriginCharacters.Korvash, true)
	end
	Uniques.DemonHand:Transfer(OriginCharacters.Korvash, true)

	if Ext.IsDeveloperMode() or isEditorMode == 1 then
		local host = GetUUID(CharacterGetHostCharacter())
		if host ~= OriginCharacters.Harken then
			Osi.PROC_GLO_PartyMembers_Add(OriginCharacter.Harken, host)
		end
		if host ~= OriginCharacters.Korvash then
			Osi.PROC_GLO_PartyMembers_Add(OriginCharacter.Korvash, host)
		end
	end
end