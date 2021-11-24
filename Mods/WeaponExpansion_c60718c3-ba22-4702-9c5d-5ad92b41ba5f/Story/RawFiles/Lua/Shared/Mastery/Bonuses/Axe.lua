local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

MasteryBonusManager.AddRankBonuses(MasteryID.Axe, 1, {
	rb:Create("AXE_BONUSDAMAGE", {
		Skills = {"Target_CripplingBlow", "Target_EnemyCripplingBlow"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Axe_CripplingBlow"),
		NamePrefix = "<font color='#DD4444'>Executioner's</font>"
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.HIT and data.Success then
			if GameHelpers.Status.IsDisabled(data.Target) then
				GameHelpers.Skill.Explode(data.Target, "Projectile_LLWEAPONEX_MasteryBonus_CripplingBlowPiercingDamage", char)
			end
		end
	end),

	rb:Create("AXE_EXECUTIONER", {
		Skills = {"ActionAttackGround"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Axe_Executioner", "Axes deal [ExtraData:LLWEAPONEX_MB_Axe_ProneDamageBonus]% more damage to targets that are [Key:KNOCKED_DOWN_DisplayName].")
	}):RegisterOnWeaponTagHit("LLWEAPONEX_Axe", function(tag, source, target, data, bonuses, bHitObject, isFromSkill)
		if bHitObject and not isFromSkill and data.Damage > 0 then
			if HasActiveStatus(source, "AOO") == 1 and ObjectIsCharacter(target.MyGuid) == 1 then
				local damageBonus = GameHelpers.GetExtraData("LLWEAPONEX_MB_Axe_AoOMaxDamageBonus", 50) * 0.01
				local missingVitPerc = 0.0
				missingVitPerc = math.max(0.01, math.min(1, 1 - (target.Stats.CurrentVitality / target.Stats.MaxVitality) + 0.01))
				data:MultiplyDamage(1+(damageBonus * missingVitPerc))
			end
		end
	end)
})

MasteryBonusManager.AddRankBonuses(MasteryID.Axe, 2, {
	rb:Create("AXE_VULNERABLE", {
		Skills = {"MultiStrike_BlinkStrike", "MultiStrike_EnemyBlinkStrike"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Axe_BlitzAttack")
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.HIT and data.Success then
			Timer.Start("LLWEAPONEX_MasteryBonus_ApplyVulnerable", 50, char, data.Target)
		end
	end):RegisterOnHit(function(bHitObject,attacker,target,damage,data)
		if bHitObject and HasActiveStatus(target.MyGuid, "LLWEAPONEX_MASTERYBONUS_VULNERABLE") == 1 then
			RemoveStatus(target.MyGuid, "LLWEAPONEX_MASTERYBONUS_VULNERABLE")
			GameHelpers.Damage.ApplySkillDamage(attacker, target, "Projectile_LLWEAPONEX_MasteryBonus_VulnerableDamage", HitFlagPresets.GuaranteedWeaponHit)
		end
	end, true),

	rb:Create("AXE_SAVAGE", {
		Skills = {"ActionAttackGround"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Axe_Savage", "Attack of Opportunities deal [ExtraData:LLWEAPONEX_MB_Axe_AoOMaxDamageBonus]% more damage, in proportion to the target's missing vitality.")
	}):RegisterOnWeaponTagHit("LLWEAPONEX_Axe", function(tag, source, target, data, bonuses, bHitObject, isFromSkill)
		if bHitObject and not isFromSkill and data.Damage > 0 then
			if NRD_ObjectHasStatusType(target.MyGuid, "KNOCKED_DOWN") == 1 then
				local damageMult = GameHelpers.GetExtraData("LLWEAPONEX_MB_Axe_ProneDamageBonus", 25)
				if damageMult > 0 then
					data:MultiplyDamage(1 + (damageMult * 0.01))
				end
			end
		end
	end)
})

MasteryBonusManager.AddRankBonuses(MasteryID.Axe, 3, {
	rb:Create("AXE_SPINNING", {
		Skills = {"Shout_Whirlwind", "Shout_EnemyWhirlwind", "Shout_LLWEAPONEX_MasteryBonus_Axe_Whirlwind_Spin2", "Shout_LLWEAPONEX_MasteryBonus_Axe_Whirlwind_Spin3"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Axe_Whirlwind"),
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.CAST then
			if skill == "Shout_Whirlwind" or "Shout_EnemyWhirlwind" then
				GameHelpers.ClearActionQueue(char)
				CharacterUseSkill(char, "Shout_LLWEAPONEX_MasteryBonus_Axe_Whirlwind_Spin2", char, 0, 1, 1)
			elseif skill == "Shout_LLWEAPONEX_MasteryBonus_Axe_Whirlwind_Spin2" then
				if Ext.Random(0,100) <= 50 then
					GameHelpers.ClearActionQueue(char)
					CharacterUseSkill(char, "Shout_LLWEAPONEX_MasteryBonus_Axe_Whirlwind_Spin3", char, 0, 1, 1)
				end
			elseif skill == "Shout_LLWEAPONEX_MasteryBonus_Axe_Whirlwind_Spin3" then
				if Ext.Random(0,100) <= 25 then
					GameHelpers.ClearActionQueue(char)
					CharacterUseSkill(char, "Shout_LLWEAPONEX_MasteryBonus_Axe_Whirlwind_Spin4", char, 0, 1, 1)
				end
			end
		end
	end),

	rb:Create("AXE_2H_ALLIN", {
		Skills = {"Target_HeavyAttack"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Axe_AllIn"),
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.HIT and data.Success then
			local damageMultiplier = GameHelpers.GetExtraData("LLWEAPONEX_MB_Axe_AllInPiercingDamagePercentage", 50)
			if damageMultiplier > 0 then
				if damageMultiplier > 1 then
					damageMultiplier = damageMultiplier * 0.01
				end

				local totalPiercingDamage = 0
				for i,damageType in Data.DamageTypes:Get() do
					local damage = nil
					damage = NRD_HitStatusGetDamage(data.Target, data.Handle, damageType)
					if damage ~= nil and damage > 0 then
						local damageAmount = Ext.Round(damage * damageMultiplier)
						if damageAmount > 0 then
							totalPiercingDamage = totalPiercingDamage + damageAmount
							NRD_HitStatusAddDamage(data.Target, data.Handle, damageType, damageAmount * -1)
						end
					end
				end
				if totalPiercingDamage > 0 then
					data:AddDamage("Piercing", totalPiercingDamage)
				end
			end
		end
	end),

	rb:Create("AXE_DW_FLURRY", {
		Skills = {"Target_DualWieldingAttack"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Axe_FlurryCleave"),
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.HIT and data.Success ~= nil then
			if PersistentVars.MasteryMechanics.AxeFlurryHits[char] == nil then
				PersistentVars.MasteryMechanics.AxeFlurryHits[char] = 0
			end
			if data.Success then
				PersistentVars.MasteryMechanics.AxeFlurryHits[char] = PersistentVars.MasteryMechanics.AxeFlurryHits[char] + 1
			end
			Timer.StartObjectTimer("LLWEAPONEX_Axe_CheckFlurryCounter", char, 1000)
		end
	end),
})

if Vars.IsClient then
	Timer.RegisterListener("LLWEAPONEX_Axe_CheckFlurryCounter", function(timerName, char)
		if PersistentVars.MasteryMechanics.AxeFlurryHits[char] >= 3 then
			CharacterAddActionPoints(char, 1)
			CharacterStatusText(char, "LLWEAPONEX_StatusText_FlurryAxeCombo")
		end
		PersistentVars.MasteryMechanics.AxeFlurryHits[char] = nil
	end)
end

MasteryBonusManager.AddRankBonuses(MasteryID.Axe, 4, {
	rb:Create("AXE_CLEAVE", {
		Skills = {"Target_Flurry", "Target_EnemyFlurry"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Axe_FlurryCleave")
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.HIT and data.Success then
			SetTag(data.Target, "LLWEAPONEX_FlurryTarget")
			-- Uses ShootLocalCone in behavior
			SetStoryEvent(char, "LLWEAPONEX_Flurry_Axe_CreateCleaveCone")
			Timer.Start("LLWEAPONEX_MasteryBonus_RemoveFlurryTargetTag", 250, data.Target)
		end
	end),

	rb:Create("AXE_SCOUNDREL", {
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Axe_Scoundrel","Axes can now be used with [Handle:hed591025g5c39g48ccga899gc9b1569716c1:Scoundrel] skills."),
	})
})

if not Vars.IsClient then
	Timer.RegisterListener("LLWEAPONEX_MasteryBonus_ApplyVulnerable", function(timerName, char, target)
		if char and target and CharacterIsDead(target) == 0 then
			if CharacterIsInCombat(char) == 1 then
				ApplyStatus(target, "LLWEAPONEX_MASTERYBONUS_VULNERABLE", -1.0, 0, char)
			else
				ApplyStatus(target, "LLWEAPONEX_MASTERYBONUS_VULNERABLE", 6.0, 0, char)
			end
		end
	end)
	
	Timer.RegisterListener("LLWEAPONEX_MasteryBonus_RemoveFlurryTargetTag", function(timerName, target)
		ClearTag(target, "LLWEAPONEX_FlurryTarget")
	end)
end