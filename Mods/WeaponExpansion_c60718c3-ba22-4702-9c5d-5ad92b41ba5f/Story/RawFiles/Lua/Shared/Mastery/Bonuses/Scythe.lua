local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

MasteryBonusManager.AddRankBonuses(MasteryID.Scythe, 1, {
	rb:Create("SCYTHE_RUPTURE", {
		Skills = {"Shout_Whirlwind", "Shout_EnemyWhirlwind"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Scythe_Whirlwind", "<font color='#DC143C'>Rupture</font> the wounds of <font color='#FF0000'>[Key:BLEEDING_DisplayName]</font> targets, dealing [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_WhirlwindRuptureBleeding] for each turn of <font color='#FF0000'>[Key:BLEEDING_DisplayName]</font> remaining."),
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.HIT and data.Success then
			local bleedingTurns = GetStatusTurns(data.Target, "BLEEDING")
			if bleedingTurns ~= nil and bleedingTurns > 0 then
				local level = CharacterGetLevel(char)
				for i=0,bleedingTurns do
					GameHelpers.Skill.Explode(data.TargetObject, "Projectile_LLWEAPONEX_MasteryBonus_WhirlwindRuptureBleeding", char)
				end
				if ObjectIsCharacter(data.Target) == 1 then
					local text = Text.StatusText.RupteredWound:ReplacePlaceholders(bleedingTurns)
					CharacterStatusText(data.Target, text)
				end
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