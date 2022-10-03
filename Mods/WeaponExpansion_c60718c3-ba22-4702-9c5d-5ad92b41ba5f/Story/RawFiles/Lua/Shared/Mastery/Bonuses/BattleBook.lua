local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

local _ISCLIENT = Ext.IsClient()

local _eqSet = "Class_LLWEAPONEX_BattleScholar_Preview"

MasteryBonusManager.Vars.BattleBookBookcaseRootTemplateWords = {
	Cont_Bookcase = true,
}

local function IsBookcase(template)
	---@type ItemTemplate
	local root = Ext.Template.GetTemplate(template)
	if root then
		for _,v in pairs(root.Treasures) do
			if MasteryBonusManager.Vars.BattleBookBookcaseRootTemplateWords[v] == true then
				return true
			end
		end
	end
	return false
end

MasteryBonusManager.AddRankBonuses(MasteryID.BattleBook, 1, {
	rb:Create("BATTLEBOOK_CONCUSSION", {
		Skills = {"ActionAttackGround"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_BattleBook_BasicAttackConcussion", "<font color='#99AACC'>Basic attacks have a [ExtraData:LLWEAPONEX_MB_BattleBook_ConcussionChance]% chance to give the target a Concussion for [ExtraData:LLWEAPONEX_MB_BattleBook_ConcussionTurns] turn(s).</font>")
	}).Register.WeaponTagHit(MasteryID.BattleBook, function(self, e, bonuses)
		if not e.SkillData and e.TargetIsObject then
			local chance = GameHelpers.GetExtraData("LLWEAPONEX_MB_BattleBook_ConcussionChance", 25.0)
			local turns = GameHelpers.GetExtraData("LLWEAPONEX_MB_BattleBook_ConcussionTurns", 1)
			if chance > 0 and turns > 0 and (e.Attacker:HasTag("LLWEAPONEX_MasteryTestCharacter") or GameHelpers.Math.Roll(chance)) then
				GameHelpers.Status.Apply(e.Target, "LLWEAPONEX_CONCUSSION", turns, false, e.Attacker)
				PlaySound(e.Target.MyGuid, "LLWEAPONEX_FFT_Dictionary_Book_Hit")
				SignalTestComplete(self.ID)
			end
		end
	end).Test(function(test, self)
		local char,dummy,cleanup = WeaponExTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet, nil, true)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char, dummy, "", 0, 1, 1)
		CharacterSetFightMode(char, 1, 1)
		test:Wait(1000)
		CharacterAttack(char, dummy)
		test:WaitForSignal(self.ID, 30000)
		test:AssertGotSignal(self.ID)
		test:Wait(500)
		test:AssertEquals(HasActiveStatus(dummy, "LLWEAPONEX_CONCUSSION") == 1, true, "LLWEAPONEX_CONCUSSION not applied to target")
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
	end).StatusApplied(function(self, e, bonuses)
		if bonuses.HasBonus("BATTLEBOOK_FIRST_AID", e.Source) then
			local turnBonus = GameHelpers.GetExtraData("LLWEAPONEX_MB_BattleBook_Rested_TurnBonus", 1)
			if turnBonus > 0 then
				GameHelpers.Status.ExtendTurns(e.Target, e.Status, turnBonus, true, false)
				SignalTestComplete("BATTLEBOOK_FIRST_AID_TurnsExtended")
			end
		end
	end, "Source").StatusRemoved(function(self, e, bonuses)
		ClearTag(e.TargetGUID, "LLWEAPONEX_BattleBook_FirstAid_Active")
	end, "None").Test(function(test, self)
		local char,dummy,cleanup = WeaponExTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char, dummy, "", 0, 1, 1)
		SetFaction(dummy, "Good NPC")
		test:Wait(1000)
		CharacterUseSkill(char, "Target_FirstAidEnemy", dummy, 1, 1, 1)
		test:WaitForSignal("BATTLEBOOK_FIRST_AID_BonusHealApplied", 10000)
		test:AssertGotSignal("BATTLEBOOK_FIRST_AID_BonusHealApplied")
		test:WaitForSignal("BATTLEBOOK_FIRST_AID_TurnsExtended", 5000)
		test:AssertGotSignal("BATTLEBOOK_FIRST_AID_TurnsExtended")
		test:AssertEquals(IsTagged(dummy, "LLWEAPONEX_BattleBook_FirstAid_Active") == 1, true, "LLWEAPONEX_BattleBook_FirstAid_Active tag not set on target.")
		return true
	end),

	rb:Create("BATTLEBOOK_LOOT", {
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_BattleBook_BookHunter","<font color='#99AACC'>Chance to find a skillbook when opening a repository of books for the first time.</font>")
	}).Register.Osiris("CharacterUsedItem", 2, "before", function (character, item)
		if IsTagged(item, "LLWEAPONEX_MB_BattleBook_RolledBookcase") == 0
		and ItemIsContainer(item) == 1 
		--and MasteryBonusManager.HasMasteryBonus(character, "BATTLEBOOK_LOOT")
		and IsBookcase(GameHelpers.GetTemplate(item)) then
			local chance = GameHelpers.GetExtraData("LLWEAPONEX_MB_BattleBook_BookcaseLootChance", 10)
			if chance > 0 and (character:HasTag("LLWEAPONEX_MasteryTestCharacter") or GameHelpers.Math.Roll(chance)) then
				GenerateTreasure(item, "ST_Skillbook", CharacterGetLevel(character), character)
			end
			SetTag(item, "LLWEAPONEX_MB_BattleBook_RolledBookcase")
			SignalTestComplete("BATTLEBOOK_LOOT")
		end
	end).Test(function(test, self)
		local char,dummy,cleanup = WeaponExTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet)
		test.Cleanup = cleanup
		test:Wait(500)
		local x,y,z = GameHelpers.Grid.GetValidPositionInRadius(GameHelpers.Math.GetPosition(char), 6.0)
		local bookcase = CreateItemTemplateAtPosition("d60689b2-e01a-4524-a64c-c85c8957531e", x, y, z)
		test.Cleanup = function ()
			ItemRemove(bookcase)
			cleanup()
		end
		test:Wait(1000)
		CharacterUseItem(char, bookcase, "")
		test:WaitForSignal(self.ID, 10000)
		test:AssertGotSignal(self.ID)
		test:Wait(250)
		test:AssertEquals(IsTagged(bookcase, "LLWEAPONEX_MB_BattleBook_RolledBookcase") == 1, true, "Bookcase wasn't tagged with 'LLWEAPONEX_MB_BattleBook_RolledBookcase'")
		local items = {}
		for _,v in pairs(GameHelpers.GetItem(bookcase):GetInventoryItems()) do
			items[#items+1] = GameHelpers.Item.GetItemStat(v)
		end
		Ext.Dump(items)
		test:AssertEquals(#items > 0, true, "No treasure generated")
		return true
	end)
})

if not _ISCLIENT then
	--Allows mods to change this

	---The skill used when creating a secondary ground smash, for the `BATTLEBOOK_TECTONICSHIFT` bonus.
	MasteryBonusManager.Vars.BattleBookGroundSmashBonusSkill = "Cone_LLWEAPONEX_MasteryBonus_BattleBook_GroundSmashBonus"

	Timer.Subscribe("LLWEAPONEX_BattleBook_BattleStompBonus", function (e)
		if e.Data.UUID and e.Data.Target and e.Data.Source then
			--local rot = me.Stats.Rotation; local fx = Ext.Effect.CreateEffect("RS3_FX_Skills_Warrior_GroundSmash_Cast_01", Ext.Entity.NullHandle(), ""); fx.Rotation = rot; fx.Position = me.WorldPos;
			local caster = e.Data.UUID
			local tx,ty,tz = table.unpack(e.Data.Target)
			local sx,sy,sz = table.unpack(e.Data.Source)
			local rot = e.Data.Rotation or 0
			PlaySound(e.Data.UUID, "Skill_Earth_DustBlast_Impact")
			PlayEffectAtPositionAndRotation("RS3_FX_Skills_Warrior_GroundSmash_Cast_01", sx, sy, sz, rot)
			--EffectManager.PlayEffectAt("RS3_FX_Skills_Warrior_GroundSmash_Cast_01", me.WorldPos, {Rotation=me.Stats.Rotation})
			--Timer._Internal.ClearObjectData("LLWEAPONEX_BattleBook_BattleStompBonus", e.Data.UUID)
			GameHelpers.Skill.ShootZoneAt(MasteryBonusManager.Vars.BattleBookGroundSmashBonusSkill, caster, {tx,ty,tz}, {Position = {sx,sy,sz}, SurfaceType="Sentinel"})
			SignalTestComplete("BATTLEBOOK_TECTONICSHIFT")
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
	end).Test(function(test, self)
		local char,dummy,cleanup = WeaponExTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet)
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

	rb:Create("BATTLEBOOK_TECTONICSHIFT", {
		Skills = {"Cone_GroundSmash", "Cone_EnemyGroundSmash"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_BattleBook_BattleStomp", "<font color='#99AACC'>Knowledge of tectonic shifts allow you to create a secondary wave of force from the target, back to you, for double damage.</font>"),
	}).Register.SkillUsed(function(self, e, bonuses)
		local range = GameHelpers.Stats.GetAttribute(e.Skill, "Range", 10) + 1
		local target = GameHelpers.Math.ExtendPositionWithForwardDirection(e.Character, range)

		local _,angle,_ = GetRotation(e.Character.MyGuid)
		--angle + 180 works to flip the effect around for some reason, since we're using PlayEffectAtPositionAndRotation
		Timer.StartObjectTimer("LLWEAPONEX_BattleBook_BattleStompBonus", e.Character, 2000, {
			Source = target,
			Target = TableHelpers.Clone(e.Character.WorldPos),
			Skill = e.Skill,
			Rotation = angle + 180
		})
	end).SkillHit(function(self, e, bonuses)
		--Since it hit something, start the bonus quicker
		Timer.RestartObjectTimer("LLWEAPONEX_BattleBook_BattleStompBonus", e.Character, 500)
	end).Test(function(test, self)
		local char,dummy,cleanup = WeaponExTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char, dummy, "", 0, 1, 1)
		SetFaction(dummy, "Evil NPC")
		test:Wait(1000)
		CharacterUseSkill(char, "Cone_EnemyGroundSmash", dummy, 1, 1, 1)
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
		GetIsTooltipActive = function (self, skillOrStatus, character, tooltipType, item)
			if tooltipType == "item" then
				local statsId = GameHelpers.Item.GetItemStat(item)
				if statsId and GameHelpers.Stats.GetAttribute(statsId, "UseAPCost", 0) > 0 then
					if StringHelpers.Contains({statsId, item.RootTemplate.Name}, "scroll", true) or GameHelpers.Stats.HasParent(statsId, "_Scrolls") then
						return true
					end
				end
			end
			return false
		end,
		OnGetTooltip = function(self, id, character, tooltipType)
			if character:HasTag("LLWEAPONEX_BattleBook_ScrollBonusAP") then
				return GameHelpers.GetStringKeyText("LLWEAPONEX_MB_BattleBook_Scrolls_Disabled", "<font color='#FF2222'>Bonus AP already gained this turn.</font>")
			else
				return self.Tooltip
			end
		end
	}).Register.SkillCast(function (self, e, bonuses)
		if not e.Character:HasTag("LLWEAPONEX_BattleBook_ScrollBonusAP") and e.SourceItem then
			local statsId = GameHelpers.Item.GetItemStat(e.SourceItem)
			local apBonus = GameHelpers.GetExtraData("LLWEAPONEX_MB_BattleBook_ScrollUseAPBonus", 1)
			if apBonus ~= 0 and StringHelpers.Contains({statsId, e.SourceItem.RootTemplate.Name}, "scroll", true) or GameHelpers.Stats.HasParent(statsId, "_Scrolls") then
				CharacterAddActionPoints(e.Character.MyGuid, apBonus)
				if GameHelpers.Character.IsInCombat(e.Character) then
					SetTag(e.Character.MyGuid, "LLWEAPONEX_BattleBook_ScrollBonusAP")
				end
				SignalTestComplete("BATTLEBOOK_SCROLLS")
			end
		end
	end).Test(function(test, self)
		local char,dummy,cleanup = WeaponExTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char, dummy, "", 0, 1, 1)
		SetFaction(char, "PVP_1")
		SetFaction(dummy, "PVP_2")
		CharacterAddPreferredAiTargetTag(char, "LLWEAPONEX_Test_Target")
		SetTag(dummy, "LLWEAPONEX_Test_Target")
		--Try to make the AI priotize using the scroll in combat
		CharacterSetReactionPriority(char, "Combat_AI_MoveSkill", 0)
		CharacterSetReactionPriority(char, "Combat_AI_Attack", 0)
		CharacterSetReactionPriority(char, "Combat_AI_CastSkill", 100)
		GameHelpers.Skill.RemoveAllSkills(char)
		test:Wait(1000)
		CharacterSetTemporaryHostileRelation(char, dummy)
		test:Wait(1000)
		ItemTemplateAddTo("06283763-23e8-4ffd-a7c0-3f99d6a45094", char, 6, 0)
		test:Wait(500)
		SetCanJoinCombat(char, 1)
		SetCanFight(char, 1)
		SetCanJoinCombat(dummy, 1)
		SetCanFight(dummy, 1)
		EnterCombat(char, dummy)
		test:WaitForSignal(self.ID, 10000)
		test:AssertGotSignal(self.ID)
		return true
	end),
})

---Skill ID to RootTemplate
---@type table<string,string>
local _CACHEDSKILLBOOKS = {}

local function GetSkillWithMemorizationRequirements(id)
	---@type StatEntrySkillData
	local skill = Ext.Stats.Get(id, nil, false)
	if skill.MemorizationRequirements and #skill.MemorizationRequirements > 0 then
		return id
	end
	if not StringHelpers.IsNullOrEmpty(skill.Using) then
		return GetSkillWithMemorizationRequirements(skill.Using)
	end
	return nil
end

---@param target EsvCharacter
local function GetValidSkillsFromEnemy(target)
	local allowAnySkill = SettingsManager.GetMod(ModuleUUID, false, true).Global:FlagEquals("LLWEAPONEX_AllowAnySkillForBattleBookChallengeReward", true)
	--GameHelpers.IO.SaveJsonFile("Dumps/GetValidSkillsFromEnemy.json", Ext.DumpExport(target))
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

local function _IsSkillMemorized(skill, checkForOncePerCombat)
	if skill.IsLearned and skill.IsActivated and not skill.ZeroMemory and (_ISCLIENT and skill.CauseListSize == 0 or not _ISCLIENT and #skill.CauseList == 0) then
		if not checkForOncePerCombat or (skill.OncePerCombat == false or skill.OncePerCombat ~= skill.ActiveCooldown == 60) then
			return true
		end
	end
	return false
end

---@param character EsvCharacter|EclCharacter
---@return table<SkillAbility,boolean> highestAbilities
---@return table<SkillAbility,integer> abilitySlots
---@return integer maxSkillSlots
local function GetCharacterMajorityMemorizedSkillAbility(character)
	character = GameHelpers.GetCharacter(character)
	local totalSlots = 0
	totalSlots = totalSlots + GameHelpers.GetExtraData("CharacterBaseMemoryCapacity", 3)
	totalSlots = totalSlots + (GameHelpers.GetExtraData("CharacterBaseMemoryCapacityGrowth", 0.5) * character.Stats.Level)
	totalSlots = totalSlots + (GameHelpers.GetExtraData("CharacterAttributePointsPerMemoryCapacity", 1) * (character.Stats.Memory - GameHelpers.GetExtraData("AttributeBaseValue", 10)))
	if character.Stats.TALENT_Memory == true then
		totalSlots = totalSlots + GameHelpers.GetExtraData("TalentMemoryBonus", 3)
	end
	if character.Stats.TALENT_Quest_Rooted == true then
		totalSlots = totalSlots + GameHelpers.GetExtraData("TalentQuestRootedMemoryBonus", 3)
	end
	totalSlots = math.floor(totalSlots)
	--SkillAbility
	local totalAbilitySkills = {
		None = 0,
		Warrior = 0,
		Ranger = 0,
		Rogue = 0,
		Source = 0,
		Fire = 0,
		Water = 0,
		Air = 0,
		Earth = 0,
		Death = 0,
		Summoning = 0,
		Polymorph = 0,
		Sulfurology = 0,
	}

	local totalUsedMemorySlots = 0

	for _,v in pairs(character.SkillManager.Skills) do
		if _IsSkillMemorized(v) then
			local skill = Ext.Stats.Get(v.SkillId, nil, false)
			if skill and skill["Memory Cost"] > 0 then
				totalUsedMemorySlots = totalUsedMemorySlots + skill["Memory Cost"]
				totalAbilitySkills[skill.Ability] = totalAbilitySkills[skill.Ability] + skill["Memory Cost"]
			end
		end
	end

	local lastHighest = 0

	for ability,total in pairs(totalAbilitySkills) do
		if total > 0 and total > lastHighest then
			lastHighest = total
		end
	end

	local highestAbilities = {}
	if lastHighest > 0 then
		for ability,total in pairs(totalAbilitySkills) do
			if total == lastHighest then
				highestAbilities[ability] = true
			end
		end
	end

	--So ties work

	return highestAbilities,totalAbilitySkills,totalSlots
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
			if IsTagged(v, "LLWEAPONEX_BattleBook_ChallengeBookGranted") == 0 then
				SetTag(v, "LLWEAPONEX_BattleBook_ChallengeActive")
				PersistentVars.MasteryMechanics.BattlebookChallenge[e.Character.MyGuid] = v
				SignalTestComplete("BATTLEBOOK_CHALLENGE_Active")
			end
		end, e.Data.TargetMode.Objects)
	end).StatusRemoved(function(self, e, bonuses)
		if e.Target:HasTag("LLWEAPONEX_BattleBook_ChallengeActive") then
			ClearTag(e.TargetGUID, "LLWEAPONEX_BattleBook_ChallengeActive")
		end
	end, "None").StatusApplied(function(self, e, bonuses)
		local challengerGUID = e.TargetGUID
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

				local skills = GetValidSkillsFromEnemy(target)
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
							local rootTemplate = GameHelpers.Stats.GetSkillbookForSkill(v)
							if rootTemplate then
								ItemTemplateAddTo(rootTemplate, challengerGUID, 1, 1)
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
					CombatLog.AddTextToAllPlayers(CombatLog.Filters.Combat, Text.CombatLog.BattleBook.ChallengeWon:ReplacePlaceholders(challengerName, targetName, skillbookName))
					SignalTestComplete("BATTLEBOOK_CHALLENGE_Reward")
				else
					CharacterGiveReward(challengerGUID, "OnlyGold", 1)
					CombatLog.AddTextToAllPlayers(CombatLog.Filters.Combat, Text.CombatLog.BattleBook.ChallengeWon_NoSkills:ReplacePlaceholders(challengerName, targetName))
				end
			end
			PersistentVars.MasteryMechanics.BattlebookChallenge[challengerGUID] = nil
		end
	end, "Target", "CHALLENGE_WIN").Test(function(test, self)
		local char1,char2,dummy,cleanup = WeaponExTesting.CreateTwoTemporaryCharactersAndDummy(test, nil, _eqSet)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char1, dummy, "", 0, 1, 1)
		test:Wait(250)
		TeleportTo(char2, dummy, "", 0, 1, 1)
		SetFaction(char1, "PVP_1")
		SetFaction(char2, "PVP_2")
		CharacterSetTemporaryHostileRelation(char1, char2)
		test:Wait(1000)
		CharacterAddSkill(char2, "Target_Apportation", 0)
		CharacterAddSkill(char2, "Dome_CircleOfProtection", 0)
		CharacterUseSkill(char1, "Target_EnemyChallenge", char2, 1, 1, 1)
		test:WaitForSignal("BATTLEBOOK_CHALLENGE_Active", 10000)
		test:AssertGotSignal("BATTLEBOOK_CHALLENGE_Active")
		test:Wait(500)
		CharacterDieImmediate(char2, 0, "Physical", char1)
		test:WaitForSignal("BATTLEBOOK_CHALLENGE_Reward", 10000)
		test:AssertGotSignal("BATTLEBOOK_CHALLENGE_Reward")
		test:Wait(500)
		for _,v in pairs(GameHelpers.GetCharacter(char1):GetInventoryItems()) do
			local item = GameHelpers.GetItem(v)
			if not Data.EquipmentSlotNames[item.Slot] then
				fprint(LOGLEVEL.WARNING, "[BATTLEBOOK_CHALLENGE] Reward(%s)", GameHelpers.GetDisplayName(item))
			end
		end
		test:Wait(500)
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
	end).Test(function(test, self)
		local char,dummy,cleanup = WeaponExTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet)
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

	rb:Create("BATTLEBOOK_SCHOLAR", {
		AllSkills = true,
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_BattleBook_Scholar","<font color='#99AACC'>Deal <font color='#22FF33'>[1]% more damage</font> due to [2] being the most memorized ability school.<br>Note: [3]% damage per [4] total slots, multiplied by [5] ([6] ability slots / [4] total).</font>"),
		GetIsTooltipActive = function(bonus, id, character, tooltipType)
			if tooltipType == "skill" and not GameHelpers.Skill.IsAction(id) then
				local damageMult = GameHelpers.Stats.GetAttribute(id, "Damage Multiplier", 0)
				if damageMult > 0 then
					local ability,abilitySlots,totalSlots = GetCharacterMajorityMemorizedSkillAbility(character)
					--fprint(LOGLEVEL.DEFAULT, "[GetCharacterMajorityMemorizedSkillAbility] ability(%s) abilitySlots(%s) totalSlots(%s)", ability, abilitySlots, totalSlots)
					local skillAbility = GameHelpers.Stats.GetAttribute(id, "Ability", "None")
					if ability[skillAbility] == true then
						return true
					end
				end
			end
			return false
		end,
		OnGetTooltip = function(self, id, character, tooltipType)
			if tooltipType == "skill" then
				local ability,totalAbilitySlots,totalSlots = GetCharacterMajorityMemorizedSkillAbility(character)
				local skillAbility = GameHelpers.Stats.GetAttribute(id, "Ability", "None")
				if ability[skillAbility] == true then
					local abilitySlots = totalAbilitySlots[skillAbility]
					local boostPerSlot = GameHelpers.GetExtraData("LLWEAPONEX_MB_BattleBook_Scholar_DamageBoostPerTotalSkillSlots", 1)
					local damageMult = (abilitySlots / totalSlots)
					local damageBoost = Ext.Utils.Round(damageMult * (boostPerSlot * totalSlots))
					local damageBoostText = math.floor(damageMult)
					if damageBoostText < 1 then
						damageBoostText = string.format("%.2f", damageMult)
					end
					--fprint(LOGLEVEL.DEFAULT, "[GetCharacterMajorityMemorizedSkillAbility] ability(%s) damageBoost(%s)", skillAbility, damageBoost)
					local abilityName = string.format("<font color='%s'>%s</font>", Data.Colors.Ability[skillAbility], LocalizedText.SkillAbility[skillAbility])
					--local baseDamageMult = GameHelpers.Stats.GetAttribute(id, "Damage Multiplier")
					--local damageText = GameHelpers.Tooltip.GetSkillDamageText(id, character, {["Damage Muliplier"] = baseDamageMult + damageBoost})
					return self.Tooltip:ReplacePlaceholders(damageBoost, abilityName, boostPerSlot, totalSlots, damageBoostText, abilitySlots)
				end
			end
		end
	}).Register.SkillHit(function (self, e, bonuses)
		if e.Data.Success then
			local skillAbility = e.Data.SkillData.Ability
			local abilities,totalAbilitySlots,totalSlots = GetCharacterMajorityMemorizedSkillAbility(e.Character)
			if abilities[skillAbility] == true then
				local abilitySlots = totalAbilitySlots[skillAbility]
				local boostPerSlot = GameHelpers.GetExtraData("LLWEAPONEX_MB_BattleBook_Scholar_DamageBoostPerTotalSkillSlots", 1)
				local damageBoost = Ext.Utils.Round((abilitySlots / totalSlots) * (boostPerSlot * totalSlots))
				if damageBoost > 0 then
					e.Data:MultiplyDamage(1 + (damageBoost * 0.01))
					SignalTestComplete(self.ID)
				end
			end
		end
	end).Test(function(test, self)
		local char,dummy,cleanup = WeaponExTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char, dummy, "", 0, 1, 1)
		SetFaction(dummy, "Evil NPC")
		CharacterAddAttribute(char, "Memory", 10)
		test:Wait(250)
		CharacterAddSkill(char, "Target_CripplingBlow", 0)
		CharacterAddSkill(char, "Cone_GroundSmash", 0)
		CharacterAddSkill(char, "Projectile_BouncingShield", 0)
		test:Wait(1000)
		CharacterUseSkill(char, "Target_CripplingBlow", dummy, 1, 1, 1)
		test:WaitForSignal(self.ID, 10000)
		test:AssertGotSignal(self.ID)
		return true
	end)
})

MasteryBonusManager.AddRankBonuses(MasteryID.BattleBook, 4, {
	rb:Create("BATTLEBOOK_APOTHEOSIS", {
		Skills = {"Shout_Apotheosis"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_BattleBook_Apotheosis","<font color='#99AACC'>Knowledge of godhood lowers the cooldown of [1] skills by [2] turn(s).<br>Note: The ability schools listed have the highest amount of memorized skills. This can tie.</font>"),
		GetIsTooltipActive = function (self, id, character, tooltipType)
			if tooltipType == "skill" and id == "Shout_Apotheosis" then
				local turnCooldown = GameHelpers.GetExtraData("LLWEAPONEX_MB_BattleBook_ApotheosisSkillSchoolCooldownReduction", 1)
				if turnCooldown > 0 then
					return true
				end
			end
		end,
		OnGetTooltip = function(self, id, character, tooltipType)
			local turnCooldown = GameHelpers.GetExtraData("LLWEAPONEX_MB_BattleBook_ApotheosisSkillSchoolCooldownReduction", 1)
			if turnCooldown > 0 then
				local abilities = GetCharacterMajorityMemorizedSkillAbility(character)
				local abilityNames = {}
				for ability,b in pairs(abilities) do
					local abilityName = string.format("<font color='%s'>%s</font>", Data.Colors.Ability[ability], LocalizedText.SkillAbility[ability])
					abilityNames[#abilityNames+1] = abilityName
				end
	
				return self.Tooltip:ReplacePlaceholders(StringHelpers.Join(", ", abilityNames), turnCooldown)
			end
		end
	}).Register.SkillCast(function (self, e, bonuses)
		local turnCooldown = GameHelpers.GetExtraData("LLWEAPONEX_MB_BattleBook_ApotheosisSkillSchoolCooldownReduction", 1)
		if turnCooldown > 0 then
			local abilities = GetCharacterMajorityMemorizedSkillAbility(e.Character)
			local reducedCooldown = false
			for _,v in pairs(e.Character.SkillManager.Skills) do
				if v.SkillId ~= e.Skill and _IsSkillMemorized(v, true) then
					local skillAbility = GameHelpers.Stats.GetAttribute(v.SkillId, "Ability", "None")
					if abilities[skillAbility] then
						local nextCD = math.max(0, v.ActiveCooldown - turnCooldown)
						GameHelpers.Skill.SetCooldown(e.Character, v.SkillId, nextCD)
						reducedCooldown = true
					end
				end
			end
			if reducedCooldown then
				SignalTestComplete(self.ID)
			end
		end
	end).Test(function(test, self)
		local char,dummy,cleanup = WeaponExTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char, dummy, "", 0, 1, 1)
		SetFaction(dummy, "Evil NPC")
		CharacterAddSkill(char, "Target_CripplingBlow", 0)
		CharacterAddSkill(char, "Cone_GroundSmash", 0)
		CharacterAddSkill(char, "Projectile_BouncingShield", 0)
		CharacterAddSkill(char, "Target_EnemyTimeWarp", 0)
		test:Wait(1000)
		CharacterUseSkill(char, "Target_EnemyTimeWarp", char, 1, 1, 1)
		test:Wait(5000)
		GameHelpers.Skill.SetCooldown(char, "Cone_GroundSmash", 60)
		CharacterUseSkill(char, "Shout_Apotheosis", char, 1, 1, 1)
		test:WaitForSignal(self.ID, 10000)
		test:AssertGotSignal(self.ID)
		return true
	end)
})