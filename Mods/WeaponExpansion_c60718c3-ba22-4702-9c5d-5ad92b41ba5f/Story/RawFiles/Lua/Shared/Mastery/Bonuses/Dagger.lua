local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData
local isClient = Ext.IsClient()

local ThrowingKnifeBonus = rb:Create("DAGGER_THROWINGKNIFE", {
	Skills = {"Projectile_ThrowingKnife", "Projectile_EnemyThrowingKnife"},
	Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Dagger_ThrowingKnife")
})

MasteryBonusManager.Vars.ThrowingKnifeBonusDamageSkills = {
	"Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Poison",
	"Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Explosive",
}

---@param self MasteryBonusData
---@param e OnSkillStateHitEventArgs
---@param bonuses MasteryBonusCallbackBonuses
local function ThrowingKnifeBonus_Hit(self, e, bonuses)
	if e.Data.Success then
		local chance = GameHelpers.GetExtraData("LLWEAPONEX_MB_Dagger_ThrowingKnife_Chance", 25)
		if GameHelpers.Math.Roll(chance) then
			GameHelpers.Skill.Explode(e.Data.Target, Common.GetRandomTableEntry(MasteryBonusManager.Vars.ThrowingKnifeBonusDamageSkills), e.Character)
		end
	end
end

---@param self MasteryBonusData
---@param e OnSkillStateProjectileHitEventArgs
---@param bonuses MasteryBonusCallbackBonuses
local function ThrowingKnifeBonus_ProjectileHit(self, e, bonuses)
	--Targeted a position instead of an object
	if StringHelpers.IsNullOrEmpty(e.Data.Target) and e.Data.Position then
		local chance = GameHelpers.GetExtraData("LLWEAPONEX_MB_Dagger_ThrowingKnife_Chance", 25)
		if chance > 0 and GameHelpers.Math.Roll(chance) then
			GameHelpers.Skill.Explode(e.Data.Position, Common.GetRandomTableEntry(MasteryBonusManager.Vars.ThrowingKnifeBonusDamageSkills), e.Character)
		end
	end
end

ThrowingKnifeBonus.Register.SkillHit(ThrowingKnifeBonus_Hit).SkillProjectileHit(ThrowingKnifeBonus_ProjectileHit)

local SneakingPassiveBonus = rb:Create("DAGGER_SNEAKINGBONUS", {
	Skills = {"ActionSkillSneak"},
	Statuses = {"SNEAKING", "INVISIBLE"},
	Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Dagger_SneakingBonus", "<font color='#F19824'>For every turn spent [Key:INVISIBLE_DisplayName] or [Handle:h6bf7caf0g7756g443bg926dg1ee5975ee133:Sneaking] [Handle:h2c990ecagc680g4c68g88ccgb5358faa4e33:in combat], gain an increasing damage boost for one attack.</font>"),
	MasteryMenuSettings = {
		OnlyUseTable = "Status",
	}
})

if not isClient then
	--For testing
	MasteryBonusManager.Vars.DaggerSneakBonusEnabledOutsideOfCombat = Ext.IsDeveloperMode()

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

	local function OnSneakingOrInvisible(e)
		Timer.Cancel("LLWEAPONEX_ClearDaggerSneakingBonus", e.TargetGUID)
		if GameHelpers.Character.IsInCombat(e.Target) or MasteryBonusManager.Vars.DaggerSneakBonusEnabledOutsideOfCombat then
			if PersistentVars.MasteryMechanics.SneakingTurnsInCombat[e.TargetGUID] == nil then
				TurnCounter.CountUp("LLWEAPONEX_Dagger_SneakingBonus", 0, GameHelpers.Combat.GetID(e.TargetGUID), {
					Target = e.TargetGUID,
					Infinite = true,
					CombatOnly = not MasteryBonusManager.Vars.DaggerSneakBonusEnabledOutsideOfCombat
				})
			end
			IncreaseSneakingDamageBoost(e.TargetGUID)
		end
	end

	local function OnSneakingOrInvisibleLost(e)
		Timer.StartObjectTimer("LLWEAPONEX_ClearDaggerSneakingBonus", e.TargetGUID, 500)
	end
	
	SneakingPassiveBonus.Register.StatusApplied(OnSneakingOrInvisible, "Target", "SNEAKING")
	SneakingPassiveBonus.Register.StatusApplied(OnSneakingOrInvisible, "Target", "INVISIBLE", true)
	SneakingPassiveBonus.Register.StatusRemoved(OnSneakingOrInvisibleLost, "Target", "SNEAKING")
	SneakingPassiveBonus.Register.StatusRemoved(OnSneakingOrInvisibleLost, "Target", "INVISIBLE", true)

	SneakingPassiveBonus.Register.TurnCounter("LLWEAPONEX_Dagger_SneakingBonus", function (self, e, bonuses)
		local target = e.Data.Target
		if target then
			if GameHelpers.Character.IsSneakingOrInvisible(target) then
				PersistentVars.MasteryMechanics.SneakingTurnsInCombat[target] = e.Turn
				IncreaseSneakingDamageBoost(target, e.Turn)
				if e.Turn >= 3 then
					TurnCounter.ClearTurnCounter("LLWEAPONEX_Dagger_SneakingBonus", target)
				end
			else
				Timer.StartObjectTimer("LLWEAPONEX_ClearDaggerSneakingBonus", target, 250)
			end
		end
	end)
	--sneakingPassiveBonus:RegisterTurnEndedListener("LLWEAPONEX_Dagger_SneakingBonus", OnTurnEndedWhileSneaking)
	--sneakingPassiveBonus:RegisterTurnDelayedListener(OnTurnEndedWhileSneaking)

	Timer.Subscribe("LLWEAPONEX_ClearDaggerSneakingBonus", function (e)
		if e.Data.Object then
			GameHelpers.Status.Remove(e.Data.Object, "LLWEAPONEX_MASTERYBONUS_DAGGER_SNEAKINGBONUS")
			PersistentVars.MasteryMechanics.SneakingTurnsInCombat[e.Data.UUID] = nil
			TurnCounter.ClearTurnCounter("LLWEAPONEX_Dagger_SneakingBonus", e.Data.UUID)
		end
	end)
end

MasteryBonusManager.AddRankBonuses(MasteryID.Dagger, 1, {
	ThrowingKnifeBonus,
	SneakingPassiveBonus
})

MasteryBonusManager.AddRankBonuses(MasteryID.Dagger, 2, {
	rb:Create("DAGGER_BACKLASH", {
		Skills = {"MultiStrike_Vault", "MultiStrike_EnemyVault"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Dagger_BacklashBonus", "<font color='#F19824'>Attacking a target hit by [Key:Projectile_ThrowingKnife_DisplayName] grants [Special:LLWEAPONEX_MB_BacklashAPBonus] AP and refreshs the cooldown of [Key:Projectile_ThrowingKnife_DisplayName]</font>")
	}).Register.SkillHit(function(self, e, bonuses)
		if e.Data.Success and GameHelpers.Status.IsActive(e.Data.TargetObject, "LLWEAPONEX_MASTERYBONUS_THROWINGKNIFE_TARGET") then
			---@type EsvStatusConsume
			local statusObject = e.Data.TargetObject:GetStatus("LLWEAPONEX_MASTERYBONUS_THROWINGKNIFE_TARGET")
			local sourceObject = statusObject and GameHelpers.TryGetObject(statusObject.StatusSourceHandle) or nil
			if statusObject and sourceObject and sourceObject.MyGuid == e.Character.MyGuid then
				GameHelpers.Status.Remove(e.Data.Target, "LLWEAPONEX_MASTERYBONUS_THROWINGKNIFE_TARGET")
				local sourceSkill = CharacterHasSkill(e.Character, "Projectile_EnemyThrowingKnife") == 1 and "Projectile_EnemyThrowingKnife" or "Projectile_ThrowingKnife"
				GameHelpers.Skill.SetCooldown(e.Character, sourceSkill, 0.0)
				local apCost = GameHelpers.Stats.GetAttribute(sourceSkill, "ActionPoints", 0)
				if apCost > 1 then
					local refundMult = math.min(100, math.max(0, GameHelpers.GetExtraData("LLWEAPONEX_MB_Dagger_Backlash_APRefundPercentage", 50)))
					if refundMult > 0 then
						if refundMult > 1 then
							refundMult = refundMult * 0.01
						end
						local apBonus = math.max(1, math.floor(apCost * refundMult))
						CharacterAddActionPoints(e.Character, apBonus)
					end
				end
			end
		end
	end),

	rb:Create("DAGGER_SERRATED_RUPTURE", {
		Skills = {"Target_SerratedEdge", "Target_EnemySerratedEdge"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Dagger_SerratedEdgeBonus", "<font color='#F19824'>Deal an additional [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_Dagger_RuptureBonusDamage] to targets with [Key:BLEEDING_DisplayName].</font>")
	}).Register.SkillHit(function(self, e, bonuses)
		if e.Data.Success and HasActiveStatus(e.Data.Target, "BLEEDING") == 1 then
			GameHelpers.Damage.ApplySkillDamage(e.Character, e.Data.Target, "Projectile_LLWEAPONEX_MasteryBonus_Dagger_RuptureBonusDamage", {HitParams=HitFlagPresets.GuaranteedWeaponHit})
			if ObjectIsCharacter(e.Data.Target) == 1 then
				CharacterStatusText(e.Data.Target, GameHelpers.GetStringKeyText("LLWEAPONEX_RUPTURE_DisplayName", "Ruptured"))
			end
		end
	end)
})

MasteryBonusManager.AddRankBonuses(MasteryID.Dagger, 3,{
	rb:Create("DAGGER_THROWINGKNIFE2", {
		Skills = {"Projectile_FanOfKnives", "Projectile_EnemyFanOfKnives"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Dagger_ThrowingKnife2", "<font color='#F19824'>Each knife thrown has a <font color='#CC33FF'>[ExtraData:LLWEAPONEX_MB_Dagger_ThrowingKnife_Chance]%</font> to be <font color='#00FFAA'>coated in poison or explosive oil</font>, dealing [SkillDamage:Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Explosive] or [SkillDamage:Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Poison] on hit.</font>")
	}).Register.SkillHit(ThrowingKnifeBonus_Hit).SkillProjectileHit(ThrowingKnifeBonus_ProjectileHit),

	rb:Create("DAGGER_CORRUPTED_BLADE", {
		Skills = {"Target_CorruptedBlade", "Target_EnemyCorruptedBlade"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Dagger_CorruptedBlade", "<font color='#F19824'>When the target dies at any point, spread [Special:LLWEAPONEX_MB_Dagger_CorruptedStatuses] to a nearby enemy within [ExtraData:LLWEAPONEX_MB_Dagger_CorruptedBlade_SpreadRadius]m.</font>")
	}).Register.SkillHit(function(self, e, bonuses)
		if e.Data.Success then
			local listenDelay = GameHelpers.GetExtraData("LLWEAPONEX_MB_Dagger_CorruptedBlade_DeathListenDuration", -1)
			DeathManager.ListenForDeath("CorruptedBladeDiseaseSpread", e.Data.Target, e.Character, listenDelay)
		end
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Dagger, 4, {
	rb:Create("DAGGER_FATALITY", {
		Skills = {"Target_Fatality", "Target_EnemyFatality"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Dagger_FatalityBonus")
	}).Register.SkillHit(function(self, e, bonuses)
		if e.Data.Success then
			e.Data:ConvertAllDamageTo("Piercing")
			DeathManager.ListenForDeath("FatalityRefundBonus", e.Data.Target, e.Character, 1000)
		end
	end),

	rb:Create("DAGGER_CRUELTY", {
		--The corpse explosion can proc the bonus as well
		Skills = {"Target_TerrifyingCruelty", "Target_EnemyTerrifyingCruelty", "Target_EnemyTerrifyingCruelty_Gheist", 
		"Projectile_LLWEAPONEX_MasteryBonus_Dagger_CrueltyCorpseExplosion"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Dagger_CrueltyBonus")
	}).Register.SkillHit(function(self, e, bonuses)
		if e.Data.Success then
			DeathManager.ListenForDeath("TerrifyingCrueltyBonus", e.Data.Target, e.Character, 500)
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
			local skill = Ext.Stats.Get("Target_Fatality", nil, false)
			if skill["Magic Cost"] > 0 then
				CharacterAddSourcePoints(attacker, 1)
			end
			if skill.ActionPoints > 1 then
				CharacterAddActionPoints(attacker, Ext.Utils.Round(skill.ActionPoints/2))
			end
		end
	end)
	
	DeathManager.RegisterListener("TerrifyingCrueltyBonus", function(target, attacker, success)
		if success then
			local source = GameHelpers.TryGetObject(attacker)
			---@type EsvStatusExplode
			local explode = Ext.PrepareStatus(target, "EXPLODE", 6.0)
			explode.StatusSourceHandle = source.Handle
			explode.Projectile = "Projectile_LLWEAPONEX_MasteryBonus_Dagger_CrueltyCorpseExplosion"
			Ext.ApplyStatus(explode)
		end
	end)
else

end