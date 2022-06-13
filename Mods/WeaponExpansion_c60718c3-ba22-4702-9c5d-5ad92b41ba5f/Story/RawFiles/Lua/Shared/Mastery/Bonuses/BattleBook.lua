local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

local _eqSet = "Class_LLWEAPONEX_BattleScholar_Preview"

MasteryBonusManager.AddRankBonuses(MasteryID.BattleBook, 1, {
	rb:Create("BATTLEBOOK_CONCUSSION", {
		Skills = {"ActionAttackGround"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_BattleBook_BasicAttackConcussion", "<font color='#99AACC'>Basic attacks have a [ExtraData:LLWEAPONEX_MB_BattleBook_ConcussionChance]% chance to give the target a Concussion for [ExtraData:LLWEAPONEX_MB_BattleBook_ConcussionTurns] turn(s).</font>")
	}):RegisterOnWeaponTagHit(MasteryID.BattleBook, function(tag, attacker, target, data, targetIsObject, skill, self)
		if not skill then
			local chance = GameHelpers.GetExtraData("LLWEAPONEX_MB_BattleBook_ConcussionChance", 25.0)
			local turns = GameHelpers.GetExtraData("LLWEAPONEX_MB_BattleBook_ConcussionTurns", 1)
			if chance > 0 and turns > 0 and (Debug.MasteryTests or GameHelpers.Math.Roll(chance)) then
				GameHelpers.Status.Apply(target, "LLWEAPONEX_CONCUSSION", turns, false, attacker)
				PlaySound(target.MyGuid, "LLWEAPONEX_FFT_Dictionary_Book_Hit")
				SignalTestComplete(self.ID)
			end
		end
	end).Register.Test(function(test, self)
		local char,dummy,cleanup = MasteryTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet, nil, true)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char, dummy, "", 0, 1, 1)
		CharacterSetFightMode(char, 1, 1)
		test:Wait(1000)
		CharacterAttack(char, dummy)
		test:WaitForSignal(self.ID, 30000)
		test:AssertGotSignal(self.ID)
		test:AssertEquals(HasActiveStatus(dummy, "LLWEAPONEX_CONCUSSION") == 1, true, "LLWEAPONEX_CONCUSSION not applied to target.")
		return true
	end),

	rb:Create("BATTLEBOOK_FIRST_AID", {
		Skills = {"Target_FirstAid", "Target_FirstAidEnemy"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_BattleBook_FirstAid", "<font color='#99AACC'>Medical book knowledge restores an additional <font color='#97FBFF'>[Stats:LLWEAPONEX_MASTERYBONUS_BATTLEBOOK_FIRST_AID:HealValue]% [Handle:h67a4c781g589ag4872g8c46g870e336074bd:Vitality]</font>.</font>"),
		Statuses = {"RESTED"},
		GetIsTooltipActive = rb.DefaultStatusTagCheck("LLWEAPONEX_BattleBook_FirstAid_Active", false),
		StatusTooltip = ts:CreateFromKey("LLWEAPONEX_MB_BattleBook_Rested", "Duration increased by [ExtraData:LLWEAPONEX_MB_BattleBook_Rested_TurnBonus]")
	}).Register.SkillCast(function(self, e, bonuses)
		local turnBonus = GameHelpers.GetExtraData("LLWEAPONEX_MB_BattleBook_Rested_TurnBonus", 1)
		if turnBonus > 0 then
			e.Data:ForEach(function(v, targetType, skillEventData)
				if turnBonus > 0 then
					SetTag(v, "LLWEAPONEX_BattleBook_FirstAid_Active")
				end
				GameHelpers.Status.Apply(v, "LLWEAPONEX_MASTERYBONUS_BATTLEBOOK_FIRST_AID", 0, false, e.Character)
				SignalTestComplete("BATTLEBOOK_FIRST_AID_BonusHealApplied")
			end)
		end
	end):RegisterStatusListener("Applied", function(bonuses, target, status, source)
		if bonuses.HasBonus("BATTLEBOOK_RESTED", source) then
			local turnBonus = GameHelpers.GetExtraData("LLWEAPONEX_MB_BattleBook_Rested_TurnBonus", 1)
			if turnBonus > 0 then
				GameHelpers.Status.ExtendTurns(target, status, turnBonus, true, false)
				SignalTestComplete("BATTLEBOOK_FIRST_AID_TurnsExtended")
			end
		end
	end):RegisterStatusListener("Removed", function(bonuses, target, status)
		ClearTag(target, "LLWEAPONEX_BattleBook_FirstAid_Active")
	end, nil, "None").Register.Test(function(test, self)
		local char,dummy,cleanup = MasteryTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char, dummy, "", 0, 1, 1)
		SetFaction(dummy, "Good NPC")
		test:Wait(1000)
		CharacterUseSkill(char, "Target_FirstAidEnemy", dummy, 1, 1, 1)
		test:WaitForSignal("BATTLEBOOK_FIRST_AID_BonusHealApplied", 30000)
		test:AssertGotSignal("BATTLEBOOK_FIRST_AID_BonusHealApplied")
		test:WaitForSignal("BATTLEBOOK_FIRST_AID_TurnsExtended", 30000)
		test:AssertGotSignal("BATTLEBOOK_FIRST_AID_TurnsExtended")
		test:AssertEquals(IsTagged(dummy, "LLWEAPONEX_BattleBook_FirstAid_Active") == 1, true, "LLWEAPONEX_BattleBook_FirstAid_Active tag not set on target.")
		return true
	end),

	rb:Create("BATTLEBOOK_LOOT", {
		AllSkills = true,
		GetIsTooltipActive = function(bonus, id, character, tooltipType, item)
			if tooltipType == "item" then
				if Ext.StatGetAttribute(id, "Requirement") == "DaggerWeapon" then
					return true
				end
			end
			return false
		end,
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_BattleBook_BookHunter","<font color='#99AACC'>Chance to find a skillbook when opening a repository of books for the first time.</font>")
	}).Register.Test(function(test, self)
		--Cast any skill with DaggerWeapon Requirement
		local character,dummy,cleanup = MasteryTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(character, dummy, "", 0, 1, 1)
		test:Wait(250)
		CharacterLookAt(dummy, character, 1)
		test:Wait(500)
		
		Events.OnSkillState:Subscribe(function (e)
			SignalTestComplete(self.ID)
		end, {Once = true, MatchArgs={Skill = "Projectile_ThrowingKnife", State = SKILL_STATE.USED }})
		CharacterUseSkill(character, "Projectile_ThrowingKnife", dummy, 1, 1, 0)
		test:WaitForSignal(self.ID, 10000)
		test:AssertGotSignal(self.ID)
		return true
	end)
})

if not Vars.IsClient then
	Mastery.Variables.Bonuses.BattleBookBookcaseRootTemplateWords = {
		Cont_Bookcase = true,
	}

	local function IsBookcase(template)
		---@type ItemTemplate
		local root = Ext.Template.GetTemplate(template)
		if root then
			for _,v in pairs(root.Treasures) do
				if Mastery.Variables.Bonuses.BattleBookBookcaseRootTemplateWords[v] == true then
					return true
				end
			end
		end
		return false
	end

	Ext.RegisterOsirisListener("CharacterUsedItemTemplate", 3, "before", function (character, template, item)
		if IsTagged(item, "LLWEAPONEX_MB_BattleBook_RolledBookcase") == 0 
		and ItemIsContainer(item) == 1 
		and MasteryBonusManager.HasMasteryBonus(character, "BATTLEBOOK_LOOT")
		and IsBookcase(template) then
			local chance = GameHelpers.GetExtraData("LLWEAPONEX_MB_BattleBook_BookcaseLootChance", 10)
			if chance > 0 and GameHelpers.Math.Roll(chance) then
				GenerateTreasure(item, "ST_Skillbook", CharacterGetLevel(character), character)
			end
			SetTag(item, "LLWEAPONEX_MB_BattleBook_RolledBookcase")
		end
	end)
end

MasteryBonusManager.AddRankBonuses(MasteryID.BattleBook, 2, {
	rb:Create("BATTLEBOOK_BLESS", {
		Skills = {"Target_Bless", "Target_EnemyBless"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_BattleBook_Bless", "<font color='#99AACC'>Deep knowledge of sacred texts allows [Key:Target_Bless_DisplayName] to deal [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_BattleBook_BlessUndeadDamage] to enemy Undead.</font>"),
	}).Register.SkillCast(function(self, e, bonuses)
		e.Data:ForEach(function(v, targetType, skillEventData)
			if GameHelpers.Character.IsEnemy(v, e.Character) and GameHelpers.Character.IsUndead(v) then
				GameHelpers.Damage.ApplySkillDamage(e.Character, v, "Projectile_LLWEAPONEX_MasteryBonus_BattleBook_BlessUndeadDamage", {HitParams=HitFlagPresets.GuaranteedWeaponHit})
				CharacterStatusText(v, "LLWEAPONEX_StatusText_BattleBook_BlessDamage")
				GameHelpers.Status.Remove(v, "BLESSED")
				SignalTestComplete(self.ID)
			end
		end, e.Data.TargetMode.Objects)
	end).Register.Test(function(test, self)
		local char,dummy,cleanup = MasteryTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char, dummy, "", 0, 1, 1)
		SetFaction(dummy, "Evil NPC")
		SetTag(dummy, "UNDEAD")
		test:Wait(1000)
		CharacterUseSkill(char, "Target_EnemyBless", dummy, 1, 1, 1)
		test:WaitForSignal(self.ID, 30000)
		test:AssertGotSignal(self.ID)
		return true
	end),

	rb:Create("BATTLEBOOK_SCROLLS", {
		AllSkills = true,
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_BattleBook_Scrolls", "<font color='#99AACC'>Gain [ExtraData:LLWEAPONEX_MB_BattleBook_ScrollUseAPBonus] AP on use. Can only happen once per turn.</font>"),
		---@param self MasteryBonusData
		---@param skillOrStatus string
		---@param character EclCharacter
		---@param tooltipType MasteryBonusDataTooltipID
		---@param data EsvStatus|StatEntrySkillData
		GetIsTooltipActive = function (self, skillOrStatus, character, tooltipType, data)
			--Kind of a hack where the ItemTooltip code will send this function the value "scroll" to tell it to display the bonus text
			if skillOrStatus ~= "scroll" or not character:HasTag("LLWEAPONEX_BattleBook_ScrollBonusAP") then
				return false
			end
		end,
	}):RegisterOsirisListener("CharacterUsedItem", 2, "after", function(characterid, itemid)
		local character = GameHelpers.GetCharacter(characterid)
		local item = GameHelpers.GetItem(itemid)
		if character and item 
		and not character:HasTag("LLWEAPONEX_BattleBook_ScrollBonusAP")
		and GameHelpers.Item.HasConsumeableSkillAction(item) then
			local apBonus = GameHelpers.GetExtraData("LLWEAPONEX_MB_BattleBook_ScrollUseAPBonus", 1)
			if apBonus ~= 0 then
				TurnEndRemoveTags["LLWEAPONEX_BattleBook_ScrollBonusAP"] = true
				SetTag(characterid, "LLWEAPONEX_BattleBook_ScrollBonusAP")
				CharacterAddActionPoints(characterid, apBonus)
				SignalTestComplete("BATTLEBOOK_SCROLLS")
			end
		end
	end).Register.Test(function(test, self)
		local char,dummy,cleanup = MasteryTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char, dummy, "", 0, 1, 1)
		SetFaction(dummy, "Evil NPC")
		CharacterAddPreferredAiTargetTag(char, "LLWEAPONEX_Test_Target")
		SetTag(dummy, "LLWEAPONEX_Test_Target")
		SetCombatGroupID(dummy, "LLWEAPONEX_Test")
		SetCombatGroupID(char, "LLWEAPONEX_Test")
		--Try to make the AI priotize using the scroll in combat
		CharacterSetReactionPriority(char, "Combat_AI_MoveSkill", 0)
		CharacterSetReactionPriority(char, "Combat_AI_Attack", 0)
		CharacterSetReactionPriority(char, "Combat_AI_CastSkill", 100)
		GameHelpers.Skill.RemoveAllSkills(char)
		test:Wait(1000)
		--Scroll_Skill_Water_Restoration
		--local x,y,z = GetPosition(char)
		--local scroll = CreateItemTemplateAtPosition("b852456a-1230-4933-92ef-ad7c65611ab5", x, y, z)
		--Scroll_Skill_Earth_PoisonDartStart
		ItemTemplateAddTo("06283763-23e8-4ffd-a7c0-3f99d6a45094", char, 1, 0)
		test:Wait(500)
		SetCanJoinCombat(char, 1)
		SetCanFight(char, 1)
		SetCanJoinCombat(dummy, 1)
		SetCanFight(dummy, 1)
		EnterCombat(char, dummy)
		test:WaitForSignal(self.ID, 30000)
		test:AssertGotSignal(self.ID)
		return true
	end),
})

---Skill ID to RootTemplate
---@type table<string,string>
local _CACHEDSKILLBOOKS = {}

local function GetSkillWithMemorizationRequirements(id)
	---@type StatEntrySkillData
	local skill = Ext.GetStat(id)
	if skill.MemorizationRequirements and #skill.MemorizationRequirements > 0 then
		return id
	end
	if not StringHelpers.IsNullOrEmpty(skill.Using) then
		return GetSkillWithMemorizationRequirements(skill.Using)
	end
	return nil
end

local function GetValidSkillsFromEnemy(target)
	local allowAnySkill = SettingsManager.GetMod(ModuleUUID, false, true).Global:FlagEquals("LLWEAPONEX_AllowAnySkillForBattleBookChallengeReward", true)
	local skills = target:GetSkills()
	if allowAnySkill then
		return skills
	end
	local validSkills = {}
	for i,v in pairs(skills) do
		local skill = GetSkillWithMemorizationRequirements(v)
		if skill ~= nil then
			validSkills[#validSkills+1] = skill
		end
	end
	return validSkills
end

MasteryBonusManager.AddRankBonuses(MasteryID.BattleBook, 3, {
	rb:Create("BATTLEBOOK_CHALLENGE", {
		Skills = {"Target_Challenge", "Target_EnemyChallenge"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_BattleBook_Challenge", "<font color='#99AACC'>Challenge the target's book smarts as well. Upon winning, gain a random spellbook transcribed from the opponent's known skills, once per character.</font>"),
		Statuses = {"CHALLENGE"},
		GetIsTooltipActive = rb.DefaultStatusTagCheck("LLWEAPONEX_BattleBook_ChallengeActive", false),
		StatusTooltip = ts:CreateFromKey("LLWEAPONEX_MB_BattleBook_Challenge_Status", "<font color='#33FF88'>Defeating this target grants the challenger a random skillbook from the target's skills.</font>")
	}).Register.SkillCast(function(self, e, bonuses)
		e.Data:ForEach(function(v, targetType, skillEventData)
			if not IsTagged(v, "LLWEAPONEX_BattleBook_ChallengeBookGranted") then
				SetTag(v, "LLWEAPONEX_BattleBook_ChallengeActive")
				PersistentVars.MasteryMechanics.BattlebookChallenge[e.Character.MyGuid] = v
				SignalTestComplete("BATTLEBOOK_CHALLENGE_Active")
			end
		end, e.Data.TargetMode.Objects)
	end):RegisterStatusListener("Removed", function(bonuses, targetGUID, status, source, statusType)
		if IsTagged(targetGUID, "LLWEAPONEX_BattleBook_ChallengeActive") then
			ClearTag(targetGUID, "LLWEAPONEX_BattleBook_ChallengeActive")
		end
	end, nil, "None"):RegisterStatusListener("Applied", function(bonuses, challengerGUID, status, source, statusType)
		local targetGUID = PersistentVars.MasteryMechanics.BattlebookChallenge[challengerGUID]
		if targetGUID then
			SetTag(targetGUID, "LLWEAPONEX_BattleBook_ChallengeBookGranted")
			local challenger = GameHelpers.GetCharacter(challengerGUID)
			local target = GameHelpers.GetCharacter(targetGUID)
			if challenger and target then
				local challengerName = GameHelpers.Character.GetDisplayName(target)
				local targetName = GameHelpers.Character.GetDisplayName(challenger)
				local skillbookName = ""
				local addedSkillbook = false

				local skills = GetValidSkillsFromEnemy(challenger)
				if #skills > 0 then
					skills = Common.ShuffleTable(skills)
					for _,v in pairs(skills) do
						local rootTemplate = _CACHEDSKILLBOOKS[v]
						if rootTemplate then
							ItemTemplateAddTo(rootTemplate, target, 1, 1)
							addedSkillbook = true
							local root = Ext.Template.GetTemplate(rootTemplate)
							if root then
								skillbookName = root.Name
							end
						else
							--Ext.IO.SaveFile("Dumps/ECLRootTemplate_SKILLBOOK_Water_VampiricHungerAura.json", Ext.DumpExport(Ext.Template.GetTemplate("2398983b-d9f3-40ca-9269-9a4fb0860931")))
							local rootTemplate = GameHelpers.Stats.GetSkillbookForSkill(v)
							if rootTemplate then
								ItemTemplateAddTo(rootTemplate, target, 1, 1)
								addedSkillbook = true
								local root = Ext.Template.GetTemplate(rootTemplate)
								if root then
									skillbookName = root.Name
								end
							end
						end
	
						if addedSkillbook then
							break
						end
					end
				end
				if addedSkillbook then
					CombatLog.AddTextToAllPlayers(CombatLog.Filters.Combat, Text.CombatLog.BattleBook_ChallengeWon:ReplacePlaceholders(challengerName, targetName, skillbookName))
				else
					CharacterGiveReward(target, "OnlyGold", 1)
					CombatLog.AddTextToAllPlayers(CombatLog.Filters.Combat, Text.CombatLog.BattleBook_ChallengeWon_NoSkills:ReplacePlaceholders(challengerName, targetName))
				end
				SignalTestComplete("BATTLEBOOK_CHALLENGE_Reward")
			end
			PersistentVars.MasteryMechanics.BattlebookChallenge[challengerGUID] = nil
		end
	end, "CHALLENGE_WIN", "Target").Register.Test(function(test, self)
		local char1,char2,dummy,cleanup = MasteryTesting.CreateTwoTemporaryCharactersAndDummy(test, nil, _eqSet)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char1, dummy, "", 0, 1, 1)
		test:Wait(250)
		TeleportTo(char2, dummy, "", 0, 1, 1)
		CharacterSetTemporaryHostileRelation(char1, char2)
		test:Wait(1000)
		CharacterUseSkill(char1, "Target_EnemyChallenge", char2, 1, 1, 1)
		test:WaitForSignal("BATTLEBOOK_CHALLENGE_Active", 30000)
		test:AssertGotSignal("BATTLEBOOK_CHALLENGE_Active")
		CharacterDieImmediate(char2, 0, "Physical", char1)
		test:WaitForSignal("BATTLEBOOK_CHALLENGE_Reward", 30000)
		test:AssertGotSignal("BATTLEBOOK_CHALLENGE_Reward")
		return true
	end),

	rb:Create("BATTLEBOOK_CURSE", {
		Skills = {"Target_Curse", "Target_EnemyCurse", "Target_LLWEAPONEX_Curse", "Target_EnemyCurse_Alan", "Target_EnemyCurse_Werewolf", "Target_EnemyCurse_Witch"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_BattleBook_Curse", "<font color='#99AACC'>Knowledge of the occult amplifies this skill again non-Undead, non-Voidwoken targets, dealing [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_BattleBook_CurseDamage].</font>"),
	}).Register.SkillCast(function(self, e, bonuses)
		e.Data:ForEach(function(v, targetType, skillEventData)
			if IsTagged(v, "VOIDWOKEN") == 0 and not GameHelpers.Character.IsUndead(v) then
				GameHelpers.Damage.ApplySkillDamage(e.Character, v, "Projectile_LLWEAPONEX_MasteryBonus_BattleBook_CurseDamage", {HitParams=HitFlagPresets.GuaranteedWeaponHit})
				CharacterStatusText(v, "LLWEAPONEX_StatusText_BattleBook_CurseDamage")
				SignalTestComplete(self.ID)
			end
		end, e.Data.TargetMode.Objects)
	end).Register.Test(function(test, self)
		local char,dummy,cleanup = MasteryTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char, dummy, "", 0, 1, 1)
		SetFaction(dummy, "Evil NPC")
		test:Wait(1000)
		CharacterUseSkill(char, "Target_EnemyCurse", dummy, 1, 1, 1)
		test:WaitForSignal(self.ID, 30000)
		test:AssertGotSignal(self.ID)
		return true
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.BattleBook, 4, {
	
})