---@param last integer
---@param next integer
LeaderLib.RegisterModListener("Loaded", "c60718c3-ba22-4702-9c5d-5ad92b41ba5f", function(last, next)
	print("[LLWEAPONEX:Loaded]", last, "=>", next)
	if last < 152764417 then
		ItemLockUnEquip("40039552-3aae-4beb-8cca-981809f82988", 0)
		ItemToInventory("40039552-3aae-4beb-8cca-981809f82988", "80976258-a7a5-4430-b102-ba91a604c23f")
		ItemLockUnEquip("927669c3-b885-4b88-a0c2-6825fbf11af2", 0)
		ItemToInventory("927669c3-b885-4b88-a0c2-6825fbf11af2", "80976258-a7a5-4430-b102-ba91a604c23f")
	end

	-- Tag updating
	for _,db in pairs(Osi.DB_IsPlayer:Get(nil)) do
		local uuid = db[1]
		local player = Ext.GetCharacter(uuid)
		EquipmentManager.CheckWeaponRequirementTags(StringHelpers.GetUUID(db[1]))
		if HasActiveStatus(uuid, "LLWEAPONEX_UNARMED_LIZARD_DEBUFF") == 1 then
			RemoveStatus(uuid, "LLWEAPONEX_UNARMED_LIZARD_DEBUFF")
		end

		if IsTagged(uuid, "LLWEAPONEX_Quiver_Equipped") == 1 and last < 153026560 then
			local quiver = Ext.GetCharacter(uuid).Stats:GetItemBySlot("Belt")
			if quiver ~= nil then
				ItemResetChargesToMax(quiver.MyGuid)
			end
			if CharacterIsInCombat(uuid) == 0 then
				Quiver_RemoveTempArrows(uuid)
			end
		end

		if CharacterHasSkill(uuid, "Shout_LLWEAPONEX_Prepare_BalrinsAxe") == 1 then
			CharacterRemoveSkill(uuid, "Shout_LLWEAPONEX_Prepare_BalrinsAxe")
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
	end
end)