
local affectHealTypes = {
	Vitality = true,
	All = true
}

if not Vars.IsClient then
	RegisterHealListener(function(target, source, heal, originalAmount, handle, skill, healingSourceStatus)
		if heal.HealAmount > 0
		and affectHealTypes[heal.HealType] 
		and GameHelpers.CharacterOrEquipmentHasTag(source, "LLWEAPONEX_AnatomyBook_Equipped") then
			local healMult = GameHelpers.GetExtraData("LLWEAPONEX_AnatomyBook_HealBonusMultiplier", 50, false)
			if healMult > 0 then
				healMult = healMult / 100
				heal.HealAmount = math.ceil(heal.HealAmount + (heal.HealAmount * healMult))
			end
		end
	end)
else
	local healingBonusText = Classes.TranslatedString:CreateFromKey("LLWEAPONEX_AnatomyBook_SkillBonus", "<font color='#C7A758'>[Key:WPN_UNIQUE_LLWEAPONEX_BattleBook_1H_AnatomyBook_A_DisplayName]</font><br><font color='#97FBFF'>Vitality healing increased by [ExtraData:LLWEAPONEX_AnatomyBook_HealBonusMultiplier]%.</font>")
	Tags.SkillBonusText["LLWEAPONEX_AnatomyBook_Equipped"] = function(character, skill, tag, tooltip)
		if GameHelpers.Stats.IsHealingSkill(skill, {"Vitality", "All"}) then
			return healingBonusText.Value
		end
	end
end