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