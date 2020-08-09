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
	Vars = {}
}

Ext.RegisterNetListener("LLWEAPONEX_SendClientUserID", function(call,id)
	CLIENT_UI.ID = math.tointeger(tonumber(id))
	print("[WeaponExpansion:MasteryMenu.lua:NetMessage_SetClientId] Set CLIENT_UI.ID to (",CLIENT_UI.ID,")")
end)

Ext.RegisterNetListener("LLWEAPONEX_SetActiveCharacter", function(call, uuid)
	CLIENT_UI.ACTIVE_CHARACTER = uuid
	print("Set active character for client to", uuid)
	if Ext.GetGameState() == "Running" and CLIENT_UI.ACTIVE_CHARACTER ~= nil and Ext.GetCharacter(uuid) ~= nil then
		local ui = Ext.GetBuiltinUI("Public/Game/GUI/characterSheet.swf")
		if ui ~= nil then
			UI.SetCharacterSheetDamageText(ui,CLIENT_UI.ACTIVE_CHARACTER)
		end
	end
end)

Ext.RegisterNetListener("LLWEAPONEX_FixLizardSkin", function(call, uuid)
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/characterCreation.swf")
	if ui ~= nil then
		--ExternalInterface.call("setGender",param1.isMale);
		--ExternalInterface.call("selectOption",(parent as MovieClip).contentID,this.optionsList[this.currentIdx].optionID,true);
		if Ext.IsModLoaded("db07c22c-8935-3848-2366-7827b70c6030") then
			--ui:ExternalInterfaceCall("setGender", true)
			ui:ExternalInterfaceCall("selectOption", 3, 103, false)
		else
			ui:ExternalInterfaceCall("selectOption", 3, 13, false)
		end
	end
end)

Ext.RegisterNetListener("LLWEAPONEX_SyncVars", function(call, dataStr)
	CLIENT_UI.Vars = Ext.JsonParse(dataStr)
end)