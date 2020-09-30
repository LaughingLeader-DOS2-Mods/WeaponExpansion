if Ext.IsServer() then
	---@param data SharedData
	LeaderLib.RegisterListener("SyncData", function(data)
		data.LLWEAPONEX = {
			PersistentVars = PersistentVars
		}
	end)
end

if Ext.IsClient() then
	---@param data SharedData
	LeaderLib.RegisterListener("ClientDataSynced", function(data)
		PersistentVars = data.LLWEAPONEX.PersistentVars
		if SharedData.RegionData.LevelType == LEVELTYPE.CHARACTER_CREATION then
			MasteryMenu.SetToggleButtonVisibility(false, false)
		elseif SharedData.RegionData.LevelType == LEVELTYPE.GAME then
			MasteryMenu.SetToggleButtonVisibility(true, true)
		end
	end)
end