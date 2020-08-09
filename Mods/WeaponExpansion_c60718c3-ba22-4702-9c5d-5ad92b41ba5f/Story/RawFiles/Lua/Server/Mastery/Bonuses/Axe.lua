MasteryBonusManager.RegisterSkillListener({"Target_CripplingBlow", "Target_EnemyCripplingBlow"}, {"AXE_BONUSDAMAGE"}, function(bonuses, skill, char, state, hitData)
	if state == SKILL_STATE.HIT and hitData.Target ~= nil then
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

MasteryBonusManager.RegisterSkillListener({"MultiStrike_BlinkStrike", "MultiStrike_EnemyBlinkStrike"}, {"AXE_VULNERABLE"}, function(bonuses, skill, char, state, skillData)
	if state == SKILL_STATE.HIT and skillData.Target ~= nil then
		Mods.LeaderLib.StartTimer("LLWEAPONEX_MasteryBonus_ApplyVulnerable", 50, char, skillData.Target)
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