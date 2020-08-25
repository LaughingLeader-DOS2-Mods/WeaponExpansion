Mercs = {
	-- S_Player_LLWEAPONEX_Harken_e446752a-13cc-4a88-a32e-5df244c90d8b
	Harken = "e446752a-13cc-4a88-a32e-5df244c90d8b",
	-- S_Player_LLWEAPONEX_Korvash_3f20ae14-5339-4913-98f1-24476861ebd6
	Korvash = "3f20ae14-5339-4913-98f1-24476861ebd6",
}

local function SetupOriginSkills(char, skillset)
	if CharacterHasSkill(char, "Dome_CircleOfProtection") == 1 then
		CharacterRemoveSkill(char, "Dome_CircleOfProtection")
	end

	---@type StatSkillSet
	local skillSet = Ext.GetSkillSet(skillset)
	if skillSet ~= nil then
		for i,skill in pairs(skillSet.Skills) do
			if CharacterHasSkill(char, skill) == 0 then
				CharacterAddSkill(char, skill, 0)
			end
		end
	end
end

function Origins_InitCharacters(region, isEditorMode)
	pcall(SetupOriginSkills, Mercs.Harken, "Avatar_LLWEAPONEX_Harken")
	pcall(SetupOriginSkills, Mercs.Korvash, "Avatar_LLWEAPONEX_Korvash")

	CharacterRemoveSkill(Mercs.Korvash, "Cone_Flamebreath")
	CharacterAddSkill(Mercs.Korvash, "Cone_LLWEAPONEX_DarkFlamebreath", 0)

	--IsCharacterCreationLevel(region) == 0
	if CharacterIsPlayer(Mercs.Harken) == 0 and ObjectGetFlag(Mercs.Harken, "LLWEAPONEX_Origins_SetupComplete") == 0 then
		CharacterAddAbility(Mercs.Harken, "WarriorLore", 1)
		CharacterAddAbility(Mercs.Harken, "TwoHanded", 1)
		CharacterAddAbility(Mercs.Harken, "Barter", 1)
		CharacterAddTalent(Mercs.Harken, "Opportunist")
		LeaderLib.Data.Presets.Preview.Knight:ApplyToCharacter(Mercs.Harken, "Uncommon", {"Weapon", "Helmet", "Breast", "Gloves"})
		--Mods.LeaderLib.Data.Presets.Preview.Knight:ApplyToCharacter(Mods.WeaponExpansion.Mercs.Harken, "Uncommon", {"Weapon", "Helmet", "Breast", "Gloves"})
		Uniques.AnvilMace:Transfer(Mercs.Harken, true)
		Uniques.HarkenPowerGloves:Transfer(Mercs.Harken, true)
		ObjectSetFlag(Mercs.Harken, "LLWEAPONEX_FixSkillBar", 0)
		ObjectSetFlag(Mercs.Harken, "LLWEAPONEX_Origins_SetupComplete", 0)
		--CharacterAddSkill(Mercs.Harken, "Shout_LLWEAPONEX_UnrelentingRage", 0)
	end
	
	if CharacterIsPlayer(Mercs.Korvash) == 0 and ObjectGetFlag(Mercs.Korvash, "LLWEAPONEX_Origins_SetupComplete") == 0 then
		CharacterAddAbility(Mercs.Korvash, "WarriorLore", 1)
		CharacterAddAbility(Mercs.Korvash, "Necromancy", 1)
		CharacterAddAbility(Mercs.Korvash, "Telekinesis", 1)
		CharacterAddTalent(Mercs.Korvash, "Executioner")
		LeaderLib.Data.Presets.Preview.LLWEAPONEX_Reaper:ApplyToCharacter(Mercs.Korvash, "Uncommon", {"Weapon", "Helmet", "Gloves"})
		--Mods.LeaderLib.Data.Presets.Preview.LLWEAPONEX_Reaper:ApplyToCharacter(Mods.WeaponExpansion.Mercs.Korvash, "Uncommon", {"Weapon", "Helmet", "Gloves"})
		--CharacterAddSkill(Mercs.Korvash, "Projectile_LLWEAPONEX_DarkFireball", 0)
		--Mods.LeaderLib.Data.Presets.Preview.Inquisitor:ApplyToCharacter("3f20ae14-5339-4913-98f1-24476861ebd6", "Uncommon", {"Weapon", "Helmet"})
		--Mods.LeaderLib.Data.Presets.Preview.LLWEAPONEX_Reaper:ApplyToCharacter("3f20ae14-5339-4913-98f1-24476861ebd6", "Uncommon", {"Weapon", "Helmet"})
		--NRD_SkillBarSetSkill(Mods.WeaponExpansion.Mercs.Korvash, 0, "Projectile_LLWEAPONEX_DarkFireball")
		Uniques.DeathEdge:Transfer(Mercs.Korvash, true)
		Uniques.DemonGauntlet:Transfer(Mercs.Korvash, true)
		ObjectSetFlag(Mercs.Korvash, "LLWEAPONEX_FixSkillBar", 0)
		ObjectSetFlag(Mercs.Korvash, "LLWEAPONEX_Origins_SetupComplete", 0)
	end

	if Ext.IsDeveloperMode() or isEditorMode == 1 then		
		local host = CharacterGetHostCharacter()
		if string.find(GetUserName(CharacterGetReservedUserID(host)), "LaughingLeader") then
			local totalAdded = 0
			if CharacterIsInPartyWith(host, Mercs.Harken) == 0 then
				Osi.PROC_GLO_PartyMembers_Add(Mercs.Harken, host)
				TeleportTo(Mercs.Harken, host, "", 1, 0, 1)
				totalAdded = totalAdded + 1
			end
			if CharacterIsInPartyWith(host, Mercs.Korvash) == 0 then
				Osi.PROC_GLO_PartyMembers_Add(Mercs.Korvash, host)
				TeleportTo(Mercs.Korvash, host, "", 1, 0, 1)
				totalAdded = totalAdded + 1
			end
			local frozenCount = Osi.DB_GlobalCounter:Get("FTJ_PlayersWokenUp", nil)
			if frozenCount ~= nil and #frozenCount > 0 then
				local count = frozenCount[1][2]
				Osi.DB_GlobalCounter:Delete("FTJ_PlayersWokenUp", count)
				Osi.DB_GlobalCounter("FTJ_PlayersWokenUp", count + totalAdded)
			end
		end
	end
end

local tierValue = {
    None = 0,
    Starter = 1,
    Novice = 2,
    Adept = 3,
    Master = 4,
}

local ignoredSkillsForFixing = {
	Shout_LLSPRINT_ToggleSprint = true,
	Shout_LeaderLib_ChainAll = true,
	Shout_LeaderLib_UnchainAll = true,
	Shout_LeaderLib_OpenModMenu = true,
}

function Origins_FixSkillBar(uuid)
	local slotEntries = {}
	for i=0,28,1 do
		local slot = NRD_SkillBarGetItem(uuid, i)
		if not StringHelpers.IsNullOrEmpty(slot) then
			NRD_SkillBarClear(uuid, i)
			--slotEntries[i] = slot
		else
			slot = NRD_SkillBarGetSkill(uuid, i)
			if not StringHelpers.IsNullOrEmpty(slot) and ignoredSkillsForFixing[slot] ~= true then
				NRD_SkillBarClear(uuid, i)
				table.insert(slotEntries, slot)
			end
		end
	end
	table.sort(slotEntries, function(a,b)
		local val1 = 0
		local val2 = 0

		local ma1 = Ext.StatGetAttribute(a, "Magic Cost")
		if ma1 > 0 then
			val1 = 9
		elseif Ext.StatGetAttribute(a, "ForGameMaster") == "No" then
			val1 = 6
		else
			val1 = tierValue[Ext.StatGetAttribute(a, "Tier")] or -1
		end

		local ma2 = Ext.StatGetAttribute(b, "Magic Cost")
		if ma2 > 0 then
			val2 = 9
		elseif Ext.StatGetAttribute(b, "ForGameMaster") == "No" then
			val2 = 6
		else
			val2 = tierValue[Ext.StatGetAttribute(b, "Tier")] or -1
		end

		return val1 < val2
	end)

	local slotNum = 0
	for i,v in pairs(slotEntries) do
		print(slotNum, v, uuid)
		NRD_SkillBarSetSkill(uuid, slotNum, v)
		slotNum = slotNum + 1
	end
	-- local slot = 0
	-- for i,skill in pairs(Ext.GetCharacter(uuid):GetSkills()) do
	-- 	NRD_SkillBarSetSkill(uuid, slot, skill)
	-- 	slot = slot + 1
	-- end
end

Ext.RegisterOsirisListener("CharacterJoinedParty", 1, "after", function(partyMember)
	if ObjectGetFlag(partyMember, "LLWEAPONEX_FixSkillBar") == 1 then
		ObjectClearFlag(partyMember, "LLWEAPONEX_FixSkillBar", 0)
		Osi.LeaderLib_Timers_StartObjectTimer(partyMember, 500, "Timers_LLWEAPONEX_FixSkillbar", "LLWEAPONEX_FixSkillbar")
	end
end)


local anvilSwapPresets = {
	Knight = true,
	Inquisitor = true,
	Berserker = true,
	Barbarian = true,
}

function CC_CheckKorvashColor(player)
	if Ext.IsDeveloperMode() then
		local character = Ext.GetCharacter(player)
		local color = character.PlayerCustomData.SkinColor
		if color == 4294902015 then-- Pink?
			NRD_PlayerSetCustomDataInt(player, "SkinColor", 4281936940)
			Ext.EnableExperimentalPropertyWrites()
			character.PlayerCustomData.SkinColor = 4281936940
			Ext.PostMessageToClient(player, "LLWEAPONEX_FixLizardSkin", player)
		end
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
		PersistentVars.SkillData.DarkFireballCount[char] = 0
		UpdateDarkFireballSkill(char)
		SyncVars()
	end
end)

function UpdateDarkFireballSkill(char)
	local killCount = PersistentVars.SkillData.DarkFireballCount[char] or 0
	if killCount >= 1 then
		local rangeBonusMult = Ext.ExtraData["LLWEAPONEX_DarkFireball_RangePerCount"] or 1.0
		local radiusBonusMult = Ext.ExtraData["LLWEAPONEX_DarkFireball_ExplosionRadiusPerCount"] or 0.4
	
		local nextRange = math.min(16, math.floor(6 + (rangeBonusMult * killCount)))
		local nextRadius = math.min(8, math.floor(1 + (radiusBonusMult * killCount)))
	
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

Ext.RegisterConsoleCommand("llweaponex_darkfireballtest", function(call, amount)
	PersistentVars.SkillData.DarkFireballCount = tonumber(amount)
	UpdateDarkFireballSkill(Mercs.Korvash)
	SyncVars()
end)