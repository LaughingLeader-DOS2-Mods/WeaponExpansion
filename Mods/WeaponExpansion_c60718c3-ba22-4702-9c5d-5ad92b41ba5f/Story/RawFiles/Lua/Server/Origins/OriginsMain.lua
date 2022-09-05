
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

local function AddToParty(uuid, host)
	--Osi.PROC_GLO_PartyMembers_Add(uuid, host)
	CharacterRecruitCharacter(uuid,host)
	Osi.ProcCharacterDisableAllCrimes(uuid)
	Osi.ProcAssignCharacterToPlayer(uuid,host)
	Osi.ProcRegisterPlayerTriggers(uuid)
	--PROC_GLO_PartyMembers_SetInpartyDialog(uuid,_NewDialog)
	--SetFaction(uuid,Osi.DB_GLO_PartyMembers_DefaultFaction:Get(uuid)[1][2])
	SetFaction(uuid,"Good NPC")
	Osi.DB_IsPlayer:Delete(uuid)
	Osi.DB_IsPlayer(uuid)
	--NOT DB_GLO_PartyMembers_DefaultFaction(uuid,hostFaction)
	CharacterAttachToGroup(uuid,host)
	CharacterSetCorpseLootable(uuid, 0)
	--Osi.Proc_CheckPartyFull()
	Osi.Proc_CheckFirstTimeRecruited(uuid)
	Osi.PROC_GLO_PartyMembers_RecruiteeAvatarBond_IfDifferent(uuid,host)
	Osi.Proc_BondedAvatarTutorial(host)
	Osi.PROC_GLO_PartyMembers_AddHook(uuid,host)
end

Events.RegionChanged:Subscribe(function (e)
	if e.State == REGIONSTATE.GAME and e.LevelType == LEVELTYPE.GAME then
		Origins_InitCharacters(e.Region)
	end
end)

function Origins_InitCharacters(region)
	if StringHelpers.IsNullOrEmpty(CharacterGetHostCharacter()) then
		return
	end

	local isInitialized = true

	local harken = GameHelpers.GetCharacter(Origin.Harken)
	if harken and (not harken.Stats.TALENT_Dwarf_Sturdy or not harken.Stats.TALENT_Dwarf_Sneaking) then
		NRD_PlayerSetBaseTalent(Origin.Harken, "Dwarf_Sturdy", 1)
		NRD_PlayerSetBaseTalent(Origin.Harken, "Dwarf_Sneaking", 1)
		CharacterAddCivilAbilityPoint(Origin.Harken, 0)
	end

	--IsCharacterCreationLevel(region) == 0
	if CharacterIsPlayer(Origin.Harken) == 0 and ObjectGetFlag(Origin.Harken, "LLWEAPONEX_Origins_SetupComplete") == 0 then
		if isInitialized then
			isInitialized = ObjectGetFlag(Origin.Harken, "LLWEAPONEX_Origins_SetupComplete") == 1
		end
		pcall(SetupOriginSkills, Origin.Harken, "Avatar_LLWEAPONEX_Harken")

		--CharacterApplyPreset(Origin.Harken, "LLWEAPONEX_Harken")
		NRD_PlayerSetBaseAttribute(Origin.Harken, "Strength", 3)
		NRD_PlayerSetBaseAbility(Origin.Harken, "WarriorLore", 1)
		NRD_PlayerSetBaseAbility(Origin.Harken, "TwoHanded", 1)
		NRD_PlayerSetBaseAbility(Origin.Harken, "Barter", 1)
		NRD_PlayerSetBaseTalent(Origin.Harken, "Opportunist", 1)

		CharacterAddCivilAbilityPoint(Origin.Harken, 0)

		if Debug.CreateOriginPresetEquipment or Vars.LeaderDebugMode then
			Data.Presets.Preview.Knight:ApplyToCharacter(Origin.Harken, "Uncommon", {"Weapon", "Helmet", "Breast", "Gloves"})
			--Mods.Data.Presets.Preview.Knight:ApplyToCharacter(Mods.WeaponExpansion.Origin.Harken, "Uncommon", {"Weapon", "Helmet", "Breast", "Gloves"})
			if Vars.DebugMode then
				Timer.StartOneshot("Timers_LLWEAPONEX_Harken_EquipUniques", 500, function()
					Uniques.AnvilMace:Transfer(Origin.Harken, Uniques.AnvilMace.DefaultUUID, true)
					Uniques.HarkenPowerGloves:Transfer(Origin.Harken, Uniques.HarkenPowerGloves.DefaultUUID, true)
				end)
			end
		end

		ObjectSetFlag(Origin.Harken, "LLWEAPONEX_FixSkillBar", 0)
		ObjectSetFlag(Origin.Harken, "LLWEAPONEX_Origins_SetupComplete", 0)
		--CharacterAddSkill(Origin.Harken, "Shout_LLWEAPONEX_UnrelentingRage", 0)
	end

	local korvash = GameHelpers.GetCharacter(Origin.Korvash)
	if korvash and (not korvash.Stats.TALENT_Lizard_Resistance or not korvash.Stats.TALENT_Lizard_Persuasion) then
		NRD_PlayerSetBaseTalent(Origin.Korvash, "Lizard_Resistance", 1)
		NRD_PlayerSetBaseTalent(Origin.Korvash, "Lizard_Persuasion", 1)
		CharacterAddCivilAbilityPoint(Origin.Korvash, 0)
	end
	
	if CharacterIsPlayer(Origin.Korvash) == 0 and ObjectGetFlag(Origin.Korvash, "LLWEAPONEX_Origins_SetupComplete") == 0 then
		if isInitialized then
			isInitialized = ObjectGetFlag(Origin.Korvash, "LLWEAPONEX_Origins_SetupComplete") == 1
		end
		pcall(SetupOriginSkills, Origin.Korvash, "Avatar_LLWEAPONEX_Korvash")
	
		CharacterRemoveSkill(Origin.Korvash, "Cone_Flamebreath")
		CharacterAddSkill(Origin.Korvash, "Cone_LLWEAPONEX_DarkFlamebreath", 0)
		--CharacterApplyPreset(Origin.Korvash, "LLWEAPONEX_Korvash")
		NRD_PlayerSetBaseAbility(Origin.Korvash, "WarriorLore", 1)
		NRD_PlayerSetBaseAbility(Origin.Korvash, "Necromancy", 1)
		NRD_PlayerSetBaseAbility(Origin.Korvash, "Telekinesis", 1)
		NRD_PlayerSetBaseAttribute(Origin.Korvash, "Strength", 2)
		NRD_PlayerSetBaseAttribute(Origin.Korvash, "Wits", 1)
		NRD_PlayerSetBaseTalent(Origin.Korvash, "Executioner", 1)
		CharacterAddCivilAbilityPoint(Origin.Korvash, 0)

		if Debug.CreateOriginPresetEquipment or Vars.LeaderDebugMode then
			Data.Presets.Preview.LLWEAPONEX_Reaper:ApplyToCharacter(Origin.Korvash, "Uncommon", {"Weapon", "Helmet", "Gloves"})
			--Mods.Data.Presets.Preview.LLWEAPONEX_Reaper:ApplyToCharacter(Mods.WeaponExpansion.Origin.Korvash, "Uncommon", {"Weapon", "Helmet", "Gloves"})
			--CharacterAddSkill(Origin.Korvash, "Projectile_LLWEAPONEX_DarkFireball", 0)
			--Mods.Data.Presets.Preview.Inquisitor:ApplyToCharacter("3f20ae14-5339-4913-98f1-24476861ebd6", "Uncommon", {"Weapon", "Helmet"})
			--Mods.Data.Presets.Preview.LLWEAPONEX_Reaper:ApplyToCharacter("3f20ae14-5339-4913-98f1-24476861ebd6", "Uncommon", {"Weapon", "Helmet"})
			--NRD_SkillBarSetSkill(Mods.WeaponExpansion.Origin.Korvash, 0, "Projectile_LLWEAPONEX_DarkFireball")
			if Vars.DebugMode then
				Timer.StartOneshot("Timers_LLWEAPONEX_Korvash_EquipUniques", 500, function()
					Uniques.DeathEdge:Transfer(Origin.Korvash, Uniques.DeathEdge.DefaultUUID, true)
					Uniques.DemonGauntlet:Transfer(Origin.Korvash, Uniques.DemonGauntlet.DefaultUUID, true)
				end)
			end
		end

		ObjectSetFlag(Origin.Korvash, "LLWEAPONEX_FixSkillBar", 0)
		ObjectSetFlag(Origin.Korvash, "LLWEAPONEX_Origins_SetupComplete", 0)
	end

	if not isInitialized then
		if not Vars.DebugMode then
			if not GameHelpers.Character.IsPlayer(Origin.Harken) and not GameHelpers.Character.IsPlayer(Uniques.AnvilMace.Owner) then
				Uniques.AnvilMace:Transfer(NPC.VendingMachine)
			end
			if not GameHelpers.Character.IsPlayer(Origin.Korvash) then
				if not GameHelpers.Character.IsPlayer(Uniques.DeathEdge.Owner) then
					Uniques.DeathEdge:Transfer(NPC.VendingMachine)
				end
				if not GameHelpers.Character.IsPlayer(Uniques.DemonGauntlet.Owner) then
					Uniques.DemonGauntlet:Transfer(NPC.VendingMachine)
				end
			end
		elseif Debug.AddOriginsToParty or Vars.LeaderDebugMode then
			local host = CharacterGetHostCharacter()
			local user = CharacterGetReservedUserID(host)
			local totalAdded = 0
			if CharacterIsInPartyWith(host, Origin.Harken) == 0 then
				AddToParty(Origin.Harken, host)
				totalAdded = totalAdded + 1
			end
			TeleportTo(Origin.Harken, host, "", 1, 0, 1)
			CharacterAttachToGroup(Origin.Harken, host)
			SetOnStage(Origin.Harken, 1)
			CharacterAssignToUser(user, Origin.Harken)
			local pdata = Ext.GetCharacter(Origin.Harken).PlayerCustomData
			if pdata ~= nil then
				pdata.OriginName = "LLWEAPONEX_Harken"
				pdata.Race = "Dwarf"
				pdata.IsMale = true
			end
			
			if CharacterIsInPartyWith(host, Origin.Korvash) == 0 then
				AddToParty(Origin.Korvash, host)
				totalAdded = totalAdded + 1
			end
			TeleportTo(Origin.Korvash, host, "", 1, 0, 1)
			CharacterAttachToGroup(Origin.Korvash, host)
			SetOnStage(Origin.Korvash, 1)
			CharacterAssignToUser(user, Origin.Korvash)
			pdata = Ext.GetCharacter(Origin.Korvash).PlayerCustomData
			if pdata ~= nil then
				pdata.OriginName = "LLWEAPONEX_Korvash"
				pdata.Race = "Lizard"
				pdata.IsMale = true
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
		NRD_SkillBarSetSkill(uuid, slotNum, v)
		slotNum = slotNum + 1
	end
	-- local slot = 0
	-- for i,skill in pairs(Ext.GetCharacter(uuid):GetSkills()) do
	-- 	NRD_SkillBarSetSkill(uuid, slot, skill)
	-- 	slot = slot + 1
	-- end
end

RegisterProtectedOsirisListener("CharacterJoinedParty", 1, "after", function(partyMember)
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

function CC_CheckKorvashColor(characterId)
	local character = GameHelpers.GetCharacter(characterId)
	print(character, characterId)
	if character then
		local id = GameHelpers.GetUserID(character)
		if id ~= nil and character.PlayerCustomData ~= nil then
			local nextColor = OriginColors.Korvash.Default
			if Ext.IsModLoaded("db07c22c-8935-3848-2366-7827b70c6030") then
				nextColor = OriginColors.Korvash.LadyC
			end
			if character.PlayerCustomData.SkinColor ~= nextColor then
				GameHelpers.Net.PostToUser(id, "LLWEAPONEX_FixLizardSkin", "")
			end
		end
	end
end

Ext.RegisterNetListener("LLWEAPONEX_CC_CheckKorvashColor", function(cmd, characterId)
	CC_CheckKorvashColor(tonumber(characterId))
end)

local hiddenStoryButtons = {}

function CC_HideStoryButton(uuid)
	if Ext.GetGameState() == "Running" then
		local id = GameHelpers.GetUserID(uuid)
		if id ~= nil then
			hiddenStoryButtons[id] = true
			Ext.PostMessageToUser(id, "LLWEAPONEX_CC_HideStoryButton", uuid)
		end
	end
end

function CC_EnableStoryButton(uuid)
	if Ext.GetGameState() == "Running" then
		local id = GameHelpers.GetUserID(uuid)
		if id ~= nil and hiddenStoryButtons[id] ~= nil then
			hiddenStoryButtons[id] = nil
			Ext.PostMessageToUser(id, "LLWEAPONEX_CC_EnableStoryButton", uuid)
		end
	end
end

function CC_SwapToHarkenAnvilPreview(uuid, preset)
	if anvilSwapPresets[preset] == true then
		local weapon = CharacterGetEquippedWeapon(uuid)
		ItemRemove(weapon)
		NRD_ItemConstructBegin("85e2e75e-4333-425e-adc4-94474c3fc201")
		NRD_ItemCloneSetString("GenerationStatsId", "WPN_UNIQUE_LLWEAPONEX_Anvil_Mace_2H_A_Preview")
		NRD_ItemCloneSetString("StatsEntryName", "WPN_UNIQUE_LLWEAPONEX_Anvil_Mace_2H_A_Preview")
		NRD_ItemCloneSetInt("HasGeneratedStats", 0)
		NRD_ItemCloneSetInt("GenerationLevel", 1)
		NRD_ItemCloneSetInt("StatsLevel", 1)
		NRD_ItemCloneSetInt("IsIdentified", 1)
		local item = NRD_ItemClone()
		NRD_CharacterEquipItem(uuid, item, "Weapon", 0, 0, 0, 1)
	end
end

function CC_OnPresetSelected(uuid, preset)
	if preset == "LLWEAPONEX_Korvash" then
		CC_HideStoryButton(uuid)
		CC_CheckKorvashColor(uuid)
	elseif preset == "LLWEAPONEX_Harken" then
		CC_HideStoryButton(uuid)
	else
		CC_EnableStoryButton(uuid)
	end
end

RegisterSkillListener("Shout_LLWEAPONEX_UnrelentingRage", function(skill, char, state, data)
	if state == SKILL_STATE.CAST then
		ClearTag(char, "LLWEAPONEX_EnemyDiedInCombat")
	end
end)

RegisterSkillListener("Projectile_LLWEAPONEX_DarkFireball", function(skill, char, state, skillData)
	if state == SKILL_STATE.CAST then
		PersistentVars.SkillData.DarkFireballCount[char] = 0
		UpdateDarkFireballSkill(char)
		GameHelpers.Data.SyncSharedData(nil,nil,true)
	end
end)

function UpdateDarkFireballSkill(char)
	local killCount = PersistentVars.SkillData.DarkFireballCount[char] or 0
	if killCount >= 1 then
		local rangeBonusMult = GameHelpers.GetExtraData("LLWEAPONEX_DarkFireball_RangePerCount", 1.0)
		local radiusBonusMult = GameHelpers.GetExtraData("LLWEAPONEX_DarkFireball_ExplosionRadiusPerCount", 0.4)
		--local damageBonusMult = GameHelpers.GetExtraData("LLWEAPONEX_DarkFireball_DamageMultPerCount", 15)
	
		local nextRange = math.min(16, math.floor(6 + (rangeBonusMult * killCount)))
		local nextRadius = math.min(8, math.floor(1 + (radiusBonusMult * killCount)))
		--local nextDamageMult = math.min(200, math.floor(1 + (damageBonusMult * killCount)))
	
		local stat = Ext.Stats.Get("Projectile_LLWEAPONEX_DarkFireball", nil, false)
		stat.TargetRadius = nextRange
		stat.AreaRadius = nextRadius
		stat.ExplodeRadius = nextRadius
		--stat["Damage Multiplier"] = nextDamageMult

		if killCount >= 5 then
			stat.Template = "9bdb7e9c-02ce-4f2f-9e7b-463e3771af9c"
		end

		Ext.SyncStat("Projectile_LLWEAPONEX_DarkFireball", true)
	else
		local stat = Ext.Stats.Get("Projectile_LLWEAPONEX_DarkFireball", nil, false)
		--stat["Damage Multiplier"] = 10
		stat.TargetRadius = 6
		stat.AreaRadius = 1
		stat.ExplodeRadius = 1
		stat.Template = "f3af4ac9-567c-4ac8-8976-ec9c7bc8260d"
		Ext.SyncStat("Projectile_LLWEAPONEX_DarkFireball", true)
	end
end

Ext.RegisterConsoleCommand("llweaponex_darkfireballtest", function(call, amount)
	PersistentVars.SkillData.DarkFireballCount = tonumber(amount)
	UpdateDarkFireballSkill(Origin.Korvash)
	GameHelpers.Data.SyncSharedData(nil,nil,true)
end)

local function HasHarkenVisualSet(uuid)
	local character = Ext.GetCharacter(uuid)
	return character ~= nil and character.RootTemplate ~= nil and character.RootTemplate.VisualTemplate == "b8ddbc75-415f-4894-afc2-2256e11b723d"
end

function Harken_SwapTattoos(uuid)
	-- CharacterSetVisualElement doesn't work in the editor
	if Ext.GameVersion() ~= "v3.6.51.9303" then
		local character = Ext.GetCharacter(uuid)
		if character ~= nil and character.RootTemplate ~= nil 
		and character.RootTemplate.VisualTemplate == "b8ddbc75-415f-4894-afc2-2256e11b723d"
		then
			if HasActiveStatus(uuid, "UNSHEATHED") == 1 then
				CharacterSetVisualElement(uuid, 3, "LLWEAPONEX_Dwarves_Male_Body_Naked_A_UpperBody_Tattoos_Magic_A")
			else
				CharacterSetVisualElement(uuid, 3, "LLWEAPONEX_Dwarves_Male_Body_Naked_A_UpperBody_Tattoos_Normal_A")
			end
		end
	end
end

function Harken_SetTattoosActive(uuid)
	local canSetVisualElement = CharacterSetVisualElement ~= nil and HasHarkenVisualSet(uuid)
	local needsSync = false
	local stat = Ext.Stats.Get("LLWEAPONEX_TATTOOS_STRENGTH", nil, false)
	if CharacterIsInCombat(uuid) == 1 and StringHelpers.IsNullOrEmpty(CharacterGetEquippedItem(uuid, "Breast")) then
		if stat.StatsId ~= "Stats_LLWEAPONEX_Tattoos_Strength_Active" then
			needsSync = true
			stat.StatsId = "Stats_LLWEAPONEX_Tattoos_Strength_Active"
			stat.Description = "LLWEAPONEX_TATTOOS_STRENGTH_ACTIVE_Description"
			stat.Icon = "LLWEAPONEX_Items_Armor_Unique_Tattoos_Magic_A"
		end
		if canSetVisualElement then
			CharacterSetVisualElement(uuid, 3, "LLWEAPONEX_Dwarves_Male_Body_Naked_A_UpperBody_Tattoos_Magic_A")
		end
	else
		if stat.StatsId ~= "Stats_LLWEAPONEX_Tattoos_Strength" then
			needsSync = true
			stat.StatsId = "Stats_LLWEAPONEX_Tattoos_Strength"
			stat.Description = "LLWEAPONEX_TATTOOS_STRENGTH_Description"
			stat.Icon = "LLWEAPONEX_Items_Armor_Unique_Tattoos_A"
		end
		if canSetVisualElement then
			CharacterSetVisualElement(uuid, 3, "LLWEAPONEX_Dwarves_Male_Body_Naked_A_UpperBody_Tattoos_Normal_A")
		end
	end
	if needsSync then
		Ext.SyncStat("Stats_LLWEAPONEX_Tattoos_Strength", true)
		StatusManager.RemovePermanentStatus(uuid, "LLWEAPONEX_TATTOOS_STRENGTH")
		Timer.StartObjectTimer("LLWEAPONEX_Harken_ApplyTattooStatus", uuid, 250)
	end
end

Timer.Subscribe("LLWEAPONEX_Harken_ApplyTattooStatus", function (e)
	if e.Data.UUID then
		StatusManager.ApplyPermanentStatus(e.Data.UUID, "LLWEAPONEX_TATTOOS_STRENGTH")
	end
end)

RegisterListener("Initialized", function ()
	StatusManager.ApplyPermanentStatus(Origin.Harken, "LLWEAPONEX_TATTOOS_STRENGTH")
end)