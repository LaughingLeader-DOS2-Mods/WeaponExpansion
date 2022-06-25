local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

MasteryBonusManager.AddRankBonuses(MasteryID.Scythe, 1, {
	rb:Create("SCYTHE_RUPTURE", {
		Skills = {"Shout_Whirlwind", "Shout_EnemyWhirlwind"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Scythe_Whirlwind", "<font color='#DC143C'>Rupture</font> the wounds of <font color='#FF0000'>[Key:BLEEDING_DisplayName]</font> targets, dealing [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_WhirlwindRuptureBleeding] for each turn of <font color='#FF0000'>[Key:BLEEDING_DisplayName]</font> remaining."),
	}).Register.SkillHit(function(self, e, bonuses)
		if e.Data.Success and GameHelpers.Ext.ObjectIsCharacter(e.Data.TargetObject) then
			local bleedingTurns = GetStatusTurns(e.Data.Target, "BLEEDING")
			if bleedingTurns ~= nil and bleedingTurns > 0 then
				for i=0,bleedingTurns do
					GameHelpers.Skill.Explode(e.Data.TargetObject, "Projectile_LLWEAPONEX_MasteryBonus_WhirlwindRuptureBleeding", e.Character)
				end
				local text = Text.StatusText.RupteredWound:ReplacePlaceholders(bleedingTurns)
				CharacterStatusText(e.Data.Target, text)
			end
		end
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Scythe, 2, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Scythe, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Scythe, 4, {
	
})