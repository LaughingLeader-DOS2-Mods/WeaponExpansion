if Vars.IsClient then
	local healingBonusText = Classes.TranslatedString:CreateFromKey("LLWEAPONEX_AnatomyBook_SkillBonus", "<font color='#C7A758'>[Key:WPN_UNIQUE_LLWEAPONEX_BattleBook_1H_AnatomyBook_A_DisplayName]</font><br><font color='#97FBFF'>Vitality healing increased by [ExtraData:LLWEAPONEX_AnatomyBook_HealBonusMultiplier]%.</font>")
	Tags.SkillBonusText["LLWEAPONEX_AnatomyBook_Equipped"] = function(character, skill, tag, tooltip)
		if GameHelpers.Stats.IsHealingSkill(skill, {"Vitality", "All"}) then
			return healingBonusText.Value
		end
	end
else
	local affectHealTypes = {
		Vitality = true,
		All = true
	}

	Uniques.AnatomyBook:RegisterHealListener(function(e, self)
		if e.Heal.HealAmount > 0 and affectHealTypes[e.Heal.HealType] then
			local healMult = GameHelpers.GetExtraData("LLWEAPONEX_AnatomyBook_HealBonusMultiplier", 50, false)
			if healMult > 0 then
				healMult = healMult * 0.01
				e.Heal.HealAmount = math.ceil(e.Heal.HealAmount + (e.Heal.HealAmount * healMult))
			end
		end
	end)
end