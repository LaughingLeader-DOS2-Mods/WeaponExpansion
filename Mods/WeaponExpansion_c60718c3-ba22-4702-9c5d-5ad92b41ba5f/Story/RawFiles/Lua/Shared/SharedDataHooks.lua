if Ext.IsServer() then
	---@param id integer
	---@param profile string
	---@param uuid string
	---@param isHost boolean
	LeaderLib.RegisterListener("SyncData", function(id, profile, uuid, isHost)
		ArmCannon_SyncData(nil, id)
		Ext.PostMessageToUser(id, "LLWEAPONEX_SyncData", Ext.JsonStringify(PersistentVars.SkillData.DarkFireballCount))
	end)
end

if Ext.IsClient() then
	Ext.RegisterNetListener("LLWEAPONEX_SyncData", function(cmd, payload)
		local vtable = GameHelpers.Data.GetPersistentVars("WeaponExpansion", true, "SkillData", "DarkFireballCount")
		vtable.DarkFireballCount = Common.JsonParse(payload)
		if SharedData.RegionData.LevelType == LEVELTYPE.CHARACTER_CREATION or Client.Character.IsInCharacterCreation then
			MasteryMenu.SetToggleButtonVisibility(false, false)
		elseif SharedData.RegionData.LevelType == LEVELTYPE.GAME then
			MasteryMenu.SetToggleButtonVisibility(true, false)
		end
	end)
end