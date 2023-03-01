local removeSkills = {
	Target_LLWEAPONEX_Pistol_Shoot = true,
	Projectile_LLWEAPONEX_Pistol_Shoot_LeftHand = true,
	Projectile_LLWEAPONEX_Pistol_Shoot_RightHand = true,
	Shout_LLWEAPONEX_Prepare_BalrinsAxe = true,
}

function MasterySystem.MigrateMasteryExperience()
	local migratedData = false
	for _,db in pairs(Osi.DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience:Get(nil,nil,nil,nil)) do
		local guid,mastery,level,experience = table.unpack(db)
		---@cast guid string
		---@cast mastery string
		---@cast level integer
		---@cast experience integer
		guid = StringHelpers.GetUUID(guid)
		local player = GameHelpers.GetCharacter(guid)
		if player then
			if PersistentVars.MasteryExperience[guid] == nil then
				PersistentVars.MasteryExperience[guid] = {}
			end
			local masteryData = PersistentVars.MasteryExperience[guid] --[[@as MasteryExperienceData]]
			if masteryData[mastery] == nil or level > masteryData.Level then
				masteryData[mastery] = {
					Experience = experience,
					Level = level
				}
				migratedData = true
			end
		end
	end
	Osi.DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience:Delete(nil,nil,nil,nil)
	if migratedData then
		fprint(LOGLEVEL.TRACE, "[WeaponExpansion] Migrated mastery experience to lua:")
		fprint(LOGLEVEL.TRACE, Ext.DumpExport(PersistentVars.MasteryExperience))
	end
end

---@param last integer
---@param next integer
RegisterModListener("Loaded", ModuleUUID, function(last, next)
	print("[LLWEAPONEX:Loaded]", last, "=>", next)
	if last < 152764417 then
		ItemLockUnEquip("40039552-3aae-4beb-8cca-981809f82988", 0)
		ItemToInventory("40039552-3aae-4beb-8cca-981809f82988", "80976258-a7a5-4430-b102-ba91a604c23f", 1, 0, 0)
		ItemLockUnEquip("927669c3-b885-4b88-a0c2-6825fbf11af2", 0)
		ItemToInventory("927669c3-b885-4b88-a0c2-6825fbf11af2", "80976258-a7a5-4430-b102-ba91a604c23f", 1, 0, 0)
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

	if last < 268435456 or Vars.LeaderDebugMode then
		if not PersistentVars.MasteryExperience then
			Events.PersistentVarsLoaded:Subscribe(function (e)
				MasterySystem.MigrateMasteryExperience()
			end, {Once=true, Priority=0})
		else
			MasterySystem.MigrateMasteryExperience()
		end
	end

	for player in GameHelpers.Character.GetPlayers(false, false, "EsvCharacter") do
		EquipmentManager:CheckWeaponRequirementTags(player)
		if HasActiveStatus(player.MyGuid, "LLWEAPONEX_UNARMED_LIZARD_DEBUFF") == 1 then
			GameHelpers.Status.Remove(player.MyGuid, "LLWEAPONEX_UNARMED_LIZARD_DEBUFF")
		end

		Osi.PROC_StopLoopEffect(player.MyGuid, "LLWEAPONEX.FX.Quiver")

		if player:HasTag("LLWEAPONEX_Quiver_Equipped") and last < 153026560 then
			for quiver in GameHelpers.Character.GetTaggedItems(player, "LLWEAPONEX_Quiver_Equipped") do
				ItemResetChargesToMax(quiver.MyGuid)
			end
			if not GameHelpers.Character.IsInCombat(player) then
				Config.Skill.Quivers.RemoveTempArrows(player)
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
			Config.Skill.BalrinAxe.Calls.EquipBalrinAxe(player)
		end
	end

	--[[ local revenantsDB = GameHelpers.DB.Get("DB_LLWEAPONEX_Statuses_Temp_Revenants", 4)
	if revenantsDB then
		for _,db in pairs(revenantsDB) do
			local target,revenant,source,status = table.unpack(db)
			Config.Skill.Revenants.KillRevenant(GameHelpers.GetCharacter(revenant), revenant)
		end
	end ]]
	
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
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Demolition_PlayerData_BackpackEquipped", 2)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_RemoteMines_Temp_JustDetonated", 1)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Demolition_Temp_ListenForSkill", 3)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Demolition_Temp_ListenForSkillPosition", 6)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Demolition_SkillBonuses", 5)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Demolition_Temp_AddToList", 1)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Demolition_Temp_AddToListError", 1)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Demolition_Temp_DisplacementTarget", 5)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Demolition_Temp_Displaced", 3)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_RemoteMines_Templates", 1)
	Osi.LeaderLib_Array_ClearArray("LLWEAPONEX_Demolition_BonusSkillListQueue")

	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_WeaponMastery_MasteryVariables", 4)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_WeaponMastery_MasteryLevelTags", 3)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_WeaponMastery_MasteryCap", 1)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_WeaponMastery_MaxExperience", 2)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_WeaponMastery_Progression", 4)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_WeaponMastery_Flags", 4)

	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_CampaignRegions", 3)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_UniqueManager_RegisteredOwner", 3)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_UniqueManager_RegisteredPosition", 6)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_UniqueManager_Temp_ResolvedMove", 2)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_UniqueManager_Temp_ActiveOwner", 2)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_UniqueManager_Temp_ActiveItem", 2)

	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Skills_TagRequirements", 3)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Skills_SlayHidden_Targets", 2)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Skills_SlayHidden_CurrentTarget", 2)

	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_WeaponFX_UnsheathedStatus", 2)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_WeaponFX_Temp_UnsheathedStatus", 3)

	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Uniques_DemonGauntlet_ListenForDeath", 2)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Uniques_DemonGauntlet_ActiveDefense", 2)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Uniques_AnvilMace_Temp_GroundSlamTarget", 3)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Uniques_Temp_NextCombinedWarchiefHalberd", 3)

	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Statuses_Temp_Rage_ListenForAttacked", 1)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_MasteryBonus_ListenForRemoval", 3)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Statuses_ListenForTurnEnding", 4)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Statuses_Temp_WaitForFinished", 7)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Statuses_Temp_Revenants", 4)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Skills_Temp_AttachedRevanents", 2)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_TS_Temp_CustomUnsheathed", 2)

	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Runeblades_Temp_AddedDualWieldingRuneSkill", 3)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Runeblades_Temp_PreventSound", 3)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Runeblades_StatusSound", 3)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Runeblades_FlagSound", 3)

	Osi.LeaderLib_ClearDatabase("LLWEAPONEX_BattleBooks_SpellScroll_Spells", 1)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_BattleBooks_SpellScroll_SpellNames", 2)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_BattleBooks_SpellScroll_CasterEffects", 3)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_BattleBooks_SpellScroll_ExpodeEffects", 3)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_BattleBooks_SpellScroll_ProjectileSettings", 3)
	
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Throwing_StrengthDistanceConstants", 2)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Throwing_StrengthToDistance", 2)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Throwing_Temp_TossResolved", 2)

	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Throwing_KevinSkills", 1)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Temp_KevinOriginalForm", 2)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Throwing_Temp_KevinIterator", 4)

	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Throwing_ReturnSkillTags", 2)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Throwing_ReturnSkill", 6)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Throwing_Temp_ReturnTarget", 4)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Throwing_Temp_ForkIterator", 5)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Throwing_Temp_SkillNotReturned", 3)

	Osi.LeaderLib_Helper_ClearSurfaceList("LLWEAPONEX_ChaosSurfaces")
	-- Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Skills_Temp_ChaosSlicePath", 4)
	-- Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Skills_Temp_ChaosChargeDrawing", 3)
	--Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_Skills_Temp_ChaosSlashCaster", 1)

	--[[ for _,db in pairs(Osi.DB_LLWEAPONEX_Skills_Temp_ChaosSlicePath:Get(nil,nil,nil,nil)) do
		local character,obj,handle,surface = table.unpack(db)
		StopDrawSurfaceOnPath(handle)
	end

	for _,db in pairs(Osi.DB_LLWEAPONEX_Skills_Temp_ChaosChargeDrawing:Get(nil,nil,nil)) do
		local character,surface,handle = table.unpack(db)
		StopDrawSurfaceOnPath(handle)
	end ]]

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
	Osi.LeaderLib_ToggleScripts_Clear_ByGoal("LLWEAPONEX_80_TS_10_DemolitionBackpack")
	Osi.LeaderLib_ToggleScripts_Clear_ByGoal("LLWEAPONEX_80_TS_60_UniqueManager")
	Osi.LeaderLib_ToggleScripts_Clear_ByGoal("LLWEAPONEX_80_TS_00_ExtenderSkillRefreshing")
	Osi.LeaderLib_ToggleScripts_Clear_ByGoal("LLWEAPONEX_80_TS_03_WeaponFX")
	
	Osi.LeaderLib_GameScripts_ClearScriptsForGroup("WeaponExpansion")

	--Vending Machine deprecated stuff
	Osi.LeaderLib_Trader_Clear_AllData("LLWEAPONEX.VendingMachine")
	Osi.LeaderLib_Treasure_Clear_AllDataForTreasure("LLWEAPONEX.VendingMachine.Orders")
	Osi.LeaderLib_Treasure_Clear_AllDataForTreasure("LLWEAPONEX.VendingMachine.Uniques")
	Osi.LeaderLib_Treasure_Clear_AllDataForTreasure("LLWEAPONEX.VendingMachine.WorldUniques")

	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_VendingMachine_SaleCooldown", 2)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_VendingMachine_Temp_SaleStarted", 1)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_VendingMachine_Temp_GenerationTickDone", 1)
	Osi.LeaderLib_ClearDatabase("DB_LLWEAPONEX_VendingMachine_Temp_SaleJustDecreased", 1)
end)