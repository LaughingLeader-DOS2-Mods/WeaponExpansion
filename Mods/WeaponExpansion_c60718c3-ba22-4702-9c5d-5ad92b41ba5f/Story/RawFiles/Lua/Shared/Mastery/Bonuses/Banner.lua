local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

local _eqSet = "Class_LLWEAPONEX_BannerCommander_Preview"

local warChargeStatuses = {
	"LLWEAPONEX_WARCHARGE_DAMAGEBOOST",
	"LLWEAPONEX_WARCHARGE_BONUS",
	"LLWEAPONEX_WARCHARGE01",
	"LLWEAPONEX_WARCHARGE02",
	"LLWEAPONEX_WARCHARGE03",
	"LLWEAPONEX_WARCHARGE04",
	"LLWEAPONEX_WARCHARGE05",
	"LLWEAPONEX_WARCHARGE06",
	"LLWEAPONEX_WARCHARGE07",
	"LLWEAPONEX_WARCHARGE08",
	"LLWEAPONEX_WARCHARGE09",
	"LLWEAPONEX_WARCHARGE10",
}

MasteryBonusManager.Vars.WarChargeStatuses = warChargeStatuses

local inspireCleanseStatuses = {
	FEAR = "#7F00FF",
	MADNESS = "#D040D0",
	SLEEPING = "#7D71D9",
}

MasteryBonusManager.Vars.BannerInspireCleanseStatuses = inspireCleanseStatuses

MasteryBonusManager.AddRankBonuses(MasteryID.Banner, 1, {
	rb:Create("BANNER_WARCHARGE", {
		Skills = MasteryBonusManager.Vars.RushSkills,
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Banner_Rush", "If under the effects of <font color='#FFCE58'>War Charge</font>, deal <font color='#33FF00'>[ExtraData:LLWEAPONEX_MB_Banner_WarCharge_DamageBoost]% more damage on hit</font> and gain <font color='#7D71D9'>[Key:HASTED_DisplayName]</font> after rushing.")
	}).Register.SkillCast(function(self, e, bonuses)
		local hasStatus = false
		for i,status in pairs(warChargeStatuses) do
			if GameHelpers.Status.IsActive(e.Character, status) then
				hasStatus = true
				break
			end
		end
		if hasStatus then
			Timer.StartObjectTimer("LLWEAPONEX_WarCharge_ApplyHasted", e.Character, 1000)
		end
	end).SkillHit(function(self, e, bonuses)
		if e.Data.Success then
			local hasStatus = false
			for i,status in pairs(warChargeStatuses) do
				if GameHelpers.Status.IsActive(e.Character, status) then
					hasStatus = true
					break
				end
			end
			if hasStatus then
				local bonusMultiplier = GameHelpers.GetExtraData("LLWEAPONEX_MB_Banner_WarCharge_DamageBoost", 25.0)
				if bonusMultiplier > 0 then
					e.Data:MultiplyDamage(1 + (bonusMultiplier * 0.01))
				end
				SignalTestComplete(self.ID)
			end
		end
	end).Test(function(test, self)
		--Bonus damage while rushing if a War Charge status active
		local character,dummy,cleanup = WeaponExTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(character, dummy, "", 0, 1, 1)
		test:Wait(250)
		GameHelpers.Status.Apply(character, "LLWEAPONEX_WARCHARGE01", -1.0, true, character)
		CharacterLookAt(dummy, character, 1)
		test:Wait(1000)
		CharacterUseSkill(character, "Rush_EnemyBatteringRam", dummy, 1, 1, 1)
		test:WaitForSignal(self.ID, 10000)
		test:AssertGotSignal(self.ID)
		return true
	end),

	rb:Create("BANNER_INSPIRE", {
		Skills = {"Shout_InspireStart", "Shout_EnemyInspire"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Banner_Encourage", "<font color='#FFCE58'>Fear, Madness, and Sleep are cleansed from encouraged allies.</font>"),
		Statuses = {"ENCOURAGED"},
		DisableStatusTooltip = true
	}).Register.StatusApplied(function(self, e, bonuses)
		if bonuses.HasBonus("BANNER_INSPIRE", e.Source) then
			local cleansed = {}
			for status,color in pairs(inspireCleanseStatuses) do
				if GameHelpers.Status.IsActive(e.Target, status) then
					GameHelpers.Status.Remove(e.Target, status)
					cleansed[#cleansed+1] = string.format("<font color='%s'>%s</font>", color, GameHelpers.Stats.GetDisplayName(status))
				end
			end
			if #cleansed > 0 then
				--PlayBeamEffect(source, target, "RS3_FX_GP_Status_Retaliation_Beam_01", "Dummy_R_HandFX", "Dummy_BodyFX")
				GameHelpers.Status.Apply(e.Target, "LLWEAPONEX_ENCOURAGED_CLEANSE_BEAM_FX", 0, true, e.Source)
				--EffectManager.PlayEffect("RS3_FX_GP_Status_Retaliation_Beam_01", target, {BeamTarget=target, BeamTargetBone = "Dummy_HeadFX", Bone="Dummy_FX_01"})
				local text = GameHelpers.GetStringKeyText("LLWEAPONEX_StatusText_Encourage_Cleansed"):gsub("%[1%]", Common.StringJoin("/", cleansed))
				CharacterStatusText(e.TargetGUID, text)
				SignalTestComplete("BANNER_INSPIRE")
			end
		end
	end).Test(function(test, self)
		--Inspire cleanses certain negative statuses
		local character,dummy,cleanup = WeaponExTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet, false)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(character, dummy, "", 0, 1, 1)
		test:Wait(1000)
		GameHelpers.Status.Apply(dummy, "SLEEPING", -1.0, true, dummy)
		SetFaction(dummy, "Good NPC")
		test:Wait(1000)
		CharacterUseSkill(character, "Shout_EnemyInspire", character, 1, 1, 1)
		test:WaitForSignal(self.ID, 10000)
		test:AssertGotSignal(self.ID)
		return true
	end)
})

if not Vars.IsClient then
	Timer.Subscribe("LLWEAPONEX_WarCharge_ApplyHasted", function(e)
		if e.Data.UUID then
			GameHelpers.Status.Apply(e.Data.UUID, "HASTED", -1.0, true, e.Data.UUID)
		end
	end)
end

MasteryBonusManager.AddRankBonuses(MasteryID.Banner, 2, {
	rb:Create("BANNER_RALLYINGCRY", {
		Skills = {"Target_Harmony", "Target_EnemyHarmony"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Banner_RallyingCry", "<font color='#88FF33'>Affected allies will basic attack the nearest enemy within range.</font>"),
		Statuses = {"HARMONY"},
		DisableStatusTooltip = true
	}).Register.StatusApplied(function(self, e, bonuses)
		if (ObjectIsCharacter(e.TargetGUID) == 1
		and not GameHelpers.Status.IsDisabled(e.Target, true)
		and not GameHelpers.Status.HasStatusType(e.Target, "DISARMED")
		and bonuses.HasBonus("BANNER_RALLYINGCRY", e.Source)) then
			local range = 1.0
			local weapon = GameHelpers.Character.GetEquippedWeapons(e.Target)
			if weapon ~= nil then
				range = weapon.Stats.WeaponRange / 100
			end

			---@type EsvCharacter[]
			local targets = GameHelpers.Grid.GetNearbyObjects(e.Target, {AsTable=true, Radius=range, Relation={Enemy=true}, Type="Character"})

			if #targets > 0 then
				---@type EsvCharacter
				local attackTarget = Common.GetRandomTableEntry(targets)
				CharacterAttack(e.TargetGUID, attackTarget.MyGuid)
				SignalTestComplete("BANNER_RALLYINGCRY")
			end
		end
	end).Test(function(test, self)
		--Target of Harmony automatically basic attacks a nearby enemy
		local char1,char2,dummy,cleanup = WeaponExTesting.CreateTwoTemporaryCharactersAndDummy(test, nil, _eqSet, nil, true)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char1, dummy, "", 0, 1, 1)
		test:Wait(250)
		TeleportTo(char2, dummy, "", 0, 1, 1)
		test:Wait(1000)
		CharacterUseSkill(char1, "Target_EnemyHarmony", char2, 1, 1, 1)
		test:WaitForSignal(self.ID, 10000)
		test:AssertGotSignal(self.ID)
		test:Wait(5000)
		return true
	end),

	rb:Create("BANNER_GUARDIAN_ANGEL", {
		Skills = {"Shout_GuardianAngel", "Shout_EnemyGuardianAngel"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Banner_GuardianAngelSkill", "<font color='#00FFFF'>If an ally protected by Guardian Angel dies, automatically resurrect them at the start of your turn.</font>"),
		StatusTooltip = ts:CreateFromKey("LLWEAPONEX_MB_Banner_GuardianAngelStatus", "<font color='#00FFFF'>If killed, character will be resurrected by the Guardian when their turn starts.</font>"),
		Statuses = {"GUARDIAN_ANGEL"},
	}).Register.StatusApplied(function(self, e, bonuses)
		--Skip providing this bonus if the source is already protected by the target, to prevent immortality
		if bonuses.HasBonus("BANNER_GUARDIAN_ANGEL", e.Source)
		and PersistentVars.MasteryMechanics.GuardianAngelResurrect[e.SourceGUID] ~= e.TargetGUID
		and e.SourceGUID ~= e.TargetGUID then
			PersistentVars.MasteryMechanics.GuardianAngelResurrect[e.TargetGUID] = e.SourceGUID
		end
	end).StatusRemoved(function(self, e, bonuses)
		if not GameHelpers.Status.IsActive(e.Target, "DYING") then
			PersistentVars.MasteryMechanics.GuardianAngelResurrect[e.TargetGUID] = nil
		end
	end, "None").Osiris("CharacterPrecogDying", 1, "after", function(char)
		char = StringHelpers.GetUUID(char)
		if PersistentVars.MasteryMechanics.GuardianAngelResurrect[char] then
			local sourceCharacter = GameHelpers.GetCharacter(PersistentVars.MasteryMechanics.GuardianAngelResurrect[char])
			if sourceCharacter then
				if not GameHelpers.Character.IsInCombat(sourceCharacter) then
					--Resurrect after a delay instead, since we're not in combat
					Timer.StartObjectTimer("LLWEAPONEX_Banner_GuardianAngelResurrect", sourceCharacter, sourceCharacter:HasTag("LLWEAPONEX_MasteryTestCharacter") and 500 or 3000)
				end
			end
		end
	end, true).Test(function(test, self)
		--Ally under GUARDIAN_ANGEL gets resurrected if they die
		local char1,char2,dummy,cleanup = WeaponExTesting.CreateTwoTemporaryCharactersAndDummy(test, nil, _eqSet)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char1, dummy, "", 0, 1, 1)
		test:Wait(250)
		TeleportTo(char2, dummy, "", 0, 1, 1)
		test:Wait(1000)
		CharacterUseSkill(char1, "Shout_EnemyGuardianAngel", char2, 1, 1, 1)
		test:Wait(5000)
		CharacterDie(char2, 0, "Physical", char2)
		test:WaitForSignal(self.ID, 30000)
		test:AssertGotSignal(self.ID)
		return true
	end)
})

local function CheckLeadershipBonus(char)
	if Vars.IsClient then
		return
	end
	if HasActiveStatus(char, "LEADERSHIP") == 1 and GameHelpers.Character.IsPlayer(char) then
		local character = GameHelpers.GetCharacter(char)
		if character then
			local status = character:GetStatus("LEADERSHIP")
			if status then
				local bonusChance = 0
				local bonusSource = nil

				local baseChance = GameHelpers.GetExtraData("LLWEAPONEX_MB_Banner_LeadershipInspirationChance", 25, true)
				local masteryChance = GameHelpers.GetExtraData("LLWEAPONEX_MB_Banner_LeadershipInspirationChance2", 50, true)
	
				--Check the source of Leadership first
				local source = GameHelpers.GetCharacter(status.StatusSourceHandle)
				if source ~= nil then
					if MasteryBonusManager.HasMasteryBonus(source, "BANNER_LEADERSHIP") then
						bonusChance = masteryChance
						bonusSource = source.MyGuid
					end
				end
	
				--Try to get allied characters with Leadership in range,
				--in case there's multiple party members with Leadership, but the status source doesn't have banner mastery.
				if bonusChance == 0 then
					local leadershipDistance = GameHelpers.GetExtraData("LeadershipRange", 8)
					local combatid = CombatGetIDForCharacter(char)
					for ally in GameHelpers.Combat.GetCharacters(combatid, "Ally") do
						if MasteryBonusManager.HasMasteryBonus(ally.MyGuid, "BANNER_LEADERSHIP")
						and ally.Stats.Leadership > 0
						and GameHelpers.Math.GetDistance(ally.WorldPos, character.WorldPos) <= leadershipDistance
						then
							bonusChance = baseChance
							bonusSource = ally.MyGuid
						end
					end
				end
	
				if bonusChance > 0 and (bonusChance >= 100 or character:HasTag("LLWEAPONEX_MasteryTestCharacter") or GameHelpers.Math.Roll(bonusChance)) then
					GameHelpers.Status.Apply(character, "LLWEAPONEX_MASTERYBONUS_BANNER_LEADERSHIPBONUS", 6, false, bonusSource)
					SignalTestComplete("BANNER_LEADERSHIP")
				end
			end
		end
	end
end

if not Vars.IsClient then
	Timer.Subscribe("LLWEAPONEX_Banner_GuardianAngelResurrect", function (e)
		if e.Data.UUID then
			if PersistentVars.MasteryMechanics.GuardianAngelResurrect ~= nil then
				local signaled = false
				for deadChar,v in pairs(PersistentVars.MasteryMechanics.GuardianAngelResurrect) do
					if v == e.Data.UUID then
						if CharacterIsDead(deadChar) == 1 then
							CharacterResurrect(deadChar)
						else
							PersistentVars.MasteryMechanics.GuardianAngelResurrect[deadChar] = nil
						end
						if not signaled then
							SignalTestComplete("BANNER_GUARDIAN_ANGEL")
							signaled = true
						end
					end
				end
			end
		end
	end)

	Events.TurnDelayed:Subscribe(function (e)
		local statusSource = nil
		if e.Character then
			local auraStatus = e.Character:GetStatus("LLWEAPONEX_BANNER_RALLY_DIVINEORDER_AURABONUS") or e.Character:GetStatus("LLWEAPONEX_BANNER_RALLY_DWARVES_AURABONUS")
			if auraStatus then
				statusSource = auraStatus.StatusSourceHandle
			end
			if statusSource then
				statusSource = GameHelpers.GetCharacter(statusSource)
				if statusSource and MasteryBonusManager.HasMasteryBonus(statusSource.MyGuid, "BANNER_PROTECTION") then
					GameHelpers.Status.Apply(e.Character, "LLWEAPONEX_BANNER_TURNDELAYPROTECTION", 6.0, false, e.Character)
				end
			end
		end
	end)

	Ext.Osiris.RegisterListener("ObjectTurnStarted", 1, "after", function(char)
		local char = StringHelpers.GetUUID(char)
		if HasActiveStatus(char, "LLWEAPONEX_BANNER_TURNDELAYPROTECTION") == 1 then
			GameHelpers.Status.Remove(char, "LLWEAPONEX_BANNER_TURNDELAYPROTECTION")
		end
		Timer.StartObjectTimer("LLWEAPONEX_Banner_GuardianAngelResurrect", char, 250)
		CheckLeadershipBonus(char)
	end)
end

--Beam test
---Mods.LeaderLib.GameHelpers.Status.Apply(Mods.WeaponExpansion.Origin.Harken, "LLWEAPONEX_MASTERYBONUS_BANNER_COOPERATION_BEAM_FX", 0, false, me.MyGuid)
--EffectManager.PlayClientEffect("RS3_FX_Skills_Water_ChainHeal_Beam_01,Beam:Dummy_FX_01,Dummy_BodyFX", e.Target, {Target=GameHelpers.GetNetID(v)})
--EffectManager.PlayEffect("RS3_FX_Skills_Water_ChainHeal_Beam_01", e.Target, {BeamTarget=v, BeamTargetBone="Dummy_BodyFX", Bone="Dummy_FX_01"})
--Mods.LeaderLib.EffectManager.PlayClientEffect("RS3_FX_Skills_Water_ChainHeal_Beam_01,Beam:Dummy_FX_01,Dummy_BodyFX", me.NetID, {Target=Mods.LeaderLib.GameHelpers.GetNetID(Mods.WeaponExpansion.Origin.Harken)})
--Mods.LeaderLib.EffectManager.PlayEffect("RS3_FX_Skills_Water_ChainHeal_Beam_01", me.MyGuid, {BeamTarget=Mods.WeaponExpansion.Origin.Harken, BeamTargetBone="Dummy_BodyFX", Bone="Dummy_FX_01"})

MasteryBonusManager.Vars.BannerIgnoredHealingStatuses = {
	POST_MAGIC_CONTROL = true,
	POST_PHYS_CONTROL = true,
}

MasteryBonusManager.AddRankBonuses(MasteryID.Banner, 3, {
	rb:Create("BANNER_WHIRLWIND", {
		Skills = {"Shout_Whirlwind", "Shout_EnemyWhirlwind"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Banner_Whirlwind", "<font color='#00CCAA'>If near an active banner, enemies hit are pulled towards the banner.</font>")
	}).Register.SkillHit(function(self, e, bonuses)
		if e.Data.Success then
			local skillDist = e.Data.SkillData.AreaRadius
			local addWeaponRange = e.Data.SkillData.AddWeaponRange == "Yes"
			if addWeaponRange then
				local banners = GameHelpers.Item.FindTaggedEquipment(e.Character.MyGuid, "LLWEAPONEX_Banner")
				if #banners > 0 then
					local banner = GameHelpers.GetItem(banners[1])
					if banner then
						skillDist = skillDist + (banner.Stats.WeaponRange/100)
					end
				end
			end
			skillDist = skillDist + 0.5
			local banner = nil
			local lastDist = 9999
			for _,data in pairs(PersistentVars.SkillData.BannerRally) do
				for guid,_ in pairs(data.Banners) do
					if ObjectExists(guid) == 1 then
						local dist = GameHelpers.Math.GetDistance(guid, e.Character)
						if dist <= skillDist and dist < lastDist then
							banner = guid
							lastDist = dist
						end
					end
				end
			end
			if banner then
				local x,y,z = GameHelpers.Grid.GetValidPositionInRadius(GameHelpers.Math.GetPosition(banner), 3.0)
				--Ext.Action.CreateGameAction("GameObjectMoveAction", "", e.Character)
				NRD_CreateGameObjectMove(e.Data.Target, x, y, z, "", e.Character.MyGuid)
				SignalTestComplete(self.ID)
			end
		end
	end).Test(function(test, self)
		--Pull targets towards a banner
		local char,dummy,cleanup = WeaponExTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet)
		test.Cleanup = cleanup
		test:Wait(250)
		local skillPos = GameHelpers.Math.GetPositionBetween(char, dummy, 0.5)
		test:Wait(1000)
		--CharacterUseSkill(char, "Dome_LLWEAPONEX_Banner_Rally_DivineOrder", char, 1, 1, 1)
		GameHelpers.Action.UseSkill(char, "Dome_LLWEAPONEX_Banner_Rally_DivineOrder", skillPos)
		test:Wait(4000)
		Osi.TeleportTo(char, dummy)
		test:Wait(500)
		CharacterUseSkill(char, "Shout_EnemyWhirlwind", dummy, 1, 1, 1)
		test:WaitForSignal(self.ID, 30000)
		test:AssertGotSignal(self.ID)
		return true
	end),

	---@see CheckLeadershipBonus
	rb:Create("BANNER_LEADERSHIP", {
		Statuses = {"LEADERSHIP"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Banner_Leadership", "<font color='#00FFFF'>[Special:LLWEAPONEX_MB_Banner_LeadershipInspirationChance]% chance to gain <font color='#11FF88'>[Key:LLWEAPONEX_MASTERYBONUS_BANNER_LEADERSHIPBONUS_DisplayName]</font> on turn start if within [ExtraData:LeadershipRange]m range of a [Key:LLWEAPONEX_Banner] wielder.</font>"),
		GetIsTooltipActive = rb.DefaultStatusTagCheck("LLWEAPONEX_Banner_Mastery3", true),
		OnGetTooltip = function(bonus, skillOrStatus, character, tooltipType, status)
			--Appending "Empowered by x's Banner" if Leadership is from a Banner user
			if tooltipType == "status" and status then
				local source = GameHelpers.TryGetObject(status.StatusSourceHandle)
				if source and GameHelpers.CharacterOrEquipmentHasTag(source, "LLWEAPONEX_Banner_Mastery3") or Vars.LeaderDebugMode then
					return string.format("%s<br>%s", bonus.Tooltip.Value, Text.MasteryBonusParams.BannerLeadershipSource:ReplacePlaceholders(source.DisplayName))
				end
			end
		end
	}).Register.Test(function(test, self)
		--Gain bonus from Leadership
		local char,dummy,cleanup = WeaponExTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet, false)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char, dummy, "", 0, 1, 1)
		SetFaction(dummy, "Good NPC")
		CharacterAddAbility(char, "Leadership", 4)
		test:Wait(3000)
		Timer.StartOneshot("", 250, function ()
			CheckLeadershipBonus(char)
		end)
		test:WaitForSignal(self.ID, 30000)
		test:AssertGotSignal(self.ID)
		return true
	end),

	rb:Create("BANNER_COOPERATION", {
		AllSkills = true,
		AllStatuses = true,
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Banner_Cooperation", "<font color='#00FFFF'>When you are healed, nearby allies within a [ExtraData:LLWEAPONEX_MB_Banner_Cooperation_HealingShareRadius]m radius are also healed for [ExtraData:LLWEAPONEX_MB_Banner_Cooperation_HealingSharePercentage]% of the amount.</font>"),
		MasteryMenuSettings = {
			TooltipSkill = "Target_FirstAid",
			TooltipStatus = "HEAL",
		},
		--self:MasteryBonusData, skillOrStatus:string, character:EclCharacter, tooltipType:MasteryBonusDataTooltipID):string|TranslatedString
		---@param self MasteryBonusData
		---@param id string
		---@param character EclCharacter
		---@param tooltipType MasteryBonusDataTooltipID
		---@param extraParam EclItem|EclStatus
		---@param tags table<string,boolean>|nil
		GetIsTooltipActive = function(self, id, character, tooltipType, extraParam, tags, itemHasSkill)
			if tooltipType == "status" then
				local statusType = GameHelpers.Status.GetStatusType(id)
				if statusType == "HEALING" or statusType == "HEAL" then
					return true
				end
			elseif tooltipType == "skill" and not GameHelpers.Skill.IsAction(id) then
				local properties = GameHelpers.Stats.GetSkillProperties(id)
				if properties then
					for _,v in pairs(properties) do
						if v.Type == "Status" then
							local statusType = GameHelpers.Status.GetStatusType(v.Action)
							if statusType == "HEALING" or statusType == "HEAL" then
								return true
							end
						end
					end
				end
			elseif tooltipType == "item" and extraParam and itemHasSkill ~= true then -- Tags is "ItemHasSkill"
				if extraParam.RootTemplate and extraParam.RootTemplate.OnUsePeaceActions then
					for _,v in pairs(extraParam.RootTemplate.OnUsePeaceActions) do
						if v.Type == "UseSkill" then
							local properties = GameHelpers.Stats.GetSkillProperties(v.SkillID)
							if properties then
								for _,v2 in pairs(properties) do
									if v2.Type == "Status" then
										local statusType = GameHelpers.Status.GetStatusType(v2.Action)
										if statusType == "HEALING" or statusType == "HEAL" then
											return true
										end
									end
								end
							end
						elseif v.Type == "Consume" then
							local statId = v.StatsId
							if StringHelpers.IsNullOrWhitespace(v.StatsId) then
								statId = id
							end
							if not StringHelpers.IsNullOrEmpty(statId) and GameHelpers.Stats.Exists(statId, "Potion") then
								local potion = Ext.Stats.Get(statId, nil, false)
								if potion.Vitality > 0 then
									return true
								end
							end
						end
					end
				end
			end
			return false
		end
	}).Register.Healed(function(self, e, bonuses)
		if e.Heal.StatusId ~= "LLWEAPONEX_MASTERYBONUS_BANNER_COOPERATION_HEAL"
		and (e.Heal.HealType == "All" or e.Heal.HealType == "Vitality")
		and not MasteryBonusManager.Vars.BannerIgnoredHealingStatuses[e.Heal.StatusId] then
			local radius = GameHelpers.GetExtraData("LLWEAPONEX_MB_Banner_Cooperation_HealingShareRadius", 6.0)
			local percentage = GameHelpers.GetExtraData("LLWEAPONEX_MB_Banner_Cooperation_HealingSharePercentage", 50.0)
			if radius > 0 and percentage > 0 then
				local mult = percentage * 0.01
				local healAmount = math.ceil(e.OriginalAmount * mult)
				Ext.Stats.Get("LLWEAPONEX_MASTERYBONUS_BANNER_COOPERATION_HEAL", nil, false).HealValue = healAmount
				Ext.SyncStat("LLWEAPONEX_MASTERYBONUS_BANNER_COOPERATION_HEAL", false)

				local affectedTargets = 0
				for ally in GameHelpers.Grid.GetNearbyObjects(e.Target, {Radius=radius, Relation={Ally=true}}) do
					affectedTargets = affectedTargets + 1

					---@type EsvStatusHeal
					local status = Ext.PrepareStatus(ally.MyGuid, "LLWEAPONEX_MASTERYBONUS_BANNER_COOPERATION_HEAL", 0.0)
					status.HealAmount = healAmount
					status.StatusSourceHandle = e.Target.Handle
					Ext.ApplyStatus(status)
					GameHelpers.Status.Apply(ally.MyGuid, "LLWEAPONEX_MASTERYBONUS_BANNER_COOPERATION_BEAM_FX", 0, true, e.Target)
				end
				if affectedTargets > 0 then
					SignalTestComplete(self.ID)
				end
			end
		end
	end, "Target").Test(function(test, self)
		--Gain bonus from Leadership
		local char,dummy,cleanup = WeaponExTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet, false)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char, dummy, "", 0, 1, 1)
		SetFaction(dummy, "Good NPC")
		GameHelpers.GetCharacter(char).Stats.CurrentVitality = 1
		GameHelpers.GetCharacter(dummy).Stats.CurrentVitality = 1
		CharacterSetFightMode(char, 1, 1)
		test:Wait(1000)
		CharacterUseSkill(char, "Target_FirstAidEnemy", char, 1, 1, 1)
		test:WaitForSignal(self.ID, 30000)
		test:AssertGotSignal(self.ID)
		local x,y,z = GetPosition(char)
		--Healing Potion
		local item = CreateItemTemplateAtPosition("68b40462-247a-44fd-87d0-c2eea2f49ed1", x, y, z)
		test:Wait(500)
		CharacterUseItem(char, item, "")
		test:WaitForSignal(self.ID, 30000)
		test:AssertGotSignal(self.ID)
		test:Wait(2000)
		return true
	end),
})

if Vars.IsClient then
	TooltipParams.SpecialParamFunctions.LLWEAPONEX_MB_Banner_LeadershipInspirationChance = function(param, statCharacter)
		local baseBonusChance = GameHelpers.GetExtraData("LLWEAPONEX_MB_Banner_LeadershipInspirationChance", 25, true)
		if statCharacter.Character then
			local status = statCharacter.Character:GetStatus("LEADERSHIP")
			if status then
				local bonusChance = 0
	
				--Check the source of Leadership first
				local source = GameHelpers.GetCharacter(status.StatusSourceHandle)
				if source ~= nil then
					if MasteryBonusManager.HasMasteryBonus(source, "BANNER_LEADERSHIP") then
						bonusChance = GameHelpers.GetExtraData("LLWEAPONEX_MB_Banner_LeadershipInspirationChance2", 50, true)
					end
				end
	
				if bonusChance == 0 then
					bonusChance = baseBonusChance
				end
	
				return string.format("%i", bonusChance)
			end
		end
		return string.format("%i", baseBonusChance)
	end
end

MasteryBonusManager.AddRankBonuses(MasteryID.Banner, 4, {
	rb:Create("BANNER_PROTECTION", {
		Skills = {"Dome_LLWEAPONEX_Banner_Rally_Dwarves", "Dome_LLWEAPONEX_Banner_Rally_DivineOrder"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Banner_BannerAuraProtection", "<font color='#33FF33'>When near a placed banner, allies cannot be flanked, and turn delaying reduces damage taken by [Stats:Stats_LLWEAPONEX_Banner_TurnDelayProtection:FireResistance]% until their turn occurs.</font>"),
		Statuses = {"LLWEAPONEX_BANNER_RALLY_DIVINEORDER_AURABONUS", "LLWEAPONEX_BANNER_RALLY_DWARVES_AURABONUS"},
		StatusTooltip = ts:CreateFromKey("LLWEAPONEX_MB_Banner_BannerAuraStatusProtection","<font color='#C9AA58'>Immune to Flanking</font><br><font color='#33FF33'>Turn delaying reduces damage taken by [Stats:Stats_LLWEAPONEX_Banner_TurnDelayProtection:FireResistance]%.</font>"),
		GetIsTooltipActive = rb.DefaultStatusTagCheck("LLWEAPONEX_Banner_Mastery4", true)
	}).Register.StatusBeforeAttempt(function(self, e, bonuses)
		local statusSource = nil
		local auraStatus = e.Target:GetStatus("LLWEAPONEX_BANNER_RALLY_DIVINEORDER_AURABONUS") or e.Target:GetStatus("LLWEAPONEX_BANNER_RALLY_DWARVES_AURABONUS")
		if auraStatus then
			statusSource = auraStatus.StatusSourceHandle
		end
		if statusSource then
			local statusSource = GameHelpers.GetCharacter(statusSource)
			if statusSource then
				local hasBonus = false
				if statusSource.MyGuid ~= e.TargetGUID then
					hasBonus = MasteryBonusManager.GetMasteryBonuses(statusSource).BANNER_PROTECTION == true
				else
					hasBonus = bonuses.HasBonus("BANNER_PROTECTION", e.Target)
				end
				if hasBonus then
					--Block FLANKED
					SignalTestComplete("BANNER_PROTECTION")
					return false
				end
			end
		end
	end, "Target", "FLANKED").Test(function(test, self)
		--Block flanking
		local char,dummy,cleanup = WeaponExTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char, dummy, "", 0, 1, 1)
		test:Wait(1000)
		CharacterUseSkill(char, "Dome_LLWEAPONEX_Banner_Rally_DivineOrder", char, 1, 1, 1)
		test:Wait(4000)
		Timer.StartOneshot("", 250, function ()
			GameHelpers.Status.Apply(char, "FLANKED", 6.0, true, dummy)
		end)
		test:WaitForSignal(self.ID, 30000)
		test:AssertGotSignal(self.ID)
		return true
	end),
	rb:Create("BANNER_OVERPOWER", {
		Skills = {"Target_Overpower", "Target_EnemyOverpower"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Banner_OverpowerAllyBoost", "<font color='#33FF33'>Damage is increased by [ExtraData:LLWEAPONEX_MB_Banner_Overpower_DamageBoostPerAlly]% per ally within [ExtraData:LLWEAPONEX_MB_Banner_Overpower_AllyRadius]m.</font>"),
	}).Register.SkillHit(function(self, e, bonuses)
		if e.Data.Success then
			local damagePerAlly = GameHelpers.GetExtraData("LLWEAPONEX_MB_Banner_Overpower_DamageBoostPerAlly", 25)
			local allyRadius = GameHelpers.GetExtraData("LLWEAPONEX_MB_Banner_Overpower_AllyRadius", 3)
			if damagePerAlly > 0 and allyRadius > 0 then
				local totalAllies = #GameHelpers.Grid.GetNearbyObjects(e.Character, {AsTable=true, Radius=allyRadius, Relation={Ally=true}})
				if totalAllies > 0 then
					local boost = 1 + ((totalAllies * damagePerAlly) * 0.01)
					e.Data:MultiplyDamage(boost)
					SignalTestComplete(self.ID)
				end
			end
		end
	end).Test(function(test, self)
		--Boost Overpower damage by having an ally nearby
		local char1,char2,dummy,cleanup = WeaponExTesting.CreateTwoTemporaryCharactersAndDummy(test, nil, _eqSet, nil, true)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char1, dummy, "", 0, 1, 1)
		test:Wait(250)
		TeleportTo(char2, char1, "", 0, 1, 1)
		test:Wait(1000)
		CharacterUseSkill(char1, "Target_EnemyOverpower", dummy, 1, 1, 1)
		test:WaitForSignal(self.ID, 10000)
		test:AssertGotSignal(self.ID)
	end),
})