return function()
	---@type ModSettings
	local settings = LeaderLib.CreateModSettings("c60718c3-ba22-4702-9c5d-5ad92b41ba5f")
	---@type TranslatedString
	local ts = LeaderLib.Classes.TranslatedString
	
	settings.Global:AddLocalizedFlags({
		"LLWEAPONEX_NoArmCannonRestrictions",
		"LLWEAPONEX_RemoteChargeDetonationCountDisabled",
		"LLWEAPONEX_DemolitionBackpackAutoRechargeEnabled",
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