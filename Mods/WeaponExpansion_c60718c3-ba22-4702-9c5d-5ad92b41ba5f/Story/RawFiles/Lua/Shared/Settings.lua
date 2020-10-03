return function()
	---@type ModSettings
	local settings = LeaderLib.CreateModSettings("e21fcd37-daec-490d-baec-f6f3e83f1ac9")
	---@type TranslatedString
	local ts = LeaderLib.Classes.TranslatedString
	
	settings.Global:AddLocalizedFlags({
		"LLWEAPONEX_NoArmCannonRestrictions",
		"LLWEAPONEX_RemoteChargeDetonationCountDisabled",
	})
	settings.Global:AddLocalizedFlag("LLWEAPONEX_AutoUnlockRecipesDisabled", "User", false, nil, nil, false)

	---@param self SettingsData
	---@param name string
	---@param data VariableData
	settings.UpdateVariable = function(self, name, data)
		
	end

	-- settings.GetMenuOrder = function()
		
	-- end

	return settings
end