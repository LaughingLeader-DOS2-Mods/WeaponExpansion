local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

MasteryBonusManager.AddRankBonuses(MasteryID.Greatbow, 1, {
	rb:Create("GREATBOW_RICOCHET", {
		Skills = {"Projectile_Ricochet", "Projectile_EnemyRicochet"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Greatbow_Ricochet", "<font color='#F19824'>Eat hit deals [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_Greatbow_Ricochet] in a [Stats:Projectile_LLWEAPONEX_MasteryBonus_Greatbow_Ricochet:ExplodeRadius]m radius around the target.</font>"),
	}).Register.SkillHit(function(self, e, bonuses)
		if e.Data.Success then
			SetTag(e.Data.Target, "LLWEAPONEX_RicochetTarget")
			GameHelpers.Skill.Explode(e.Data.Target, "Projectile_LLWEAPONEX_MasteryBonus_Greatbow_Ricochet", e.Character)
			Timer.StartObjectTimer("LLWEAPONEX_MasteryBonus_ClearRicochetTarget", e.Data.Target, 50)
		end
	end).TimerFinished("LLWEAPONEX_MasteryBonus_ClearRicochetTarget", function (self, e, bonuses)
		if e.Data.UUID then
			ClearTag(e.Data.UUID, "LLWEAPONEX_RicochetTarget")
		end
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Greatbow, 2, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Greatbow, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Greatbow, 4, {
	
})