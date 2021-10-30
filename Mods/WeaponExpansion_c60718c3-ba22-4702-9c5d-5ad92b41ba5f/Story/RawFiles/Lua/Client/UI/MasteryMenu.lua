---@class VisibilityMode
local VisibilityMode = {
	Default = "DEFAULT",
	ShowIfNotZero = "SHOWIFNOTZERO",
	ShowAll = "ShowAll",
}

MasteryMenu = {
	CHARACTER_HANDLE = nil,
	Open = false,
	RegisteredListeners = false,
	Initialized = false,
	---@type UIObject
	Instance = nil,
	---@type UIObject
	ToggleButtonInstance = nil,
	DisplayingSkillTooltip = false,
	DisplayingStatusTooltip = false,
	SelectedMastery = nil,
	LastSelected = 0,
	---@type CharacterMasteryData
	MasteryData = nil,
	IsControllerMode = false,
	Layer = 10,
	---@type VisibilityMode
	RankVisibility = VisibilityMode.Default
}
MasteryMenu.__index = MasteryMenu

---@type MessageData
local MessageData = LeaderLib.Classes["MessageData"]

local CharacterMasteryData = MasteryDataClasses.CharacterMasteryData
local CharacterMasteryDataEntry = MasteryDataClasses.CharacterMasteryDataEntry

---@type LeaderLibInputManager
local Input = LeaderLib.Input

local function CloseMenu(skipRequest)
	if skipRequest == nil then
		skipRequest = false
	end
	if MasteryMenu.Open and MasteryMenu.Instance ~= nil then
		MasteryMenu.Instance:Invoke("closeMenu", skipRequest)
		MasteryMenu.DisplayingSkillTooltip = false
		MasteryMenu.DisplayingStatusTooltip = false
		MasteryMenu.SelectedMastery = nil
		MasteryMenu.Open = false
	end
end

local function OnSheetEvent(ui, call, ...)
	local params = {...}
	--PrintDebug("[WeaponExpansion:MasteryMenu.lua:OnSheetEvent] Event called. call("..tostring(call)..") params("..Common.Dump(params)..")")
	if call == "hotbarBtnPressed" or call == "selectedTab" or call == "showUI" then
		CloseMenu()
	end
end

local function OnSidebarEvent(ui, call, ...)
	local params = {...}
	--PrintDebug("[WeaponExpansion:MasteryMenu.lua:OnSidebarEvent] Event called. call("..tostring(call)..") params("..Common.Dump(params)..")")
	if call == "charSel" then
		CloseMenu()
	end
end

local function OnHotbarEvent(ui, call, ...)
	local params = {...}
	--PrintDebug("[WeaponExpansion:MasteryMenu.lua:OnHotbarEvent] Event called. call("..tostring(call)..") params("..Common.Dump(params)..")")
	
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
		PrintDebug("[WeaponExpansion:MasteryMenu.lua:SetupListeners] Found (characterSheet.swf). Registered listeners.")
	else
		Ext.PrintError("[WeaponExpansion:MasteryMenu.lua:SetupListeners] Failed to find Public/Game/GUI/characterSheet.swf")
	end
	ui = Ext.GetBuiltinUI("Public/Game/GUI/playerInfo.swf")
	if ui ~= nil then
		Ext.RegisterUICall(ui, "charSel", OnSidebarEvent)
		PrintDebug("[WeaponExpansion:MasteryMenu.lua:SetupListeners] Found (playerInfo.swf). Registered listeners.")
	else
		Ext.PrintError("[WeaponExpansion:MasteryMenu.lua:SetupListeners] Failed to find Public/Game/GUI/playerInfo.swf")
	end
	ui = Ext.GetBuiltinUI("Public/Game/GUI/hotBar.swf")
	if ui ~= nil then
		Ext.RegisterUICall(ui, "hotbarBtnPressed", OnHotbarEvent)
		PrintDebug("[WeaponExpansion:MasteryMenu.lua:SetupListeners] Found (hotBar.swf). Registered listeners.")
	else
		Ext.PrintError("[WeaponExpansion:MasteryMenu.lua:SetupListeners] Failed to find Public/Game/GUI/hotBar.swf")
	end
end

local function ClientIsUnset()
	if Client == nil or Client.ID < 0 then
		return true
	end
	return false
end

local requestingToOpenMenu = false

local function TryOpenMasteryMenu()
	requestingToOpenMenu = true
	local character = GameHelpers.Client.GetCharacter() or Client:GetCharacter()
	if character ~= nil then
		local netid = character.NetID
		Ext.PostMessageToServer("LLWEAPONEX_RequestOpenMasteryMenu", tostring(netid))
	end
end

Ext.RegisterNetListener("LLWEAPONEX_TryGetClientID_RequestOpen", function(cmd, payload)
	if requestingToOpenMenu then
		requestingToOpenMenu = false
		local character = GameHelpers.Client.GetCharacter()
		if character ~= nil then
			local profile = ""
			if character.PlayerCustomData ~= nil then
				profile = character.PlayerCustomData.OwnerProfileID
			end
			Ext.PostMessageToServer("LLWEAPONEX_RequestOpenMasteryMenu", Ext.JsonStringify({ID=character.UserID, UUID=character.MyGuid, Profile=profile}))
		end
	end
end)

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
	PrintDebug(string.format("pushDescriptionEntry iconId(%s) iconName(%s) iconType(%s)", iconId, iconName, iconType))
	ui:SetValue("descriptionContent", iconId, index+1)
	ui:SetValue("descriptionContent", iconName, index+2)
	ui:SetValue("descriptionContent", iconType, index+3)
	return index + 4
end

local iconPattern = "(<icon.-/>)"
--<icon id='Target_LLWEAPONEX_BasicAttack' icon='Action_AttackGround'/>

local iconIntId = 0

---@param ui UIObject
local function RegisterIcon(ui, call, name, icon, iconType)
	local iconSize = iconType == 2 and 40 or 64
	ui:ClearCustomIcon(name)
	ui:SetCustomIcon(name, icon, iconSize, iconSize)
end

local function ClearIcons(ui, call, count)
	for i=0,count do
		MasteryMenu.Instance:ClearCustomIcon(string.format("masteryMenu_%i", i))
	end
end

---@param ui UIObject
local function parseDescription(ui, index, descriptionText)
	local icons = {}
	local separatedText = splitDescriptionByPattern(descriptionText,iconPattern)
	for v in string.gmatch(descriptionText, iconPattern) do
		icons[#icons+1] = v
	end
	local result = {}
	for i,v in pairs(separatedText) do
		local icon = icons[i]
		if icon == nil then 
			icon = "" 
		else
			icons[i] = nil
		end
		result[#result+1] = {
			Text = GameHelpers.Tooltip.ReplacePlaceholders(v),
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

	for i,v in pairs(result) do
		if v.Icon ~= "" then
			local _,_,iconName = v.Icon:find("id='(.-)'")
			local _,_,icons = v.Icon:find("icon='(.-)'")
			local _,_,iconType = v.Icon:find("type='(.-)'")
			index = pushDescriptionEntry(ui, index, v.Text, iconName, icons, iconType)
		else
			index = pushDescriptionEntry(ui, index, v.Text, "", "", nil)
		end
	end
	return index
end

local function GetAdditionalMasteryRankText(mastery, rank)
	local parentTable = Mastery.AdditionalRankText[mastery]
	if parentTable ~= nil then
		local rankTable = parentTable[rank]
		if rankTable ~= nil then
			return rankTable
		end
	end
	return nil
end

local function buildMasteryDescription(ui, this, mastery)
	local data = Masteries[mastery]
	local rank = MasteryMenu.MasteryData.Masteries[mastery].Rank
	local index = 0
	for i=1,Mastery.Variables.MaxRank,1 do
		local rankText = "_Rank"..tostring(i)
		local rankDisplayText = GameHelpers.GetStringKeyText("LLWEAPONEX_UI_MasteryMenu" .. rankText)
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
			description = GameHelpers.GetStringKeyText(mastery..rankText.."_Description", "")
			local hasDescription = true
			if description == nil or description == "" then
				description = Text.MasteryMenu.RankPlaceholder.Value
				hasDescription = false
			elseif i > rank then
				description = Text.MasteryMenu.RankLocked.Value
				hasDescription = false
			end
			if hasDescription then
				local extraTextTable = GetAdditionalMasteryRankText(mastery, i)
				if extraTextTable ~= nil then
					for stringKey,enabled in pairs(extraTextTable) do
						if enabled ~= false then
							local text = GameHelpers.GetStringKeyText(stringKey, "")
							if not StringHelpers.IsNullOrEmpty(stringKey) then
								description = description .. "<br>" .. text
							end
						end
					end
				end
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
	this.buildDescription()
end

local function OnMenuEvent(ui, call, ...)
	local this = ui:GetRoot()
	local params = {...}
	if call ~= "overMastery" then
		PrintDebug("[WeaponExpansion:MasteryMenu.lua:OnMenuEvent] Event called. call("..tostring(call)..") params("..tostring(Common.Dump(params))..")")
	end
	if call == "requestCloseUI" or call == "requestCloseMasteryMenu" then
		CloseMenu(true)
	elseif call == "onMasterySelected" then
		MasteryMenu.LastSelected = params[1]
		MasteryMenu.SelectedMastery = params[2]
		buildMasteryDescription(ui, this, MasteryMenu.SelectedMastery)
	elseif call == "selectedMastery" then
		this.selectMastery(params[1])
	elseif call == "mastery_showIconTooltip" then
		if params[1] == 1 then
			MasteryMenu.DisplayingSkillTooltip = true
			ui:ExternalInterfaceCall("showSkillTooltip", MasteryMenu.CHARACTER_HANDLE, params[2], params[3], params[4], params[5], params[6])
		elseif params[1] == 2 then
			ui:ExternalInterfaceCall("showTooltip", GetStatusTooltipText(MasteryMenu.MasteryData.UUID, params[2]), params[3], params[4], params[5], params[6], "right", false)
		elseif params[1] == 3 then
			local specialVals = StringHelpers.Split(params[2], ",")
			if specialVals ~= nil and #specialVals >= 2 then
				local name,_ = GameHelpers.GetStringKeyText(specialVals[1])
				local description,_ = GameHelpers.GetStringKeyText(specialVals[2])
				if name ~= nil then
					local passiveDesc,_ = GameHelpers.GetStringKeyText("LLWEAPONEX_MasteryBonus_Passive_Description")
					name = GameHelpers.Tooltip.ReplacePlaceholders(name)
					if description ~= nil then
						description = GameHelpers.Tooltip.ReplacePlaceholders(description).."<br>"..passiveDesc
					else
						description = passiveDesc
					end
					local text = string.format("<p align='center'><font size='24'>%s</font></p><img src='Icon_Line' width='350%%'><br>%s", name, description)
					ui:ExternalInterfaceCall("showTooltip", text, params[3], params[4], params[5], params[6], "right", false)
				end
			end
		end
	elseif call == "mastery_hideIconTooltip" then
		MasteryMenu.DisplayingSkillTooltip = false
		MasteryMenu.DisplayingStatusTooltip = false
		--ui:ExternalInterfaceCall("hideTooltip")
	end
end

local function sortMasteries(a,b)
	return a:upper() < b:upper()
end

---@param masteryData MasteryData
local function getMasteryDescriptionTitle(masteryData)
	return string.format("<font color='%s'>%s %s</font>", masteryData.Color, masteryData.Name.Value, Text.Mastery.Value)
end

local buttonSpacingX = 16

function MasteryMenu.RepositionToggleButton(dialogOpen)
	local main = MasteryMenu.ToggleButtonInstance:GetRoot()
	if main then
		local menu_btn = main.menu_btn
		if dialogOpen == nil then
			dialogOpen = false
			local dialog = Ext.GetUIByType(Data.UIType.dialog)
			if dialog then
				dialog = dialog:GetRoot()
				if dialog and dialog.dialog_mc.visible then
					dialogOpen = true
				end
			end
		end

		--fprint(LOGLEVEL.TRACE, "sizeHelper.width(%s) sizeHelper.height(%s) screenWidth(%s) screenHeight(%s)", main.sizeHelper.width, main.sizeHelper.height, main.screenWidth, main.screenHeight)

		--MasteryMenu.ToggleButtonInstance:Resize(main.screenWidth, main.screenHeight)

		local scaleDiff = (main.screenWidth / main.designResolution.x)

		local hotbar = not Vars.ControllerEnabled and Ext.GetUIByType(Data.UIType.hotBar) or Ext.GetUIByType(Data.UIType.bottomBar_c)
		if hotbar then
			local hotbarMain = hotbar:GetRoot()
			--MasteryMenu.ToggleButtonInstance:Resize(hotbarMain.stage.stageWidth, hotbarMain.stage.stageHeight)

			if hotbarMain.hotbar_mc.scrollRect ~= nil then
				local hotbarSizeDiff = hotbarMain.hotbar_mc.scrollRect.width / hotbarMain.stage.stageWidth
				local button_x = main.defaultButtonPosition.x * hotbarSizeDiff
				menu_btn.x = button_x
			else
				menu_btn.x = main.defaultButtonPosition.x * (hotbarMain.hotbar_mc.width / hotbarMain.stage.stageWidth)
			end
		else
			menu_btn.x = main.defaultButtonPosition.x
		end

		if dialogOpen then
			--menu_btn.x = 96
			menu_btn.y = main.stage.stageHeight
		else
			menu_btn.y = main.defaultButtonPosition.y
		end

		--fprint(LOGLEVEL.TRACE, "menu_btn.x(%s) menu_btn.y(%s) scaleDiff(%s)", menu_btn.x, menu_btn.y, scaleDiff)
	end
end

function MasteryMenu.SetToggleButtonVisibility(isVisible, tween)
	if MasteryMenu.ToggleButtonInstance ~= nil then
		if not isVisible then
			if tween == true then
				MasteryMenu.ToggleButtonInstance:Invoke("fade", 1.0, 0.0, 0.5)
			else
				MasteryMenu.ToggleButtonInstance:Hide()
			end
		else
			MasteryMenu.RepositionToggleButton()
			if tween == true then
				MasteryMenu.ToggleButtonInstance:Show()
				MasteryMenu.ToggleButtonInstance:Invoke("fade", 0.0, 1.0, 1.2)
			else
				MasteryMenu.ToggleButtonInstance:Show()
			end
		end
		--MasteryMenu.ToggleButtonInstance:Invoke("setToggleButtonVisibility", isVisible)
	end
	if MasteryMenu.Instance ~= nil then
		if not isVisible then
			MasteryMenu.Instance:Hide()
		else
			MasteryMenu.Instance:Show()
		end
		--MasteryMenu.ToggleButtonInstance:Invoke("setToggleButtonVisibility", isVisible)
	end
end

function MasteryMenu.InitializeToggleButton()
	-- TODO: Figure out something for controllers.
	if MasteryMenu.IsControllerMode then
		return false
	end
	local ui = Ext.GetUI("MasteryMenuToggleButton")
	if ui == nil then
		ui = Ext.CreateUI("MasteryMenuToggleButton", "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/MasteryMenuToggleButton.swf", MasteryMenu.Layer)
		if ui ~= nil then
			Ext.RegisterUICall(ui, "toggleMasteryMenu", function(ui,call,...)
				if not MasteryMenu.Open then
					TryOpenMasteryMenu()
				else
					CloseMenu()
				end
			end)
			Ext.RegisterUICall(ui, "repositionMasteryMenuToggleButton", function(ui,call, w, h)
				MasteryMenu.RepositionToggleButton()
			end)
		else
			Ext.PrintError("[WeaponExpansion] Error creating MasteryMenuToggleButton.swf.")
		end
	end
	MasteryMenu.ToggleButtonInstance = ui
	if MasteryMenu.ToggleButtonInstance ~= nil then
		local displayButton = Ext.GetBuiltinUI("Public/Game/GUI/characterCreation.swf") == nil and Ext.GetBuiltinUI("Public/Game/GUI/characterCreation_c.swf") == nil
		if displayButton and SharedData.RegionData.LevelType == LEVELTYPE.CHARACTER_CREATION then
			displayButton = false
		end
		MasteryMenu.SetToggleButtonVisibility(displayButton, false)
		MasteryMenu.RepositionToggleButton()
		ui:Invoke("setToggleButtonTooltip", Text.MasteryMenu.MenuToggleTooltip.Value)
	end
end

local closePanelTypes = {
	Data.UIType.areaInteract_c,
	Data.UIType.characterSheet,
	Data.UIType.containerInventory,
	Data.UIType.craftPanel_c,
	Data.UIType.equipmentPanel_c,
	Data.UIType.partyInventory_c,
	Data.UIType.partyInventory,
	Data.UIType.skills,
	Data.UIType.statsPanel_c,
	Data.UIType.uiCraft,
}

local function CloseOtherPanels()
	for _,id in pairs(closePanelTypes) do
		local ui = Ext.GetUIByType(id)
		if ui then
			--ui:ExternalInterfaceCall("requestCloseUI")
			ui:ExternalInterfaceCall("hideUI")
		end
	end
end

function MasteryMenu.InitializeMasteryMenu()
	local newlyCreated = false
	local ui = Ext.GetUI("MasteryMenu")
	if ui == nil then
		MasteryMenu.RegisteredListeners = false
		PrintDebug("[WeaponExpansion:MasteryMenu.lua:OpenMasteryMenu] Creating mastery menu ui.")
		ui = Ext.CreateUI("MasteryMenu", "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/MasteryMenu.swf", MasteryMenu.Layer)
		newlyCreated = true
	end
	if ui ~= nil and MasteryMenu.Open == false then
		MasteryMenu.Instance = ui
		local this = MasteryMenu.Instance:GetRoot()
		this.controllerEnabled = LeaderLib.Vars.ControllerEnabled
		this.setEmptyListText(Text.MasteryMenu.NoMasteriesTitle.Value, Text.MasteryMenu.NoMasteriesDescription.Value)
		this.setTooltipText(Text.MasteryMenu.MasteredTooltip.Value)
		this.setMaxRank(Mastery.Variables.MaxRank)
		
		local xpMax = Mastery.Variables.RankVariables[Mastery.Variables.MaxRank].Required
		if xpMax <= 0 then
			Ext.PrintError("[WeaponExpansion:MasteryMenu.lua:MasteryMenu.InitializeMasteryMenu] Max mastery XP is (",xpMax,")! Is something configured wrong?")
			xpMax = 12000
		end
		local i = 1
		while i < Mastery.Variables.MaxRank do
			local data = Mastery.Variables.RankVariables[i]
			local barPercentage = 0
			local xp = data.Required
			barPercentage = (xp / xpMax)
			this.setRankNodePosition(i, barPercentage)
			i = i + 1
		end
		if not MasteryMenu.RegisteredListeners then
			ui:SetCustomIcon("masteryMenu_unknown", "LeaderLib_Placeholder", 64, 64)
			Ext.RegisterUICall(ui, "requestCloseUI", OnMenuEvent)
			Ext.RegisterUICall(ui, "requestCloseMasteryMenu", OnMenuEvent)
			Ext.RegisterUICall(ui, "buttonPressed", OnMenuEvent)
			Ext.RegisterUICall(ui, "overMastery", OnMenuEvent)
			Ext.RegisterUICall(ui, "selectedMastery", OnMenuEvent)
			Ext.RegisterUICall(ui, "onMasterySelected", OnMenuEvent)
			Ext.RegisterUICall(ui, "mastery_showIconTooltip", OnMenuEvent)
			Ext.RegisterUICall(ui, "mastery_hideTooltip", OnMenuEvent)
			Ext.RegisterUICall(ui, "registerIcon", RegisterIcon)
			Ext.RegisterUICall(ui, "clearIcons", ClearIcons)
			
			if Vars.DebugMode then
				Ext.RegisterUICall(ui, "showSkillTooltip", OnMenuEvent)
				Ext.RegisterUICall(ui, "showStatusTooltip", OnMenuEvent)
				--Ext.RegisterUICall(ui, "UIAssert", OnMenuEvent)
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
		if newlyCreated then
			ui:Show()
			CloseOtherPanels()
		end
		MasteryMenu.Initialized = true
	else
		Ext.PrintError("[WeaponExpansion:MasteryMenu.lua:OpenMasteryMenu] Error creating mastery menu.")
	end
end

local function InitMasteryMenu()
	if Game.Tooltip.ControllerVars ~= nil then
		MasteryMenu.IsControllerMode = Game.Tooltip.ControllerVars.Enabled
	end
	
	if not MasteryMenu.Initialized and Ext.GetGameState() == "Running" then
		MasteryMenu.InitializeToggleButton()
		MasteryMenu.InitializeMasteryMenu()
	end
end

local function hasMinimumMasteryRankData(t,tag,min)
	if Debug.MasteryTests then
		return true
	end
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
		return string.format("<font color='%s'>%s</font><br>%s xp", rankNameData.Color, rankNameData.Name.Value, Common.FormatNumber(xpMax))
	else
		local rankText = "_Rank"..tostring(i)
		return GameHelpers.GetStringKeyText("LLWEAPONEX_UI_MasteryMenu" .. "_Rank" .. tostring(i))
	end
end

local function BuildMenuEntries(ui)
	local this = ui:GetRoot()
	this.resetList()
	iconIntId = 0
	local masteryKeys = {}
	for tag,data in pairs(Masteries) do
		if MasteryMenu.RankVisibility == VisibilityMode.ShowAll or hasMinimumMasteryRankData(MasteryMenu.MasteryData, tag, 1) then
			table.insert(masteryKeys, tag)
		else
			--PrintDebug("[WeaponExpansion:MasteryMenu.lua:OpenMasteryMenu] Character("..tostring(MasteryMenu.MasteryData.UUID)..") rank for mastery ("..tag..") is <= 0. Skipping displaying entry.")
		end
	end
	table.sort(masteryKeys, sortMasteries)
	
	local i = 0
	for _,tag in pairs(masteryKeys) do
		local data = Masteries[tag]
		local rank = MasteryMenu.MasteryData.Masteries[tag].Rank
		local xp = math.ceil(MasteryMenu.MasteryData.Masteries[tag].XP)
		local xpMax = math.ceil(Mastery.Variables.RankVariables[Mastery.Variables.MaxRank].Required)
		-- if Debug.MasteryTests then
			-- 	MasteryMenu.MasteryData.Masteries[tag].Rank = 4
			-- 	MasteryMenu.MasteryData.Masteries[tag].XP = xpMax
			-- 	rank = 4
			-- 	xp = xpMax
		-- end
		local canShowRank = MasteryMenu.RankVisibility == VisibilityMode.ShowAll or rank > 0
		if not canShowRank then
			if MasteryMenu.RankVisibility == VisibilityMode.ShowIfNotZero and xp > 0 then
				canShowRank = true
			elseif MasteryMenu.RankVisibility == VisibilityMode.Default then
				-- If rank 0, show if at 40% of the way there
				local threshold = Ext.ExtraData.LLWEAPONEX_MasteryMenu_MinRankZeroXPVisibilityThreshold or 0.4
				canShowRank = xp >= math.floor(Mastery.Variables.RankVariables[1].Required*threshold)
			end
		end
		if canShowRank then
			local barPercentage = 0.0
			if xp > 0 and xp < xpMax then
				barPercentage = math.max(math.floor(((xp / xpMax) * 100) + 0.5) / 100, 0.01)
			elseif xp >= xpMax then
				barPercentage = 1.0
			end
			local xpPercentage = math.floor(barPercentage * 100)
			local rankDisplayText = GameHelpers.GetStringKeyText("LLWEAPONEX_UI_MasteryMenu" .. "_Rank"..tostring(rank), "")
			local masteryColorTitle = getMasteryDescriptionTitle(data)
			this.addMastery(i, tag, data.Name.Value, masteryColorTitle, rank, barPercentage, rank >= Mastery.Variables.MaxRank)
			local expRankDisplay = rankDisplayText
			if rank >= Mastery.Variables.MaxRank then
				expRankDisplay = string.format("%s (%s)", Text.MasteryMenu.MasteredTooltip.Value, rankDisplayText)
			end
			this.setExperienceBarTooltip(i, string.format("%s<br>%s<br><font color='#02FF67'>%i%%</font><br><font color='#C9AA58'>%s/%s xp</font>", masteryColorTitle, expRankDisplay, xpPercentage, Common.FormatNumber(xp), Common.FormatNumber(xpMax)))
			
			for k=1,Mastery.Variables.MaxRank,1 do
				this.setRankTooltipText(i, k, getRankTooltip(data, k))
				--print("Set rank tooltip: ", i, k)
			end
			
			PrintDebug("[WeaponExpansion:MasteryMenu.lua:OpenMasteryMenu] mastery("..tag..") rank("..tostring(rank)..") xp("..tostring(xp)..") xpMax("..tostring(xpMax)..") barPercentage("..tostring(barPercentage)..")")
			i = i + 1
		end
	end
	this.selectMastery(MasteryMenu.LastSelected, true)
end

---@param CharacterMasteryData characterMasteryData
local function OpenMasteryMenu(characterMasteryData)
	if not MasteryMenu.Initialized then
		MasteryMenu.InitializeToggleButton()
		MasteryMenu.InitializeMasteryMenu()
		MasteryMenu.MasteryData = characterMasteryData
	end
	if MasteryMenu.CHARACTER_HANDLE == nil then
		MasteryMenu.CHARACTER_HANDLE = Ext.HandleToDouble(Ext.GetCharacter(characterMasteryData.UUID).Handle)
	end
	PrintDebug("[WeaponExpansion:MasteryMenu.lua:OpenMasteryMenu] Opening mastery menu for ("..characterMasteryData.UUID..")")
	--PrintDebug(Common.Dump(characterMasteryData))
	local ui = Ext.GetUI("MasteryMenu")
	if ui ~= nil then
		MasteryMenu.Instance = ui
		local this = MasteryMenu.Instance:GetRoot()
		this.setTitle(Text.MasteryMenu.Title.Value)
		this.setButtonText(Text.MasteryMenu.CloseButton.Value)
		BuildMenuEntries(ui)
		this.selectMastery(MasteryMenu.LastSelected, true)
		this.openMenu()
		MasteryMenu.Open = true
		CloseOtherPanels()
	else
		Ext.PrintError("[WeaponExpansion:MasteryMenu.lua:OpenMasteryMenu] Error opening mastery menu.")
	end
end

local function NetMessage_OpenMasteryMenu(call,data)
	requestingToOpenMenu = false
	---@type CharacterMasteryData
	local characterMasteryData = CharacterMasteryData:Create()
	characterMasteryData:LoadFromString(data)
	MasteryMenu.MasteryData = characterMasteryData
	OpenMasteryMenu(characterMasteryData)
end

Ext.RegisterNetListener("LLWEAPONEX_OpenMasteryMenu", NetMessage_OpenMasteryMenu)

Ext.RegisterListener("GameStateChanged", function(last, next)
	if next == "Running" and last ~= "Paused" then
		if not MasteryMenu.Initialized then
			MasteryMenu.InitializeToggleButton()
			MasteryMenu.InitializeMasteryMenu()
		end
	end
end)

Ext.RegisterNetListener("LLWEAPONEX_InitializeMasteryMenu", function(call,uuid)
	if not MasteryMenu.Initialized and Ext.GetGameState() == "Running" then
		MasteryMenu.InitializeToggleButton()
		MasteryMenu.InitializeMasteryMenu()
	end
end)

Ext.RegisterNetListener("LLWEAPONEX_Debug_DestroyUI", function(...)
	if MasteryMenu.Instance ~= nil then
		MasteryMenu.Instance:Destroy()
	end
	if MasteryMenu.ToggleButtonInstance ~= nil then
		MasteryMenu.ToggleButtonInstance:Destroy()
	end
end)

---@type InputEventCallback
Input.RegisterListener(function(eventName, pressed, id, inputMap, controllerEnabled)
	if not MasteryMenu.Open then
		if controllerEnabled then
			-- Right Trigger + Left Trigger 
			if eventName == "PartyManagement" and Input.IsPressed("PanelSelect") then
				TryOpenMasteryMenu()
			end
		else
			-- CTRL + Shift + M
			--Ext.Print(eventName, Input.GetKeyState("FlashCtrl"), Input.GetKeyState("SplitItemToggle"))
			if eventName == "ToggleMap" and pressed and Input.IsPressed("SplitItemToggle") then
				TryOpenMasteryMenu()
			end
		end
	end
end)

Ext.RegisterUITypeInvokeListener(Data.UIType.dialog, "hideWin", function()
	MasteryMenu.RepositionToggleButton(false)
end)
Ext.RegisterUITypeInvokeListener(Data.UIType.dialog, "hideDialog", function()
	MasteryMenu.RepositionToggleButton(false)
end)
Ext.RegisterUITypeInvokeListener(Data.UIType.dialog, "showWin", function()
	MasteryMenu.RepositionToggleButton(true)
end)
Ext.RegisterUITypeInvokeListener(Data.UIType.dialog, "showDialog", function()
	MasteryMenu.RepositionToggleButton(true)
end)
Ext.RegisterUITypeInvokeListener(Data.UIType.hotBar, "showSkillBar", function(ui,method,visible)
	MasteryMenu.RepositionToggleButton(visible == false)
end)
Ext.RegisterUITypeInvokeListener(Data.UIType.bottomBar_c, "showSkillBar", function(ui,method,visible)
	MasteryMenu.RepositionToggleButton(visible == false)
end)

return {
	Init = InitMasteryMenu
}