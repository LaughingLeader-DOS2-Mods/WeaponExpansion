local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryRankBonus

MasteryBonusManager.AddRankBonuses(MasteryID.Rapier, 1, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Rapier, 2, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Rapier, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Rapier, 4, {
	
})

---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param skillData SkillEventData|HitData
MasteryBonusManager.RegisterSkillListener(Mastery.Bonuses.LLWEAPONEX_Rapier_Mastery1.SUCKER_PUNCH_COMBO.Skills, "SUCKER_PUNCH_COMBO", function(bonuses, skill, char, state, skillData)
	if state == SKILL_STATE.CAST then
		ApplyStatus(char, "LLWEAPONEX_RAPIER_MASTERY_SUCKERCOMBO1", 12.0, 0, char)
	elseif state == SKILL_STATE.HIT and skillData.Success then
		local target = skillData.Target
		if HasActiveStatus(target, "KNOCKED_DOWN") == 1 then
			local chance = GameHelpers.GetExtraData("LLWEAPONEX_MB_Unarmed_PetrifyingTouch_KnockbackDistance", 4.0)
			if Ext.Random(0,100) <= chance then
				local handle = NRD_StatusGetHandle(target, "KNOCKED_DOWN")
				if handle ~= nil then
					local duration = NRD_StatusGetReal(target, handle, "CurrentLifeTime")
					local lastTurns = math.floor(duration / 6)
					duration = duration + 6.0
					local nextTurns = math.floor(duration / 6)
					NRD_StatusSetReal(target, handle, "CurrentLifeTime", duration)
					local text = Ext.GetTranslatedStringFromKey("LLWEAPONEX_StatusText_StatusExtended")
					if text == nil then
						text = "<font color='#99FF22' size='22'><p align='center'>[1] Extended!</p></font><p align='center'>[2] -> [3]</p>"
					end
					text = text:gsub("%[1%]", Ext.GetTranslatedStringFromKey(Ext.StatGetAttribute("KNOCKED_DOWN", "DisplayName")))
					text = text:gsub("%[2%]", lastTurns)
					text = text:gsub("%[3%]", nextTurns)
					if ObjectIsCharacter(target) == 1 then
						CharacterStatusText(target, text)
					else
						DisplayText(target, text)
					end
				end
			end
		end
	end
end)