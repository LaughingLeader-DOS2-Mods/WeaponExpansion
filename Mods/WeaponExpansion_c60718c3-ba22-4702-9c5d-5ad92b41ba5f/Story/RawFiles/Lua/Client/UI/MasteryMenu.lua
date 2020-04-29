local panelOpen = false

local function OnMenuEvent(ui, call, ...)
	local params = {...}
	PrintDebug("[WeaponExpansion_MasteryMenu.lua:OnMenuEvent] Event called. call("..tostring(call)..") params("..tostring(Common.Dump(params))..")")
	if call == "switchMenu" then
		SwitchMenu(ui, call, ...)
	elseif call == "requestCloseUI" then
		ui:Hide()
		CloseMenu()
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
		ui:Invoke("modMenuSetTopTitle", "Mods")
		BuildMenu(ui)
		PrintDebug("LeaderLib_ModMenuClient.lua:OpenModMenu] Showing mod menu.")

		ui:Invoke("modMenuSetTitle", "Select a Mod")
		ui:Show()
		ui:Invoke("setMenuScrolling", true)
		ui:Invoke("openMenu")
		ui:ExternalInterfaceCall("requestOpenUI")
		ui:ExternalInterfaceCall("inputFocus")
		ui:ExternalInterfaceCall("show")
		ui:ExternalInterfaceCall("focus")
		panelOpen = true
	end
end

Ext.RegisterNetListener("LLWEAPONEX_OpenMasteryMenu", OpenMasteryMenu)