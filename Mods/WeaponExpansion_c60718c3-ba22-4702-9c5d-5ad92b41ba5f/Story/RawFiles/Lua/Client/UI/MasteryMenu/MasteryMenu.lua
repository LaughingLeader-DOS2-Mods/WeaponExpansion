---@class MasteryMenuVisibilityMode
local VisibilityMode = {
	Default = "DEFAULT",
	ShowIfNotZero = "SHOWIFNOTZERO",
	ShowAll = "ShowAll",
}

---@class MasteryMenu
---@field Instance UIObject
---@field Root FlashMainTimeline
---@field Exists boolean
MasteryMenu = {
	ID = "WeaponExpansionMasteryMenu",
	Visible = false,
	Variables = {
		SelectedMastery = {
			Last = "",
			Current = ""
		},
		CurrentTooltip = nil,
		---@type CharacterMasteryData
		MasteryData = nil,
		RankVisibility = VisibilityMode.Default
	},
	Params = {
		IconType = {
			None = 0,
			Skill = 1,
			Status = 2,
			Passive = 3,
		}
	},
	Layer = 9
}

local function GetInstance()
	local instance = Ext.GetUI(MasteryMenu.ID)
	if not instance then
		instance = MasteryMenu:Initialize()
	end
	return instance
end

setmetatable(MasteryMenu, {
	__index = function(_,k)
		if k == "Instance" then
			return GetInstance()
		elseif k == "Root" then
			local ui = GetInstance()
			if ui then
				return ui:GetRoot()
			end
		elseif k == "Exists" then
			return Ext.GetUI(MasteryMenu.ID) ~= nil
		end
	end
})

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
	if Debug.MasteryTests or Vars.LeaderDebugMode then
		return true
	end
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
			Ext.PrintError("[WeaponExpansion:MasteryMenu.lua:MasteryMenu.InitializeMasteryMenu] Max mastery XP is (",xpMax,")! Is something configured wrong?")
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
	if not self.Visible then
		return true
	end
	if skipRequest == nil then
		skipRequest = false
	end
	local this = self.Root
	if this then
		this.closeMenu(skipRequest)
		self.Variables.CurrentTooltip = nil
		self.Variables.SelectedMastery.Last = self.Variables.SelectedMastery.Current
		self.Variables.SelectedMastery.Current = ""
		self.Variables.MasteryData = nil
		self.Visible = false
		self.Instance:Hide()
	end
end

local closePanelTypes = {
	[false] = {
		Data.UIType.characterSheet,
		Data.UIType.containerInventory,
		Data.UIType.partyInventory,
		Data.UIType.skills,
		Data.UIType.uiCraft,
	},
	[true] = {
		Data.UIType.areaInteract_c,
		Data.UIType.craftPanel_c,
		Data.UIType.equipmentPanel_c,
		Data.UIType.partyInventory_c,
		Data.UIType.statsPanel_c,
	},
}

---@private
function MasteryMenu:CloseOtherPanels()
	for _,id in pairs(closePanelTypes[Vars.ControllerEnabled]) do
		local ui = Ext.GetUIByType(id)
		if ui then
			--ui:ExternalInterfaceCall("requestCloseUI")
			ui:ExternalInterfaceCall("hideUI")
		end
	end
end

function MasteryMenu:Open(skipRequest)
	if skipRequest then
		local instance = self.Instance
		if instance then
			instance:Show()
			local this = instance:GetRoot()
			if this then
				self:BuildMasteryMenu(this)
				this.openMenu()
				self.Visible = true
				self:CloseOtherPanels()
			end
		end
	else
		local character = Client:GetCharacter()
		if character then
			Ext.PostMessageToServer("LLWEAPONEX_RequestOpenMasteryMenu", tostring(character.NetID))
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
			characterMasteryData.Handle = Ext.HandleToDouble(character.Handle)
		end
		MasteryMenu.Variables.MasteryData = characterMasteryData
		MasteryMenu:Open(true)
	end
end)

---@private
function MasteryMenu:OnMenuEvent(ui, call, ...)
	local characterMasteryData = self.Variables.MasteryData
	local this = ui:GetRoot()
	local params = {...}
	if call == "requestCloseUI" or call == "requestCloseMasteryMenu" then
		self:Close(true)
	elseif call == "onMasterySelected" or call == "selectedMastery" then
		self:SetMastery(params[1])
	elseif call == "mastery_showIconTooltip" then
		local iconType = params[1]
		if iconType == self.Params.IconType.Skill then
			ui:ExternalInterfaceCall("showSkillTooltip", characterMasteryData.Handle, params[2], params[3], params[4], params[5], params[6])
			self.CurrentTooltip = "Skill"
		elseif iconType == self.Params.IconType.Status then
			ui:ExternalInterfaceCall("showTooltip", GetStatusTooltipText(characterMasteryData.UUID, params[2]), params[3], params[4], params[5], params[6], "right", false)
			self.CurrentTooltip = "Status"
		elseif iconType == self.Params.IconType.Passive then
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
					self.CurrentTooltip = "Generic"
				end
			end
		end
	elseif call == "mastery_hideIconTooltip" then
		self.CurrentTooltip = nil
	end
end

---@param ui UIObject
function MasteryMenu:RegisterIcon(ui, call, name, icon, iconType)
	local iconSize = 64
	if iconType >= 2 then
		iconSize = 40
	end
	ui:ClearCustomIcon(name)
	ui:SetCustomIcon(name, icon, iconSize, iconSize)
end

---@private
function MasteryMenu:ClearIcons(ui, call, count)
	local instance = self.Instance
	for i=0,count do
		instance:ClearCustomIcon(string.format("masteryMenu_%i", i))
	end
end

---@private
function MasteryMenu:RegisterUICall(name, callback, instance)
	instance = instance or self.Instance
	Ext.RegisterUICall(instance, name, function(...)
		callback(self, ...)
	end)
end

---@private
function MasteryMenu:RegisterListeners(instance)
	instance = instance or self.Instance
	if instance then
		instance:SetCustomIcon("masteryMenu_unknown", "LeaderLib_Placeholder", 64, 64)
		self:RegisterUICall("requestCloseUI", self.OnMenuEvent, instance)
		self:RegisterUICall("requestCloseMasteryMenu", self.OnMenuEvent, instance)
		self:RegisterUICall("buttonPressed", self.OnMenuEvent, instance)
		self:RegisterUICall("overMastery", self.OnMenuEvent, instance)
		self:RegisterUICall("selectedMastery", self.OnMenuEvent, instance)
		self:RegisterUICall("onMasterySelected", self.OnMenuEvent, instance)
		self:RegisterUICall("mastery_showIconTooltip", self.OnMenuEvent, instance)
		self:RegisterUICall("mastery_hideTooltip", self.OnMenuEvent, instance)
		self:RegisterUICall("registerIcon", self.RegisterIcon, instance)
		self:RegisterUICall("clearIcons", self.ClearIcons, instance)
		
		-- if Vars.DebugMode then
		-- 	Ext.RegisterUICall(instance, "showSkillTooltip", OnMenuEvent)
		-- 	Ext.RegisterUICall(instance, "showStatusTooltip", OnMenuEvent)
		-- 	--Ext.RegisterUICall(instance, "UIAssert", OnMenuEvent)
		-- 	Ext.RegisterUICall(instance, "hideTooltip", OnMenuEvent)
		-- 	Ext.RegisterUICall(instance, "showTooltip", OnMenuEvent)
		-- 	Ext.RegisterUICall(instance, "focusLost", OnMenuEvent)
		-- 	Ext.RegisterUICall(instance, "inputFocusLost", OnMenuEvent)
		-- 	Ext.RegisterUICall(instance, "focus", OnMenuEvent)
		-- 	Ext.RegisterUICall(instance, "inputFocus", OnMenuEvent)
		-- end
	end
end

local defaultUIFlags = Data.DefaultUIFlags | Data.UIFlags.OF_PlayerInput2 | Data.UIFlags.OF_PlayerInput3 | Data.UIFlags.OF_PlayerInput4

---@private
function MasteryMenu:Initialize()
	local instance = Ext.GetUI(MasteryMenu.ID)
	if not instance then
		instance = Ext.CreateUI(MasteryMenu.ID, "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/MasteryMenu.swf", MasteryMenu.Layer, defaultUIFlags)
		self:RegisterListeners(instance)
	end
	return instance
end

Ext.RegisterListener("GameStateChanged", function(last, next)
	if next == "Running" then
		if not MasteryMenu.Exists then
			local instance = MasteryMenu:Initialize()
			if instance then
				instance:Hide()
			end
		end
	end
end)

local function HideMasteryMenu()
	MasteryMenu:Close()
end

--[[
Mods.WeaponExpansion.MasteryMenu:Open(true)
Ext.CreateUI("test", "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/MasteryMenu.swf", 8)
]]

Ext.RegisterUITypeCall(Data.UIType.characterSheet, "selectedTab", HideMasteryMenu)
Ext.RegisterUITypeCall(Data.UIType.characterSheet, "hotbarBtnPressed", HideMasteryMenu)
Ext.RegisterUITypeCall(Data.UIType.characterSheet, "showUI", HideMasteryMenu)
Ext.RegisterUITypeCall(Data.UIType.playerInfo, "charSel", HideMasteryMenu)
Ext.RegisterUITypeCall(Data.UIType.hotBar, "hotbarBtnPressed", HideMasteryMenu)

RegisterListener("BeforeLuaReset", function()
	MasteryMenu:Close(true)
	local instance = MasteryMenu.Instance
	if instance then
		instance:Destroy()
	end
end)

---@type InputEventCallback
Input.RegisterListener({"PartyManagement", "ToggleMap"}, function(eventName, pressed, id, inputMap, controllerEnabled)
	if not MasteryMenu.Visible and Ext.GetGameState() == "Running" then
		if controllerEnabled then
			-- Right Trigger + Left Trigger 
			if eventName == "PartyManagement" and Input.IsPressed("PanelSelect") then
				MasteryMenu:Open()
			end
		else
			-- CTRL + Shift + M
			--Ext.Print(eventName, Input.GetKeyState("FlashCtrl"), Input.GetKeyState("SplitItemToggle"))
			if eventName == "ToggleMap" and pressed and Input.IsPressed("SplitItemToggle") then
				MasteryMenu:Open()
			end
		end
	end
end)

-- RegisterListener("ClientCharacterChanged", function(uuid, userId, profile, netId, isHost)
-- 	if MasteryMenu.Visible then
-- 		MasteryMenu:BuildMasteryMenu()
-- 	end
-- end)