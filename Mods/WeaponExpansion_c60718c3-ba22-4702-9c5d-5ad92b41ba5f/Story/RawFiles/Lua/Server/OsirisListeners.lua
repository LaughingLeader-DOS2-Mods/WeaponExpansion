local currentLevel = ""
local isInCharacterCreation = false

Ext.RegisterOsirisListener("GameStarted", 2, "after", function(region, editorMode)
	currentLevel = region
	isInCharacterCreation = IsCharacterCreationLevel(region) == 1
	if isInCharacterCreation then
		Ext.BroadcastMessage("LLWEAPONEX_OnCharacterCreationStarted", "", nil)
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