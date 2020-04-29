local panelOpen = false

local function OpenMasteryPanel(call,param)
	local ui = Ext.GetUI("WeaponExpansionMasteryPanel")
	if ui == nil then
		ui = Ext.CreateUI("WeaponExpansionMasteryPanel", "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/MasteryPanel.swf", 99)
	end
	if ui ~= nil and panelOpen == false then
		Ext.RegisterUICall(ui, "switchMenu", OnModMenuEvent)
		Ext.RegisterUICall(ui, "requestCloseUI", OnModMenuEvent)
		--ui:Invoke("updateAddBaseTopTitleText", "Mods")
		ui:Invoke("modMenuSetTopTitle", "Mods")
		BuildMenu(ui)
		PrintDebug("LeaderLib_ModMenuClient.lua:OpenModMenu] Showing mod menu.")

		local gameMenu = Ext.GetBuiltinUI("Public/Game/GUI/gameMenu.swf")
		gameMenu:ExternalInterfaceCall("focusLost")
		gameMenu:ExternalInterfaceCall("inputFocusLost")
		gameMenu:Hide()
		
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

Ext.RegisterNetListener("LLWEAPONEX_OpenMasteryPanel", OpenMasteryPanel)