MasteryMenu = {
	CHARACTER_HANDLE = nil,
	Open = false,
	RegisteredListeners = false,
	Initialized = false,
	---@type UIObject
	Instance = nil,
	DisplayingSkillTooltip = false,
	DisplayingStatusTooltip = false,
	SelectedMastery = nil,
	LastSelected = 0,
	---@type CharacterMasteryData
	MasteryData = nil
}

---@type MessageData
local MessageData = LeaderLib.Classes["MessageData"]

local function CloseMenu()
	if MasteryMenu.Open and MasteryMenu.Instance ~= nil then
		MasteryMenu.Instance:Invoke("closeMenu")
		MasteryMenu.DisplayingSkillTooltip = false
		MasteryMenu.DisplayingStatusTooltip = false
		MasteryMenu.SelectedMastery = nil
		MasteryMenu.Open = false
	end
end

local function OnSheetEvent(ui, call, ...)
	local params = {...}
	--LeaderLib.PrintDebug("[WeaponExpansion:MasteryMenu.lua:OnSheetEvent] Event called. call("..tostring(call)..") params("..LeaderLib.Common.Dump(params)..")")

	if call == "hotbarBtnPressed" or call == "selectedTab" or call == "showUI" then
		CloseMenu()
	end
end

local function OnSidebarEvent(ui, call, ...)
	local params = {...}
	--LeaderLib.PrintDebug("[WeaponExpansion:MasteryMenu.lua:OnSidebarEvent] Event called. call("..tostring(call)..") params("..LeaderLib.Common.Dump(params)..")")

	if call == "charSel" then
		CloseMenu()
	end
end

local function OnHotbarEvent(ui, call, ...)
	local params = {...}
	--LeaderLib.PrintDebug("[WeaponExpansion:MasteryMenu.lua:OnHotbarEvent] Event called. call("..tostring(call)..") params("..LeaderLib.Common.Dump(params)..")")

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
	LeaderLib.PrintDebug("[WeaponExpansion:MasteryMenu.lua:TryOpenMasteryMenu] CLIENT_UI.ID(", CLIENT_UI.ID,")")
	if CLIENT_UI.ID ~= nil then
		Ext.PostMessageToServer("LLWEAPONEX_RequestOpenMasteryMenu", tostring(CLIENT_UI.ID))
	else
		Ext.PostMessageToServer("LLWEAPONEX_RequestOpenMasteryMenu", "-1")
		LeaderLib.PrintDebug("[WeaponExpansion:MasteryMenu.lua:TryOpenMasteryMenu] CLIENT_UI.ID not set.")
	end
end

local function splitDescriptionByPattern(str, pattern, includeMatch)
	local list = {};
	local pos = 1
	local lastMatch = ""
	if string.find("", pattern, 1) then
		return list
	end
	while 1 do
		local first,last,a,b = string.find(str, pattern, pos)
		if first then
			local s = string.sub(str, pos, first-1);
			if s ~= "" then
				if includeMatch == true then
					if lastMatch ~= "" then
						s = lastMatch..s
						lastMatch = ""
					elseif a ~= nil then
						s = a..s
					end
				end
				table.insert(list, s)
			elseif a ~= nil then
				lastMatch = a
			end
			pos = last+1
		else
			local s = string.sub(str, pos);
			if s ~= "" then
				if includeMatch == true then
					if lastMatch ~= "" then
						s = lastMatch..s
						lastMatch = ""
					elseif a ~= nil then
						s = a..s
					end
				end
				table.insert(list, s)
			elseif a ~= nil then
				lastMatch = a
			end
			break
		end
		lastMatch = a
	end
	return list
end

local function pushDescriptionEntry(ui, index, text, iconId, iconName, iconType)
	ui:SetValue("descriptionContent", text, index)
	if iconId == nil then
		iconId = ""
	end
	if iconName == nil then
		iconName = ""
	end
	if iconType == nil then
		if iconId ~= "" then
			iconType = 1
		else
			iconType = 0
		end
	end
	LeaderLib.PrintDebug(string.format("pushDescriptionEntry iconId(%s) iconName(%s) iconType(%s)", iconId, iconName, iconType))
	ui:SetValue("descriptionContent", iconId, index+1)
	ui:SetValue("descriptionContent", iconName, index+2)
	ui:SetValue("descriptionContent", iconType, index+3)
	return index + 4
end

local iconPattern = "(<icon.-/>)"
--<icon id='Target_LLWEAPONEX_BasicAttack' icon='Action_AttackGround'/>
local function parseDescription(ui, index, descriptionText)
	local icons = {}
	local separatedText = splitDescriptionByPattern(descriptionText,iconPattern)
	for v in string.gmatch(descriptionText, iconPattern) do
		icons[#icons+1] = v
	end
	local result = {}
	for i,v in ipairs(separatedText) do
		local icon = icons[i]
		if icon == nil then 
			icon = "" 
		else
			icons[i] = nil
		end
		result[#result+1] = {
			Text = Tooltip.ReplacePlaceholders(v),
			Icon = icon
		}
	end
	for _,v in pairs(icons) do
		if v ~= nil then
			result[#result+1] = {
				Text = "",
				Icon = v
			}
		end
	end
	--print(LeaderLib.Common.Dump(result))
	for i,v in ipairs(result) do
		if v.Icon ~= "" then
			local _,_,iconName = v.Icon:find("id='(.-)'")
			local _,_,icon = v.Icon:find("icon='(.-)'")
			local _,_,iconType = v.Icon:find("type='(.-)'")
			index = pushDescriptionEntry(ui, index, v.Text, iconName, icon, iconType)
		else
			index = pushDescriptionEntry(ui, index, v.Text, "", "", nil)
		end
	end
	return index
end

local function buildMasteryDescription(ui, mastery)
	local data = Masteries[mastery]
	local rank = MasteryMenu.MasteryData.Masteries[mastery].Rank
	local index = 0
	for i=1,Mastery.Variables.MaxRank,1 do
		local rankText = "_Rank"..tostring(i)
		local rankDisplayText = Ext.GetTranslatedStringFromKey("LLWEAPONEX_UI_MasteryMenu" .. rankText)
		local rankNameData = data.Ranks[i]
		local rankName = nil
		if rankNameData ~= nil then
			rankName = rankNameData.Name.Value
		end
		if rankDisplayText ~= nil and rankDisplayText ~= "" then
			local rankHeader = ""
			if rankName ~= nil then
				rankHeader = string.format("<font size='24'>%s: %s</font>", rankDisplayText, rankName)
			else
				rankHeader = string.format("<font size='24'>%s</font>", rankDisplayText)
			end
			local description = ""
			description = Ext.GetTranslatedStringFromKey(mastery..rankText.."_Description")
			local hasDescription = true
			if description == nil or description == "" then
				description = Text.MasteryMenu.RankPlaceholder.Value
				hasDescription = false
			elseif i > rank then
				description = Text.MasteryMenu.RankLocked.Value
				hasDescription = false
			end
			--string.format("<font size='18'>%s</font>", description:gsub("%%", "%%%%")) -- Escaping percentages
			index = pushDescriptionEntry(ui, index, rankHeader)
			if hasDescription then
				index = parseDescription(ui, index, description)
			else
				index = pushDescriptionEntry(ui, index, description) -- Escaping percentages)
			end
		end
		i = i + 1
	end
	ui:Invoke("buildDescription")
end

local function OnMenuEvent(ui, call, ...)
	local params = {...}
	if call ~= "overMastery" then
		LeaderLib.PrintDebug("[WeaponExpansion:MasteryMenu.lua:OnMenuEvent] Event called. call("..tostring(call)..") params("..tostring(LeaderLib.Common.Dump(params))..")")
	end
	if call == "requestCloseUI" then
		CloseMenu()
	elseif call == "toggleMasteryMenu" then
		if not MasteryMenu.Open then
			TryOpenMasteryMenu()
		else
			CloseMenu()
		end
	elseif call == "onMasterySelected" then
		MasteryMenu.LastSelected = params[1]
		MasteryMenu.SelectedMastery = params[2]
		buildMasteryDescription(ui, MasteryMenu.SelectedMastery)
	elseif call == "selectedMastery" then
		ui:Invoke("selectMastery", params[1])
	elseif call == "mastery_showIconTooltip" then
		if params[1] == 1 then
			MasteryMenu.DisplayingSkillTooltip = true
			CLIENT_UI.LAST_SKILL = params[2]
			if Ext.DoubleToHandle ~= nil then
				CLIENT_UI.ACTIVE_CHARACTER = Ext.DoubleToHandle(MasteryMenu.CHARACTER_HANDLE)
			end
			ui:ExternalInterfaceCall("showSkillTooltip", MasteryMenu.CHARACTER_HANDLE, params[2], params[3], params[4], params[5], params[6])
		elseif params[1] == 2 then
			--MasteryMenu.DisplayingStatusTooltip = true
			ui:ExternalInterfaceCall("showTooltip", GetStatusTooltipText(MasteryMenu.MasteryData.UUID, params[2]), params[3], params[4], params[5], params[6], "right", false)
			--ui:ExternalInterfaceCall("showStatusTooltip", MasteryMenu.CHARACTER_HANDLE, params[2], params[3], params[4], params[5], params[6], "leftTop")
			-- x, y, width, height, tooltipPos
			---@type MessageData
			--local data = MessageData:CreateFromTable(MasteryMenu.MasteryData.UUID, {Status = params[2], x = params[3], y = params[4], width=params[5], height=params[6]})
			--Ext.PostMessageToServer("LLWEAPONEX_MasteryMenu_RequestStatusTooltip", data:ToString())
			---@type UIObject
			-- local tooltipUI = Ext.GetBuiltinUI("Public/Shared/GUI/tooltipHelper_kb.swf")
			-- if tooltipUI == nil then tooltipUI = Ext.GetBuiltinUI("Public/Shared/GUI/tooltipHelper.swf") end
			-- if tooltipUI == nil then tooltipUI = Ext.GetBuiltinUI("Public/Shared/GUI/tooltip.swf") end
			-- if tooltipUI == nil then 
			-- 	tooltipUI = Ext.CreateUI("tooltipKB", "Public/Shared/GUI/tooltipHelper_kb.swf", 99) 
			-- end
			-- if tooltipUI ~= nil then
			-- 	local i = 0
			-- 	tooltipUI:SetValue("tooltip_array", LeaderLib.Data.UI.TOOLTIP_TYPE.StatName, i)
			-- 	tooltipUI:SetValue("tooltip_array", "Status Info", i+1)
			-- 	tooltipUI:SetValue("tooltip_array", LeaderLib.Data.UI.TOOLTIP_TYPE.StatsDescription, i+2)
			-- 	tooltipUI:SetValue("tooltip_array", "STATUS?!", i+3)
			-- 	tooltipUI:Invoke("addStatusTooltip", 0, 0)
			-- else
			-- 	Ext.PrintError("tooltipHelper_kb is nil?")
			-- end
		end
	elseif call == "mastery_hideIconTooltip" then
		MasteryMenu.DisplayingSkillTooltip = false
		MasteryMenu.DisplayingStatusTooltip = false
		--ui:ExternalInterfaceCall("hideTooltip")
	end
end

local function NetMessage_StatusHandleRetrieved(call,datastr)
	LeaderLib.PrintDebug("[WeaponExpansion:MasteryMenu.lua:LLWEAPONEX_MasteryMenu_StatusHandleRetrieved] Data:")
	LeaderLib.PrintDebug(datastr)
	local data = MessageData:CreateFromString(datastr)
	if data ~= nil then
		---@type EsvCharacter
		local character = Ext.GetCharacter(data.Params.NetID)--Ext.GetCharacter("S_LeaderLib_Dummy_TargetHelper_A_36069245-0e2d-44b1-9044-6797bd29bb15")
		local statuses = character:GetStatuses()
		print("Statuses:", LeaderLib.Common.Dump(statuses))
		---@type EsvStatus
		local status = character:GetStatus(data.Params.Status)
		if status ~= nil then
			local dummyHandle = Ext.HandleToDouble(character.Handle)
			local statusHandle = Ext.HandleToDouble(1)
			print(status, STATUS_HANDLE_TEST, statusHandle)
		--MasteryMenu.Instance:ExternalInterfaceCall("showTooltip", 7, STATUS_HANDLE_TEST, data.Params.x, data.Params.y, width, height, "right")
		--MasteryMenu.Instance:ExternalInterfaceCall("showTooltip", 7, STATUS_HANDLE_TEST, 18.0, 254.0, 425.0, 32.999496459961, "right")
			--MasteryMenu.Instance:ExternalInterfaceCall("showStatusTooltip", dummyHandle, STATUS_HANDLE_TEST, data.Params.x, data.Params.y, data.Params.width, data.Params.height, "right")
			--("showTooltip", targetMC.tooltip, globalPos.x + xOffset, globalPos.y + yOffset, width, height, tooltipPos, stayOpen);
			--MasteryMenu.Instance:ExternalInterfaceCall("showTooltip", "Test tooltip", data.Params.x, data.Params.y, data.Params.width, data.Params.height, "right", false)
		end
	end
end

Ext.RegisterNetListener("LLWEAPONEX_MasteryMenu_StatusHandleRetrieved", NetMessage_StatusHandleRetrieved)

local function sortMasteries(a,b)
	return a:upper() < b:upper()
end

---@param masteryData MasteryData
local function getMasteryDescriptionTitle(masteryData)
	return string.format("<font color='%s'>%s %s</font>", masteryData.Color, masteryData.Name.Value, Text.Mastery.Value)
end

local function initializeMasteryMenu()
	local newlyCreated = false
	local ui = Ext.GetUI("MasteryMenu")
	if ui == nil then
		MasteryMenu.RegisteredListeners = false
		LeaderLib.PrintDebug("[WeaponExpansion:MasteryMenu.lua:OpenMasteryMenu] Creating mastery menu ui.")
		ui = Ext.CreateUI("MasteryMenu", "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/MasteryMenu.swf", 12)
		newlyCreated = true
	end
	if ui ~= nil and MasteryMenu.Open == false then
		MasteryMenu.Instance = ui
		ui:Invoke("setEmptyListText", Text.MasteryMenu.NoMasteriesTitle.Value, Text.MasteryMenu.NoMasteriesDescription.Value)
		ui:Invoke("setTooltipText", Text.MasteryMenu.MasteredTooltip.Value)
		ui:Invoke("setMaxRank", Mastery.Variables.MaxRank)

		local xpMax = Mastery.Variables.RankVariables[Mastery.Variables.MaxRank].Required
		if xpMax <= 0 then
			Ext.PrintError("[WeaponExpansion:MasteryMenu.lua:initializeMasteryMenu] Max mastery XP is (",xpMax,")! Is something configured wrong?")
			xpMax = 12000
		end
		local i = 1
		while i < Mastery.Variables.MaxRank do
			local data = Mastery.Variables.RankVariables[i]
			local barPercentage = 0
			local xp = data.Required
			barPercentage = (xp / xpMax)
			LeaderLib.PrintDebug("[WeaponExpansion:MasteryMenu.lua:initializeMasteryMenu] rank("..tostring(i)..") xp("..tostring(xp)..") xpMax("..tostring(xpMax)..") barPercentage("..tostring(barPercentage)..")")
			ui:Invoke("setRankNodePosition", i, barPercentage)
			i = i + 1
		end
		if not MasteryMenu.RegisteredListeners then
			Ext.RegisterUICall(ui, "requestCloseUI", OnMenuEvent)
			Ext.RegisterUICall(ui, "buttonPressed", OnMenuEvent)
			Ext.RegisterUICall(ui, "toggleMasteryMenu", OnMenuEvent)
			Ext.RegisterUICall(ui, "overMastery", OnMenuEvent)
			Ext.RegisterUICall(ui, "selectedMastery", OnMenuEvent)
			Ext.RegisterUICall(ui, "onMasterySelected", OnMenuEvent)
			Ext.RegisterUICall(ui, "mastery_showIconTooltip", OnMenuEvent)
			Ext.RegisterUICall(ui, "mastery_hideTooltip", OnMenuEvent)
			
			if Ext.IsDeveloperMode() then
				Ext.RegisterUICall(ui, "showSkillTooltip", OnMenuEvent)
				Ext.RegisterUICall(ui, "showStatusTooltip", OnMenuEvent)
				Ext.RegisterUICall(ui, "UIAssert", OnMenuEvent)
				Ext.RegisterUICall(ui, "hideTooltip", OnMenuEvent)
				Ext.RegisterUICall(ui, "showTooltip", OnMenuEvent)
				Ext.RegisterUICall(ui, "focusLost", OnMenuEvent)
				Ext.RegisterUICall(ui, "inputFocusLost", OnMenuEvent)
				Ext.RegisterUICall(ui, "focus", OnMenuEvent)
				Ext.RegisterUICall(ui, "inputFocus", OnMenuEvent)
			end
			SetupListeners()
			MasteryMenu.RegisteredListeners = true
		end
		ui:Invoke("setToggleButtonTooltip", Text.MasteryMenu.MenuToggleTooltip.Value)
		if newlyCreated then
			ui:Show()
		end
		MasteryMenu.Initialized = true
	else
		Ext.PrintError("[WeaponExpansion:MasteryMenu.lua:OpenMasteryMenu] Error creating mastery menu.")
	end
end

local function InitMasteryMenu()
	if not MasteryMenu.Initialized then
		initializeMasteryMenu()
	end
end

local function hasMinimumMasteryRankData(t,tag,min)
	if t == nil then return false end
	return pcall(function()
		return t.Masteries[tag].Rank >= min
	end)
end

local function getRankTooltip(data, i)
	local rankNameData = data.Ranks[i]
	local rankName = nil
	local xpMax = math.ceil(Mastery.Variables.RankVariables[i].Required)
	if rankNameData ~= nil then
		return string.format("<font color='%s'>%s</font><br>%s xp", rankNameData.Color, rankNameData.Name.Value, LeaderLib.Common.FormatNumber(xpMax))
	else
		local rankText = "_Rank"..tostring(i)
		return Ext.GetTranslatedStringFromKey("LLWEAPONEX_UI_MasteryMenu" .. "_Rank" .. tostring(i))
	end
end

---@param CharacterMasteryData characterMasteryData
local function OpenMasteryMenu(characterMasteryData)
	if not MasteryMenu.Initialized then
		initializeMasteryMenu()
		MasteryMenu.MasteryData = characterMasteryData
	end
	if MasteryMenu.CHARACTER_HANDLE == nil then
		MasteryMenu.CHARACTER_HANDLE = Ext.HandleToDouble(Ext.GetCharacter(characterMasteryData.UUID).Handle)
	end
	LeaderLib.PrintDebug("[WeaponExpansion:MasteryMenu.lua:OpenMasteryMenu] Opening mastery menu for ("..characterMasteryData.UUID..")")
	LeaderLib.PrintDebug(LeaderLib.Common.Dump(characterMasteryData))
	local ui = Ext.GetUI("MasteryMenu")
	if ui ~= nil then
		MasteryMenu.Instance = ui
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
			local rank = characterMasteryData.Masteries[tag].Rank
			local xp = math.ceil(characterMasteryData.Masteries[tag].XP)
			local xpMax = math.ceil(Mastery.Variables.RankVariables[Mastery.Variables.MaxRank].Required)
			local barPercentage = 0.0
			if xp > 0 and xp < xpMax then
				barPercentage = math.floor(((xp / xpMax) * 100) + 0.5) / 100
			elseif xp >= xpMax then
				barPercentage = 1.0
			end
			local xpPercentage = math.floor(barPercentage * 100);
			local rankDisplayText = Ext.GetTranslatedStringFromKey("LLWEAPONEX_UI_MasteryMenu" .. "_Rank"..tostring(rank))
			local masteryColorTitle = getMasteryDescriptionTitle(data)
			ui:Invoke("addMastery", i, tag, data.Name.Value, masteryColorTitle, rank, barPercentage, rank >= Mastery.Variables.MaxRank)
			local expRankDisplay = rankDisplayText
			if rank >= Mastery.Variables.MaxRank then
				expRankDisplay = string.format("%s (%s)", Text.MasteryMenu.MasteredTooltip.Value, rankDisplayText)
			end
			ui:Invoke("setExperienceBarTooltip", i, string.format("%s<br>%s<br><font color='#02FF67'>%i%%</font><br><font color='#C9AA58'>%s/%s xp</font>", masteryColorTitle, expRankDisplay, xpPercentage, LeaderLib.Common.FormatNumber(xp), LeaderLib.Common.FormatNumber(xpMax)))

			for k=1,Mastery.Variables.MaxRank,1 do
				ui:Invoke("setRankTooltipText", i, k, getRankTooltip(data, k))
				--print("Set rank tooltip: ", i, k)
			end

			LeaderLib.PrintDebug("[WeaponExpansion:MasteryMenu.lua:OpenMasteryMenu] mastery("..tag..") rank("..tostring(rank)..") xp("..tostring(xp)..") xpMax("..tostring(xpMax)..") barPercentage("..tostring(barPercentage)..")")
			i = i + 1
		end
		ui:Invoke("selectMastery", MasteryMenu.LastSelected, true)
		ui:Invoke("openMenu")
		MasteryMenu.Open = true
	else
		Ext.PrintError("[WeaponExpansion:MasteryMenu.lua:OpenMasteryMenu] Error opening mastery menu.")
	end
end

local function NetMessage_OpenMasteryMenu(call,data)
	---@type CharacterMasteryData
	local characterMasteryData = CharacterMasteryData:Create()
	characterMasteryData:LoadFromString(data)
	MasteryMenu.MasteryData = characterMasteryData
	OpenMasteryMenu(characterMasteryData)
end

Ext.RegisterNetListener("LLWEAPONEX_OpenMasteryMenu", NetMessage_OpenMasteryMenu)

local function NetMessage_SetClientId(call,id)
	CLIENT_UI.ID = tonumber(id)
	LeaderLib.PrintDebug("[WeaponExpansion:MasteryMenu.lua:NetMessage_SetClientId] Set CLIENT_UI.ID to (",id,")")
	if not MasteryMenu.Initialized then
		initializeMasteryMenu()
	end
end

Ext.RegisterNetListener("LLWEAPONEX_SendClientID", NetMessage_SetClientId)

return {
	Init = InitMasteryMenu
}