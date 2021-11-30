---@class MasteryMenuVisibilityMode
local VisibilityMode = {
	Default = "DEFAULT",
	ShowIfNotZero = "SHOWIFNOTZERO",
	ShowAll = "ShowAll",
}

---@class MasteryMenu
---@field Instance UIObject
---@field Root FlashMainTimeline
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
		MasteryData = nil
	},
	Params = {
		IconType = {
			None = 0,
			Skill = 1,
			Status = 2,
			Passive = 3,
		}
	}
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
		end
	end
})

function MasteryMenu:SetMastery(mastery)
	self.Variables.SelectedMastery.Last = self.Variables.SelectedMastery.Current
	self.Variables.SelectedMastery.Current = mastery
	self:BuildDescription(mastery)
	local this = self.Root
	if this then
		this.selectMastery(mastery, true)
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

		if self.Variables.SelectedMastery.Current then
			self:SetMastery(self.Variables.SelectedMastery.Current)
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
	if not self.Visible then
		if skipRequest ~= true and not self.Variables.MasteryData then
			local character = Client:GetCharacter()
			if character then
				Ext.PostMessageToServer("LLWEAPONEX_RequestOpenMasteryMenu", tostring(character.NetID))
			end
		else
			local this = self.Root
			if this then
				self:BuildMasteryMenu(this)
				this.openMenu()
				self.Visible = true
				self:CloseOtherPanels()
			end
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
	elseif call == "onMasterySelected" then
		local index = params[1]; local mastery = params[2]
		self:SetMastery(mastery)
	elseif call == "selectedMastery" then
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
	local instance = Ext.CreateUI(MasteryMenu.ID, "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/MasteryMenu.swf", MasteryMenu.Layer, defaultUIFlags)
	instance:Invoke("closeMenu", true)
	self:RegisterListeners(instance)
	return instance
end

local function HideMasteryMenu()
	MasteryMenu:Close()
end

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
Input.RegisterListener(function(eventName, pressed, id, inputMap, controllerEnabled)
	if not MasteryMenu.Visible then
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