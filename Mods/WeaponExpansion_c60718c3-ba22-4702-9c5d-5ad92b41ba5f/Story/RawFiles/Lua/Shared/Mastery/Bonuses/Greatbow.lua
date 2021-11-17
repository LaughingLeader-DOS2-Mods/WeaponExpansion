local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryRankBonus

MasteryBonusManager.AddRankBonuses(MasteryID.Greatbow, 1, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Greatbow, 2, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Greatbow, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Greatbow, 4, {
	
})

---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param data HitData|SkillEventData
MasteryBonusManager.RegisterSkillListener({"Projectile_Ricochet", "Projectile_EnemyRicochet"}, "GREATBOW_RICOCHET", function(bonuses, skill, char, state, data)
	if state == SKILL_STATE.HIT and data.Success then
		SetTag(data.Target, "LLWEAPONEX_RicochetTarget")
		GameHelpers.ExplodeProjectile(char, data.Target, "Projectile_LLWEAPONEX_MasteryBonus_Greatbow_Ricochet")
		Timer.Start("LLWEAPONEX_MasteryBonus_ClearRicochetTarget", 50, data.Target)
	end
end)

Timer.RegisterListener("LLWEAPONEX_MasteryBonus_ClearRicochetTarget", function(_, char)
	if char then
		ClearTag(char, "LLWEAPONEX_RicochetTarget")
	end
end)

--Timer.Start("LLWEAPONEX_MasteryBonus_ClearRicochetTarget", 50, CharacterGetHostCharacter())