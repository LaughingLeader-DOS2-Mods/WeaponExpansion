local lastshowSkillBarValue = nil

Ext.RegisterUITypeInvokeListener(Data.UIType.hotBar, "showSkillBar", function (wrapper, ui, method, visible)
	lastshowSkillBarValue = visible
end, "Before")

---@return boolean
local function IsHotbarVisible()
	if SharedData.RegionData.LevelType ~= LEVELTYPE.GAME then
		return false
	end
	local instance = Ext.GetUIByType(Data.UIType.hotBar)
	if instance then
		local hasFlag = false
		for _,flag in pairs(instance.Flags) do
			if flag == "OF_Visible" then
				hasFlag = true
			end
		end
		if not hasFlag then
			return false
		end
		local this = instance:GetRoot()
		return (this and this.hotbar_mc.isSkillBarShown) or lastshowSkillBarValue == true
	end
	return false
end

local function IsToggleButtonVisible()
	return Ext.GetGameState() == "Running" and IsHotbarVisible()
end

local function SetPositionToHotbar(self)
	local this = self.Root
	if this then
		local dialogOpen = false
		if dialogOpen == nil then
			dialogOpen = false
			local dialog = Ext.GetUIByType(Data.UIType.dialog)
			if dialog and Common.TableHasValue(dialog.Flags, "OF_Visible") then
				dialogOpen = true
				-- local this = dialog:GetRoot()
				-- if this and this.dialog_mc.visible then
				-- 	dialogOpen = true
				-- end
			end
		end

		local x,y = this.defaultButtonPosition.x, this.defaultButtonPosition.y

		if not Vars.ControllerEnabled then
			local hotbar = Ext.GetUIByType(Data.UIType.hotBar)
			if hotbar then
				local targetLayer = hotbar.Layer - 1
				local inst = self.Instance
				if inst.Layer ~= targetLayer then
					inst.Layer = targetLayer
					if Common.TableHasValue(inst.Flags, "OF_Visible") then
						inst:Hide()
						inst:Show()
					end
				end
				local hthis = hotbar:GetRoot()
				if hthis then
					--x = (this.hotbar_mc.x + this.hotbar_mc.chatBtn_mc.x) + 3
					x = (hthis.hotbar_mc.x + hthis.hotbar_mc.basebarFrame_mc.x + hthis.hotbar_mc.portraitHitBox_mc.x + hthis.hotbar_mc.portraitHitBox_mc.width) + (this.menu_btn.width / 2)
					y = (hthis.hotbar_mc.y + hthis.hotbar_mc.actionsButton_mc.y)
				end
			end
		else
			-- local hotbar = Ext.GetUIByType(Data.UIType.bottomBar_c)
			-- if hotbar then
			-- 	local this = hotbar:GetRoot()
			-- 	if this then
			-- 		x = (this.hotbar_mc.x + this.hotbar_mc.chatBtn_mc.x) + 3
			-- 		y = (this.hotbar_mc.y + this.hotbar_mc.chatBtn_mc.y)
			-- 	end
			-- end
		end

		if dialogOpen then
			y = self.Instance.FlashMovieSize[2]
		end
		this.setToggleButtonPosition(x, y)
		this.setToggleButtonTooltip(Text.MasteryMenu.MenuToggleTooltip.Value)
	end
end

local ToggleButton = Classes.UIObjectExtended:Create({
	ID = "WeaponExpansionMasteryMenuToggleButton",
	Layer = 6,
	SwfPath = "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/MasteryMenuToggleButton.swf",
	OnVisibilityChanged = function (self, last, b)
		local this = self.Root
		if b then
			if self.Tween then
				this.fade(0.0, 1.0, 1.2)
			else
				this.setToggleButtonVisibility(true)
			end
		else
			if self.Tween then
				this.fade(1.0, 0.0, 0.5)
			else
				this.setToggleButtonVisibility(false)
			end
		end
	end,
	ShouldBeVisible = IsToggleButtonVisible,
	OnInitialized = function (self, instance)
		local this = self.Root
		if this then
			this.setToggleButtonTooltip(Text.MasteryMenu.MenuToggleTooltip.Value)
		end
	end,
	SetPosition = SetPositionToHotbar,
	Tween = false,
})

Ext.RegisterUINameCall("LLWEAPONEX_MasteryMenu_ToggleMasteryMenu", function (ui, call)
	if not MasteryMenu.IsOpen then
		MasteryMenu:Open()
	else
		MasteryMenu:Close()
	end
end)

Ext.RegisterUINameCall("LLWEAPONEX_MasteryMenu_ToggleButton_FadeinComplete", function (ui, call)
	if IsToggleButtonVisible() then
		ToggleButton:SetVisible(true)
	end
end)

Ext.RegisterUINameCall("LLWEAPONEX_MasteryMenu_ToggleButton_FadeOutComplete", function (ui, call)
	ToggleButton:SetVisible(false)
end)

MasteryMenu.ToggleButton = ToggleButton