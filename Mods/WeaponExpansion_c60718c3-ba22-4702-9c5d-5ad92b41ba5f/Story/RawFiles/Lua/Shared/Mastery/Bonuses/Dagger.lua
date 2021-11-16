
local throwingKnifeBonuses = {
	"Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Poison",
	"Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Explosive",
}

local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryRankBonus

local throwingKnifeBonus = rb:Create("DAGGER_THROWINGKNIFE", {
	Skills = {"Projectile_ThrowingKnife", "Projectile_EnemyThrowingKnife"},
	Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Dagger_ThrowingKnife")
})

---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param data SkillEventData|HitData|ProjectileHitData
local function ThrowingKnifeBonusLogic(bonuses, skill, char, state, data)
	--PrintDebug("[MasteryBonuses:ThrowingKnife] char(",char,") state(",state,") data("..Ext.JsonStringify(data)..")")
	if state == SKILL_STATE.HIT and data.Success then
		local chance = GameHelpers.GetExtraData("LLWEAPONEX_MB_Dagger_ThrowingKnife_Chance", 25)
		if chance > 0 then
			if Ext.Random(1,100) < chance then
				GameHelpers.Skill.Explode(data.Target, Common.GetRandomTableEntry(throwingKnifeBonuses), char)
			end
		end
	--Targeted a position instead of an object
	elseif state == SKILL_STATE.PROJECTILEHIT and StringHelpers.IsNullOrEmpty(data.Target) and data.Position then
		local chance = GameHelpers.GetExtraData("LLWEAPONEX_MB_Dagger_ThrowingKnife_Chance", 25)
		if chance > 0 then
			if Ext.Random(1,100) < chance then
				GameHelpers.Skill.Explode(data.Position, Common.GetRandomTableEntry(throwingKnifeBonuses), char)
			end
		end
	end
end

throwingKnifeBonus:RegisterSkillListener(ThrowingKnifeBonusLogic)

MasteryBonusManager.AddRankBonuses(MasteryID.Dagger, 1, throwingKnifeBonus)

local RupturedFlags = {
	SimulateHit = 1,
	HitType = "Melee",
	HitWithWeapon = 1,
	Hit = 1,
	Blocked = 0,
	Dodged = 0,
	Missed = 0,
}

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
				RemoveStatus(data.Target, "LLWEAPONEX_MASTERYBONUS_THROWINGKNIFE_TARGET")
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
			GameHelpers.Damage.ApplySkillDamage(char, "Target_LLWEAPONEX_DaggerMastery_RuptureBonusDamage", skill, RupturedFlags)
			if ObjectIsCharacter(data.Target) == 1 then
				CharacterStatusText(data.Target, GameHelpers.GetStringKeyText("LLWEAPONEX_RUPTURE_DisplayName", "Ruptured"))
			end
		end
	end)
})

MasteryBonusManager.AddRankBonuses(MasteryID.Dagger, 3, rb:Create("DAGGER_THROWINGKNIFE2", {
	Skills = {"Projectile_FanOfKnives", "Projectile_EnemyFanOfKnives"},
	Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Dagger_ThrowingKnife2")
}):RegisterSkillListener(ThrowingKnifeBonusLogic))

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

if not Vars.IsClient then
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
end