MasteryBonusManager.RegisterSkillListener({"Shout_RecoverArmour"}, "GUARANTEED_BLOCK", function(bonuses, skill, char, state, skillData)
	if state == SKILL_STATE.CAST then
		PlayEffect(char, "RS3_FX_GP_Impacts_Arena_PillarLight_01_Silver", "")
		ApplyStatus(char, "LLWEAPONEX_MASTERYBONUS_SHIELD_BLOCK", -1.0, 0, char)
	end
end)