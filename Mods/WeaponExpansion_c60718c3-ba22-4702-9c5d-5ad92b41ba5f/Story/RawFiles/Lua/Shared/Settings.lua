return function()
	---@type ModSettings
	local settings = LeaderLib.CreateModSettings("c60718c3-ba22-4702-9c5d-5ad92b41ba5f")
	---@type TranslatedString
	local ts = LeaderLib.Classes.TranslatedString

	local MenuSectionGeneral = ts:Create("h6145e729g4cb0g4018gafe9gd89175b8943d", "General")
	local MenuSectionUniques = ts:Create("h903efedcge7b3g485ag87bfgc121d0ecad7f", "<font color='#C7A758'>Unique Items</font>")
	
	settings.Global:AddLocalizedFlags({
		"LLWEAPONEX_UniqueAutoLevelingDisabled",
		"LLWEAPONEX_ArmCannonRestrictionsDisabled",
		"LLWEAPONEX_RemoteChargeDetonationCountDisabled",
		"LLWEAPONEX_DemolitionBackpackAutoRechargeEnabled",
		"LLWEAPONEX_ThrowObjectLimitDisabled",
	})
	settings.Global:AddLocalizedFlag("LLWEAPONEX_AutoUnlockRecipesDisabled", "User", false, nil, nil, false)
	--settings.Global:AddLocalizedVariable("ButtonOffsetX", "LLWEAPONEX_Variables_ButtonOffsetX", 0, -100, 100, 0.1)
	--settings.Global:AddLocalizedVariable("ButtonOffsetY", "LLWEAPONEX_Variables_ButtonOffsetY", 0, -100, 100, 0.1)
	
	---@param self SettingsData
	---@param name string
	---@param data VariableData
	settings.UpdateVariable = function(self, name, data)
		
	end

	settings.GetMenuOrder = function()
		return {{
			DisplayName = MenuSectionGeneral.Value,
			Entries = {
				"LLWEAPONEX_AutoUnlockRecipesDisabled",
				"LLWEAPONEX_ThrowObjectLimitDisabled",
			}},
			{DisplayName = MenuSectionUniques.Value, 
			Entries = {		
				"LLWEAPONEX_UniqueAutoLevelingDisabled",
				"LLWEAPONEX_RemoteChargeDetonationCountDisabled",
				"LLWEAPONEX_DemolitionBackpackAutoRechargeEnabled",
				"LLWEAPONEX_ArmCannonRestrictionsDisabled",
			}},
		}
	end

	return settings
end