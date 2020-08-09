MasteryBonusManager.RegisterSkillListener({"Target_CripplingBlow", "Target_EnemyCripplingBlow"}, {"AXE_BONUSDAMAGE"}, function(bonuses, skill, char, state, hitData)
	if state == SKILL_STATE.HIT and hitData.Success then
		if GameHelpers.Status.IsDisabled(hitData.Target) then
			GameHelpers.ExplodeProjectile(char, hitData.Target, "Projectile_LLWEAPONEX_MasteryBonus_CripplingBlowPiercingDamage")
		end
	end
end)

MasteryBonusManager.RegisterSkillListener({"Shout_Whirlwind", "Shout_EnemyWhirlwind", "Shout_LLWEAPONEX_Whirlwind_Spin2", "Shout_LLWEAPONEX_Whirlwind_Spin3"}, {"AXE_SPINNING"}, function(bonuses, skill, char, state, skillData)
	if state == SKILL_STATE.CAST then
		if skill == "Shout_Whirlwind" or "Shout_EnemyWhirlwind" then
			GameHelpers.ClearActionQueue(char)
			CharacterUseSkill(char, "Shout_LLWEAPONEX_Whirlwind_Spin2", char, 0, 1, 1)
		elseif skill == "Shout_LLWEAPONEX_Whirlwind_Spin2" then
			if Ext.Random(0,100) <= 50 then
				GameHelpers.ClearActionQueue(char)
				CharacterUseSkill(char, "Shout_LLWEAPONEX_Whirlwind_Spin3", char, 0, 1, 1)
			end
		elseif skill == "Shout_LLWEAPONEX_Whirlwind_Spin3" then
			if Ext.Random(0,100) <= 25 then
				GameHelpers.ClearActionQueue(char)
				CharacterUseSkill(char, "Shout_LLWEAPONEX_Whirlwind_Spin4", char, 0, 1, 1)
			end
		end
	end
end)

MasteryBonusManager.RegisterSkillListener({"MultiStrike_BlinkStrike", "MultiStrike_EnemyBlinkStrike"}, {"AXE_VULNERABLE"}, function(bonuses, skill, char, state, hitData)
	if state == SKILL_STATE.HIT and hitData.Success then
		Mods.LeaderLib.StartTimer("LLWEAPONEX_MasteryBonus_ApplyVulnerable", 50, char, hitData.Target)
	end
end)

local function BlinkStrike_ApplyVulnerable(timerData)
	local char = timerData[1]
	local target = timerData[2]
	if char ~= nil and target ~= nil and CharacterIsDead(target) == 0 then
		if CharacterIsInCombat(char) == 1 then
			ApplyStatus(target, "LLWEAPONEX_MASTERYBONUS_VULNERABLE", -1.0, 0, char)
		else
			ApplyStatus(target, "LLWEAPONEX_MASTERYBONUS_VULNERABLE", 6.0, 0, char)
		end
	end
end

OnTimerFinished["LLWEAPONEX_MasteryBonus_ApplyVulnerable"] = BlinkStrike_ApplyVulnerable

---@param hitData HitData
MasteryBonusManager.RegisterSkillListener({"Target_HeavyAttack"}, {"AXE_ALLIN"}, function(bonuses, skill, char, state, hitData)
	if state == SKILL_STATE.HIT and hitData.Success then
		local totalPiercingDamage = 0
		for i,damageType in Data.DamageTypes:Get() do
			local damage = nil
			damage = NRD_HitStatusGetDamage(hitData.Target, hitData.Handle, damageType)
			if damage ~= nil and damage > 0 then
				totalPiercingDamage = totalPiercingDamage + (damage / 2)
				local reduced_damage = (damage/2) * -1
				NRD_HitStatusAddDamage(hitData.Target, hitData.Handle, damageType, reduced_damage)
			end
		end
		if totalPiercingDamage > 0 then
			NRD_HitStatusAddDamage(hitData.Target, hitData.Handle, "Piercing", totalPiercingDamage)
		end
	end
end)

local flurryHits = {}

---@param hitData HitData
MasteryBonusManager.RegisterSkillListener({"Target_DualWieldingAttack"}, {"AXE_FLURRY"}, function(bonuses, skill, char, state, hitData)
	if state == SKILL_STATE.HIT and hitData.Target ~= nil then
		if flurryHits[char] == nil then
			flurryHits[char] = 0
		end
		if hitData.Success then
			flurryHits[char] = flurryHits[char] + 1
		end
		local timerName = "LLWEAPONEX_Axe_FlurryCounter"..char
		LeaderLib.StartOneshotTimer(timerName, 1000, function()
			if flurryHits[char] >= 3 then
				CharacterAddActionPoints(char, 1)
				CharacterStatusText(char, "LLWEAPONEX_StatusText_FlurryAxeCombo")
			end
			flurryHits[char] = nil
		end)
	end
end)