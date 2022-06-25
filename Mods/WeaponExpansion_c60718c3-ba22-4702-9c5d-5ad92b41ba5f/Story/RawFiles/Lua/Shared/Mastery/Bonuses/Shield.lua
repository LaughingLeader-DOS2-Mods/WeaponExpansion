local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

MasteryBonusManager.AddRankBonuses(MasteryID.Shield, 1, {
	rb:Create("SHIELD_GUARANTEED_BLOCK", {
		Skills = {"Shout_RecoverArmour"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Shield_RecoverArmourBonus", "Damage from the next direct hit taken is reduced by <font color='#33FF00'>[ExtraData:LLWEAPONEX_MB_Shield_RecoverArmour_DamageReduction]%</font>."),
	}).Register.SkillCast(function(self, e, bonuses)
		EffectManager.PlayEffectAt("RS3_FX_GP_Impacts_Arena_PillarLight_01_Silver", e.Character.WorldPos)
		GameHelpers.Status.Apply(e.Character, "LLWEAPONEX_MASTERYBONUS_SHIELD_BLOCK", -1.0, 0, e.Character)
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Shield, 2, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Shield, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Shield, 4, {
	
})