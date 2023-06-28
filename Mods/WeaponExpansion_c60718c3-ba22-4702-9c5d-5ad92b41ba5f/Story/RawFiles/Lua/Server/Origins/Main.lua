
local function SetupOriginSkills(char, skillset)
	if Osi.CharacterHasSkill(char, "Dome_CircleOfProtection") == 1 then
		Osi.CharacterRemoveSkill(char, "Dome_CircleOfProtection")
	end

	local skillSet = Ext.Stats.SkillSet.GetLegacy(skillset)
	if skillSet ~= nil then
		for i,skill in pairs(skillSet.Skills) do
			if Osi.CharacterHasSkill(char, skill) == 0 then
				Osi.CharacterAddSkill(char, skill, 0)
			end
		end
	end
end

local function FixPlayerCustomData()
	local harken = GameHelpers.GetCharacter(Origin.Harken, "EsvCharacter")
	local pdata = harken.PlayerCustomData
	GameHelpers.Utils.SetPlayerCustomData(harken, {
		OriginName = "LLWEAPONEX_Harken",
		Race = pdata.Race,
		IsMale = pdata.IsMale or harken:HasTag("MALE"),
		SkinColor = pdata.SkinColor,
		HairColor = pdata.HairColor,
		ClothColor1 = pdata.ClothColor1,
		ClothColor2 = pdata.ClothColor2,
		ClothColor3 = pdata.ClothColor3,
	})

	local korvash = GameHelpers.GetCharacter(Origin.Korvash, "EsvCharacter")
	pdata = korvash.PlayerCustomData
	GameHelpers.Utils.SetPlayerCustomData(korvash, {
		OriginName = "LLWEAPONEX_Korvash",
		Race = "Lizard",
		IsMale = pdata.IsMale or korvash:HasTag("MALE"),
		SkinColor = pdata.SkinColor,
		HairColor = pdata.HairColor,
		ClothColor1 = pdata.ClothColor1,
		ClothColor2 = pdata.ClothColor2,
		ClothColor3 = pdata.ClothColor3,
	})
end

Ext.RegisterNetListener("LLWEAPONEX_FixPlayerCustomData", function (channel, payload, user)
	if payload == Origin.Harken or payload == "All" then
		GameHelpers.Utils.UpdatePlayerCustomData(Origin.Harken, "Dwarf", "LLWEAPONEX_Harken")
	end
	if payload == Origin.Korvash or payload == "All" then
		GameHelpers.Utils.UpdatePlayerCustomData(Origin.Korvash, "Lizard", "LLWEAPONEX_Korvash")
	end
end)

Events.RegionChanged:Subscribe(function (e)
	if e.State == REGIONSTATE.GAME and e.LevelType == LEVELTYPE.GAME and Ext.Utils.GetGameMode() == "Campaign" then
		Origins_InitCharacters(SharedData.RegionData.Current)
		-- Timer.StartOneshot("", 3000, function (_)
		-- end)
	end
end)

Ext.RegisterConsoleCommand("llweaponex_initorigins", function (cmd)
	Origins_InitCharacters(SharedData.RegionData.Current)
end)

function Origins_InitCharacters(region)
	local host = GameHelpers.Character.GetHost()
	if host == nil then
		return
	end

	local isInitialized = Osi.ObjectGetFlag(Origin.Harken, "LLWEAPONEX_Origins_SetupComplete") == 1 and Osi.ObjectGetFlag(Origin.Korvash, "LLWEAPONEX_Origins_SetupComplete") == 1

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
			local user = host.ReservedUserID
			local totalAdded = 0
			if Osi.CharacterIsInPartyWith(host.MyGuid, Origin.Harken) == 0 then
				GameHelpers.Character.MakePlayer(Origin.Harken, host, {SkipPartyCheck=true})
				totalAdded = totalAdded + 1
			end
			Osi.TeleportTo(Origin.Harken, host.MyGuid, "", 1, 0, 1)
			Osi.CharacterAttachToGroup(Origin.Harken, host.MyGuid)
			Osi.SetOnStage(Origin.Harken, 1)

			--local pdata = GameHelpers.GetCharacter(Mods.WeaponExpansion.Origin.Harken).PlayerCustomData; pdata.OriginName = "LLWEAPONEX_Harken"; pdata.Race = "Dwarf"; pdata.IsMale = true;
			
			if Osi.CharacterIsInPartyWith(host.MyGuid, Origin.Korvash) == 0 then
				GameHelpers.Character.MakePlayer(Origin.Korvash, host, {SkipPartyCheck=true})
				totalAdded = totalAdded + 1
			end
			Osi.TeleportTo(Origin.Korvash, host.MyGuid, "", 1, 0, 1)
			Osi.CharacterAttachToGroup(Origin.Korvash, host.MyGuid)
			Osi.SetOnStage(Origin.Korvash, 1)

			local frozenCount = Osi.DB_GlobalCounter:Get("FTJ_PlayersWokenUp", nil)
			if frozenCount ~= nil and #frozenCount > 0 then
				local count = frozenCount[1][2]
				Osi.DB_GlobalCounter:Delete("FTJ_PlayersWokenUp", count)
				Osi.DB_GlobalCounter("FTJ_PlayersWokenUp", count + totalAdded)
			end

			FixPlayerCustomData()
		end
	end

	local harken = GameHelpers.GetCharacter(Origin.Harken)
	if harken and (not harken.Stats.TALENT_Dwarf_Sturdy or not harken.Stats.TALENT_Dwarf_Sneaking) then
		Osi.NRD_PlayerSetBaseTalent(Origin.Harken, "Dwarf_Sturdy", 1)
		Osi.NRD_PlayerSetBaseTalent(Origin.Harken, "Dwarf_Sneaking", 1)
		Osi.CharacterAddCivilAbilityPoint(Origin.Harken, 0)
	end
	local baseAttribute = GameHelpers.GetExtraData("AttributeBaseValue", 10)

	--IsCharacterCreationLevel(region) == 0
	if Osi.ObjectGetFlag(Origin.Harken, "LLWEAPONEX_Origins_SetupComplete") == 0 then
		pcall(SetupOriginSkills, Origin.Harken, "Avatar_LLWEAPONEX_Harken")

		--CharacterApplyPreset(Origin.Harken, "LLWEAPONEX_Harken")
		Osi.NRD_PlayerSetBaseAttribute(Origin.Harken, "Strength", baseAttribute+3)
		Osi.NRD_PlayerSetBaseAbility(Origin.Harken, "WarriorLore", 1)
		Osi.NRD_PlayerSetBaseAbility(Origin.Harken, "TwoHanded", 1)
		Osi.NRD_PlayerSetBaseAbility(Origin.Harken, "Barter", 1)
		Osi.NRD_PlayerSetBaseTalent(Origin.Harken, "AttackOfOpportunity", 1)

		Osi.CharacterAddCivilAbilityPoint(Origin.Harken, 0)

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

		Osi.ObjectSetFlag(Origin.Harken, "LLWEAPONEX_FixSkillBar", 0)
		Osi.ObjectSetFlag(Origin.Harken, "LLWEAPONEX_Origins_SetupComplete", 0)
		--CharacterAddSkill(Origin.Harken, "Shout_LLWEAPONEX_UnrelentingRage", 0)
	end

	local korvash = GameHelpers.GetCharacter(Origin.Korvash)
	if korvash and (not korvash.Stats.TALENT_Lizard_Resistance or not korvash.Stats.TALENT_Lizard_Persuasion) then
		Osi.NRD_PlayerSetBaseTalent(Origin.Korvash, "Lizard_Resistance", 1)
		Osi.NRD_PlayerSetBaseTalent(Origin.Korvash, "Lizard_Persuasion", 1)
		Osi.CharacterAddCivilAbilityPoint(Origin.Korvash, 0)
	end
	
	if Osi.ObjectGetFlag(Origin.Korvash, "LLWEAPONEX_Origins_SetupComplete") == 0 then
		pcall(SetupOriginSkills, Origin.Korvash, "Avatar_LLWEAPONEX_Korvash")
	
		Osi.CharacterRemoveSkill(Origin.Korvash, "Cone_Flamebreath")
		Osi.CharacterAddSkill(Origin.Korvash, "Cone_LLWEAPONEX_DarkFlamebreath", 0)
		Osi.NRD_PlayerSetBaseAbility(Origin.Korvash, "WarriorLore", 1)
		Osi.NRD_PlayerSetBaseAbility(Origin.Korvash, "Necromancy", 1)
		Osi.NRD_PlayerSetBaseAbility(Origin.Korvash, "Telekinesis", 1)
		Osi.NRD_PlayerSetBaseAttribute(Origin.Korvash, "Strength", baseAttribute+2)
		Osi.NRD_PlayerSetBaseAttribute(Origin.Korvash, "Wits", baseAttribute+1)
		Osi.NRD_PlayerSetBaseTalent(Origin.Korvash, "Executioner", 1)
		Osi.CharacterAddCivilAbilityPoint(Origin.Korvash, 0)

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

		Osi.ObjectSetFlag(Origin.Korvash, "LLWEAPONEX_FixSkillBar", 0)
		Osi.ObjectSetFlag(Origin.Korvash, "LLWEAPONEX_Origins_SetupComplete", 0)
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
	local character = GameHelpers.GetCharacter(uuid, "EsvCharacter")
	if not character then
		return
	end
	---@type StatEntrySkillData[]
	local slotEntries = {}
	local totalSlotEntries = 0
	for i=0,28,1 do
		local slot = character.PlayerData.SkillBar[i]
		if slot then
			if slot.Type == "Skill" and not StringHelpers.IsNullOrEmpty(slot.SkillOrStatId) then
				local skill = Ext.Stats.Get(slot.SkillOrStatId, nil, false) --[[@as StatEntrySkillData]]
				if skill then
					totalSlotEntries = totalSlotEntries + 1
					slotEntries[totalSlotEntries] = skill
				end
			end
			slot.ItemHandle = Ext.Entity.NullHandle()
			slot.Type = "None"
			slot.SkillOrStatId = ""
		end
	end
	table.sort(slotEntries, function(a,b)
		local val1 = 0
		local val2 = 0

		local ma1 = a["Magic Cost"]
		if ma1 > 0 then
			val1 = 9
		elseif a.ForGameMaster == "No" then
			val1 = 6
		else
			val1 = tierValue[a.Tier] or -1
		end

		local ma2 = b["Magic Cost"]
		if ma2 > 0 then
			val2 = 9
		elseif b.ForGameMaster == "No" then
			val2 = 6
		else
			val2 = tierValue[b.Tier] or -1
		end

		return val1 < val2
	end)

	local slotNum = 0
	for _,v in pairs(slotEntries) do
		local slot = character.PlayerData.SkillBar[slotNum]
		if slot then
			slot.Type = "Skill"
			slot.ItemHandle = Ext.Entity.NullHandle()
			slot.SkillOrStatId = v.Name
			slotNum = slotNum + 1
		end
	end
end

RegisterProtectedOsirisListener("CharacterJoinedParty", 1, "after", function(partyMember)
	if ObjectGetFlag(partyMember, "LLWEAPONEX_FixSkillBar") == 1 then
		ObjectClearFlag(partyMember, "LLWEAPONEX_FixSkillBar", 0)
		Timer.StartObjectTimer("LLWEAPONEX_FixSkillbar", partyMember, 500)
	end
end)

Timer.Subscribe("LLWEAPONEX_FixSkillbar", function (e)
	if e.Data.UUID then
		Origins_FixSkillBar(e.Data.Object)
	end
end)

local hiddenStoryButtons = {}

function CC_HideStoryButton(uuid)
	if Ext.GetGameState() == "Running" then
		local id = GameHelpers.GetUserID(uuid)
		if id ~= nil then
			hiddenStoryButtons[id] = true
			GameHelpers.Net.PostToUser(id, "LLWEAPONEX_CC_HideStoryButton", uuid)
		end
	end
end

function CC_EnableStoryButton(uuid)
	if Ext.GetGameState() == "Running" then
		local id = GameHelpers.GetUserID(uuid)
		if id ~= nil and hiddenStoryButtons[id] ~= nil then
			hiddenStoryButtons[id] = nil
			GameHelpers.Net.PostToUser(id, "LLWEAPONEX_CC_EnableStoryButton", uuid)
		end
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