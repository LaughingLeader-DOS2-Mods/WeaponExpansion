---@param uuid string
---@param id integer
---@param profile string
---@param isHost boolean
LeaderLib.RegisterListener("ClientCharacterChanged", function(uuid, id, profile, isHost)
	if Ext.GetGameState() == "Running" then
		local ui = Ext.GetBuiltinUI("Public/Game/GUI/characterSheet.swf")
		if ui ~= nil then
			UI.SetCharacterSheetDamageText(ui, uuid)
		end
	end
end)

Ext.RegisterNetListener("LLWEAPONEX_FixLizardSkin", function(call, uuid)
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/characterCreation.swf")
	if ui ~= nil then
		--ExternalInterface.call("setGender",param1.isMale);
		--ExternalInterface.call("selectOption",(parent as MovieClip).contentID,this.optionsList[this.currentIdx].optionID,true);
		-- LadyC's More Colors
		if Ext.IsModLoaded("db07c22c-8935-3848-2366-7827b70c6030") then
			--ui:ExternalInterfaceCall("setGender", true)
			ui:ExternalInterfaceCall("selectOption", 3, 103, false)
		else
			ui:ExternalInterfaceCall("selectOption", 3, 13, false)
		end
	end
end)