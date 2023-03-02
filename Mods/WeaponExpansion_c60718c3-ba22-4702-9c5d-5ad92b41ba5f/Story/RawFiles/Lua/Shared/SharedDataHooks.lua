if Ext.IsServer() then
	function SyncDataToClient(id, profile, uuid, isHost)
		UniqueVars.SyncRunicCannon()
		local darkFireBallData = {}
		if PersistentVars.SkillData.DarkFireballCount then
			for savedUUID,count in pairs(PersistentVars.SkillData.DarkFireballCount) do
				local char = GameHelpers.GetCharacter(savedUUID)
				if char ~= nil then
					darkFireBallData[char.NetID] = count
				end
			end
			GameHelpers.Net.PostToUser(id, "LLWEAPONEX_SyncData", darkFireBallData)
		end
	end

	Events.SyncData:Subscribe(function (e)
		SyncDataToClient(e.UserID, e.Profile, e.UUID, e.IsHost)
	end)
end

if Ext.IsClient() then
	Ext.RegisterNetListener("LLWEAPONEX_SyncData", function(cmd, payload)
		local vtable = GameHelpers.Data.GetPersistentVars("WeaponExpansion", true, "SkillData", "DarkFireballCount")
		if vtable then
			vtable.DarkFireballCount = Common.JsonParse(payload)
			PersistentVars.SkillData.DarkFireballCount = vtable.DarkFireballCount
		end
	end)
	-- Checks for SharedData.RegionData need to happen here since this is after that data has been synced
	-- RegisterListener("ClientDataSynced", function(modData, sharedData)
	-- 	if SharedData.RegionData.LevelType == LEVELTYPE.CHARACTER_CREATION or Client.Character.IsInCharacterCreation then
	-- 		MasteryMenu.ToggleButton:SetVisible(false, false)
	-- 	elseif SharedData.RegionData.LevelType == LEVELTYPE.GAME then
	-- 		MasteryMenu.ToggleButton:SetVisible(true, false)
	-- 	end
	-- end)
end