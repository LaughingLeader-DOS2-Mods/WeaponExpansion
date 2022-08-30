local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

SkillConfiguration.Rapiers = {
	FrenzyChargeStatuses = {
		"LLWEAPONEX_RAPIER_FRENZYCHARGE1",
		"LLWEAPONEX_RAPIER_FRENZYCHARGE2",
		"LLWEAPONEX_RAPIER_FRENZYCHARGE3",
		"LLWEAPONEX_RAPIER_FRENZYCHARGE4",
	}
}

MasteryBonusManager.AddRankBonuses(MasteryID.Rapier, 1, {
	rb:Create("RAPIER_SUCKER_PUNCH_COMBO", {
		Skills = {"Target_SingleHandedAttack", "Target_LLWEAPONEX_SinglehandedAttack"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Rapier_SuckerPunch", "Gain a follow-up combo skill ([Key:Target_LLWEAPONEX_Rapier_SuckerCombo1_DisplayName]) after punching a target.<br><font color='#99FF22' size='22'>[ExtraData:LLWEAPONEX_MB_Unarmed_SuckerPunch_KnockdownTurnExtensionChance]% chance to increase Knockdown by 1 turn.</font>"),
	}).Register.SkillCast(function(self, e, bonuses)
		GameHelpers.Status.Apply(e.Character, "LLWEAPONEX_RAPIER_MASTERY_SUCKERCOMBO1", 12.0, false, e.Character)
	end).SkillHit(function(self, e, bonuses)
		if e.Data.Success then
			local target = e.Data.TargetObject
			local status = target:GetStatusByType("KNOCKED_DOWN")
			if status then
				if status.CurrentLifeTime > 0 then
					local chance = GameHelpers.GetExtraData("LLWEAPONEX_MB_Rapier_SuckerPunch_KnockdownTurnExtensionChance", 25)
					if GameHelpers.Math.Roll(chance) then
						local duration = status.CurrentLifeTime
						local lastTurns = math.floor(duration / 6)
						duration = duration + 6.0
						local nextTurns = math.floor(duration / 6)
						status.CurrentLifeTime = duration
						status.RequestClientSync = true
						local statusName = GameHelpers.Stats.GetDisplayName(status.StatusId, "StatusData")
						local text = Text.StatusText.StatusExtended:ReplacePlaceholders(statusName, lastTurns, nextTurns)
						if GameHelpers.Ext.ObjectIsCharacter(target) then
							CharacterStatusText(target.MyGuid, text)
						else
							DisplayText(target.MyGuid, text)
						end
					end
					GameHelpers.Status.Apply(target, "LLWEAPONEX_RAPIER_MASTERY_DELAYED_DAZED", status.CurrentLifeTime + 1.0, true, e.Character)
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


if not Ext.IsClient() then
	local _ActiveRapierRequiredStatuses = {
		"LLWEAPONEX_RAPIER_MASTERY_SUCKERCOMBO1",
		"LLWEAPONEX_RAPIER_MASTERY_SUCKERCOMBO2",
		"LLWEAPONEX_RAPIER_MASTERY_DUELIST_BONUS",
	}

	Mastery.Events.MasteryChanged:Subscribe(function (e)
		if not e.Enabled then
			StatusManager.RemovePermanentStatus(e.Character, "LLWEAPONEX_RAPIER_MASTERY_STANCE_DUELIST")
			GameHelpers.Status.Remove(e.Character, _ActiveRapierRequiredStatuses)
			GameHelpers.Status.Remove(e.Character, SkillConfiguration.Rapiers.FrenzyChargeStatuses)
			CharacterRemoveSkill(e.CharacterGUID, "Target_LLWEAPONEX_SinglehandedAttack")
		end
	end, {MatchArgs={ID=MasteryID.Rapier}})

	EquipmentManager.Events.EquipmentChanged:Subscribe(function (e)
		if e.Character:GetStatus("LLWEAPONEX_RAPIER_MASTERY_STANCE_DUELIST") then
			Timer.StartObjectTimer("LLWEAPONEX_Rapier_CheckForEmptyHand", e.Character, 250)
		end
	end)

	Timer.Subscribe("LLWEAPONEX_Rapier_CheckForEmptyHand", function (e)
		local character = e.Data.Object
		if character then
			---@cast character EsvCharacter
			if HasEmptyHand(character, false) then
				local wasEnabled = ObjectGetFlag(character.MyGuid, "LLWEAPONEX_DuelistStanceWasEnabled") == 1
				if wasEnabled then
					StatusManager.ApplyPermanentStatus(character, "LLWEAPONEX_RAPIER_MASTERY_STANCE_DUELIST", character)
				end
			else
				if GameHelpers.Status.IsActive(character, "LLWEAPONEX_RAPIER_MASTERY_STANCE_DUELIST") then
					ObjectSetFlag(character.MyGuid, "LLWEAPONEX_DuelistStanceWasEnabled", 0)
					CharacterStatusText(character.MyGuid, "LLWEAPONEX_Status_DuelistStance_Warning")
					StatusManager.RemovePermanentStatus(character, "LLWEAPONEX_RAPIER_MASTERY_STANCE_DUELIST")
				end
			end
		end
	end)

	SkillManager.Register.Cast("Shout_LLWEAPONEX_Rapier_DuelistStance", function (e)
		StatusManager.TogglePermanentStatus(e.Character, "LLWEAPONEX_RAPIER_MASTERY_STANCE_DUELIST", e.Character)
	end)

	---Called when a basic attacks or weapon skills has a critical hit
	---@param attacker EsvCharacter
	---@param target EsvCharacter|EsvItem
	function SkillConfiguration.Rapiers.OnWeaponCriticalHit(attacker, target)
		GameHelpers.Status.Apply(attacker, "LLWEAPONEX_RAPIER_MASTERY_STANCE_DUELIST", 12, false, attacker)
		CharacterStatusText(attacker.MyGuid, "LLWEAPONEX_Skills_DuelistStance_Bonus")
	end

	Events.OnWeaponTagHit:Subscribe(function (e)
		SkillConfiguration.Rapiers.OnWeaponCriticalHit(e.Attacker, e.Target)
	end,{
		---@param _e OnWeaponTagHitEventArgs
		MatchArgs = function(_e)
			return (_e.Tag == "LLWEAPONEX_Rapier_Equipped" and _e.TargetIsObject and _e.Data:HasHitFlag("CriticalHit", true)
			and _e.Attacker:GetStatus("LLWEAPONEX_RAPIER_MASTERY_STANCE_DUELIST"))
		end
	})

	--#region Sucker Punch Combo
	SkillManager.Register.Hit("Target_LLWEAPONEX_Rapier_SuckerCombo2", function (e)
		--GameHelpers.Status.Remove(e.Character, "LLWEAPONEX_RAPIER_MASTERY_SUCKERCOMBO2")
		GameHelpers.Skill.SetCooldown(e.Character, "Target_SingleHandedAttack", 0)
		if e.Data.Success and GameHelpers.Status.HasStatusType(e.Data.TargetObject, "KNOCKED_DOWN") then
			GameHelpers.Status.Apply(e.Data.TargetObject, "LLWEAPONEX_RAPIER_MASTERY_SUCKERCOMBO2_FLYING", 1, true, e.Character)
			GameHelpers.ForceMoveObject(e.Character, e.Data.TargetObject, 3, e.Skill, nil, nil, "LLWEAPONEX_RapierSuckerPunch")
		end
	end)

	--Flying body collides with a character or item
	StatusManager.Subscribe.Applied("LLWEAPONEX_RAPIER_MASTERY_SUCKERCOMBO2_FLYING_CHECK", function (e)
		local flyingStatus = e.Source and e.Source:GetStatus("LLWEAPONEX_RAPIER_MASTERY_SUCKERCOMBO2_FLYING")
		if flyingStatus then
			local attacker = GameHelpers.GetCharacter(flyingStatus.StatusSourceHandle)
			if attacker and GameHelpers.Character.CanAttackTarget(e.Target, attacker, true) then
				GameHelpers.Damage.ApplySkillDamage(attacker, e.Target, "Projectile_LLWEAPONEX_Status_Rapier_SuckerCombo2_FlyingDamage")
				GameHelpers.Damage.ApplySkillDamage(attacker, e.Source, "Projectile_LLWEAPONEX_Status_Rapier_SuckerCombo2_FlyingDamage")
			end
		end
	end)

	Events.ForceMoveFinished:Subscribe(function (e)
		GameHelpers.Status.Remove(e.Target, "LLWEAPONEX_RAPIER_MASTERY_SUCKERCOMBO2_FLYING")
	end, {MatchArgs={ID="LLWEAPONEX_RapierSuckerPunch"}})

	StatusManager.Subscribe.RemovedType("KNOCKED_DOWN", function (e)
		local delayedDizzy = e.Target:GetStatus("LLWEAPONEX_RAPIER_MASTERY_DELAYED_DAZED")
		if delayedDizzy then
			local source = GameHelpers.TryGetObject(delayedDizzy.StatusSourceHandle)
			GameHelpers.Status.Apply(e.Target, "LLWEAPONEX_DIZZY", 12, true, source)
		end
	end)
	--#endregion

	--#region Frenzy
	SkillManager.Register.Hit({"MultiStrike_LLWEAPONEX_Rapier_FlickerStrike", "MultiStrike_LLWEAPONEX_Rapier_FlickerStrike_Enemy"}, function (e)
		Timer.Cancel("LLWEAPONEX_Rapier_FlickerStrike_CheckForContinue", e.Character)
		if e.Data.Success then
			local totalJumps = PersistentVars.SkillData.FlickerStrikeTotalJumps[e.CharacterGUID] or 0
			totalJumps = totalJumps + 1
			PersistentVars.SkillData.FlickerStrikeTotalJumps[e.CharacterGUID] = totalJumps
			local maxJumps = GameHelpers.GetExtraData("LLWEAPONEX_Rapier_FlickerStrikeMaxJumps", 6, true)
			if totalJumps < maxJumps then
				Timer.StartObjectTimer("LLWEAPONEX_Rapier_FlickerStrike_CheckForContinue", e.Character, 500)
			else
				PersistentVars.SkillData.FlickerStrikeTotalJumps[e.CharacterGUID] = nil
			end
			local chance = GameHelpers.GetExtraData("LLWEAPONEX_Rapier_FrenzyChargeChancePerHit", 50)
			if chance > 0 and GameHelpers.Math.Roll(chance) then
				GameHelpers.Status.Apply(e.Character, "LLWEAPONEX_RAPIER_FRENZYCHARGE_APPLY", 6.0, false, e.Character)
			end
		end
	end)

	---@param character EsvCharacter
	---@return integer|false
	local function _RemoveFrenzyCharge(character)
		local len = #SkillConfiguration.Rapiers.FrenzyChargeStatuses
		for i=len,1,-1 do
			local id = SkillConfiguration.Rapiers.FrenzyChargeStatuses[i]
			local status = character:GetStatus(id)
			if status then
				GameHelpers.Status.Remove(character, id)
				if i > 1 then
					local nextStatus = SkillConfiguration.Rapiers.FrenzyChargeStatuses[i-1]
					if nextStatus then
						GameHelpers.Status.Apply(character, nextStatus, 6.0, true, character)
					end
				end
				return i
			end
		end
		return false
	end

	Timer.Subscribe("LLWEAPONEX_Rapier_FlickerStrike_CheckForContinue", function (e)
		if e.Data.UUID then
			local success = false
			local character = e.Data.Object
			---@cast character EsvCharacter
			if not GameHelpers.ObjectIsDead(character) and _RemoveFrenzyCharge(character) then
				local flickerSkill = Ext.Stats.Get("MultiStrike_LLWEAPONEX_Rapier_FlickerStrike")
				local radius = flickerSkill.TargetRadius
				local targets = GameHelpers.Grid.GetNearbyObjects(character,
				{
					Relation={Enemy=true},
					Radius=radius,
					Sort="Distance",
					Type="Character",
					AsTable=true
				})
				---@cast targets EsvCharacter[]
				local target = targets[1]
				if target then
					success = true
					local targetGUID = target.MyGuid
					local characterGUID = character.MyGuid
					Osi.LeaderLib_Behavior_TeleportTo(characterGUID, targetGUID)
					CharacterLookAt(characterGUID, targetGUID, 1)
					local skillParamOverrides = nil
					local reduction = GameHelpers.GetExtraData("LLWEAPONEX_Rapier_FlickerStrikeBonusDamageReduction", 20)
					if reduction > 0 then
						local damageMult = flickerSkill["Damage Multiplier"] - reduction
						skillParamOverrides = {["Damage Multiplier"] = damageMult}
					end
					EffectManager.PlayEffect("RS3_FX_Skills_Warrior_BlinkStrike_Cast_01", character)
					EffectManager.PlayEffect("RS3_FX_Skills_Warrior_BlinkStrike_Impact_01", target)
					GameHelpers.Damage.ApplySkillDamage(character, target, "MultiStrike_LLWEAPONEX_Rapier_FlickerStrike", {SkillDataParamModifiers=skillParamOverrides, InvokeSkillHitListeners=true})
				end
			end
			if not success then
				EffectManager.PlayEffect("RS3_FX_Skills_Warrior_BlinkStrike_Reappear_01", character)
				PersistentVars.SkillData.FlickerStrikeTotalJumps[character.MyGuid] = nil
			end
		end
	end)
	--#endregion
end