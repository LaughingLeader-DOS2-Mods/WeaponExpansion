
local throwingKnifeBonuses = {
	"Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Poison",
	"Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Explosive",
}

---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param data SkillEventData|HitData|ProjectileHitData
local function ThrowingKnifeBonus(bonuses, skill, char, state, data)
	--PrintDebug("[MasteryBonuses:ThrowingKnife] char(",char,") state(",state,") data("..Ext.JsonStringify(data)..")")
	if state == SKILL_STATE.HIT and data.Success then
		local chance = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_ThrowingKnife_Chance", 25)
		if chance > 0 then
			if Ext.Random(1,100) < chance then
				GameHelpers.Skill.Explode(data.Target, Common.GetRandomTableEntry(throwingKnifeBonuses), char)
			end
		end
	--Targeted a position instead of an object
	elseif state == SKILL_STATE.PROJECTILEHIT and StringHelpers.IsNullOrEmpty(data.Target) and data.Position then
		local chance = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_ThrowingKnife_Chance", 25)
		if chance > 0 then
			if Ext.Random(1,100) < chance then
				GameHelpers.Skill.Explode(data.Position, Common.GetRandomTableEntry(throwingKnifeBonuses), char)
			end
		end
	end
end

MasteryBonusManager.RegisterSkillListener({"Projectile_ThrowingKnife", "Projectile_EnemyThrowingKnife"}, "DAGGER_THROWINGKNIFE", ThrowingKnifeBonus)
MasteryBonusManager.RegisterSkillListener({"Projectile_FanOfKnives", "Projectile_EnemyFanOfKnives"}, "DAGGER_THROWINGKNIFE2", ThrowingKnifeBonus)

--TODO Mastery Menu / Tooltip bonus text
---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param data HitData
local function BacklashBonus(bonuses, skill, char, state, data)
	if state == SKILL_STATE.HIT and HasActiveStatus(data.Target, "LLWEAPONEX_MASTERYBONUS_THROWINGKNIFE_TARGET") == 1 then
		local target = GameHelpers.TryGetObject(data.Target)
		if not target then return end
		---@type EsvStatusConsume
		local statusObject = target:GetStatus("LLWEAPONEX_MASTERYBONUS_THROWINGKNIFE_TARGET")
		local sourceObject = statusObject and GameHelpers.TryGetObject(statusObject.StatusSourceHandle) or nil
		if statusObject and sourceObject.MyGuid == char then
			RemoveStatus(data.Target, "LLWEAPONEX_MASTERYBONUS_THROWINGKNIFE_TARGET")
			local sourceSkill = CharacterHasSkill(char, "Projectile_EnemyThrowingKnife") == 1 and "Projectile_EnemyThrowingKnife" or "Projectile_ThrowingKnife"
			local apCost = Ext.StatGetAttribute(sourceSkill, "ActionPoints")
			if apCost > 1 then
				local apBonus = Ext.Round(apCost/2)
				CharacterAddActionPoints(char, apBonus)
				NRD_SkillSetCooldown(char, sourceSkill, 0)
			end
		end
	end
end

MasteryBonusManager.RegisterSkillListener({"MultiStrike_Vault", "MultiStrike_EnemyVault"}, "DAGGER_BACKLASH", BacklashBonus)

local RupturedFlags = {
	SimulateHit = 1,
	HitType = "Melee",
	HitWithWeapon = 1,
	Hit = 1,
	Blocked = 0,
	Dodged = 0,
	Missed = 0,
}

--TODO Mastery Menu / Tooltip bonus text
---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param data SkillEventData|HitData
local function SerratedRuptureBonus(bonuses, skill, char, state, data)
	if state == SKILL_STATE.HIT and HasActiveStatus(data.Target, "BLEEDING") == 1 then
		GameHelpers.Damage.ApplySkillDamage(char, "Target_LLWEAPONEX_DaggerMastery_RuptureBonusDamage", skill, RupturedFlags)
		if ObjectIsCharacter(data.Target) == 1 then
			CharacterStatusText(data.Target, GameHelpers.GetStringKeyText("LLWEAPONEX_RUPTURE_DisplayName", "Ruptured"))
		end
	end
end

MasteryBonusManager.RegisterSkillListener({"Target_SerratedEdge", "Target_EnemySerratedEdge"}, "DAGGER_RUPTURE", SerratedRuptureBonus)

--TODO Mastery Menu / Tooltip bonus text
---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param data SkillEventData|HitData
local function MortalBlowRefundBonus(bonuses, skill, char, state, data)
	if state == SKILL_STATE.HIT then
		DeathManager.ListenForDeath("MortalBlowRefundBonus", data.Target, char, 1000)
	end
end

DeathManager.RegisterListener("MortalBlowRefundBonus", function(target, attacker, success)
	if success then
		local skill = Ext.GetStat("Target_TerrifyingCruelty")
		if skill["Magic Cost"] > 0 then
			CharacterAddSourcePoints(attacker, 1)
		end
		if skill.ActionPoints > 1 then
			CharacterAddActionPoints(attacker, Ext.Round(skill.ActionPoints/2))
		end
	end
end)

MasteryBonusManager.RegisterSkillListener({"Target_Fatality", "Target_EnemyFatality"}, "DAGGER_MORTALBLOW_REFUND", MortalBlowRefundBonus)

--TODO Mastery Menu / Tooltip bonus text
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

--The corpse explosion can proc the bonus as well
MasteryBonusManager.RegisterSkillListener({"Target_TerrifyingCruelty", "Target_EnemyTerrifyingCruelty", "Target_EnemyTerrifyingCruelty_Gheist", "Projectile_LLWEAPONEX_DaggerMastery_CrueltyCorpseExplosion"}, "DAGGER_CRUELTY", function(bonuses, skill, char, state, data)
	if state == SKILL_STATE.HIT then
		DeathManager.ListenForDeath("TerrifyingCrueltyBonus", data.Target, char, 500)
	end
end)