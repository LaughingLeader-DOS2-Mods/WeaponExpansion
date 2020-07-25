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
		CharacterRemoveSkill(Mercs.Korvash, "Cone_Flamebreath")
		CharacterAddSkill(Mercs.Korvash, "Cone_LLWEAPONEX_DarkFlamebreath", 0)
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


local anvilSwapPresets = {
	Knight = true,
	Inquisitor = true,
	Berserker = true,
	Barbarian = true,
}

function CC_CheckKorvashColor(player)
	local character = Ext.GetCharacter(player)
	local color = character.PlayerCustomData.SkinColor
	print(color)
	if color == 4294902015 then-- Pink?
		NRD_PlayerSetCustomDataInt(player, "SkinColor", 4281936940)
		Ext.EnableExperimentalPropertyWrites()
		character.PlayerCustomData.SkinColor = 4281936940
		Ext.PostMessageToClient(player, "LLWEAPONEX_FixLizardSkin", player)
	end
end

function CC_SwapToHarkenAnvilPreview(player, preset)
	if anvilSwapPresets[preset] == true then
		local weapon = CharacterGetEquippedWeapon(player)
		ItemRemove(weapon)
		NRD_ItemConstructBegin("85e2e75e-4333-425e-adc4-94474c3fc201")
		NRD_ItemCloneSetString("GenerationStatsId", "WPN_UNIQUE_LLWEAPONEX_Anvil_Mace_2H_A_Preview")
		NRD_ItemCloneSetString("StatsEntryName", "WPN_UNIQUE_LLWEAPONEX_Anvil_Mace_2H_A_Preview")
		NRD_ItemCloneSetInt("HasGeneratedStats", 0)
		NRD_ItemCloneSetInt("GenerationLevel", 1)
		NRD_ItemCloneSetInt("StatsLevel", 1)
		NRD_ItemCloneSetInt("IsIdentified", 1)
		local item = NRD_ItemClone()
		NRD_CharacterEquipItem(player, item, "Weapon", 0, 0, 0, 1)
	end
end

---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param skillData HitData
local function ClearOriginSkillRequiredTag(skill, char, state, skillData)
	if state == SKILL_STATE.CAST then
		ClearTag(char, "LLWEAPONEX_EnemyDiedInCombat")
	end
end
LeaderLib.RegisterSkillListener("Shout_LLWEAPONEX_UnrelentingRage", ClearOriginSkillRequiredTag)


---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param skillData HitData
LeaderLib.RegisterSkillListener("Projectile_LLWEAPONEX_DarkFireball", function(skill, char, state, skillData)
	if state == SKILL_STATE.CAST then
		PersistentVars.SkillData.DarkFireballCount = 0
		UpdateDarkFireballSkill()
		SyncVars()
	end
end)

function UpdateDarkFireballSkill()
	local killCount = PersistentVars.SkillData.DarkFireballCount or 0
	if killCount >= 1 then
		local rangeBonusMult = Ext.ExtraData["LLWEAPONEX_DarkFireball_RangePerCount"] or 1.0
		local radiusBonusMult = Ext.ExtraData["LLWEAPONEX_DarkFireball_ExplosionRadiusPerCount"] or 0.4
	
		local nextRange = math.floor(6 + (rangeBonusMult * killCount))
		local nextRadius = math.floor(1 + (radiusBonusMult * killCount))
	
		local stat = Ext.GetStat("Projectile_LLWEAPONEX_DarkFireball")
		stat.TargetRadius = nextRange
		stat.AreaRadius = nextRadius
		stat.ExplodeRadius = nextRadius

		if killCount >= 5 then
			stat.Template = "9bdb7e9c-02ce-4f2f-9e7b-463e3771af9c"
		end

		Ext.SyncStat("Projectile_LLWEAPONEX_DarkFireball", true)
	else
		local stat = Ext.GetStat("Projectile_LLWEAPONEX_DarkFireball")
		stat.TargetRadius = 6
		stat.AreaRadius = 1
		stat.ExplodeRadius = 1
		stat.Template = "f3af4ac9-567c-4ac8-8976-ec9c7bc8260d"
		Ext.SyncStat("Projectile_LLWEAPONEX_DarkFireball", true)
	end
end