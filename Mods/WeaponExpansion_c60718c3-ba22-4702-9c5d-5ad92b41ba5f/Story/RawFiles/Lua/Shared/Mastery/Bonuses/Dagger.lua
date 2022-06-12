local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData
local isClient = Ext.IsClient()

local ThrowingKnifeBonus = rb:Create("DAGGER_THROWINGKNIFE", {
	Skills = {"Projectile_ThrowingKnife", "Projectile_EnemyThrowingKnife"},
	Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Dagger_ThrowingKnife")
})

Mastery.Variables.Bonuses.ThrowingKnifeBonusDamageSkills = {
	"Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Poison",
	"Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Explosive",
}

---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param data SkillEventData|HitData|ProjectileHitData
local function ThrowingKnifeBonusLogic(bonuses, skill, char, state, data)
	if state == SKILL_STATE.HIT and data.Success then
		local chance = GameHelpers.GetExtraData("LLWEAPONEX_MB_Dagger_ThrowingKnife_Chance", 25)
		if chance > 0 then
			if Ext.Random(1,100) < chance then
				GameHelpers.Skill.Explode(data.Target, Common.GetRandomTableEntry(Mastery.Variables.Bonuses.ThrowingKnifeBonusDamageSkills), char)
			end
		end
	--Targeted a position instead of an object
	elseif state == SKILL_STATE.PROJECTILEHIT and StringHelpers.IsNullOrEmpty(data.Target) and data.Position then
		local chance = GameHelpers.GetExtraData("LLWEAPONEX_MB_Dagger_ThrowingKnife_Chance", 25)
		if chance > 0 then
			if Ext.Random(1,100) < chance then
				GameHelpers.Skill.Explode(data.Position, Common.GetRandomTableEntry(Mastery.Variables.Bonuses.ThrowingKnifeBonusDamageSkills), char)
			end
		end
	end
end

ThrowingKnifeBonus:RegisterSkillListener(ThrowingKnifeBonusLogic)

local SneakingPassiveBonus = rb:Create("DAGGER_SNEAKINGBONUS", {
	Skills = {"ActionSkillSneak"},
	Statuses = {"SNEAKING", "INVISIBLE"},
	Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Dagger_SneakingBonus", "<font color='#F19824'>For every turn spent [Key:INVISIBLE_DisplayName] or [Handle:h6bf7caf0g7756g443bg926dg1ee5975ee133:Sneaking] [Handle:h2c990ecagc680g4c68g88ccgb5358faa4e33:in combat], gain an increasing damage boost for one attack.</font>"),
})

if not isClient then
	--For testing
	Mastery.Variables.Bonuses.DaggerSneakBonusEnabledOutsideOfCombat = Ext.IsDeveloperMode()

	local function IncreaseSneakingDamageBoost(target, turns)
		local target = GameHelpers.GetCharacter(target)
		if target then
			turns = turns or PersistentVars.MasteryMechanics.SneakingTurnsInCombat[target.MyGuid] or 0
			if turns > 0 then
				local bonusStatus = Ext.PrepareStatus(target.Handle, "LLWEAPONEX_MASTERYBONUS_DAGGER_SNEAKINGBONUS", -1)
				if bonusStatus then
					bonusStatus.ForceStatus = true
					local maxBoost = GameHelpers.GetExtraData("LLWEAPONEX_MB_Dagger_SneakingBonus_MaxMultiplier", 10.0)
					local turnBoost = GameHelpers.GetExtraData("LLWEAPONEX_MB_Dagger_SneakingBonus_TurnBoost", 5.0)
					local nextBoost = math.max(1.0, math.min(maxBoost, math.ceil((turns - 1) * turnBoost)))
					if bonusStatus.StatsMultiplier ~= nextBoost then
						CharacterStatusText(target.MyGuid, string.format("Assassin's Patience Increased (%i)", turns))
					end
					bonusStatus.StatsMultiplier = nextBoost
					Ext.ApplyStatus(bonusStatus)
				end
			end
		end
	end

	local function OnSneakingOrInvisible(bonuses, target, status, source, statusType)
		Timer.Cancel("LLWEAPONEX_ClearDaggerSneakingBonus", target)
		local target = GameHelpers.GetCharacter(target)
		if GameHelpers.Character.IsInCombat(target) or Mastery.Variables.Bonuses.DaggerSneakBonusEnabledOutsideOfCombat then
			if PersistentVars.MasteryMechanics.SneakingTurnsInCombat[target] == nil then
				TurnCounter.CreateTurnCounter("LLWEAPONEX_Dagger_SneakingBonus", 0, 0,
				TurnCounter.Mode.Increment, CombatGetIDForCharacter(target.MyGuid), {
					Target = target.MyGuid,
					Infinite = true,
					CombatOnly = not Mastery.Variables.Bonuses.DaggerSneakBonusEnabledOutsideOfCombat
				})
			end
			IncreaseSneakingDamageBoost(target)
		end
	end
	
	local function OnSneakingOrInvisibleLost(bonuses, target, status, source, statusType)
		Timer.StartObjectTimer("LLWEAPONEX_ClearDaggerSneakingBonus", target, 500)
	end
	
	SneakingPassiveBonus:RegisterStatusListener("Applied", OnSneakingOrInvisible, "SNEAKING", "Target")
	SneakingPassiveBonus:RegisterStatusTypeListener("Applied", OnSneakingOrInvisible, "INVISIBLE", "Target")
	SneakingPassiveBonus:RegisterStatusListener("Removed", OnSneakingOrInvisibleLost, "SNEAKING", "Target")
	SneakingPassiveBonus:RegisterStatusTypeListener("Removed", OnSneakingOrInvisibleLost, "INVISIBLE", "Target")

	local function OnTurnEndedWhileSneaking(counterId, turnCount, lastTurn, finished, data)
		local target = data.Target
		if GameHelpers.Character.IsSneakingOrInvisible(target) then
			PersistentVars.MasteryMechanics.SneakingTurnsInCombat[target] = turnCount
			IncreaseSneakingDamageBoost(target, turnCount)
			if turnCount >= 3 then
				TurnCounter.ClearTurnCounter("LLWEAPONEX_Dagger_SneakingBonus", target.MyGuid)
			end
		else
			Timer.StartObjectTimer("LLWEAPONEX_ClearDaggerSneakingBonus", target, 250)
		end
	end

	SneakingPassiveBonus:RegisterTurnCounterListener("LLWEAPONEX_Dagger_SneakingBonus", OnTurnEndedWhileSneaking)
	--sneakingPassiveBonus:RegisterTurnEndedListener("LLWEAPONEX_Dagger_SneakingBonus", OnTurnEndedWhileSneaking)
	--sneakingPassiveBonus:RegisterTurnDelayedListener(OnTurnEndedWhileSneaking)

	Timer.RegisterListener("LLWEAPONEX_ClearDaggerSneakingBonus", function (timerName, target)
		GameHelpers.Status.Remove(target, "LLWEAPONEX_MASTERYBONUS_DAGGER_SNEAKINGBONUS")
		PersistentVars.MasteryMechanics.SneakingTurnsInCombat[target] = nil
		TurnCounter.ClearTurnCounter("LLWEAPONEX_Dagger_SneakingBonus", target)
	end)
end

MasteryBonusManager.AddRankBonuses(MasteryID.Dagger, 1, {
	ThrowingKnifeBonus,
	SneakingPassiveBonus
})

MasteryBonusManager.AddRankBonuses(MasteryID.Dagger, 2, {
	rb:Create("DAGGER_BACKLASH", {
		Skills = {"MultiStrike_Vault", "MultiStrike_EnemyVault"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Dagger_BacklashBonus")
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.HIT and HasActiveStatus(data.Target, "LLWEAPONEX_MASTERYBONUS_THROWINGKNIFE_TARGET") == 1 then
			local target = GameHelpers.TryGetObject(data.Target)
			if not target then return end
			---@type EsvStatusConsume
			local statusObject = target:GetStatus("LLWEAPONEX_MASTERYBONUS_THROWINGKNIFE_TARGET")
			local sourceObject = statusObject and GameHelpers.TryGetObject(statusObject.StatusSourceHandle) or nil
			if statusObject and sourceObject.MyGuid == char then
				GameHelpers.Status.Remove(data.Target, "LLWEAPONEX_MASTERYBONUS_THROWINGKNIFE_TARGET")
				local sourceSkill = CharacterHasSkill(char, "Projectile_EnemyThrowingKnife") == 1 and "Projectile_EnemyThrowingKnife" or "Projectile_ThrowingKnife"
				GameHelpers.Skill.SetCooldown(char, sourceSkill, 0.0)
				local apCost = Ext.StatGetAttribute(sourceSkill, "ActionPoints")
				if apCost > 1 then
					local refundMult = math.min(100, math.max(0, GameHelpers.GetExtraData("LLWEAPONEX_MB_Dagger_Backlash_APRefundPercentage", 50)))
					if refundMult > 0 then
						if refundMult > 1 then
							refundMult = refundMult * 0.01
						end
						local apBonus = math.max(1, math.floor(apCost * refundMult))
						CharacterAddActionPoints(char, apBonus)
					end
				end
			end
		end
	end),

	rb:Create("DAGGER_SERRATED_RUPTURE", {
		Skills = {"Target_SerratedEdge", "Target_EnemySerratedEdge"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Dagger_SerratedEdgeBonus")
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.HIT and HasActiveStatus(data.Target, "BLEEDING") == 1 then
			GameHelpers.Damage.ApplySkillDamage(char, data.Target, "Target_LLWEAPONEX_DaggerMastery_RuptureBonusDamage", {HitParams=HitFlagPresets.GuaranteedWeaponHit})
			if ObjectIsCharacter(data.Target) == 1 then
				CharacterStatusText(data.Target, GameHelpers.GetStringKeyText("LLWEAPONEX_RUPTURE_DisplayName", "Ruptured"))
			end
		end
	end)
})

MasteryBonusManager.AddRankBonuses(MasteryID.Dagger, 3,{
	rb:Create("DAGGER_THROWINGKNIFE2", {
		Skills = {"Projectile_FanOfKnives", "Projectile_EnemyFanOfKnives"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Dagger_ThrowingKnife2")
	}):RegisterSkillListener(ThrowingKnifeBonusLogic),

	rb:Create("DAGGER_CORRUPTED_BLADE", {
		Skills = {"Target_CorruptedBlade", "Target_EnemyCorruptedBlade"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Dagger_CorruptedBlade")
	}):RegisterSkillListener(function (bonuses, char, skill, state, data)
		if state == SKILL_STATE.HIT and data.Success then
			local listenDelay = GameHelpers.GetExtraData("LLWEAPONEX_MB_Dagger_CorruptedBlade_DeathListenDuration", -1)
			DeathManager.ListenForDeath("CorruptedBladeDiseaseSpread", data.Target, char, listenDelay)
		end
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Dagger, 4, {
	rb:Create("DAGGER_FATALITY", {
		Skills = {"Target_Fatality", "Target_EnemyFatality"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Dagger_FatalityBonus")
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.HIT and data.Success then
			data:ConvertAllDamageTo("Piercing")
			DeathManager.ListenForDeath("FatalityRefundBonus", data.Target, char, 1000)
		end
	end),

	rb:Create("DAGGER_CRUELTY", {
		--The corpse explosion can proc the bonus as well
		Skills = {"Target_TerrifyingCruelty", "Target_EnemyTerrifyingCruelty", "Target_EnemyTerrifyingCruelty_Gheist", 
		"Projectile_LLWEAPONEX_DaggerMastery_CrueltyCorpseExplosion"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Dagger_CrueltyBonus")
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.HIT and data.Success then
			DeathManager.ListenForDeath("TerrifyingCrueltyBonus", data.Target, char, 500)
		end
	end)
})

if not isClient then
	local function TargetIsEnemy(t, source, status)
		return GameHelpers.Character.CanAttackTarget(t, source, false)
	end

	DeathManager.RegisterListener("CorruptedBladeDiseaseSpread", function(target, attacker, success)
		if success then
			local radius = GameHelpers.GetExtraData("LLWEAPONEX_MB_Dagger_CorruptedBlade_SpreadRadius", 12.0)
			local pos = GameHelpers.Math.GetPosition(target, GameHelpers.Math.GetPosition(attacker))
			local props = GameHelpers.Stats.GetSkillProperties("Target_CorruptedBlade")
			if not props or #props == 0 then
				--If Corrupted Blade applies no statuses, apply Diseased.
				GameHelpers.Status.Apply(pos, "DISEASED", 12.0, true, attacker, radius, false, 
				TargetIsEnemy)
			else
				--Ext.ExecuteSkillPropertiesOnPosition("Target_CorruptedBlade", attacker, pos, radius, "Target", false)
				for _,prop in pairs(GameHelpers.Stats.GetSkillProperties("Target_CorruptedBlade")) do
					if prop.Type == "Status" and prop.Duration ~= 0 then
						GameHelpers.Status.Apply(pos, prop.Action, prop.Duration, false, attacker, radius, false, 
						TargetIsEnemy)
					end
				end
			end
		end
	end)

	DeathManager.RegisterListener("FatalityRefundBonus", function(target, attacker, success)
		if success then
			local cd = GameHelpers.GetExtraData("LLWEAPONEX_MB_Dagger_Fatality_CooldownOverride", 6.0)
			local sourceSkill = CharacterHasSkill(attacker, "Target_EnemyFatality") == 1 and "Target_EnemyFatality" or "Target_Fatality"
			GameHelpers.Skill.SetCooldown(attacker, sourceSkill, cd)
			local skill = Ext.GetStat("Target_Fatality")
			if skill["Magic Cost"] > 0 then
				CharacterAddSourcePoints(attacker, 1)
			end
			if skill.ActionPoints > 1 then
				CharacterAddActionPoints(attacker, Ext.Round(skill.ActionPoints/2))
			end
		end
	end)
	
	DeathManager.RegisterListener("TerrifyingCrueltyBonus", function(target, attacker, success)
		if success then
			local source = GameHelpers.TryGetObject(attacker)
			---@type EsvStatusExplode
			local explode = Ext.PrepareStatus(target, "EXPLODE", 6.0)
			explode.StatusSourceHandle = source.Handle
			explode.Projectile = "Projectile_LLWEAPONEX_DaggerMastery_CrueltyCorpseExplosion"
			Ext.ApplyStatus(explode)
		end
	end)
else

end