local panelOpen = false
local registeredListeners = false
local initialized = false
local masteryMenu = nil

local function CloseMenu()
	if panelOpen and masteryMenu ~= nil then
		masteryMenu:Invoke("closeMenu")
		panelOpen = false
	end
end

local function OnSheetEvent(ui, call, ...)
	local params = {...}
	LeaderLib.PrintDebug("[WeaponExpansion:MasteryMenu.lua:OnSheetEvent] Event called. call("..tostring(call)..") params("..LeaderLib.Common.Dump(params)..")")

	if call == "hotbarBtnPressed" or call == "selectedTab" or call == "showUI" then
		CloseMenu()
	end
end

local function OnSidebarEvent(ui, call, ...)
	local params = {...}
	LeaderLib.PrintDebug("[WeaponExpansion:MasteryMenu.lua:OnSidebarEvent] Event called. call("..tostring(call)..") params("..LeaderLib.Common.Dump(params)..")")

	if call == "charSel" then
		CloseMenu()
	end
end

local function OnHotbarEvent(ui, call, ...)
	local params = {...}
	LeaderLib.PrintDebug("[WeaponExpansion:MasteryMenu.lua:OnHotbarEvent] Event called. call("..tostring(call)..") params("..LeaderLib.Common.Dump(params)..")")

	if call == "hotbarBtnPressed" then
		CloseMenu()
	end
end

local function SetupListeners()
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/characterSheet.swf")
	if ui ~= nil then
		Ext.RegisterUICall(ui, "selectedTab", OnSheetEvent)
		Ext.RegisterUICall(ui, "hotbarBtnPressed", OnSheetEvent)
		Ext.RegisterUICall(ui, "showUI", OnSheetEvent)
		LeaderLib.PrintDebug("[WeaponExpansion:MasteryMenu.lua:SetupListeners] Found (characterSheet.swf). Registered listeners.")
	else
		Ext.PrintError("[WeaponExpansion:MasteryMenu.lua:SetupListeners] Failed to find Public/Game/GUI/characterSheet.swf")
	end
	ui = Ext.GetBuiltinUI("Public/Game/GUI/playerInfo.swf")
	if ui ~= nil then
		Ext.RegisterUICall(ui, "charSel", OnSidebarEvent)
		LeaderLib.PrintDebug("[WeaponExpansion:MasteryMenu.lua:SetupListeners] Found (playerInfo.swf). Registered listeners.")
	else
		Ext.PrintError("[WeaponExpansion:MasteryMenu.lua:SetupListeners] Failed to find Public/Game/GUI/playerInfo.swf")
	end
	ui = Ext.GetBuiltinUI("Public/Game/GUI/hotBar.swf")
	if ui ~= nil then
		Ext.RegisterUICall(ui, "hotbarBtnPressed", OnHotbarEvent)
		LeaderLib.PrintDebug("[WeaponExpansion:MasteryMenu.lua:SetupListeners] Found (hotBar.swf). Registered listeners.")
	else
		Ext.PrintError("[WeaponExpansion:MasteryMenu.lua:SetupListeners] Failed to find Public/Game/GUI/hotBar.swf")
	end
end

local function TryOpenMasteryMenu()
	-- Try and get the controlled character through net messages
	if CLIENT_ID ~= nil then
		Ext.PostMessageToServer("LLWEAPONEX_RequestOpenMasteryMenu", tostring(CLIENT_ID))
	else
		Ext.PostMessageToServer("LLWEAPONEX_RequestOpenMasteryMenu", "-1")
		LeaderLib.PrintDebug("[WeaponExpansion:MasteryMenu.lua:TryOpenMasteryMenu] CLIENT_ID not set.")
	end
end

local function OnMenuEvent(ui, call, ...)
	local params = {...}
	LeaderLib.PrintDebug("[WeaponExpansion:MasteryMenu.lua:OnMenuEvent] Event called. call("..tostring(call)..") params("..tostring(LeaderLib.Common.Dump(params))..")")
	if call == "requestCloseUI" then
		ui:Invoke("closeMenu")
		panelOpen = false
	elseif call == "toggleMasteryMenu" then
		if not panelOpen then
			TryOpenMasteryMenu()
		else
			ui:Invoke("closeMenu")
		end
		panelOpen = not panelOpen
	elseif call == "selectedMastery" then
		ui:Invoke("selectMastery", params[1])
	end
end

local function sortMasteries(a,b)
	return a:upper() < b:upper()
end

local testDescription = "This is some test description text.<br>Rank 1<br>Crippling Blow<br>If the target is disabled, deal additional piercing damage.<br><br>Rank 2<br>Blitz Attack<br>Each target hit becomes Vulnerable. If hit again, Vulnerable is removed and bonus damage is dealt.<br>Rank 3<br>Some Skill<br>Some other description here.<br><br>Rank 4<br>Super Cool Skill<br>Does all the cool things whenever you need it to. Not broken at all.<br><br><br><br><br>The End"

local function getMasteryDescriptionTitle(text)
	return text:gsub("</font>", " " .. Text.Mastery.Value .. "</font>")
end

local function initializeMasteryMenu()
	local newlyCreated = false
	local ui = Ext.GetUI("MasteryMenu")
	if ui == nil then
		registeredListeners = false
		LeaderLib.PrintDebug("[WeaponExpansion:MasteryMenu.lua:OpenMasteryMenu] Creating mastery menu ui.")
		ui = Ext.CreateUI("MasteryMenu", "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/MasteryMenu.swf", 12)
		newlyCreated = true
	end
	if ui ~= nil and panelOpen == false then
		masteryMenu = ui
		ui:Invoke("setEmptyListText", Text.MasteryMenu.NoMasteriesTitle.Value, Text.MasteryMenu.NoMasteriesDescription.Value)
		if not registeredListeners then
			Ext.RegisterUICall(ui, "requestCloseUI", OnMenuEvent)
			Ext.RegisterUICall(ui, "buttonPressed", OnMenuEvent)
			Ext.RegisterUICall(ui, "toggleMasteryMenu", OnMenuEvent)
			Ext.RegisterUICall(ui, "overMastery", OnMenuEvent)
			Ext.RegisterUICall(ui, "selectedMastery", OnMenuEvent)
			
			if Ext.IsDeveloperMode() then
				Ext.RegisterUICall(ui, "UIAssert", OnMenuEvent)
				Ext.RegisterUICall(ui, "hideTooltip", OnMenuEvent)
				Ext.RegisterUICall(ui, "showTooltip", OnMenuEvent)
				Ext.RegisterUICall(ui, "focusLost", OnMenuEvent)
				Ext.RegisterUICall(ui, "inputFocusLost", OnMenuEvent)
				Ext.RegisterUICall(ui, "focus", OnMenuEvent)
				Ext.RegisterUICall(ui, "inputFocus", OnMenuEvent)
			end
			SetupListeners()
			registeredListeners = true
		end
		ui:Invoke("setToggleButtonTooltip", Text.MasteryMenu.MenuToggleTooltip.Value)
		if newlyCreated then
			ui:Show()
		end
		initialized = true
	else
		Ext.PrintError("[WeaponExpansion:MasteryMenu.lua:OpenMasteryMenu] Error creating mastery menu.")
	end
end

function InitMasteryMenu()
	if not initialized then
		initializeMasteryMenu()
	end
end

local function hasMinimumMasteryRankData(t,tag,min)
	if t == nil then return false end
	return pcall(function()
		return t.Masteries[tag].Rank >= min
	end)
end

---@param CharacterMasteryData characterMasteryData
local function OpenMasteryMenu(characterMasteryData)
	if not initialized then
		initializeMasteryMenu()
	end
	LeaderLib.PrintDebug("[WeaponExpansion:MasteryMenu.lua:OpenMasteryMenu] Opening mastery menu for ("..characterMasteryData.UUID..")")
	LeaderLib.PrintDebug(LeaderLib.Common.Dump(characterMasteryData))
	local ui = Ext.GetUI("MasteryMenu")
	if ui ~= nil then
		masteryMenu = ui
		ui:Invoke("setTitle", Text.MasteryMenu.Title.Value)
		ui:Invoke("setButtonText", Text.MasteryMenu.CloseButton.Value)
		ui:Invoke("resetList")
		local masteryKeys = {}
		for tag,data in pairs(Masteries) do
			if hasMinimumMasteryRankData(characterMasteryData, tag, 1) then
				table.insert(masteryKeys, tag)
			else
				LeaderLib.PrintDebug("[WeaponExpansion:MasteryMenu.lua:OpenMasteryMenu] Character("..tostring(characterMasteryData.UUID)..") rank for mastery ("..tag..") is <= 0. Skipping displaying entry.")
			end
		end
		table.sort(masteryKeys, sortMasteries)
		
		local i = 0
		for _,tag in ipairs(masteryKeys) do
			local data = Masteries[tag]
			local xp = characterMasteryData.Masteries[tag].XP
			local rank = characterMasteryData.Masteries[tag].Rank
			ui:Invoke("addMastery", i, tag, data.Name.Value, getMasteryDescriptionTitle(data.Name.Value), testDescription, 0, xp, true)
			i = i + 1
		end
		ui:Invoke("selectMastery", 0)
		ui:Invoke("openMenu")
		panelOpen = true
	else
		Ext.PrintError("[WeaponExpansion:MasteryMenu.lua:OpenMasteryMenu] Error opening mastery menu.")
	end
end

local function NetMessage_OpenMasteryMenu(call,data)
	---@type CharacterMasteryData
	local characterMasteryData = CharacterMasteryData:Create()
	characterMasteryData:LoadFromString(data)
	OpenMasteryMenu(characterMasteryData)
end

Ext.RegisterNetListener("LLWEAPONEX_OpenMasteryMenu", NetMessage_OpenMasteryMenu)

local function NetMessage_SetClientId(call,id)
	CLIENT_ID = tonumber(id)
	LeaderLib.PrintDebug("[WeaponExpansion:MasteryMenu.lua:NetMessage_SetClientId] Set CLIENT_ID to (",id,")")
	if not initialized then
		initializeMasteryMenu()
	end
end

Ext.RegisterNetListener("LLWEAPONEX_SetClientID", NetMessage_SetClientId)