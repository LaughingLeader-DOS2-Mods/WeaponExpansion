if not Vars.IsClient then
	---Tiered statuses that apply when enemies hit by Cone_LLWEAPONEX_SoulHarvest_Reap die.
	---@type string[]
	Skills.Data.SoulHarvestDamageTiers = {
		"LLWEAPONEX_SOULHARVEST_DAMAGE_BONUS1",
		"LLWEAPONEX_SOULHARVEST_DAMAGE_BONUS2",
		"LLWEAPONEX_SOULHARVEST_DAMAGE_BONUS3",
		"LLWEAPONEX_SOULHARVEST_DAMAGE_BONUS4",
		"LLWEAPONEX_SOULHARVEST_DAMAGE_BONUS5",
	}

	---@param statusTarget CharacterParam
	---@param deadCharacter CharacterParam
	local function _ApplyDamageBonus(statusTarget, deadCharacter)
		if deadCharacter then
			PlaySound(GameHelpers.GetUUID(deadCharacter), "LeaderLib_Madness_09")
		end
		local tier,lastTier = GameHelpers.Status.ApplyTieredStatus(statusTarget, Skills.Data.SoulHarvestDamageTiers, -1.0, nil, statusTarget, true)
		if tier ~= lastTier then
			EffectManager.PlayEffect("LLWEAPONEX_FX_Status_SoulHarvest_Impact_01", statusTarget, {Bone="Dummy_OverheadFX"})
		end
		SignalTestComplete("LLWEAPONEX_SoulHarvest_BuffApplied")
	end

	SkillManager.Register.Hit("Cone_LLWEAPONEX_SoulHarvest_Reap", function (e)
		if e.Data.Success and GameHelpers.Ext.ObjectIsCharacter(e.Data.TargetObject) then
			SignalTestComplete("LLWEAPONEX_SoulHarvest_SkillHit")
			local target = e.Data.TargetObject
			---@cast target EsvCharacter
			EffectManager.PlayEffect("RS3_FX_Skills_Soul_Cast_Target_Cast_LastRites_Body_01", e.Data.Target, {Bone="Dummy_BodyFX"})
			DeathManager.ListenForDeath("SoulHarvestReaping", target, e.Character, 1000)
		end
	end)

	DeathManager.RegisterListener("SoulHarvestReaping", function(target, source, targetDied)
		if targetDied then
			SignalTestComplete("LLWEAPONEX_SoulHarvest_TargetDied")
			_ApplyDamageBonus(GameHelpers.GetCharacter(source), target)
		end
	end)

	---Expire the damage bonus if the character dies, but otherwise prevent its removal
	Events.CharacterDied:Subscribe(function(e)
		local b,statusID = StatusManager.IsPermanentStatusActive(e.Character, Skills.Data.SoulHarvestDamageTiers)
		if b and statusID then
			StatusManager.RemovePermanentStatus(e.Character, Skills.Data.SoulHarvestDamageTiers)
			CharacterStatusText(e.Character.MyGuid, "LLWEAPONEX_StatusText_SoulBountyLost")
			local name = GameHelpers.GetDisplayName(e.Character)
			local statusColor = Data.Colors.FormatStringColor[Ext.Stats.Get(statusID).FormatColor] or Data.Colors.FormatStringColor.Decay
			local statusName = string.format("<font color='%s'>%s</font>", statusColor, GameHelpers.Stats.GetDisplayName(statusID, "StatusData"))
			CombatLog.AddCombatText(Text.CombatLog.SoulBountyLost:ReplacePlaceholders(name, statusName))
			SignalTestComplete("LLWEAPONEX_SoulHarvest_RemovedPermanentStatusOnDeath")
		end
	end, {MatchArgs={StateIndex=Vars.CharacterDiedState.Died}})

	WeaponExTesting.RegisterUniqueTest("harvest", function (test)
		local char,target,dummy,cleanup = WeaponExTesting.CreateTwoTemporaryCharactersAndDummy(test, nil, "Class_Shadowblade_Humans", nil, true)
		test.Cleanup = function (...)
			StatusManager.RemoveAllPermanentStatuses(char)
			DeathManager.RemoveAllDataForTarget(char)
			DeathManager.RemoveAllDataForTarget(target)
			cleanup(...)
		end
		local weapon = GameHelpers.Item.CreateItemByStat("_WPN_UNIQUE_LLWEAPONEX_Scythe_2H_SoulHarvest_A_Npc_Harvester")
		test:Wait(250)
		NRD_CharacterEquipItem(char, weapon, "Weapon", 0, 0, 1, 1)
		TeleportTo(char, target, "", 0, 1, 1)
		CharacterSetFightMode(char, 1, 1)
		SetFaction(char, "PVP_1")
		SetFaction(dummy, "PVP_1")
		SetFaction(target, "PVP_2")
		GameHelpers.Status.Apply(char, "DOUBLE_DAMAGE", -1)
		CharacterConsume(target, "Stats_Unconscious")
		SetCanFight(char, 0)
		SetCanFight(target, 0)
		test:Wait(1000)
		for i=1,5 do
			CharacterSetHitpointsPercentage(target, 1)
			test:Wait(500)
			CharacterSetArmorPercentage(target, 1)
			CharacterSetMagicArmorPercentage(target, 1)
			CharacterUseSkill(char, "Cone_LLWEAPONEX_SoulHarvest_Reap", target, 1, 1, 1)
			test:WaitForSignal("LLWEAPONEX_SoulHarvest_BuffApplied", 3000)
			test:AssertGotSignal("LLWEAPONEX_SoulHarvest_BuffApplied")
			test:Wait(1000)
			test:AssertEquals(GameHelpers.Status.IsActive(char, Skills.Data.SoulHarvestDamageTiers[i]), true, string.format("'%s' was not applied", Skills.Data.SoulHarvestDamageTiers[i]))
			if i < 5 then
				test:Wait(500)
				CharacterResurrectCustom(target, "noprepare")
				test:Wait(1000)
				CharacterConsume(target, "Stats_Unconscious")
			end
		end
		test:Wait(1000)
		CharacterDieImmediate(char, 0, "Physical", char)
		test:WaitForSignal("LLWEAPONEX_SoulHarvest_RemovedPermanentStatusOnDeath", 5000)
		test:AssertGotSignal("LLWEAPONEX_SoulHarvest_RemovedPermanentStatusOnDeath")
		return true
	end)
end