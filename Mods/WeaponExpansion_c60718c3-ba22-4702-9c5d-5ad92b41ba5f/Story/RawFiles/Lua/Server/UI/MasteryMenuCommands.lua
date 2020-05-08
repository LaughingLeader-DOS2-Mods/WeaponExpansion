---@type MessageData
local MessageData = LeaderLib.Classes["MessageData"]

function SendClientID(uuid, id)
	Ext.PostMessageToClient(uuid, "LLWEAPONEX_SetClientID", tostring(id))
end

function InitClientID()
	local sentIDs = {}
	for i,player in ipairs(Osi.DB_IsPlayer:Get(nil)) do
		local uuid = player[1]
		local id = CharacterGetReservedUserID(uuid)
		if not sentIDs[id] then
			SendClientID(uuid, id)
			sentIDs[id] = true
		end
	end
end

function OpenMasteryMenu_Start(uuid)
	--DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience(_Player, _Mastery, _Rank, _Experience)
	local masteries = {}
	local dbEntry = Osi.DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience:Get(uuid, nil, nil, nil)
	print(LeaderLib.Common.Dump(dbEntry))
	if dbEntry ~= nil then
		for i,entry in pairs(dbEntry) do
			local mastery = entry[2]
			local rank = entry[3]
			local xp = entry[4]
			masteries[mastery] = CharacterMasteryDataEntry:Create(xp,rank)
		end
	end

	---@type CharacterMasteryData
	local data = CharacterMasteryData:Create(uuid, masteries)
	Ext.PostMessageToClient(uuid, "LLWEAPONEX_OpenMasteryMenu", Ext.JsonStringify(data))
end

local function RequestOpenMasteryMenu(call,id,callbackID)
	--Ext.Print("RequestOpenMasteryMenu", "Sent ID", id, "Callback ID", callbackID, "Host UserID", CharacterGetReservedUserID(CharacterGetHostCharacter()))
	--Ext.Print("RequestOpenMasteryMenu", "Sent UserName", GetUserName(tonumber(id)), "Callback UserName", GetUserName(callbackID), "Host UserName", GetUserName(CharacterGetReservedUserID(CharacterGetHostCharacter())))
	if id == nil or id == "-1" then
		id = callbackID+1
	end
	local clientID = tonumber(id)
	if clientID ~= nil then
		local character = GetCurrentCharacter(clientID)
		if character ~= nil then
		if CharacterIsSummon(character) == 1 then
			if CharacterIsControlled(character) == 1 then
				ShowNotification(character, "LLWEAPONEX_Notifications_NoMasteriesForSummons")
			else
				CharacterStatusText(character, "LLWEAPONEX_Notifications_NoMasteriesForSummons")
			end
		elseif CharacterIsPartyFollower(character) == 1 then
			if CharacterIsControlled(character) == 1 then
				ShowNotification(character, "LLWEAPONEX_Notifications_NoMasteriesForFollowers")
			else
				CharacterStatusText(character, "LLWEAPONEX_Notifications_NoMasteriesForFollowers")
			end
		elseif CharacterIsPlayer(character) then
			OpenMasteryMenu_Start(character)
			return true
		end
		end
		for i,entry in ipairs(Osi.DB_IsPlayer:Get(nil)) do
			local uuid = entry[1]
			local id = CharacterGetReservedUserID(uuid)
			print(id,clientID, id==clientID)
			if id == clientID and CharacterIsControlled(uuid) == 1 then
				OpenMasteryMenu_Start(uuid)
				return true
			end
		end
	end
	LeaderLib.PrintDebug("[WeaponExpansion:MasteryMenuCommands.lua:RequestOpenMasteryMenu] Could not find any controlled party members for (",id,").")
end

Ext.RegisterNetListener("LLWEAPONEX_RequestOpenMasteryMenu", RequestOpenMasteryMenu)

local statusDummy = "S_LeaderLib_Dummy_TargetHelper_A_36069245-0e2d-44b1-9044-6797bd29bb15"
local function RequestStatusTooltip(call,datastr)
	LeaderLib.PrintDebug("[WeaponExpansion:MasteryMenuCommands.lua:LLWEAPONEX_MasteryMenu_RequestStatusTooltip] Data:")
	LeaderLib.PrintDebug(datastr)
	local data = MessageData:CreateFromString(datastr)
	if data ~= nil then
		local character = data.ID
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
			LeaderLib.PrintDebug("[WeaponExpansion:MasteryMenuCommands.lua:LLWEAPONEX_MasteryMenu_RequestStatusTooltip] Sending data back to client:")
			LeaderLib.PrintDebug(resultStr)
			Ext.PostMessageToClient(character, "LLWEAPONEX_MasteryMenu_StatusHandleRetrieved", resultStr)
		end
	else
		Ext.PrintError("MessageData:CreateFromString failed.")
	end
end

Ext.RegisterNetListener("LLWEAPONEX_MasteryMenu_RequestStatusTooltip", RequestStatusTooltip)