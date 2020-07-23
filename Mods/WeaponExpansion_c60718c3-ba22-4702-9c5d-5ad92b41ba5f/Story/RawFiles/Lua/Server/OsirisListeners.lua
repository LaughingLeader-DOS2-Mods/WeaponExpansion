local currentLevel = ""
local isInCharacterCreation = false

Ext.RegisterOsirisListener("GameStarted", 2, "after", function(region, editorMode)
	currentLevel = region
	isInCharacterCreation = IsCharacterCreationLevel(region) == 1
	if isInCharacterCreation then
		Ext.BroadcastMessage("LLWEAPONEX_OnCharacterCreationStarted", "", nil)
	else
		for id,unique in pairs (Uniques) do
			unique:OnLevelChange(region)
		end
	end
end)

Ext.RegisterOsirisListener("RegionEnded", 1, "after", function(region)
	if IsCharacterCreationLevel(region) == 1 then
		Ext.BroadcastMessage("LLWEAPONEX_OnCharacterCreationFinished", "", nil)
		isInCharacterCreation = false
	end
end)

Ext.RegisterOsirisListener("UserConnected", 3, "after", function(id, name, profileId)
	if isInCharacterCreation then
		local character = GetCurrentCharacter(id)
		Ext.PostMessageToClient(character, "LLWEAPONEX_OnCharacterCreationStarted", "")
	end
end)

Ext.RegisterOsirisListener("ItemLockUnEquip", 2, "after", function(item, locked)
	if locked == 1 then
		ObjectSetFlag(item, "LLWEAPONEX_ItemIsLocked", 0)
	else
		ObjectClearFlag(item, "LLWEAPONEX_ItemIsLocked", 0)
	end
end)