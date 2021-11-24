local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

MasteryBonusManager.AddRankBonuses(MasteryID.Greatbow, 1, {
	rb:Create("GREATBOW_RICOCHET", {
		Skills = {"Projectile_Ricochet", "Projectile_EnemyRicochet"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Greatbow_Ricochet", "<font color='#F19824'>Eat hit deals [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_Greatbow_Ricochet] in a [Stats:Projectile_LLWEAPONEX_MasteryBonus_Greatbow_Ricochet:ExplodeRadius]m radius around the target.</font>"),
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.HIT and data.Success then
			SetTag(data.Target, "LLWEAPONEX_RicochetTarget")
			GameHelpers.Skill.Explode(data.Target, "Projectile_LLWEAPONEX_MasteryBonus_Greatbow_Ricochet", char)
			Timer.StartObjectTimer("LLWEAPONEX_MasteryBonus_ClearRicochetTarget", data.Target, 50)
		end
	end),
})

if not Vars.IsClient then
	Timer.RegisterListener("LLWEAPONEX_MasteryBonus_ClearRicochetTarget", function(timerName, char)
		if char then
			ClearTag(char, "LLWEAPONEX_RicochetTarget")
		end
	end)
end

MasteryBonusManager.AddRankBonuses(MasteryID.Greatbow, 2, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Greatbow, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Greatbow, 4, {
	
})