---@class MasteryMenuToggleButton
---@field Instance UIObject
---@field Root FlashMainTimeline
local ToggleButton = {
	ID = "WeaponExpansionMasteryMenuToggleButton",
	Visible = false,
	Layer = 8
}

local function GetInstance()
	local instance = Ext.GetUI(ToggleButton.ID)
	if not instance then
		instance = ToggleButton:Initialize()
	end
	return instance
end

setmetatable(ToggleButton, {
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

local buttonSpacingX = 16

function ToggleButton:Reposition(this, dialogOpen)
	local this = this or self.Root
	if this then
		local menu_btn = this.menu_btn
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

		--fprint(LOGLEVEL.TRACE, "sizeHelper.width(%s) sizeHelper.height(%s) screenWidth(%s) screenHeight(%s)", this.sizeHelper.width, this.sizeHelper.height, this.screenWidth, this.screenHeight)

		--MasteryMenu.ToggleButtonInstance:Resize(this.screenWidth, this.screenHeight)

		local scaleDiff = (this.stage.stageWidth / this.designResolution.x)
		local padding = 0
		if this.stage.stageWidth > 1920 then
			padding = 128 * scaleDiff
		end

		local hotbar = not Vars.ControllerEnabled and Ext.GetUIByType(Data.UIType.hotBar) or Ext.GetUIByType(Data.UIType.bottomBar_c)
		if hotbar then
			local hotbarMain = hotbar:GetRoot()
			--MasteryMenu.ToggleButtonInstance:Resize(hotbarMain.stage.stageWidth, hotbarMain.stage.stageHeight)

			if hotbarMain.hotbar_mc.scrollRect ~= nil then
				local hotbarSizeDiff = hotbarMain.hotbar_mc.scrollRect.width / hotbarMain.stage.stageWidth
				local button_x = this.defaultButtonPosition.x * hotbarSizeDiff
				menu_btn.x = button_x + padding
			else
				menu_btn.x = this.defaultButtonPosition.x * scaleDiff + padding
			end
		else
			menu_btn.x = this.defaultButtonPosition.x * scaleDiff + padding
		end

		if dialogOpen then
			--menu_btn.x = 96
			menu_btn.y = this.stage.stageHeight
		else
			menu_btn.y = this.defaultButtonPosition.y
		end

		--fprint(LOGLEVEL.TRACE, "menu_btn.x(%s) menu_btn.y(%s) scaleDiff(%s)", menu_btn.x, menu_btn.y, scaleDiff)
	end
end

---@param b boolean
---@param tween boolean
function ToggleButton:SetVisible(b, tween)
	local instance = self.Instance
	if instance then
		local this = instance:GetRoot()
		if b then
			self:Reposition(this)
			instance:Show()
			if tween then
				this.fade(0.0, 1.0, 1.2)
			else
				self.Visible = true
				this.setToggleButtonVisibility(true)
			end
		else
			if tween then
				this.fade(1.0, 0.0, 0.5)
			else
				self.Visible = false
				this.setToggleButtonVisibility(false)
				instance:Hide()
			end
		end
	else
		self.Visible = false
	end
end

---@private
function ToggleButton:RegisterListeners(instance)
	instance = instance or self.Instance
	if instance then
		Ext.RegisterUICall(instance, "toggleMasteryMenu", function(ui,call,...)
			if not MasteryMenu.Visible then
				MasteryMenu:Open()
			else
				MasteryMenu:Close()
			end
		end)
		Ext.RegisterUICall(instance, "repositionMasteryMenuToggleButton", function(ui,call, w, h)
			ToggleButton:Reposition()
		end)
		Ext.RegisterUICall(instance, "masteryMenuToggleButtonFadeOutComplete", function(ui,call)
			self.Visible = false
			self.Instance:Hide()
		end)
		Ext.RegisterUICall(instance, "masteryMenuToggleButtonFadeinComplete", function(ui,call)
			self.Visible = true
		end)
	end
end

local defaultUIFlags = Data.DefaultUIFlags | Data.UIFlags.OF_PlayerInput2 | Data.UIFlags.OF_PlayerInput3 | Data.UIFlags.OF_PlayerInput4

---@private
function ToggleButton:Initialize()
	local instance = Ext.CreateUI(ToggleButton.ID, "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/MasteryMenuToggleButton.swf", self.Layer, defaultUIFlags)
	if instance then
		self:RegisterListeners(instance)

		local displayButton = Ext.GetUIByType(not Vars.ControllerEnabled and Data.UIType.characterCreation or Data.UIType.characterCreation_c) == nil
		if displayButton and SharedData.RegionData.LevelType == LEVELTYPE.CHARACTER_CREATION then
			displayButton = false
		end
		instance:GetRoot().setToggleButtonTooltip(Text.MasteryMenu.MenuToggleTooltip.Value)
		self:SetVisible(displayButton, false)
	end

	return instance
end

Ext.RegisterListener("GameStateChanged", function(last, next)
	if next == "Running" and last ~= "Paused" then
		if not Ext.GetUI(ToggleButton.ID) then
			ToggleButton:Initialize()
		end
	end
end)

MasteryMenu.ToggleButton = ToggleButton