if Ext.IsServer() then
	function SyncDataToClient(id, profile, uuid, isHost)
		ArmCannon_SyncData(nil, id)
		local darkFireBallData = {}
		for savedUUID,count in pairs(PersistentVars.SkillData.DarkFireballCount) do
			local char = Ext.GetCharacter(savedUUID)
			if char ~= nil then
				darkFireBallData[char.NetID] = count
			end
		end
		local payload = Ext.JsonStringify(darkFireBallData)
		print(payload)
		Ext.PostMessageToUser(id, "LLWEAPONEX_SyncData", payload)
	end

	---@param id integer
	---@param profile string
	---@param uuid string
	---@param isHost boolean
	LeaderLib.RegisterListener("SyncData", SyncDataToClient)
end

if Ext.IsClient() then
	Ext.RegisterNetListener("LLWEAPONEX_SyncData", function(cmd, payload)
		local vtable = GameHelpers.Data.GetPersistentVars("WeaponExpansion", true, "SkillData", "DarkFireballCount")
		vtable.DarkFireballCount = Common.JsonParse(payload)
		PersistentVars.SkillData.DarkFireballCount = vtable.DarkFireballCount
	end)
	-- Checks for SharedData.RegionData need to happen here since this is after that data has been synced
	LeaderLib.RegisterListener("ClientDataSynced", function(modData, sharedData)
		if SharedData.RegionData.LevelType == LEVELTYPE.CHARACTER_CREATION or Client.Character.IsInCharacterCreation then
			MasteryMenu.SetToggleButtonVisibility(false, false)
		elseif SharedData.RegionData.LevelType == LEVELTYPE.GAME then
			MasteryMenu.SetToggleButtonVisibility(true, false)
		end
	end)
end