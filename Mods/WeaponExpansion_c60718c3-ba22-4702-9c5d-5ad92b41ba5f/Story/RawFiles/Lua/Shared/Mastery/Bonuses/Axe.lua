local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

local _eqSet = "Class_Battlemage_Start"

MasteryBonusManager.AddRankBonuses(MasteryID.Axe, 1, {
	rb:Create("AXE_BONUSDAMAGE", {
		Skills = {"Target_CripplingBlow", "Target_EnemyCripplingBlow"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Axe_CripplingBlow", "<font color='#F19824'>If the target is disabled, deal an additional [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_CripplingBlowPiercingDamage].</font>"),
		NamePrefix = "<font color='#DD4444'>Executioner's</font>"
	}).Register.SkillHit(function(self, e, bonuses)
		if e.Data.Success and (GameHelpers.Status.IsDisabled(e.Data.TargetObject) or e.Data.TargetObject:HasTag("LLDUMMY_TrainingDummy")) then
			GameHelpers.Damage.ApplySkillDamage(e.Character, e.Data.TargetObject, "Projectile_LLWEAPONEX_MasteryBonus_CripplingBlowPiercingDamage", HitFlagPresets.GuaranteedWeaponHit)
			local text = Text.CombatLog.Axe_DisabledBonus:ReplacePlaceholders(GameHelpers.Character.GetDisplayName(e.Character),
			GameHelpers.Character.GetDisplayName(e.Data.TargetObject), GameHelpers.GetStringKeyText(e.Data.SkillData.DisplayName))
			CombatLog.AddTextToAllPlayers(CombatLog.Filters.Combat, text)
			SignalTestComplete(self.ID)
		end
	end).Test(function(test, self)
		local character,dummy,cleanup = MasteryTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(character, dummy, "", 0, 1, 1)
		test:Wait(250)
		CharacterLookAt(dummy, character, 1)
		GameHelpers.Status.Apply(dummy, "STUNNED", 12.0, true, character)
		test:Wait(500)
		CharacterUseSkill(character, "Target_EnemyCripplingBlow", dummy, 0, 1, 1)
		test:WaitForSignal(self.ID, 5000)
		test:AssertGotSignal(self.ID)
		return true
	end),

	rb:Create("AXE_EXECUTIONER", {
		Skills = {"ActionAttackGround"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Axe_Executioner", "Axes deal [ExtraData:LLWEAPONEX_MB_Axe_ProneDamageBonus]% more damage to targets that are [Key:KNOCKED_DOWN_DisplayName].")
	}).Register.OnWeaponTagHit("LLWEAPONEX_Axe", function(tag, attacker, target, data, targetIsObject, skill, self)
		if targetIsObject and not skill and data.Damage > 0 then
			if GameHelpers.Status.HasStatusType(target, "KNOCKED_DOWN") then
				local damageMult = GameHelpers.GetExtraData("LLWEAPONEX_MB_Axe_ProneDamageBonus", 25)
				if damageMult > 0 then
					data:MultiplyDamage(1 + (damageMult * 0.01))
				end
				SignalTestComplete(self.ID)
			end
		end
	end).Test(function(test, self)
		local character,dummy,cleanup = MasteryTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet, "13ee7ec6-70c3-4f2c-9145-9a5e85feb7d3")
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(character, dummy, "", 0, 1, 1)
		test:Wait(250)
		CharacterLookAt(dummy, character, 1)
		--CharacterSetImmortal(dummy, 1)
		test:Wait(1000)
		SetTag(CharacterGetEquippedWeapon(character), "LLWEAPONEX_Axe")
		GameHelpers.Status.Apply(dummy, "KNOCKED_DOWN", 24.0, true, character)
		test:Wait(500)
		test:AssertEquals(GameHelpers.Status.HasStatusType(dummy, "KNOCKED_DOWN"), true, "Failed to apply KNOCKED_DOWN")
		CharacterAttack(character, dummy)
		test:WaitForSignal(self.ID, 5000)
		test:AssertGotSignal(self.ID)
		CharacterSetImmortal(dummy, 0)
		return true
	end)
})

MasteryBonusManager.AddRankBonuses(MasteryID.Axe, 2, {
	rb:Create("AXE_VULNERABLE", {
		Skills = {"MultiStrike_BlinkStrike", "MultiStrike_EnemyBlinkStrike"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Axe_BlitzAttack")
	}).Register.SkillHit(function(self, e, bonuses)
		if e.Data.Success then
			Timer.StartObjectTimer("LLWEAPONEX_MasteryBonus_ApplyVulnerable", e.Data.Target, 50, {Source=e.Character.MyGuid})
		end
	end).OnHit(function(attacker, target, data, targetIsObject, skill, self)
		if targetIsObject and HasActiveStatus(target.MyGuid, "LLWEAPONEX_MASTERYBONUS_VULNERABLE") == 1 then
			GameHelpers.Status.Remove(target.MyGuid, "LLWEAPONEX_MASTERYBONUS_VULNERABLE")
			GameHelpers.Damage.ApplySkillDamage(attacker, target, "Projectile_LLWEAPONEX_MasteryBonus_VulnerableDamage", {HitParams=HitFlagPresets.GuaranteedWeaponHit})
			SignalTestComplete("AXE_VULNERABLE_2")
		end
	end, true).TimerFinished("LLWEAPONEX_MasteryBonus_ApplyVulnerable", function (self, e, bonuses)
		if e.Data.UUID and e.Data.Source and not GameHelpers.ObjectIsDead(e.Data.UUID) then
			if not GameHelpers.Character.IsInCombat(e.Data.Source) then
				GameHelpers.Status.Apply(e.Data.Object, "LLWEAPONEX_MASTERYBONUS_VULNERABLE", -1.0, false, e.Data.Source)
			else
				GameHelpers.Status.Apply(e.Data.Object, "LLWEAPONEX_MASTERYBONUS_VULNERABLE", -2, false, e.Data.Source)
			end
			SignalTestComplete("AXE_VULNERABLE_1")
		end
	end).Test(function(test, self)
		--Hit with blinkstrike, then do a basic attack
		local character,dummy,cleanup = MasteryTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(character, dummy, "", 0, 1, 1)
		test:Wait(250)
		CharacterLookAt(dummy, character, 1)
		test:Wait(500)
		CharacterUseSkill(character, "MultiStrike_EnemyBlinkStrike", dummy, 0, 1, 1)
		test:WaitForSignal("AXE_VULNERABLE_1", 5000)
		test:AssertGotSignal("AXE_VULNERABLE_1")
		test:Wait(1000)
		TeleportTo(character, dummy, "", 0, 1, 1)
		CharacterAttack(character, dummy)
		test:WaitForSignal("AXE_VULNERABLE_2", 5000)
		test:AssertGotSignal("AXE_VULNERABLE_2")
		test:Wait(1000)
		return true
	end),

	rb:Create("AXE_SAVAGE", {
		Skills = {"ActionAttackGround"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Axe_Savage", "Attack of Opportunities deal [ExtraData:LLWEAPONEX_MB_Axe_AttackOfOpportunityMaxDamageBonus]% more damage, in proportion to the target's missing vitality.")
	}).Register.OnWeaponTagHit("LLWEAPONEX_Axe", function(tag, attacker, target, data, targetIsObject, skill, self)
		if targetIsObject and not skill and data.Damage > 0 then
			if GameHelpers.Status.IsActive(attacker, "AOO") and GameHelpers.Ext.ObjectIsCharacter(target) then
				local damageBonus = GameHelpers.GetExtraData("LLWEAPONEX_MB_Axe_AttackOfOpportunityMaxDamageBonus", 50) * 0.01
				if damageBonus > 0 then
					local missingVitPerc = 0.0
					missingVitPerc = math.max(0.01, math.min(1, 1 - (target.Stats.CurrentVitality / target.Stats.MaxVitality) + 0.01))
					local damageMult = 1+(damageBonus * missingVitPerc)
					print("damageMult", damageMult)
					data:MultiplyDamage(damageMult)
				end
			end
			SignalTestComplete(self.ID)
		end
	end).Test(function(test, self)
		--Missing vitality bonus damage with an Attack of Opportunity
		local character,dummy,cleanup = MasteryTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(character, dummy, "", 0, 1, 1)
		test:Wait(250)
		CharacterLookAt(dummy, character, 1)
		--CharacterSetHitpointsPercentage(dummy, 0.1)
		test:Wait(500)
		Ext.GetCharacter(dummy).Stats.CurrentVitality = 10
		SetTag(CharacterGetEquippedWeapon(character), "LLWEAPONEX_Axe")
		GameHelpers.Status.Apply(character, "AOO", 12.0, true, dummy)
		GameHelpers.Status.Apply(dummy, "AOO", 12.0, true, character)
		test:Wait(500)
		CharacterAttack(character, dummy)
		test:WaitForSignal(self.ID, 5000)
		test:AssertGotSignal(self.ID)
		test:Wait(1500)
		return true
	end)
})

MasteryBonusManager.AddRankBonuses(MasteryID.Axe, 3, {
	rb:Create("AXE_SPINNING", {
		Skills = {"Shout_Whirlwind", "Shout_EnemyWhirlwind", "Shout_LLWEAPONEX_MasteryBonus_Axe_Whirlwind_Spin2", "Shout_LLWEAPONEX_MasteryBonus_Axe_Whirlwind_Spin3"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Axe_Whirlwind", "Spin an additional 1-3 times, dealing reduced damage each spin."),
	}).Register.SkillCast(function(self, e, bonuses)
		Timer.StartObjectTimer("LLWEAPONEX_Axe_Whirlwind_TryNextSpin", e.Character, 500, {Skill = e.Skill})
	end).TimerFinished("LLWEAPONEX_Axe_Whirlwind_TryNextSpin", function (self, e, bonuses)
		if e.Data.UUID and e.Data.Skill then
			local skill = e.Data.Skill
			local uuid = e.Data.UUID
			if skill == "Shout_Whirlwind" or skill == "Shout_EnemyWhirlwind" then
				GameHelpers.ClearActionQueue(uuid)
				CharacterUseSkill(uuid, "Shout_LLWEAPONEX_MasteryBonus_Axe_Whirlwind_Spin2", uuid, 0, 1, 1)
				SignalTestComplete("AXE_SPINNING_1")
			elseif skill == "Shout_LLWEAPONEX_MasteryBonus_Axe_Whirlwind_Spin2" then
				if GameHelpers.Math.Roll(50) or e.Data.Object:HasTag("LLWEAPONEX_MasteryTestCharacter") then
					GameHelpers.ClearActionQueue(uuid)
					CharacterUseSkill(uuid, "Shout_LLWEAPONEX_MasteryBonus_Axe_Whirlwind_Spin3", uuid, 0, 1, 1)
					SignalTestComplete("AXE_SPINNING_2")
				end
			elseif skill == "Shout_LLWEAPONEX_MasteryBonus_Axe_Whirlwind_Spin3" then
				if GameHelpers.Math.Roll(25) or e.Data.Object:HasTag("LLWEAPONEX_MasteryTestCharacter") then
					GameHelpers.ClearActionQueue(uuid)
					CharacterUseSkill(uuid, "Shout_LLWEAPONEX_MasteryBonus_Axe_Whirlwind_Spin4", uuid, 0, 1, 1)
					SignalTestComplete("AXE_SPINNING_3")
				end
			end
		end
	end).Test(function(test, self)
		--Spin-to-win via Whirlwind
		local character,dummy,cleanup = MasteryTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(character, dummy, "", 0, 1, 1)
		test:Wait(250)
		CharacterLookAt(dummy, character, 1)
		test:Wait(500)
		CharacterUseSkill(character, "Shout_EnemyWhirlwind", dummy, 1, 1, 1)
		test:WaitForSignal("AXE_SPINNING_3", 30000)
		test:AssertGotSignal("AXE_SPINNING_3")
		return true
	end),

	rb:Create("AXE_2H_ALLIN", {
		Skills = {"Target_HeavyAttack"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Axe_AllIn", "[ExtraData:LLWEAPONEX_MB_Axe_AllInPiercingDamagePercentage]% of the damage dealt is converted to <font color='#CD1F1F'>[Handle:hd05581a1g83a7g4d95gb59fgfa5ef68f5c90:piercing damage]</font>."),
	}).Register.SkillHit(function(self, e, bonuses)
		if e.Data.Success then
			local damageMultiplier = GameHelpers.GetExtraData("LLWEAPONEX_MB_Axe_AllInPiercingDamagePercentage", 50)
			if damageMultiplier > 0 then
				if damageMultiplier > 1 then
					damageMultiplier = damageMultiplier * 0.01
				end
				
				e.Data:ConvertDamageTypeTo({"Piercing", "None", "Shadow"}, "Piercing", true, damageMultiplier, true, math.ceil)
			end
			SignalTestComplete(self.ID)
		end
	end).Test(function(test, self)
		--Piercing damage conversion for All In
		local character,dummy,cleanup = MasteryTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(character, dummy, "", 0, 1, 1)
		test:Wait(250)
		CharacterLookAt(dummy, character, 1)
		test:Wait(500)
		CharacterUseSkill(character, "Target_HeavyAttack", dummy, 1, 1, 1)
		test:WaitForSignal(self.ID, 5000)
		test:AssertGotSignal(self.ID)
		return true
	end),

	rb:Create("AXE_DW_FLURRY", {
		Skills = {"Target_DualWieldingAttack"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Axe_FlurryCleave"),
	}).Register.SkillHit(function(self, e, bonuses)
		if PersistentVars.MasteryMechanics.AxeFlurryHits[e.Character.MyGuid] == nil then
			PersistentVars.MasteryMechanics.AxeFlurryHits[e.Character.MyGuid] = 0
		end
		if e.Data.Success then
			PersistentVars.MasteryMechanics.AxeFlurryHits[e.Character.MyGuid] = PersistentVars.MasteryMechanics.AxeFlurryHits[e.Character.MyGuid] + 1
		end
		Timer.Cancel("LLWEAPONEX_Axe_CheckFlurryCounter", e.Character.MyGuid)
		Timer.StartObjectTimer("LLWEAPONEX_Axe_CheckFlurryCounter", e.Character.MyGuid, 1000)
	end).TimerFinished("LLWEAPONEX_Axe_CheckFlurryCounter", function (self, e, bonuses)
		if e.Data.UUID then
			if PersistentVars.MasteryMechanics.AxeFlurryHits[e.Data.UUID] >= 3 then
				local ap = GameHelpers.GetExtraData("LLWEAPONEX_MB_Axe_FlurryBonusAP", 1)
				if ap > 0 then
					CharacterAddActionPoints(e.Data.UUID, ap)
					CharacterStatusText(e.Data.UUID, "LLWEAPONEX_StatusText_FlurryAxeCombo")
				end
				SignalTestComplete("AXE_DW_FLURRY")
			end
			PersistentVars.MasteryMechanics.AxeFlurryHits[e.Data.UUID] = nil
		end
	end).Test(function(test, self)
		--Bonus AP from hitting 3 times with the dual-wielding skill
		local character,dummy,cleanup = MasteryTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(character, dummy, "", 0, 1, 1)
		test:Wait(250)
		CharacterLookAt(dummy, character, 1)
		test:Wait(1000)
		CharacterUseSkill(character, "Target_DualWieldingAttack", dummy, 1, 1, 1)
		test:WaitForSignal(self.ID, 10000)
		Ext.Dump(PersistentVars.MasteryMechanics.AxeFlurryHits)
		test:AssertGotSignal(self.ID)
		return true
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Axe, 4, {
	rb:Create("AXE_CLEAVE", {
		Skills = {"Target_Flurry", "Target_EnemyFlurry"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Axe_FlurryCleave", "Each hit cleaves up to [Stats:Cone_LLWEAPONEX_MasteryBonus_Axe_FlurryCleave:Range]m away in a [Stats:Cone_LLWEAPONEX_MasteryBonus_Axe_FlurryCleave:Angle] degree cone, dealing [SkillDamage:Cone_LLWEAPONEX_MasteryBonus_Axe_FlurryCleave].")
	}).Register.SkillHit(function(self, e, bonuses)
		if e.Data.Success then
			SetTag(e.Data.Target, "LLWEAPONEX_FlurryTarget")
			Timer.StartObjectTimer("LLWEAPONEX_MasteryBonus_RemoveFlurryTargetTag", e.Data.Target, 250)
			GameHelpers.Skill.ShootZoneFromSource("Cone_LLWEAPONEX_MasteryBonus_Axe_FlurryCleave", e.Character)
			SignalTestComplete(self.ID)
		end
	end).TimerFinished("LLWEAPONEX_MasteryBonus_RemoveFlurryTargetTag", function (self, e, bonuses)
		if e.Data.UUID then
			ClearTag(e.Data.UUID, "LLWEAPONEX_FlurryTarget")
			SignalTestComplete("AXE_CLEAVE")
		end
	end).Test(function(test, self)
		--Cleaving flurry
		local character,dummy,cleanup = MasteryTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(character, dummy, "", 0, 1, 1)
		test:Wait(250)
		CharacterLookAt(dummy, character, 1)
		test:Wait(500)
		CharacterUseSkill(character, "Target_EnemyFlurry", dummy, 1, 1, 1)
		--This skill can hit 5 times, but we'll just wait for 1 hit
		test:WaitForSignal(self.ID, 10000)
		test:AssertGotSignal(self.ID)
		return true
	end),

	rb:Create("AXE_SCOUNDREL", {
		AllSkills = true,
		GetIsTooltipActive = function(bonus, id, character, tooltipType, status)
			if tooltipType == "skill" then
				if Ext.StatGetAttribute(id, "Requirement") == "DaggerWeapon" then
					return true
				end
			end
			return false
		end,
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Axe_Stalker","Axes can now be used with skills that require a [Handle:hd6d18316gbc8bg400bga46eg18cd9f4185ee:Dagger].")
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