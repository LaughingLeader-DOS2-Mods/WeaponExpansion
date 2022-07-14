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
				local item = Ext.GetItem(v)
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
end)