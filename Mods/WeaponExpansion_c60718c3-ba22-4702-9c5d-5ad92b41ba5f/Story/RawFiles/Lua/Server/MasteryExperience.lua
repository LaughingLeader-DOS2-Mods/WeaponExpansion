if MasterySystem == nil then
	MasterySystem = {}
end

---@param player CharacterParam
---@param mastery string
---@param level integer
---@param totalExperience integer
function MasterySystem.SetMasteryExperience(player, mastery, level, totalExperience)
	local guid = GameHelpers.GetUUID(player)
	if guid then
		if PersistentVars.MasteryExperience[guid] == nil then
			PersistentVars.MasteryExperience[guid] = {}
		end
		PersistentVars.MasteryExperience[guid][mastery] = {
			Level = level,
			Experience = totalExperience
		}
	end
end

--- Callback for when a character's mastery levels up.
--- @param player EsvCharacter
--- @param mastery string
--- @param last integer
--- @param nextLevel integer
local function MasteryLeveledUp(player, mastery, last, nextLevel)
	local masteryData = Masteries[mastery]
	local masteryName = string.format("<font color='%s'>%s %s</font>", masteryData.Color, masteryData.Name.Value, Text.Mastery.Value)
	local text = string.gsub(Text.MasteryLeveledUp.Value, "%[1%]", masteryName):gsub("%[2%]", nextLevel)
	CharacterStatusText(player.MyGuid, text)

	TagMasteryRanks(player,mastery,nextLevel)

	-- Set the special rank 1+ unarmed tags.
	if mastery == "LLWEAPONEX_Unarmed" and nextLevel == 1 then
		EquipmentManager:CheckWeaponRequirementTags(player)
	end

	local text = Text.CombatLog.MasteryRankUp:ReplacePlaceholders(GameHelpers.Character.GetDisplayName(player), masteryName, nextLevel)
	CombatLog.AddCombatText(text)
end

--- Adds mastery experience a specific masteries.
--- @param player CharacterParam
--- @param mastery string
--- @param expGain number|nil
--- @param skipFlagCheck boolean|nil
function AddMasteryExperience(player,mastery,expGain,skipFlagCheck)
	player = GameHelpers.GetCharacter(player)
	if not player then
		return false
	end
	---@cast player EsvCharacter
	local playerGUID = player.MyGuid
	if skipFlagCheck == true or ObjectGetFlag(playerGUID, "LLWEAPONEX_DisableWeaponMasteryExperience") == 0 then
		expGain = expGain or 0.25
		local currentLevel = 0
		local currentExp = 0
		--DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience(_Player, _WeaponType, _Level, _Experience)
		local dbEntry = Osi.DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience:Get(playerGUID, mastery, nil, nil)
		if dbEntry then
			---@cast dbEntry table<integer,{[1]:Guid, [2]:string, [3]:integer, [4]:integer}>
			local playerEntry = dbEntry[1]
			if playerEntry then
				currentLevel = playerEntry[3]
				currentExp = playerEntry[4]
				if currentExp == nil or currentExp < 0 then currentExp = 0 end
			end
		end

		if currentLevel < Mastery.Variables.MaxRank then
			local expAmountData = Mastery.Variables.RankVariables[currentLevel]
			local maxAddExp = expAmountData.Amount
			local nextLevelExp = Mastery.Variables.RankVariables[currentLevel+1].Required
			local nextLevel = currentLevel

			local nextExp = Ext.Utils.Round(currentExp + (maxAddExp * expGain))
			if nextExp >= nextLevelExp then
				nextLevel = currentLevel + 1
				if nextLevel >= Mastery.Variables.MaxRank then
					nextExp = nextLevelExp
				end
			end

			if Vars.DebugMode then
				fprint(LOGLEVEL.WARNING, "[LLWEAPONEX] Mastery (%s) XP (%s) => (%s) [%s}", mastery, currentExp or 0, nextExp or 0, GameHelpers.GetDisplayName(player))
			end

			MasterySystem.SetMasteryExperience(playerGUID, mastery, nextLevel, nextExp)

			if nextLevel > currentLevel then
				MasteryLeveledUp(player, mastery, currentLevel, nextLevel)
			end
		end
	end
end

Ext.NewCall(AddMasteryExperience, "LLWEAPONEX_Ext_AddMasteryExperience", "(CHARACTERGUID)_Character, (STRING)_Mastery, (REAL)_ExperienceGain")

--- Adds mastery experience for all active masteries on equipped weapons.
--- @param character CharacterParam
--- @param expGain number
function AddMasteryExperienceForAllActive(character,expGain)
	character = GameHelpers.GetCharacter(character)
	if character and ObjectGetFlag(character.MyGuid, "LLWEAPONEX_DisableWeaponMasteryExperience") == 0 then
		local activeMasteries = Mastery.GetActiveMasteries(character, false)
		local length = #activeMasteries
		if length > 0 then
			for i=1,length do
				AddMasteryExperience(character.MyGuid,activeMasteries[i],expGain,true)
			end
		end
	end
end

Ext.NewCall(AddMasteryExperienceForAllActive, "LLWEAPONEX_Ext_AddMasteryExperienceForAllActive", "(CHARACTERGUID)_Character, (REAL)_ExperienceGain")

---@param character ObjectParam
---@return boolean
function MasterySystem.CanGrantXP(character)
	if GameHelpers.Ext.ObjectIsItem(character) then
		return false
	end
	local character = GameHelpers.GetCharacter(character)
	if not character then
		return false
	end
	---@cast character -EsvItem, -EclItem, -EclCharacter

	if not character.Resurrected
	and not character.OffStage
	and not character.Summon
	and not character.PartyFollower
	and not GameHelpers.Character.IsPlayer(character)
	and GameHelpers.Character.IsEnemyOfParty(character)
	--and GameHelpers.Character.IsInCombat(character)
	and Osi.LeaderLib_Helper_QRY_IgnoreCharacter(character.MyGuid) ~= true
	then
		return true
	end
	return false
end

---@param enemy EsvCharacter
function MasterySystem.GrantDeathExperienceToParty(enemy)
	local bossMult = 1.0
	if enemy.RootTemplate.CombatComponent.IsBoss then
		bossMult = 2.0
	end
	local mult = GameHelpers.GetExtraData("LLWEAPONEX_Mastery_DeathExperienceMult", 1.0)
	local expGain = mult * bossMult
	for player in GameHelpers.Character.GetPlayers() do
		if MasterySystem.CanGainExperience(player) then
			AddMasteryExperienceForAllActive(player, expGain)
		end
	end
end

---@param character CharacterParam
---@return boolean
function MasterySystem.CanGainExperience(character)
	if GameHelpers.Character.IsPlayer(character) and ObjectGetFlag(character.MyGuid, "LLWEAPONEX_DisableWeaponMasteryExperience") == 0 then
		return true
	end
	return false
end

--Mods.WeaponExpansion.AddMasteryExperienceForAllActive(Mods.WeaponExpansion.Origin.Harken, 20.0)
---@param player CharacterParam
---@param target ObjectParam
---@param mastery string
function MasterySystem.GrantBasicAttackExperience(player, target, mastery)
	local target = GameHelpers.TryGetObject(target)
	if target then
		if GameHelpers.ObjectHasTag(target, Mastery.Variables.TrainingDummyTags) then
			local expGain = GameHelpers.GetExtraData("LLWEAPONEX_Mastery_TrainingDummyExperienceMult", 0.1)
			if mastery then
				AddMasteryExperience(player, mastery, expGain)
			else
				AddMasteryExperienceForAllActive(player, expGain)
			end
		elseif MasterySystem.CanGrantXP(target) then
			local expGain = GameHelpers.GetExtraData("LLWEAPONEX_Mastery_BasicAttackExperienceMult", 0.5)
			if mastery then
				AddMasteryExperience(player, mastery, expGain)
			else
				AddMasteryExperienceForAllActive(player, expGain)
			end
		end
	end
end

---@param player CharacterParam
---@param target CharacterParam
---@param mastery string|nil
function MasterySystem.GrantWeaponSkillExperience(player, target, mastery)
	local target = GameHelpers.TryGetObject(target)
	if target then
		if GameHelpers.ObjectHasTag(target, Mastery.Variables.TrainingDummyTags) then
			local expGain = GameHelpers.GetExtraData("LLWEAPONEX_Mastery_TrainingDummyExperienceMult", 0.1)
			if mastery then
				AddMasteryExperience(player, mastery, expGain)
			else
				AddMasteryExperienceForAllActive(player, expGain)
			end
		elseif MasterySystem.CanGrantXP(target) then
			local expGain = GameHelpers.GetExtraData("LLWEAPONEX_Mastery_WeaponSkillExperienceMult", 0.5)
			if mastery then
				AddMasteryExperience(player, mastery, expGain)
			else
				AddMasteryExperienceForAllActive(player, expGain)
			end
		end
	end
end

RegisterProtectedOsirisListener("CharacterPrecogDying", 1, "after", function(enemy)
	local enemy = GameHelpers.GetCharacter(enemy)
	if enemy and MasterySystem.CanGrantXP(enemy) then
		MasterySystem.GrantDeathExperienceToParty(enemy)
	end
end)

Events.OnBookRead:Subscribe(function (e)
	if not PersistentVars.BattleBookExperienceGranted[e.Character.MyGuid] then
		PersistentVars.BattleBookExperienceGranted[e.Character.MyGuid] = {}
	end
	local bookData = PersistentVars.BattleBookExperienceGranted[e.Character.MyGuid]
	if bookData[e.Template] and not bookData[e.ID] then
		bookData[e.Template] = nil
	end
	if not bookData[e.ID] then
		bookData[e.ID] = true
		--Gain Battle Book experience from reading books
		AddMasteryExperience(e.Character, "LLWEAPONEX_BattleBook", 0.25)
	end
end)

StatusManager.Subscribe.Applied({"LLWEAPONEX_PISTOL_SHOOT_HIT", "LLWEAPONEX_HANDCROSSBOW_HIT"}, function(e)
	if e.SourceGUID ~= e.TargetGUID and e.Source and MasterySystem.CanGainExperience(e.Source) then
		if e.StatusId == "LLWEAPONEX_PISTOL_SHOOT_HIT" then
			MasterySystem.GrantWeaponSkillExperience(e.Source, e.Target, "LLWEAPONEX_Pistol")
		elseif e.StatusId == "LLWEAPONEX_HANDCROSSBOW_HIT" then
			MasterySystem.GrantWeaponSkillExperience(e.Source, e.Target, "LLWEAPONEX_HandCrossbow")
		end
	end
end)

local UnarmedSkills = {
	"Target_SingleHandedAttack",
	"Target_LLWEAPONEX_SinglehandedAttack",
	"Target_PetrifyingTouch",
}

SkillManager.Register.Hit(UnarmedSkills, function(e)
	if e.Data.Success and MasterySystem.CanGainExperience(e.Character) then
		MasterySystem.GrantWeaponSkillExperience(e.Character, e.Data.Target, "LLWEAPONEX_Unarmed")
	end
end)

---@param char CharacterParam
---@param target CharacterParam|nil
function GainThrowingMasteryXP(char, target)
	char = GameHelpers.GetCharacter(char)
	if MasterySystem.CanGainExperience(char) then
		target = GameHelpers.GetCharacter(target)
		if target then
			MasterySystem.GrantWeaponSkillExperience(char, target, "LLWEAPONEX_ThrowingAbility")
		end
	end
end