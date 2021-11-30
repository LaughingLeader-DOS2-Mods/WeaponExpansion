local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

MasteryBonusManager.AddRankBonuses(MasteryID.Sword, 1, {
	rb:Create("SWORD_BALANCE_SHIFT", {
		Skills = {"Target_CripplingBlow", "Target_EnemyCripplingBlow"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Sword_CripplingBlow", "<font color='#FF6624'>Targets hit deal <font color='#FF0000'>[Stats:Stats_LLWEAPONEX_MB_Sword_BalanceShift:DamageBoost]% less damage</font> until their turn ends, while you deal <font color='#33FF00'>[ExtraData:LLWEAPONEX_MB_Sword_BalanceShiftDamageBoost]% more damage to them</font> until your turn ends.</font>"),
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.HIT and data.Success then
			GameHelpers.Status.Apply(data.Target, "LLWEAPONEX_MB_SWORD_BALANCE_SHIFT", -2.0, false, char)
		end
	end):RegisterOnWeaponTagHit(MasteryID.Sword, function(tag, source, target, data, bonuses, bHitObject, isFromSkill)
		if bHitObject and data.Damage > 0 then
			if HasActiveStatus(target.MyGuid, "LLWEAPONEX_MB_SWORD_BALANCE_SHIFT") == 1 then
				local status = target:GetStatus("LLWEAPONEX_MB_SWORD_BALANCE_SHIFT")
				if status.StatusSourceHandle then
					local statusSource = GameHelpers.TryGetObject(status.StatusSourceHandle)
					if statusSource and statusSource.MyGuid == source.MyGuid then
						local damageBonus = GameHelpers.GetExtraData("LLWEAPONEX_MB_Sword_BalanceShiftDamageBoost", 10) * 0.01
						if damageBonus > 0 then
							data:MultiplyDamage(1+damageBonus)
						end
					end
				end
			end
		end
	end)
})

MasteryBonusManager.AddRankBonuses(MasteryID.Sword, 2, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Sword, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Sword, 4, {
	
})