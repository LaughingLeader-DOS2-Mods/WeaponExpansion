
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
		GameHelpers.Utils.UpdatePlayerCustomData(Origin.Harken)
	end
	if payload == Origin.Korvash or payload == "All" then
		GameHelpers.Utils.UpdatePlayerCustomData(Origin.Korvash)
	end
end)

Events.RegionChanged:Subscribe(function (e)
	if e.State == REGIONSTATE.GAME and e.LevelType == LEVELTYPE.GAME then
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

local anvilSwapPresets = {
	Knight = true,
	Inquisitor = true,
	Berserker = true,
	Barbarian = true,
}

local LadyCMoreColors = "db07c22c-8935-3848-2366-7827b70c6030"

function CC_CheckKorvashColor(characterId)
	local character = GameHelpers.GetCharacter(characterId)
	if character then
		local id = GameHelpers.GetUserID(character)
		if id ~= nil and character.PlayerCustomData ~= nil then
			local nextColor = OriginColors.Korvash.Default
			if Ext.Mod.IsModLoaded(LadyCMoreColors) then
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

SkillManager.Register.Cast("Shout_LLWEAPONEX_UnrelentingRage", function (e)
	ClearTag(e.CharacterGUID, "LLWEAPONEX_EnemyDiedInCombat")
end)

SkillManager.Register.Cast("Projectile_LLWEAPONEX_DarkFireball", function (e)
	PersistentVars.SkillData.DarkFireballCount[e.CharacterGUID] = 0
	UpdateDarkFireballSkill(e.CharacterGUID)
	GameHelpers.Data.SyncSharedData(nil,nil,true)
end)

---@param charGUID Guid
function UpdateDarkFireballSkill(charGUID)
	local killCount = PersistentVars.SkillData.DarkFireballCount[charGUID] or 0
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

		Ext.Stats.Sync("Projectile_LLWEAPONEX_DarkFireball", true)
	else
		local stat = Ext.Stats.Get("Projectile_LLWEAPONEX_DarkFireball", nil, false)
		--stat["Damage Multiplier"] = 10
		stat.TargetRadius = 6
		stat.AreaRadius = 1
		stat.ExplodeRadius = 1
		stat.Template = "f3af4ac9-567c-4ac8-8976-ec9c7bc8260d"
		Ext.Stats.Sync("Projectile_LLWEAPONEX_DarkFireball", true)
	end
end

Ext.RegisterConsoleCommand("llweaponex_darkfireballtest", function(call, amount)
	PersistentVars.SkillData.DarkFireballCount = tonumber(amount)
	UpdateDarkFireballSkill(Origin.Korvash)
	GameHelpers.Data.SyncSharedData(nil,nil,true)
end)

local function HasHarkenVisualSet(uuid)
	local character = GameHelpers.GetCharacter(uuid)
	return character ~= nil and character.RootTemplate ~= nil and character.RootTemplate.VisualTemplate == "b8ddbc75-415f-4894-afc2-2256e11b723d"
end

function Harken_SwapTattoos(uuid)
	-- CharacterSetVisualElement doesn't work in the editor
	if Ext.Utils.GameVersion() ~= "v3.6.51.9303" then
		local character = GameHelpers.GetCharacter(uuid)
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

---@param uuid CharacterParam
function Harken_SetTattoosActive(uuid)
	local character = GameHelpers.GetCharacter(uuid)
	if character then
		local canSetVisualElement = CharacterSetVisualElement ~= nil and HasHarkenVisualSet(uuid) and GameHelpers.Item.GetItemInSlot(character, "Breast") == nil
		local needsSync = false
		local stat = Ext.Stats.Get("LLWEAPONEX_TATTOOS_STRENGTH", nil, false)
		
		if GameHelpers.Character.IsInCombat(character) then
			if stat.StatsId ~= "Stats_LLWEAPONEX_Tattoos_Strength_Active" then
				needsSync = true
				stat.StatsId = "Stats_LLWEAPONEX_Tattoos_Strength_Active"
				stat.Description = "LLWEAPONEX_TATTOOS_STRENGTH_ACTIVE_Description"
				stat.Icon = "LLWEAPONEX_Items_Armor_Unique_Tattoos_Magic_A"
			end
			if canSetVisualElement then
				CharacterSetVisualElement(character.MyGuid, 3, "LLWEAPONEX_Dwarves_Male_Body_Naked_A_UpperBody_Tattoos_Magic_A")
			end
		else
			if stat.StatsId ~= "Stats_LLWEAPONEX_Tattoos_Strength" then
				needsSync = true
				stat.StatsId = "Stats_LLWEAPONEX_Tattoos_Strength"
				stat.Description = "LLWEAPONEX_TATTOOS_STRENGTH_Description"
				stat.Icon = "LLWEAPONEX_Items_Armor_Unique_Tattoos_A"
			end
			if canSetVisualElement then
				CharacterSetVisualElement(character.MyGuid, 3, "LLWEAPONEX_Dwarves_Male_Body_Naked_A_UpperBody_Tattoos_Normal_A")
			end
		end
		if needsSync then
			Ext.Stats.Sync("Stats_LLWEAPONEX_Tattoos_Strength", true)
			StatusManager.RemovePermanentStatus(character, "LLWEAPONEX_TATTOOS_STRENGTH")
			Timer.StartObjectTimer("LLWEAPONEX_Harken_ApplyTattooStatus", character, 250)
		end
	end
end

Ext.RegisterConsoleCommand("harkencrash", function ()
	local items = {"a4bf443f-5cb3-4271-bd10-b5002792f3fe","c7226c64-4270-4501-b78d-1d8cc31bb769","e8ac87e5-0fce-40f9-b9e2-ddbd742c91d0"}
	for i,v in pairs(items) do
		CharacterEquipItem(Origin.Harken, v)
	end
end)

Timer.Subscribe("LLWEAPONEX_Harken_ApplyTattooStatus", function (e)
	if e.Data.UUID then
		StatusManager.ApplyPermanentStatus(e.Data.UUID, "LLWEAPONEX_TATTOOS_STRENGTH")
	end
end)

Timer.Subscribe("LLWEAPONEX_Harken_CheckTattoos", function (e)
	if e.Data.Object then
		Harken_SetTattoosActive(e.Data.Object)
	end
end)

Events.ObjectEvent:Subscribe(function (e)
	Harken_SetTattoosActive(e.Objects[1])
end, {MatchArgs={Event="LLWEAPONEX_Harken_SetTattoosActive", EventType="StoryEvent"}})

Events.Initialized:Subscribe(function(e)
	if ObjectExists(Origin.Harken) == 1 then
		local harken = GameHelpers.GetCharacter(Origin.Harken)
		if harken and not GameHelpers.Status.IsActive(harken, "LLWEAPONEX_TATTOOS_STRENGTH") then
			StatusManager.ApplyPermanentStatus(harken, "LLWEAPONEX_TATTOOS_STRENGTH")
			Harken_SetTattoosActive(harken)
		end
	end
end)