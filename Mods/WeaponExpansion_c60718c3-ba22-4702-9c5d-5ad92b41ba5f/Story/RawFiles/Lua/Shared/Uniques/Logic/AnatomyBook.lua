if Vars.IsClient then
	local healingBonusText = Classes.TranslatedString:CreateFromKey("LLWEAPONEX_AnatomyBook_SkillBonus", "<font color='#C7A758'>[Key:WPN_UNIQUE_LLWEAPONEX_BattleBook_1H_AnatomyBook_A_DisplayName]</font><br><font color='#97FBFF'>Vitality healing increased by [ExtraData:LLWEAPONEX_AnatomyBook_HealBonusMultiplier]%.</font>")
	Tags.SkillBonusText["LLWEAPONEX_AnatomyBook_Equipped"] = function(character, skill, tag, tooltip)
		if GameHelpers.Stats.IsHealingSkill(skill, {"Vitality", "All"}) then
			return healingBonusText.Value
		end
		return ""
	end
else
	Events.OnHeal:Subscribe(function(e)
		if e.Status.HealAmount > 0 and e.Source
		and Config.Status.AnatomyBookHealStats[e.HealStat]
		and GameHelpers.CharacterOrEquipmentHasTag(e.Source, Uniques.AnatomyBook.Tag) then
			local healMult = GameHelpers.GetExtraData("LLWEAPONEX_AnatomyBook_HealBonusMultiplier", 50)
			if healMult ~= 0 then
				healMult = healMult * 0.01
				e.Status.HealAmount = math.ceil(e.Status.HealAmount + (e.Status.HealAmount * healMult))
			end
		end
	end, {MatchArgs=function(e) return e.StatusId ~= "HEAL" end})
end