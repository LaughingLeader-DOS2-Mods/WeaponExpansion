local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryRankBonus

MasteryBonusManager.AddRankBonuses(MasteryID.Scythe, 1, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Scythe, 2, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Scythe, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Scythe, 4, {
	
})

MasteryBonusManager.RegisterSkillListener({"Shout_Whirlwind", "Shout_EnemyWhirlwind"}, "SCYTHE_RUPTURE", function(bonuses, skill, char, state, hitData)
	if state == SKILL_STATE.HIT and hitData.Success then
		local bleedingTurns = GetStatusTurns(hitData.Target, "BLEEDING")
		if bleedingTurns ~= nil and bleedingTurns > 0 then
			local level = CharacterGetLevel(char)
			for i=bleedingTurns,1,-1 do
				GameHelpers.ExplodeProjectile(char, hitData.Target, "Projectile_LLWEAPONEX_MasteryBonus_WhirlwindRuptureBleeding")
			end
			if ObjectIsCharacter(hitData.Target) then
				local text = Text.RupteredWound.Value
				if bleedingTurns > 1 then
					text = text:gsub("%[1%]", "x"..tostring(bleedingTurns))
				else
					text = text:gsub("%[1%]", "")
				end
				CharacterStatusText(hitData.Target, text)
			end
			PrintDebug("[MasteryBonuses:WhirlwindBonus] Exploded (",bleedingTurns,") rupture projectiles on ("..hitData.Target..").")
		end
	end
end)