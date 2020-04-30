local panelOpen = false

local function OnMenuEvent(ui, call, ...)
	local params = {...}
	LeaderLib.PrintDebug("[WeaponExpansion_MasteryMenu.lua:OnMenuEvent] Event called. call("..tostring(call)..") params("..tostring(LeaderLib.Common.Dump(params))..")")
	if call == "requestCloseUI" then
		ui:Hide()
		Ext.DestroyUI("MasteryMenu")
		panelOpen = false
	end
end

local function OpenMasteryMenu(call,uuid)
	LeaderLib.PrintDebug("[WeaponExpansion_MasteryMenu.lua:OpenMasteryMenu] Opening mastery menu for ("..uuid..")")
	local ui = Ext.GetUI("MasteryMenu")
	if ui == nil then
		LeaderLib.PrintDebug("[WeaponExpansion_MasteryMenu.lua:OpenMasteryMenu] Creating mastery menu ui.")
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
	else
		Ext.PrintError("[WeaponExpansion_MasteryMenu.lua:OpenMasteryMenu] Error opening mastery menu.")
	end
end

Ext.RegisterNetListener("LLWEAPONEX_OpenMasteryMenu", OpenMasteryMenu)