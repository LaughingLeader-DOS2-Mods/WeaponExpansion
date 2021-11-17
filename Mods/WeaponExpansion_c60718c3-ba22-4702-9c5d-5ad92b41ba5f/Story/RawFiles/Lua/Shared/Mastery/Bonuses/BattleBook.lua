local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryRankBonus

MasteryBonusManager.AddRankBonuses(MasteryID.BattleBook, 1, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.BattleBook, 2, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.BattleBook, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.BattleBook, 4, {
	
})

MasteryBonusManager.RegisterStatusListener(StatusEvent.Applied, "RESTED", "BATTLEBOOK_FIRST_AID", function(target, status, source, bonuses)
	if bonuses.BATTLEBOOK_RESTED[source] == true then
		local turnBonus = Ext.ExtraData.LLWEAPONEX_MB_BattleBook_Rested_TurnBonus or 1
		if turnBonus > 0 then
			GameHelpers.Status.ExtendTurns(target, status, turnBonus, true, false)
		end
	end
end)

MasteryBonusManager.RegisterSkillListener({"Target_FirstAid", "Target_FirstAidEnemy"}, "BATTLEBOOK_FIRST_AID", function(bonuses, skill, char, state, data)
	if state == SKILL_STATE.CAST then
		local turnBonus = Ext.ExtraData.LLWEAPONEX_MB_BattleBook_Rested_TurnBonus or 1
		data:ForEach(function(v, targetType, skillEventData)
			if turnBonus > 0 then
				SetTag(v, "LLWEAPONEX_BattleBook_FirstAid_Active")
			end
			ApplyStatus(v, "LLWEAPONEX_MASTERYBONUS_BATTLEBOOK_FIRST_AID", 0.0, 0, char)
		end)
	end
end)

RegisterStatusListener(StatusEvent.Removed, "RESTED", function(target, status)
	ClearTag(target, "LLWEAPONEX_BattleBook_FirstAid_Active")
end)

MasteryBonusManager.RegisterSkillListener({"Target_Bless", "Target_EnemyBless"}, "BATTLEBOOK_BLESS", function(bonuses, skill, char, state, data)
	if state == SKILL_STATE.CAST then
		data:ForEach(function(v, targetType, skillEventData)
			if CharacterIsEnemy(v, char) == 1 and GameHelpers.Character.IsUndead(v) then
				GameHelpers.Damage.ApplySkillDamage(char, v, "Projectile_LLWEAPONEX_MasteryBonus_BattleBook_BlessUndeadDamage", HitFlagPresets.GuaranteedWeaponHit)
				CharacterStatusText(v, "LLWEAPONEX_StatusText_BattleBook_BlessDamage")
				RemoveStatus(v, "BLESSED")
			end
		end, 0)
	end
end)

RegisterProtectedOsirisListener("CharacterUsedItem", 2, "after", function(uuid, item)
	local character = Ext.GetCharacter(uuid)
	if MasteryBonusManager.HasMasteryBonus(character, "BATTLEBOOK_SCROLLS") and not character:HasTag("LLWEAPONEX_BattleBook_ScrollBonusAP") then
		local apBonus = Ext.ExtraData.LLWEAPONEX_MB_BattleBook_ScrollUseAPBonus or 1
		if apBonus ~= 0 then
			TurnEndRemoveTags["LLWEAPONEX_BattleBook_ScrollBonusAP"] = true
			SetTag(uuid, "LLWEAPONEX_BattleBook_ScrollBonusAP")
			CharacterAddActionPoints(uuid, apBonus)
		end
	end
end)