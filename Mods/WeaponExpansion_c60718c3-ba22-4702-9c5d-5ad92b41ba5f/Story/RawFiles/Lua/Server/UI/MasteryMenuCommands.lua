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

local function RequestOpenMasteryMenu(call,id)
	local clientID = tonumber(id)
	if clientID ~= nil then
		local character = GetCurrentCharacter(clientID)
		if character ~= nil then
			if CharacterIsSummon(character) then
				if CharacterIsControlled(character) then
					ShowNotification(character, "LLWEAPONEX_Notifications_NoMasteriesForSummons")
				else
					CharacterStatusText(character, "LLWEAPONEX_Notifications_NoMasteriesForSummons")
				end
			else
				OpenMasteryMenu_Start(character)
				return true
			end
		end
		for i,entry in ipairs(Osi.DB_IsPlayer:Get(nil)) do
			local uuid = entry[1]
			local id = CharacterGetReservedUserID(uuid)
			print(id,clientID, id==clientID)
			if id == clientID and CharacterIsControlled(uuid) then
				OpenMasteryMenu_Start(uuid)
				return true
			end
		end
	end
	LeaderLib.PrintDebug("[WeaponExpansion:MasteryMenuCommands.lua:RequestOpenMasteryMenu] Could not find any controlled party members for (",id,").")
end

Ext.RegisterNetListener("LLWEAPONEX_RequestOpenMasteryMenu", RequestOpenMasteryMenu)