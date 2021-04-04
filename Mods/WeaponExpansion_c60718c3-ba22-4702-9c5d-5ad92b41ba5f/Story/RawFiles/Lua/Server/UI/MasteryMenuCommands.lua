---@type MessageData
local MessageData = LeaderLib.Classes["MessageData"]

local CharacterMasteryData = MasteryDataClasses.CharacterMasteryData
local CharacterMasteryDataEntry = MasteryDataClasses.CharacterMasteryDataEntry

function OpenMasteryMenu_Start(uuid, id)
	--DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience(_Player, _Mastery, _Rank, _Experience)
	local masteries = {}

	for i,db in pairs(Osi.DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience:Get(uuid, nil, nil, nil)) do
		local char,mastery,rank,xp = table.unpack(db)
		masteries[mastery] = CharacterMasteryDataEntry:Create(xp,rank)
	end
	--print(Common.Dump(masteries))

	---@type CharacterMasteryData
	local data = CharacterMasteryData:Create(uuid, masteries)
	if id ~= nil then
		Ext.PostMessageToUser(id, "LLWEAPONEX_OpenMasteryMenu", Ext.JsonStringify(data))
	else
		Ext.PostMessageToClient(uuid, "LLWEAPONEX_OpenMasteryMenu", Ext.JsonStringify(data))
	end
end

local function RequestOpenMasteryMenu(call, payload)
	if payload ~= nil then
		local netid = tonumber(payload)
		local id = -1
		local uuid = ""
		local profile = ""
		if netid ~= nil then
			local character = Ext.GetCharacter(netid)
			if character ~= nil then
				uuid = character.MyGuid
				id = CharacterGetReservedUserID(uuid)
				profile = GetUserProfileID(id)
			end
			if not StringHelpers.IsNullOrEmpty(uuid) then
				if CharacterIsSummon(uuid) == 1 then
					if CharacterIsControlled(uuid) == 1 then
						ShowNotification(uuid, "LLWEAPONEX_Notifications_NoMasteriesForSummons")
					else
						CharacterStatusText(uuid, "LLWEAPONEX_Notifications_NoMasteriesForSummons")
					end
				elseif CharacterIsPartyFollower(uuid) == 1 then
					if CharacterIsControlled(uuid) == 1 then
						ShowNotification(uuid, "LLWEAPONEX_Notifications_NoMasteriesForFollowers")
					else
						CharacterStatusText(uuid, "LLWEAPONEX_Notifications_NoMasteriesForFollowers")
					end
				elseif IsPlayer(uuid) then
					OpenMasteryMenu_Start(uuid, id)
				end
				return true
			else
				Ext.PrintError("[WeaponExpansion] Failed to find character for user. NetID(%s) ID(%s) Profile(%s) UUID(%s)", payload, id, profile, uuid)
			end
		end
	end
	return false
end

Ext.RegisterNetListener("LLWEAPONEX_RequestOpenMasteryMenu", function(cmd, payload)
	if not RequestOpenMasteryMenu(cmd, payload) then
		Ext.BroadcastMessage("LLWEAPONEX_TryGetClientID_RequestOpen", "", nil)
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