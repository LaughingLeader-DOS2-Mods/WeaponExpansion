Mercs = {
	-- S_Player_LLWEAPONEX_Harken_e446752a-13cc-4a88-a32e-5df244c90d8b
	Harken = "e446752a-13cc-4a88-a32e-5df244c90d8b",
	-- S_Player_LLWEAPONEX_Korvash_3f20ae14-5339-4913-98f1-24476861ebd6
	Korvash = "3f20ae14-5339-4913-98f1-24476861ebd6",
}

function Origins_InitCharacters(region, isEditorMode)
	--IsCharacterCreationLevel(region) == 0
	if CharacterIsPlayer(Mercs.Harken) == 0 or isEditorMode == 1 then
		CharacterApplyPreset(Mercs.Harken, "Knight_Act2")
		GameHelpers.UnequipItemInSlot(Mercs.Harken, "Weapon", true)
		GameHelpers.UnequipItemInSlot(Mercs.Harken, "Helmet", true)
		Uniques.AnvilMace:Transfer(Mercs.Harken, true)
		ObjectSetFlag(Mercs.Harken, "LLWEAPONEX_FixSkillBar", 0)
	end
	Uniques.HarkenPowerGloves:Transfer(Mercs.Harken, true)
	
	if CharacterIsPlayer(Mercs.Korvash) == 0 or isEditorMode == 1 then
		CharacterApplyPreset(Mercs.Korvash, "Inquisitor_Act2")
		GameHelpers.UnequipItemInSlot(Mercs.Korvash, "Weapon", true)
		GameHelpers.UnequipItemInSlot(Mercs.Korvash, "Helmet", true)
		Uniques.DeathEdge:Transfer(Mercs.Korvash, true)
		ObjectSetFlag(Mercs.Korvash, "LLWEAPONEX_FixSkillBar", 0)
	end
	Uniques.DemonGauntlet:Transfer(Mercs.Korvash, true)

	if Ext.IsDeveloperMode() or isEditorMode == 1 then
		local host = GetUUID(CharacterGetHostCharacter())
		if host ~= Mercs.Harken then
			Osi.PROC_GLO_PartyMembers_Add(Mercs.Harken, host)
			TeleportTo(Mercs.Harken, host, "", 1, 0, 1)
		end
		if host ~= Mercs.Korvash then
			Osi.PROC_GLO_PartyMembers_Add(Mercs.Korvash, host)
			TeleportTo(Mercs.Korvash, host, "", 1, 0, 1)
		end
	end
end

Ext.RegisterOsirisListener("CharacterJoinedParty", 1, "after", function(partyMember)
	if ObjectGetFlag(partyMember, "LLWEAPONEX_FixSkillBar") == 1 then
		ObjectClearFlag(partyMember, "LLWEAPONEX_FixSkillBar")
		for i=0,64,1 do
			local slot = NRD_SkillBarGetItem(partyMember, i)
			if not StringHelpers.IsNullOrEmpty(slot) then
				NRD_SkillBarClear(partyMember, i)
			end
		end
		-- local slot = 0
		-- for i,skill in pairs(Ext.GetCharacter(partyMember):GetSkills()) do
		-- 	NRD_SkillBarSetSkill(partyMember, slot, skill)
		-- 	slot = slot + 1
		-- end
	end
end)