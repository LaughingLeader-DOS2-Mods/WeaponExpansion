
---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param data HitData|SkillEventData
MasteryBonusManager.RegisterSkillListener({"Projectile_Ricochet", "Projectile_EnemyRicochet"}, "GREATBOW_RICOCHET", function(bonuses, skill, char, state, data)
	if state == SKILL_STATE.HIT and data.Success then
		SetTag(data.Target, "LLWEAPONEX_RicochetTarget")
		GameHelpers.ExplodeProjectile(char, data.Target, "Projectile_LLWEAPONEX_MasteryBonus_Greatbow_Ricochet")
		LeaderLib.StartTimer("LLWEAPONEX_MasteryBonus_ClearRicochetTarget", 50, data.Target)
	end
end)

OnTimerFinished["LLWEAPONEX_MasteryBonus_ClearRicochetTarget"] = function(timerData)
	ClearTag(timerData[1], "LLWEAPONEX_RicochetTarget")
end

--LeaderLib.StartTimer("LLWEAPONEX_MasteryBonus_ClearRicochetTarget", 50, CharacterGetHostCharacter())