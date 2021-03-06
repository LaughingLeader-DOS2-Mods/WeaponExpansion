---@param uuid string
---@param userID integer
---@param profile string
---@param netID integer
---@param isHost boolean
RegisterListener("ClientCharacterChanged", function(uuid, userID, profile, netID, isHost)
	if Ext.GetGameState() == "Running" then
		local ui = Ext.GetBuiltinUI("Public/Game/GUI/characterSheet.swf")
		if ui ~= nil then
			SetCharacterSheetDamageText(ui, netID)
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

local registerCCListener = false
local lastCCHandle = nil

Ext.RegisterNetListener("LLWEAPONEX_CC_HideStoryButton", function(call, uuid)
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/characterCreation.swf")
	if ui ~= nil then
		local main = ui:GetRoot()
		main.header_mc.voiceOriginBtn_mc.visible = false
		main.header_mc.voiceOriginBtn_mc.isEnabled = false
		main.enableOrigin = false
		lastCCHandle = main.characterHandle
		if not registerCCListener then
			Ext.RegisterUIInvokeListener(ui, "enableStoryPlayback", function(ui, method, enabled)
				if enabled and main.characterHandle == lastCCHandle then
					main.header_mc.voiceOriginBtn_mc.visible = false
					main.header_mc.voiceOriginBtn_mc.isEnabled = false
					main.enableOrigin = false
				end
			end)
			registerCCListener = true
		end
	end
end)

Ext.RegisterNetListener("LLWEAPONEX_CC_EnableStoryButton", function(call, uuid)
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/characterCreation.swf")
	if ui ~= nil then
		ui:Invoke("enableStoryPlayback", true)
	end
end)