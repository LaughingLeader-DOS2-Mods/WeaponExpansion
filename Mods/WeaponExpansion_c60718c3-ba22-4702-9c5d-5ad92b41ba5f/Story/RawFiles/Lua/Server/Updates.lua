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
		Equipment.CheckWeaponRequirementTags(StringHelpers.GetUUID(db[1]))
		if HasActiveStatus(uuid, "LLWEAPONEX_UNARMED_LIZARD_DEBUFF") == 1 then
			RemoveStatus(uuid, "LLWEAPONEX_UNARMED_LIZARD_DEBUFF")
		end

		local hasBluntTag = not StringHelpers.IsNullOrEmpty(CharacterFindTaggedItem(uuid, "LLWEAPONEX_Blunt"))
		if hasBluntTag then
			for i,v in pairs(Ext.GetCharacter(uuid):GetInventoryItems()) do
				if IsTagged(v, "LLWEAPONEX_Blunt") == 1 then
					ClearTag(v, "LLWEAPONEX_Blunt")
					SetTag(v, "LLWEAPONEX_Bludgeon")
				end
			end
		end
	end
end)