local removeSkills = {
	Target_LLWEAPONEX_Pistol_Shoot = true,
	Projectile_LLWEAPONEX_Pistol_Shoot_LeftHand = true,
	Projectile_LLWEAPONEX_Pistol_Shoot_RightHand = true,
	Shout_LLWEAPONEX_Prepare_BalrinsAxe = true,
}

---@param last integer
---@param next integer
RegisterModListener("Loaded", ModuleUUID, function(last, next)
	print("[LLWEAPONEX:Loaded]", last, "=>", next)
	if last < 152764417 then
		ItemLockUnEquip("40039552-3aae-4beb-8cca-981809f82988", 0)
		ItemToInventory("40039552-3aae-4beb-8cca-981809f82988", "80976258-a7a5-4430-b102-ba91a604c23f")
		ItemLockUnEquip("927669c3-b885-4b88-a0c2-6825fbf11af2", 0)
		ItemToInventory("927669c3-b885-4b88-a0c2-6825fbf11af2", "80976258-a7a5-4430-b102-ba91a604c23f")
	end

	if last < 268435456 then
		pcall(function()
			local oldDB = Osi.DB_LLWEAPONEX_BattleBooks_ReadBooks:Get(nil,nil)
			if oldDB then
				--Moved to PersistentVars
				for _,db in pairs(Osi.DB_LLWEAPONEX_BattleBooks_ReadBooks:Get(nil,nil)) do
					local playerGUID,template = table.unpack(db)
					if playerGUID and template then
						playerGUID = StringHelpers.GetUUID(playerGUID)
						template = StringHelpers.GetUUID(template)
						if GameHelpers.Character.IsPlayer(playerGUID) then
							if not PersistentVars.BattleBookExperienceGranted[playerGUID] then
								PersistentVars.BattleBookExperienceGranted[playerGUID] = {}
							end
							PersistentVars.BattleBookExperienceGranted[playerGUID][template] = true
						end
					end
				end
				Osi.DB_LLWEAPONEX_BattleBooks_ReadBooks:Delete(nil,nil)
			end
		end)
	end

	for player in GameHelpers.Character.GetPlayers() do
		EquipmentManager.CheckWeaponRequirementTags(player)
		if HasActiveStatus(player.MyGuid, "LLWEAPONEX_UNARMED_LIZARD_DEBUFF") == 1 then
			GameHelpers.Status.Remove(player.MyGuid, "LLWEAPONEX_UNARMED_LIZARD_DEBUFF")
		end

		Osi.PROC_StopLoopEffect(player.MyGuid, "LLWEAPONEX.FX.Quiver")

		if IsTagged(player.MyGuid, "LLWEAPONEX_Quiver_Equipped") == 1 and last < 153026560 then
			local quiver = CharacterGetEquippedItem(player.MyGuid, "Belt")
			if quiver ~= nil then
				ItemResetChargesToMax(quiver)
			end
			if CharacterIsInCombat(player.MyGuid) == 0 then
				Quiver_RemoveTempArrows(player.MyGuid)
			end
		end

		if last < 153157632 then
			for i,v in pairs(player:GetInventoryItems()) do
				local item = GameHelpers.GetItem(v)
				if item ~= nil then
					-- Musketeer firearms were auto-tagged with crossbow previously
					if item:HasTag("LLWEAPONEX_TaggedWeaponType") and item:HasTag("LLWEAPONEX_Firearm") and item:HasTag("LLWEAPONEX_Crossbow") then
						ClearTag(item.MyGuid, "LLWEAPONEX_Crossbow")
					end
					if IsTagged(v, "LLWEAPONEX_Blunt") == 1 then
						ClearTag(v, "LLWEAPONEX_Blunt")
						SetTag(v, "LLWEAPONEX_Bludgeon")
					end
				end
			end
		end

		-- Deprecated skill
		for id,b in pairs(removeSkills) do
			if player.SkillManager.Skills[id] then
				CharacterRemoveSkill(player.MyGuid, id)
			end
		end

		-- Fix for Balrin's Axe disappearing due to unforseen consequences
		-- May need some additional checks
		if not GameHelpers.IsInCombat(player) then
			SkillConfiguration.BalrinAxe.Calls.EquipBalrinAxe(player)
		end
	end
	
	Osi.LeaderLib_Statuses_Clear_PermanentStatus("WeaponExpansion", "LLWEAPONEX_ARMCANNON_CHARGED")

	--Old Combat Shield deltamods
	Osi.DB_LeaderLib_Deltamods_Groups:Delete("WeaponExpansion.CombatShields", nil)
	Osi.DB_LeaderLib_Deltamods_MaxGuaranteedDeltamods:Delete("WeaponExpansion.CombatShields", nil)
	Osi.DB_LeaderLib_Deltamods_WithChance:Delete("WeaponExpansion.CombatShields", nil, nil, nil, nil, nil)

	--Deprecated databases
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Statuses_TormentDebuff", 4)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_DualShields_CombatShieldGenerator", 3)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_DualShields_Templates", 2)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Equipment_TrackedItems", 2)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Equipment_ActiveTags", 3)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_WeaponMastery_Temp_ActiveMasteries", 3)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_WeaponMastery_Temp_DeactivatedMasteries", 3)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Greatbows_PrepareFX", 5)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Greatbows_TemplateToID", 2)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Greatbows_CushionForce_DistanceDamage", 3)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Greatbows_CushionForce_FallDamage", 3)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Greatbows_CushionForce_ForceDistance", 3)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Greatbows_CushionForce_Temp_ForceResolved", 2)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Greatbows_Temp_CushionForce_Landing", 8)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Greatbows_Temp_Equipped", 3)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Uniques_Temp_ArmCannonEquipped", 2)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Blunderbuss_Temp_Duds_SkipTurn", 1)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Blunderbuss_Temp_Duds", 3)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_HandCrossbow_ShootingSkills", 1)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Quivers_LoopFX", 4)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Quivers_ArrowTreasure", 2)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Quivers_RechargeStatus", 3)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Rapiers_FrenzyCharge", 1)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Katanas_ComboStatus", 2)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Katanas_ComboFinisher", 2)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_ThrowingMastery_Temp_ListenForSkill", 3)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_ThrowingMastery_ThrowingSkills", 2)

	Osi.DB_LeaderLib_Skills_StatusToggleSkills:Delete("Shout_LLWEAPONEX_Rapier_DuelistStance", nil, nil, nil, nil)
	Osi.LeaderLib_Statuses_Clear_Group("WeaponExpansion")

	Osi.LeaderLib_ToggleScripts_Clear_ByGoal("LLWEAPONEX_80_TS_01_WM_Greatbow")
	Osi.LeaderLib_ToggleScripts_Clear_ByGoal("LLWEAPONEX_80_TS_01_WM_Rapier")
	Osi.LeaderLib_ToggleScripts_Clear_ByGoal("LLWEAPONEX_80_TS_03_WeaponFX")
	Osi.LeaderLib_ToggleScripts_Clear_ByGoal("LLWEAPONEX_80_TS_02_ThrowingListener")
	Osi.LeaderLib_ToggleScripts_Clear_ByGoal("LLWEAPONEX_80_TS_08_Quivers")
	Osi.LeaderLib_ToggleScripts_Clear_ByGoal("LLWEAPONEX_80_TS_10_BattleBook_SpellScroll")
	Osi.LeaderLib_ToggleScripts_Clear_ByGoal("LLWEAPONEX_80_TS_10_DemonGauntlet")
	Osi.LeaderLib_ToggleScripts_Clear_ByGoal("LLWEAPONEX_80_TS_10_DemolitionBackpack")
	Osi.LeaderLib_ToggleScripts_Clear_ByGoal("LLWEAPONEX_80_TS_10_AnvilMace")
	Osi.LeaderLib_ToggleScripts_Clear_ByGoal("LLWEAPONEX_80_TS_10_PowerGauntlets")
	Osi.LeaderLib_ToggleScripts_Clear_ByGoal("LLWEAPONEX_80_TS_10_BasilusDagger")
	Osi.LeaderLib_ToggleScripts_Clear_ByGoal("LLWEAPONEX_80_TS_11_Blunderbuss")
	Osi.LeaderLib_ToggleScripts_Clear_ByGoal("LLWEAPONEX_80_TS_12_HunkerDown")
	Osi.LeaderLib_ToggleScripts_Clear_ByGoal("LLWEAPONEX_80_TS_12_ShieldCover")
	Osi.LeaderLib_ToggleScripts_Clear_ByGoal("LLWEAPONEX_80_TS_12_UnrelentingRage")
	Osi.LeaderLib_ToggleScripts_Clear_ByGoal("LLWEAPONEX_80_TS_20_ListenForTurnEnding")
	Osi.LeaderLib_ToggleScripts_Clear_ByGoal("LLWEAPONEX_80_TS_20_ListenForStatusRemoval")
	Osi.LeaderLib_ToggleScripts_Clear_ByGoal("LLWEAPONEX_80_TS_60_UniqueManager")
	Osi.LeaderLib_ToggleScripts_Clear_ByGoal("LLWEAPONEX_80_TS_69_BlockHealing")
	Osi.LeaderLib_ToggleScripts_Clear_ByGoal("LLWEAPONEX_80_TS_10_BasilusDagger")
	Osi.LeaderLib_ToggleScripts_Clear_ByGoal("LLWEAPONEX_80_TS_11_Blunderbuss")
end)