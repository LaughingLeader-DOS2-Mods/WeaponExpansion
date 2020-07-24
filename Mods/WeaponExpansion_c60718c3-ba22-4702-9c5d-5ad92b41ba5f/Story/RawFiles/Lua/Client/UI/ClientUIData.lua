CLIENT_UI = {
	ID = nil,
	---@type EclCharacter
	ACTIVE_CHARACTER = nil,
	PARTY = nil,
	LAST_SKILL = "",
	LAST_ITEM = nil,
	LAST_STATUS_CHARACTER = nil,
	LAST_STATUS = nil,
	IsInCharacterCreation = false,
}

Ext.RegisterNetListener("LLWEAPONEX_SendClientUserID", function(call,id)
	CLIENT_UI.ID = math.tointeger(tonumber(id))
	print("[WeaponExpansion:MasteryMenu.lua:NetMessage_SetClientId] Set CLIENT_UI.ID to (",CLIENT_UI.ID,")")
end)

Ext.RegisterNetListener("LLWEAPONEX_SetActiveCharacter", function(call, uuid)
	CLIENT_UI.ACTIVE_CHARACTER = uuid
	print("Set active character for client to", uuid)
	if CLIENT_UI.ACTIVE_CHARACTER ~= nil then
		local ui = Ext.GetBuiltinUI("Public/Game/GUI/characterSheet.swf")
		if ui ~= nil then
			UI.SetCharacterSheetDamageText(ui,CLIENT_UI.ACTIVE_CHARACTER)
		end
	end
end)