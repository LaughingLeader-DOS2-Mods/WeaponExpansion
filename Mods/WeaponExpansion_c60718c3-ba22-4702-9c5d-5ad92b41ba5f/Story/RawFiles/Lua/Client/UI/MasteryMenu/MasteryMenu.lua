---@class MasteryMenuVisibilityMode
local VisibilityMode = {
	Default = "DEFAULT",
	ShowIfNotZero = "SHOWIFNOTZERO",
	ShowAll = "ShowAll",
}

local function ShouldMasteryMenuBeVisible()
	if Ext.GetGameState() == "Running" and not Vars.Resetting and Vars.Initialized and not UIExtensions.CharacterCreation.Visible then
		return MasteryMenu.IsOpen == true
	end
	return false
end

---@class MasteryMenu:UIObjectExtended
MasteryMenu = Classes.UIObjectExtended:Create({
	ID = "WeaponExpansionMasteryMenu",
	Layer = 11,
	SwfPath = "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/MasteryMenu.swf",
	ShouldBeVisible = ShouldMasteryMenuBeVisible,
	DefaultUIFlags = Data.DefaultUIFlags | Data.UIFlags.OF_PlayerInput2 | Data.UIFlags.OF_PlayerInput3 | Data.UIFlags.OF_PlayerInput4,
	ResolutionInitialized = true,
	--OnVisibilityChanged = function (self, last, b) end,
	---@param instance UIObject
	OnInitialized = function (self, instance)
		instance:SetCustomIcon("LLWEAPONEX_MasteryMenu_Unknown", "LeaderLib_Placeholder", 64, 64)
		instance:SetCustomIcon("LLWEAPONEX_MasteryMenu_UnknownSmall", "unknown", 40, 40)
		local this = instance:GetRoot()
		if this then
			self:BuildMasteryMenu(this)
		end
	end,
	--SetPosition = SetPositionToHotbar,
})

MasteryMenu._GetIndex = function (_, k)
	if k == "ToggleButtonInstance" then
		return MasteryMenu.ToggleButton:GetInstance(true)
	end
end

MasteryMenu.IsOpen = false
MasteryMenu.Variables = {
	SelectedMastery = {
		Last = "",
		Current = ""
	},
	CurrentTooltip = nil,
	---@type CharacterMasteryData
	MasteryData = nil,
	RankVisibility = VisibilityMode.Default
}
MasteryMenu.Params = {
	IconType = {
		None = 0,
		Skill = 1,
		Status = 2,
		Passive = 3,
	}
}

function MasteryMenu:SetMastery(mastery)
	self.Variables.SelectedMastery.Last = self.Variables.SelectedMastery.Current
	self.Variables.SelectedMastery.Current = mastery
	local character = GameHelpers.GetCharacter(self.Variables.MasteryData.UUID)
	if not StringHelpers.IsNullOrWhitespace(mastery) then
		local this = self.Root
		if this then
			self:BuildDescription(this, mastery, character)
		end
	end
end

local function HasMinimumMasteryRankData(tbl,tag,min)
	if tbl == nil then
		return false
	end
	local b,result = pcall(function()
		return tbl.Masteries[tag].Rank >= min
	end)
	return result == true
end

local function SortMasteries(a,b)
	return a:upper() < b:upper()
end

---@param masteryData MasteryData
local function GetMasteryDescriptionTitle(masteryData)
	return string.format("<font color='%s'>%s %s</font>", masteryData.Color, masteryData.Name.Value, Text.Mastery.Value)
end

local function GetRankTooltip(data, i)
	local rankNameData = data.Ranks[i]
	local rankName = nil
	local xpMax = math.ceil(Mastery.Variables.RankVariables[i].Required)
	if rankNameData ~= nil then
		return string.format("<font color='%s'>%s</font><br>%s xp", rankNameData.Color, rankNameData.Name.Value, Common.FormatNumber(xpMax))
	else
		return GameHelpers.GetStringKeyText(string.format("LLWEAPONEX_UI_MasteryMenu_Rank%i", i))
	end
	return ""
end

---@private
function MasteryMenu:BuildMasteryEntries(this)
	local characterMasteryData = MasteryMenu.Variables.MasteryData
	local rankVisibility = MasteryMenu.Variables.RankVisibility
	local masteryKeys = {}
	for tag,data in pairs(Masteries) do
		if MasteryMenu.Variables.RankVisibility == VisibilityMode.ShowAll or HasMinimumMasteryRankData(characterMasteryData, tag, 1) then
			masteryKeys[#masteryKeys+1] = tag
		end
	end
	table.sort(masteryKeys, SortMasteries)

	local i = 0
	for _,tag in pairs(masteryKeys) do
		local data = Masteries[tag]
		local rank = characterMasteryData.Masteries[tag].Rank
		local xp = math.ceil(characterMasteryData.Masteries[tag].XP)
		local xpMax = math.ceil(Mastery.Variables.RankVariables[Mastery.Variables.MaxRank].Required)
		if Vars.LeaderDebugMode then
			rank = Mastery.Variables.MaxRank
		end
		if rank >= Mastery.Variables.MaxRank then
			xp = xpMax
		end
		local canShowRank = rankVisibility == VisibilityMode.ShowAll or rank > 0
		if not canShowRank then
			if rankVisibility == VisibilityMode.ShowIfNotZero and xp > 0 then
				canShowRank = true
			elseif rankVisibility == VisibilityMode.Default then
				-- If rank 0, show if at 40% of the way there
				local threshold = GameHelpers.GetExtraData("LLWEAPONEX_MasteryMenu_MinRankZeroXPVisibilityThreshold", 0.4)
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
			local rankDisplayName = GameHelpers.GetStringKeyText(string.format("LLWEAPONEX_UI_MasteryMenu_Rank%i", i))
			local masteryColorTitle = GetMasteryDescriptionTitle(data)
			this.addMastery(tag, data.Name.Value, masteryColorTitle, rank, barPercentage, rank >= Mastery.Variables.MaxRank)
			local expRankDisplay = rankDisplayName
			if rank >= Mastery.Variables.MaxRank then
				expRankDisplay = string.format("%s (%s)", Text.MasteryMenu.MasteredTooltip.Value, rankDisplayName)
			end
			this.setExperienceBarTooltip(i, string.format("%s<br>%s<br><font color='#02FF67'>%i%%</font><br><font color='#C9AA58'>%s/%s xp</font>", masteryColorTitle, expRankDisplay, xpPercentage, Common.FormatNumber(xp), Common.FormatNumber(xpMax)))
			
			for k=1,Mastery.Variables.MaxRank,1 do
				this.setRankTooltipText(i, k, GetRankTooltip(data, k))
				--print("Set rank tooltip: ", i, k)
			end
			i = i + 1
		end
	end
end

function MasteryMenu:BuildMasteryMenu(this)
	this = this or self.Root
	if this then
		this.resetList()
		this.setTitle(Text.MasteryMenu.Title.Value)
		this.setButtonText(Text.MasteryMenu.CloseButton.Value)
		this.controllerEnabled = Vars.ControllerEnabled
		this.setEmptyListText(Text.MasteryMenu.NoMasteriesTitle.Value, Text.MasteryMenu.NoMasteriesDescription.Value)
		this.setTooltipText(Text.MasteryMenu.MasteredTooltip.Value)
		
		this.setMaxRank(Mastery.Variables.MaxRank)
		local xpMax = Mastery.Variables.RankVariables[Mastery.Variables.MaxRank].Required
		if xpMax <= 0 then
			Ext.Utils.PrintError("[WeaponExpansion:MasteryMenu.lua:MasteryMenu.InitializeMasteryMenu] Max mastery XP is (",xpMax,")! Is something configured wrong?")
			xpMax = 12000
		end
		for i=1,Mastery.Variables.MaxRank do
			local data = Mastery.Variables.RankVariables[i]
			local barPercentage = 0
			local xp = data.Required
			barPercentage = (xp / xpMax)
			this.setRankNodePosition(i, barPercentage)
		end

		self:BuildMasteryEntries(this)

		if not StringHelpers.IsNullOrWhitespace(self.Variables.SelectedMastery.Current) then
			this.selectMastery(self.Variables.SelectedMastery.Current, true)
		elseif not StringHelpers.IsNullOrWhitespace(self.Variables.SelectedMastery.Last) then
			this.selectMastery(self.Variables.SelectedMastery.Last, true)
		else
			if not Vars.ControllerEnabled then
				this.masteryMenuMC.selectNone()
			else
				this.masteryMenuMC.top()
			end
		end
	end
end

---@param skipRequest boolean
function MasteryMenu:Close(skipRequest)
	if not self.IsOpen and not skipRequest then
		return true
	end
	if skipRequest == nil then
		skipRequest = false
	end
	self.Variables.CurrentTooltip = nil
	self.Variables.SelectedMastery.Last = self.Variables.SelectedMastery.Current
	self.Variables.SelectedMastery.Current = ""
	self.Variables.MasteryData = nil
	local this = self.Root
	if this then
		this.CloseMenu(skipRequest)
	end
	self.IsOpen = false
end

function MasteryMenu:ForceClose()
	self:Close(true)
end

local closePanelTypes = {
	[false] = {
		Data.UIType.characterSheet,
		Data.UIType.containerInventory.Default,
		Data.UIType.partyInventory,
		Data.UIType.skills,
		Data.UIType.uiCraft,
	},
	[true] = {
		Data.UIType.areaInteract_c,
		Data.UIType.craftPanel_c,
		Data.UIType.containerInventory.Default,
		Data.UIType.equipmentPanel_c,
		Data.UIType.partyInventory_c,
		Data.UIType.statsPanel_c,
	},
}

---@private
function MasteryMenu:CloseOtherPanels()
	for _,id in pairs(closePanelTypes[Vars.ControllerEnabled]) do
		local ui = Ext.UI.GetByType(id)
		if ui then
			--ui:ExternalInterfaceCall("requestCloseUI")
			ui:ExternalInterfaceCall("hideUI")
		end
	end
end

function MasteryMenu:Open(skipRequest)
	if skipRequest then
		self.IsOpen = true
		local this = self.Root
		if this then
			self:BuildMasteryMenu(this)
			this.OpenMenu()
			self:CloseOtherPanels()
		end
	else
		local character = Client:GetCharacter()
		if character then
			Ext.Net.PostMessageToServer("LLWEAPONEX_RequestOpenMasteryMenu", tostring(character.NetID))
		end
	end
end

Ext.RegisterNetListener("LLWEAPONEX_OpenMasteryMenu", function(cmd, payload)
	local data = Common.JsonParse(payload)
	if data then
		---@type CharacterMasteryData
		local characterMasteryData = MasteryDataClasses.CharacterMasteryData:Create(data.UUID, data.Masteries)
		local character = GameHelpers.GetCharacter(data.NetID)
		if character then
			characterMasteryData.Handle = Ext.UI.HandleToDouble(character.Handle)
		end
		MasteryMenu.Variables.MasteryData = characterMasteryData
		MasteryMenu:Open(true)
	end
end)

local statusTooltipFormat = "<p align='center'><font size='24'>%s</font></p><img src='Icon_Line' width='350%%'><br>%s"

function MasteryMenu:PrepareTooltip(iconType, id, descriptionId, x, y, width, height)
	self.ActiveTooltipBonus = id
	local bonus = MasteryBonusManager.GetBonusByID(id)
	local character = Client:GetCharacter()
	local doubleHandle = Ext.UI.HandleToDouble(character.Handle)
	local characterMasteryData = self.Variables.MasteryData
	local ui = self.Instance
	if iconType == self.Params.IconType.Skill then
		self.CurrentTooltip = "Skill"
		ui:ExternalInterfaceCall("showSkillTooltip", doubleHandle, descriptionId, x, y, width, height)
	elseif iconType == self.Params.IconType.Status then
		self.CurrentTooltip = "Status"
		local statusTooltipText = ""
		local statusName = GameHelpers.Stats.GetDisplayName(descriptionId, "StatusData") or ""
		local statusTooltipName = statusName:upper()
		if not Data.EngineStatus[descriptionId] then
			local stat = Ext.Stats.Get(descriptionId, nil, false)
			if stat then
				local statusDescription = GameHelpers.GetStringKeyText(stat.Description, stat.DescriptionRef)
				local addedParams = false
				if not StringHelpers.IsNullOrWhitespace(stat.DescriptionParams) then
					local statusParams = StringHelpers.Split(stat.DescriptionParams, ";")
					if statusParams > 0 then
						local paramValues = GameHelpers.Tooltip.GetStatusDescriptionParamValues(stat, character)
						if #paramValues > 0 then
							statusTooltipText = GameHelpers.Tooltip.ReplacePlaceholders(StringHelpers.ReplacePlaceholders(statusTooltipText, table.unpack(paramValues)), character)
							addedParams = true
						end
					end
				end
				if not addedParams then
					statusTooltipText = GameHelpers.Tooltip.ReplacePlaceholders(statusDescription, character)
				end
			else
				fprint(LOGLEVEL.ERROR, "[WeaponExpansion:MasteryMenu] Stat(%s) does not exist (status tooltip).", id)
			end
		else
			local statusDescription = LocalizedText.StatusDescription[descriptionId]
			if statusDescription then
				statusTooltipText = GameHelpers.Tooltip.ReplacePlaceholders(statusDescription.Value, character)
			end
		end
		if bonus then
			local rankTag = string.format("%s_Mastery%s", bonus.Mastery, bonus.Rank)
			local rankName = GameHelpers.GetStringKeyText(rankTag, "")
			local bonusText = ""
			if not StringHelpers.IsNullOrWhitespace(rankName) then
				bonusText = rankName .. "<br>"
			end
			local bonusTooltipText = bonus:GetTooltipText(character, descriptionId, "status", true)
			if not StringHelpers.IsNullOrEmpty(bonusTooltipText) then
				bonusText = bonusText .. bonusTooltipText
			end
			if not StringHelpers.IsNullOrEmpty(bonusText) then
				if not StringHelpers.IsNullOrEmpty(statusTooltipText) then
					statusTooltipText = statusTooltipText .."<br>"
				end
				statusTooltipText = statusTooltipText .. bonusText
			end
		end
		local finalStatusTooltipText = statusTooltipFormat:format(statusTooltipName, statusTooltipText)
		if not StringHelpers.IsNullOrEmpty(finalStatusTooltipText) then
			ui:ExternalInterfaceCall("showTooltip", finalStatusTooltipText, x, y, width, height, "right", false)
		end
	elseif iconType == self.Params.IconType.Passive then
		local passiveTitle = Text.MasteryMenu.PassiveDisplayName.Value
		local passiveDesc = Text.MasteryMenu.PassiveDescription.Value
		if string.find(id, ",") then
			local specialVals = StringHelpers.Split(id, ",")
			if specialVals ~= nil and #specialVals >= 2 then
				local name,_ = GameHelpers.GetStringKeyText(specialVals[1])
				local description,_ = GameHelpers.GetStringKeyText(specialVals[2])
				if name ~= nil then
					name = GameHelpers.Tooltip.ReplacePlaceholders(name)
					if description ~= nil then
						description = GameHelpers.Tooltip.ReplacePlaceholders(description).."<br>"..passiveDesc
					else
						description = passiveDesc
					end
					local text = string.format("<p align='center'><font size='24'>%s</font></p><img src='Icon_Line' width='350%%'><br>%s", name, description)
					self.CurrentTooltip = "Generic"
					ui:ExternalInterfaceCall("showTooltip", text, x, y, width, height, "right", false)
				end
			end
		elseif bonus then
			local name = GameHelpers.GetStringKeyText(bonus.ID, "")
			if StringHelpers.IsNullOrEmpty(name) then
				name = passiveTitle
			end
			local description = MasteryMenu:GetPassiveText(bonus, character)
			if description ~= nil then
				description = GameHelpers.Tooltip.ReplacePlaceholders(description, character).."<br>"..passiveDesc
			else
				description = passiveDesc
			end
			local text = string.format("<p align='center'><font size='24'>%s</font></p><img src='Icon_Line' width='350%%'><br>%s", name, description)
			self.CurrentTooltip = "Generic"
			ui:ExternalInterfaceCall("showTooltip", text, x, y, width, height, "right", false)
		end
	end
end

function MasteryMenu:ClearTooltip(iconType)
	self.CurrentTooltip = nil
	self.ActiveTooltipBonus = nil
end

function MasteryMenu:OnButtonPressed(buttonType, buttonState)

end

local _registeredIcons = {}

function MasteryMenu:RegisterIcon(name, icon, iconType)
	local ui = self.Instance
	local iconSize = 64
	if iconType >= 2 then
		iconSize = 40
	end
	_registeredIcons[#_registeredIcons+1] = name
	ui:ClearCustomIcon(name)
	ui:SetCustomIcon(name, icon, iconSize, iconSize)
end

---@private
function MasteryMenu:ClearIcons(count)
	local ui = self.Instance
	if ui then
		local totalRegistered = #_registeredIcons
		if totalRegistered > 0 then
			for i=1,totalRegistered do
				ui:ClearCustomIcon(_registeredIcons[i])
			end
			_registeredIcons = {}
		elseif count >= 0 then
			for i=0,count-1 do
				ui:ClearCustomIcon(string.format("LLWEAPONEX_MasteryMenu_%i", i))
			end
		end
	end
end

local function RegisterNameCall(name, callback)
	Ext.RegisterUINameCall(name, function (ui, event, ...)
		local b,err = xpcall(callback, debug.traceback, MasteryMenu, ...)
	end, "Before")
end

RegisterNameCall("LLWEAPONEX_MasteryMenu_RequestCloseUI", MasteryMenu.ForceClose)
--RegisterNameCall("LLWEAPONEX_MasteryMenu_MasteryHovered", MasteryMenu.OnMasteryHover)
RegisterNameCall("LLWEAPONEX_MasteryMenu_MasterySelected", MasteryMenu.SetMastery)
RegisterNameCall("LLWEAPONEX_MasteryMenu_ShowIconTooltip", MasteryMenu.PrepareTooltip)
RegisterNameCall("LLWEAPONEX_MasteryMenu_HideIconTooltip", MasteryMenu.ClearTooltip)
RegisterNameCall("LLWEAPONEX_MasteryMenu_RegisterIcon", MasteryMenu.RegisterIcon)
RegisterNameCall("LLWEAPONEX_MasteryMenu_ClearIcons", MasteryMenu.ClearIcons)
RegisterNameCall("LLWEAPONEX_MasteryMenu_ButtonPressed", MasteryMenu.OnButtonPressed)

local function HideMasteryMenu()
	MasteryMenu:ForceClose()
end

Ext.RegisterUITypeCall(Data.UIType.characterSheet, "selectedTab", HideMasteryMenu)
Ext.RegisterUITypeCall(Data.UIType.characterSheet, "hotbarBtnPressed", HideMasteryMenu)
Ext.RegisterUITypeCall(Data.UIType.characterSheet, "showUI", HideMasteryMenu)
Ext.RegisterUITypeCall(Data.UIType.playerInfo, "charSel", HideMasteryMenu)
Ext.RegisterUITypeCall(Data.UIType.hotBar, "hotbarBtnPressed", HideMasteryMenu)

---@type InputEventCallback
Input.RegisterListener({"PartyManagement", "ToggleMap"}, function(eventName, pressed, id, inputMap, controllerEnabled)
	if not MasteryMenu.IsOpen and Ext.GetGameState() == "Running" then
		if controllerEnabled then
			-- Right Trigger + Left Trigger 
			if eventName == "PartyManagement" and Input.IsPressed("PanelSelect") then
				MasteryMenu:Open()
			end
		else
			-- CTRL + Shift + M
			--Ext.Utils.Print(eventName, Input.GetKeyState("FlashCtrl"), Input.GetKeyState("SplitItemToggle"))
			if eventName == "ToggleMap" and pressed and Input.IsPressed("SplitItemToggle") then
				MasteryMenu:Open()
			end
		end
	end
end)