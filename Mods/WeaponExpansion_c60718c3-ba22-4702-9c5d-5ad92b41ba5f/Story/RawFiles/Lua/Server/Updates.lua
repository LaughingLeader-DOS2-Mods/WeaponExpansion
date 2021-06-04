---@param last integer
---@param next integer
RegisterModListener("Loaded", "c60718c3-ba22-4702-9c5d-5ad92b41ba5f", function(last, next)
	print("[LLWEAPONEX:Loaded]", last, "=>", next)
	if last < 152764417 then
		ItemLockUnEquip("40039552-3aae-4beb-8cca-981809f82988", 0)
		ItemToInventory("40039552-3aae-4beb-8cca-981809f82988", "80976258-a7a5-4430-b102-ba91a604c23f")
		ItemLockUnEquip("927669c3-b885-4b88-a0c2-6825fbf11af2", 0)
		ItemToInventory("927669c3-b885-4b88-a0c2-6825fbf11af2", "80976258-a7a5-4430-b102-ba91a604c23f")
	end

	for player in GameHelpers.Character.GetPlayers() do
		EquipmentManager.CheckWeaponRequirementTags(player)
		if HasActiveStatus(player.MyGuid, "LLWEAPONEX_UNARMED_LIZARD_DEBUFF") == 1 then
			RemoveStatus(player.MyGuid, "LLWEAPONEX_UNARMED_LIZARD_DEBUFF")
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

		local callbacks = ServerEvents.OnModUpdated
		if callbacks ~= nil then
			for i,callback in pairs(callbacks) do
				local b,err = xpcall(callback, debug.traceback, last, next, player.MyGuid)
				if not b then
					Ext.PrintError("[LeaderLib:CancelTimer] Error calling oneshot timer callback:\n", err)
				end
			end
		end
	end
end)