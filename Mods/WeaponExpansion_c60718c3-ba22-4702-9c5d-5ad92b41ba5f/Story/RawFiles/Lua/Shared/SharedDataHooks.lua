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
	end)
end