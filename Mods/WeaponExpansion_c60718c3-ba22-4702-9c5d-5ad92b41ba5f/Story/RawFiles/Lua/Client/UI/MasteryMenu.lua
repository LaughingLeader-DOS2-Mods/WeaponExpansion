local panelOpen = false

local function OnMenuEvent(ui, call, ...)
	local params = {...}
	PrintDebug("[WeaponExpansion_MasteryMenu.lua:OnMenuEvent] Event called. call("..tostring(call)..") params("..tostring(Common.Dump(params))..")")
	if call == "requestCloseUI" then
		ui:Hide()
		Ext.DestroyUI("MasteryMenu")
		panelOpen = false
	end
end

local function OpenMasteryMenu(call,uuid)
	local ui = Ext.GetUI("MasteryMenu")
	if ui == nil then
		ui = Ext.CreateUI("MasteryMenu", "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/MasteryMenu.swf", 99)
	end
	if ui ~= nil and panelOpen == false then
		Ext.RegisterUICall(ui, "switchMenu", OnMenuEvent)
		Ext.RegisterUICall(ui, "requestCloseUI", OnMenuEvent)
		--ui:Invoke("updateAddBaseTopTitleText", "Mods")
		ui:Invoke("addMastery", 0, "Axe", "Test description", 0)
		ui:Show()
		ui:ExternalInterfaceCall("requestOpenUI")
		ui:ExternalInterfaceCall("inputFocus")
		ui:ExternalInterfaceCall("show")
		ui:ExternalInterfaceCall("focus")
		panelOpen = true
	end
end

Ext.RegisterNetListener("LLWEAPONEX_OpenMasteryMenu", OpenMasteryMenu)