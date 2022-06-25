local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

MasteryBonusManager.AddRankBonuses(MasteryID.Rapier, 1, {
	rb:Create("RAPIER_SUCKER_PUNCH_COMBO", {
		Skills = {"Target_SingleHandedAttack", "Target_LLWEAPONEX_SinglehandedAttack"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Rapier_SuckerPunch", "Gain a follow-up combo skill ([Key:Target_LLWEAPONEX_Rapier_SuckerCombo1_DisplayName]) after punching a target.<br><font color='#99FF22' size='22'>[ExtraData:LLWEAPONEX_MB_Unarmed_SuckerPunch_KnockdownTurnExtensionChance]% chance to increase Knockdown by 1 turn.</font>"),
	}).Register.SkillCast(function(self, e, bonuses)
		GameHelpers.Status.Apply(e.Character, "LLWEAPONEX_RAPIER_MASTERY_SUCKERCOMBO1", 12.0, 0, e.Character)
	end).SkillHit(function(self, e, bonuses)
		if e.Data.Success then
			local target = e.Data.TargetObject
			local status = target:GetStatus("KNOCKED_DOWN")
			if status then
				local chance = GameHelpers.GetExtraData("LLWEAPONEX_MB_Rapier_SuckerPunch_KnockdownTurnExtensionChance", 25)
				if GameHelpers.Math.Roll(chance) then
					local duration = status.CurrentLifeTime
					local lastTurns = math.floor(duration / 6)
					duration = duration + 6.0
					local nextTurns = math.floor(duration / 6)
					status.CurrentLifeTime = duration
					status.RequestClientSync = true
					local statusName = GameHelpers.GetStringKeyText(Ext.StatGetAttribute("KNOCKED_DOWN", "DisplayName"), "Knocked Down")
					local text = Text.StatusText.StatusExtended:ReplacePlaceholders(statusName, lastTurns, nextTurns)
					if GameHelpers.Ext.ObjectIsCharacter(target) then
						CharacterStatusText(target, text)
					else
						DisplayText(target, text)
					end
				end
			end
		end
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Rapier, 2, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Rapier, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Rapier, 4, {
	
})