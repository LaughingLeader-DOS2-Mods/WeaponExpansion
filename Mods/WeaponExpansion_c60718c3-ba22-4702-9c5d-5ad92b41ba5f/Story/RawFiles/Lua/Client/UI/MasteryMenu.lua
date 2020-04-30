local panelOpen = false

local function OnMenuEvent(ui, call, ...)
	local params = {...}
	LeaderLib.PrintDebug("[WeaponExpansion_MasteryMenu.lua:OnMenuEvent] Event called. call("..tostring(call)..") params("..tostring(LeaderLib.Common.Dump(params))..")")
	if call == "requestCloseUI" then
		ui:Hide()
		Ext.DestroyUI("MasteryMenu")
		panelOpen = false
	elseif call == "selectedMastery" then
		ui:Invoke("selectMastery", params[1])
	end
end

local function sortMasteries(a,b)
	return a:upper() < b:upper()
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
		Ext.RegisterUICall(ui, "UIAssert", OnMenuEvent)
		Ext.RegisterUICall(ui, "overMastery", OnMenuEvent)
		Ext.RegisterUICall(ui, "selectedMastery", OnMenuEvent)
		Ext.RegisterUICall(ui, "buttonPressed", OnMenuEvent)
		--ui:Invoke("updateAddBaseTopTitleText", "Mods")
		ui:Invoke("setTitle", "Weapon Masteries")
		ui:Invoke("setButtonText", "Confirm")
		local masteryKeys = {}
		for tag,data in pairs(Masteries) do
			table.insert(masteryKeys, tag)
		end
		table.sort(masteryKeys, sortMasteries)
		
		local i = 0
		for _,tag in ipairs(masteryKeys) do
			local data = Masteries[tag]
			ui:Invoke("addMastery", i, data.Name.Value, tag, 1)
			i = i + 1
		end
		ui:Invoke("selectMastery", 2)
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