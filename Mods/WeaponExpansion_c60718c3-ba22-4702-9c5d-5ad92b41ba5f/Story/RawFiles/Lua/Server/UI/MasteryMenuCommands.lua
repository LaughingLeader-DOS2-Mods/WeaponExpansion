---@type MessageData
local MessageData = Classes["MessageData"]

local CharacterMasteryData = MasteryDataClasses.CharacterMasteryData
local CharacterMasteryDataEntry = MasteryDataClasses.CharacterMasteryDataEntry

---@param character EsvCharacter
function OpenMasteryMenu(character)
	--DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience(_Player, _Mastery, _Rank, _Experience)
	local data = {
		UUID = character.MyGuid,
		Masteries = {},
		NetID = character.NetID
	}
	for i,db in pairs(Osi.DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience:Get(character.MyGuid, nil, nil, nil)) do
		local char,mastery,rank,xp = table.unpack(db)
		data.Masteries[mastery] = {
			Rank = rank,
			XP = xp
		}
	end
	GameHelpers.Net.PostToUser(character, "LLWEAPONEX_OpenMasteryMenu", Ext.JsonStringify(data))
end

---@param payload string
local function RequestOpenMasteryMenu(payload)
	local netid = tonumber(payload)
	local character = GameHelpers.GetCharacter(netid)
	fassert(character ~= nil, "Failed to get character from netid %s", netid)
	if GameHelpers.Character.IsSummonOrPartyFollower(character) then
		if character.PartyFollower then
			if character.CharacterControl then
				ShowNotification(character.MyGuid, "LLWEAPONEX_Notifications_NoMasteriesForFollowers")
			else
				CharacterStatusText(character.MyGuid, "LLWEAPONEX_Notifications_NoMasteriesForFollowers")
			end
		else
			if character.CharacterControl then
				ShowNotification(character.MyGuid, "LLWEAPONEX_Notifications_NoMasteriesForSummons")
			else
				CharacterStatusText(character.MyGuid, "LLWEAPONEX_Notifications_NoMasteriesForSummons")
			end
		end
		return true
	end
	OpenMasteryMenu(character)
	return true
end

Ext.RegisterNetListener("LLWEAPONEX_RequestOpenMasteryMenu", function(cmd, payload)
	local b,err = xpcall(RequestOpenMasteryMenu, debug.traceback, payload)
	if not b or err == false then
		ferror("Failed to open mastery menu with payload data:\n%s\n%s", payload, err)
	end
end)

local statusDummy = "S_LeaderLib_Dummy_TargetHelper_A_36069245-0e2d-44b1-9044-6797bd29bb15"
local function RequestStatusTooltip(call,datastr)
	PrintDebug("[WeaponExpansion:MasteryMenuCommands.lua:LLWEAPONEX_MasteryMenu_RequestStatusTooltip] Data:")
	PrintDebug(datastr)
	local data = MessageData:CreateFromString(datastr)
	if data ~= nil then
		local character = Ext.GetCharacter(data.ID)
		local status = data.Params.Status
		if status ~= nil then
			local handle = NRD_StatusGetHandle(statusDummy, status)
			if handle == nil then
				ApplyStatus(statusDummy, status, -1.0, 1, statusDummy)
				handle = NRD_StatusGetHandle(statusDummy, status)
			end
			---@type EsvStatus
			local statusObj = Ext.GetStatus(statusDummy, handle)
			data.Params.StatusHandle = statusObj.StatusHandle
			data.Params.NetID = Ext.GetCharacter(statusDummy).NetID
			local statuses = Ext.GetCharacter(statusDummy):GetStatuses()
			--CharacterSetForceSynch(statusDummy, 1)
			--CharacterSetForceUpdate(statusDummy, 1)
			--CharacterSetForceSynch(statusDummy, 0)
			--CharacterSetForceUpdate(statusDummy, 0)
			local host = CharacterGetHostCharacter()
			SetOnStage(statusDummy, 1)
			CharacterSetDetached(statusDummy, 0)
			--CharacterMakePlayer(statusDummy, host)
			TeleportTo(statusDummy, host, "", 0, 1, 1)
			--CharacterMakeNPC(statusDummy)
			data.Params.Host = host

			local resultStr = data:ToString()
			PrintDebug("[WeaponExpansion:MasteryMenuCommands.lua:LLWEAPONEX_MasteryMenu_RequestStatusTooltip] Sending data back to client:")
			PrintDebug(resultStr)
			Ext.PostMessageToUser(character.UserID, "LLWEAPONEX_MasteryMenu_StatusHandleRetrieved", resultStr)
		end
	else
		Ext.PrintError("MessageData:CreateFromString failed.")
	end
end

Ext.RegisterNetListener("LLWEAPONEX_MasteryMenu_RequestStatusTooltip", RequestStatusTooltip)