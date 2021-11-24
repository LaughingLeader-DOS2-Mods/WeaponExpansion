local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

MasteryBonusManager.AddRankBonuses(MasteryID.Unarmed, 1, {
	rb:Create("UNARMED_PETRIFYING_SLAM", {
		Skills = {"Target_PetrifyingTouch", "Target_EnemyPetrifyingTouch"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Unarmed_PetrifyingTouch", "<font color='#FFCE58'>Slam the target with your palm, knocking them back <font color='#33FF00'>[ExtraData:LLWEAPONEX_MB_Unarmed_PetrifyingTouch_KnockbackDistance]m</font> and dealing [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_PetrifyingTouchBonusDamage].</font>"),
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.CAST then
			PlayEffect(char, "RS3_FX_Char_Creatures_Condor_Cast_Warrior_01", "Dummy_R_HandFX")
			PlayEffect(char, "RS3_FX_Char_Creatures_Condor_Cast_Warrior_01", "Dummy_L_HandFX")
		elseif state == SKILL_STATE.HIT and data.Success then
			GameHelpers.Skill.Explode(data.Target, "Projectile_LLWEAPONEX_MasteryBonus_PetrifyingTouchBonusDamage", char)
			--GameHelpers.Damage.ApplySkillDamage(char, data.Target, "Projectile_LLWEAPONEX_MasteryBonus_PetrifyingTouchBonusDamage")
			local forceDistance = GameHelpers.GetExtraData("LLWEAPONEX_MB_Unarmed_PetrifyingTouch_KnockbackDistance", 4.0)
			if forceDistance > 0 then
				local x,y,z = GetPosition(data.Target)
				PlayEffectAtPosition("RS3_FX_Skills_Void_Power_Attack_Impact_01",x,y,z)
				PlayEffect(data.Target, "RS3_FX_Skills_Warrior_Impact_Weapon_01", "Dummy_BodyFX")
				GameHelpers.ForceMoveObject(char, data.Target, forceDistance, skill)
			end
		end
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Unarmed, 2, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Unarmed, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Unarmed, 4, {
	
})