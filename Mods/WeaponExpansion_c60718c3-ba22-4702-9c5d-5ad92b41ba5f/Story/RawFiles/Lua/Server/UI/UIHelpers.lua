---@type MessageData
local MessageData = LeaderLib.Classes["MessageData"]

local function SendUserCharacters(id)
	local party = {}
	local client = nil
	for i,player in pairs(Osi.DB_IsPlayer:Get(nil)) do
		local uuid = player[1]
		if CharacterGetReservedUserID(uuid) == id then
			table.insert(party, Ext.GetCharacter(uuid).NetID)
			client = uuid
		end
	end
	local partyData = MessageData:CreateFromTable("PartyData", party)
	Ext.PostMessageToUser(id, "LLWEAPONEX_SetUserCharacters", partyData:ToString())
end

local function RequestUserCharacters(call,id_str,callbackID)
	local party = {}
	local id = tonumber(id_str)
	if id == nil or id == "-1" then
		id = callbackID+1
	end
	SendUserCharacters(id)
end

Ext.RegisterNetListener("LLWEAPONEX_RequestUserCharacters", RequestUserCharacters)

function SendClientID(uuid, id)
	if Ext.GetGameState() == "Running" then
		LeaderLib.PrintDebug("[WeaponExpansion:SendClientID] Setting client ID for ("..uuid..") to ["..id.."]")
		Ext.PostMessageToUser(id, "LLWEAPONEX_SetActiveCharacter", GetUUID(uuid))
		Ext.PostMessageToUser(id, "LLWEAPONEX_SendClientUserID", id)
	end
end

function InitClientID()
	if Ext.GetGameState() == "Running" then
		local sentIDs = {}
		for i,player in pairs(Osi.DB_IsPlayer:Get(nil)) do
			local uuid = player[1]
			local id = CharacterGetReservedUserID(uuid)
			if not sentIDs[id] then
				SendClientID(uuid, id)
				sentIDs[id] = true
			end
		end
	else
		TimerCancel("Timers_LLWEAPONEX_InitClientID")
		TimerLaunch("Timers_LLWEAPONEX_InitClientID", 500)
	end
end

local function RequestActiveCharacter(call,id_str,callbackID)
	TimerCancel("Timers_LLWEAPONEX_SetActivePlayers")
	TimerLaunch("Timers_LLWEAPONEX_SetActivePlayers", 250)
	-- local id = tonumber(id_str)
	-- for i,player in pairs(Osi.DB_IsPlayer:Get(nil)) do
	-- 	local uuid = player[1]
		
	-- 	if CharacterIsControlled(uuid) == 1 then
	-- 		Ext.PostMessageToClient(uuid, "LLWEAPONEX_SetActiveCharacter", Ext.GetCharacter(uuid).NetID)
	-- 	end
	-- end
	--LeaderLib.PrintDebug("[LLWEAPONEX_RequestActiveCharacter] Getting active character for",id,callbackID)
	--Ext.Print("RequestOpenMasteryMenu", "Sent ID", id, "Callback ID", callbackID, "Host UserID", CharacterGetReservedUserID(CharacterGetHostCharacter()))
	--Ext.Print("RequestOpenMasteryMenu", "Sent UserName", GetUserName(tonumber(id)), "Callback UserName", GetUserName(callbackID), "Host UserName", GetUserName(CharacterGetReservedUserID(CharacterGetHostCharacter())))
	-- if id == nil or id == "-1" then
	-- 	id = callbackID+1
	-- end
	-- local character = nil
	-- local clientID = tonumber(id)
	-- if clientID ~= nil then
	-- 	character = GetCurrentCharacter(clientID)
	-- end
	-- if character ~= nil then
	-- 	Ext.PostMessageToClient(character, "LLWEAPONEX_SetActiveCharacter", character)
	-- else
	-- 	IterateUsers("LLWEAPONEX_SendClientID")
	-- end
end

Ext.RegisterNetListener("LLWEAPONEX_RequestActiveCharacter", RequestActiveCharacter)

function HookIntoTradeWindow(uuid)
	Ext.PostMessageToClient(uuid, "LLWEAPONEX_HookIntoTradeWindow", CharacterGetReservedUserID(uuid))
end

function SyncVars()
	--Ext.PostMessageToClient(Mercs.Korvash, "LLWEAPONEX_SyncVars", Ext.JsonStringify(PersistentVars))
	if Ext.GetGameState() == "Running" then
		Ext.BroadcastMessage("LLWEAPONEX_SyncVars", Ext.JsonStringify(PersistentVars), nil)
	else
		TimerCancel("Timers_LLWEAPONEX_SyncVars")
		TimerLaunch("Timers_LLWEAPONEX_SyncVars", 500)
	end
end

Ext.RegisterNetListener("LLWEAPONEX_SetWorldTooltipText_Request", function(cmd, datastr)
	local data = Ext.JsonParse(datastr)
	Ext.PostMessageToUser(data.Client, "LLWEAPONEX_SetWorldTooltipText", data.Text)
end)