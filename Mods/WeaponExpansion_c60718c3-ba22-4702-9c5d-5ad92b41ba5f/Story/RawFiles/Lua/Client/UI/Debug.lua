local function MouseTest()
	---@type UIObject
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/mouseIcon.swf")
	if ui ~= nil then
		local mouseIconEvent = function(ui, call, ...)
			local params = {...}
			LeaderLib.PrintDebug("[WeaponExpansion:UI/Init.lua:mouseIconEvent] Function running params("..LeaderLib.Common.Dump(params)..")")
		end
		Ext.RegisterUIInvokeListener(ui, "setTexture", mouseIconEvent)
		Ext.RegisterUIInvokeListener(ui, "setCrossVisible", mouseIconEvent)
		Ext.RegisterUIInvokeListener(ui, "setVisible", mouseIconEvent)
		Ext.RegisterUIInvokeListener(ui, "startsWith", mouseIconEvent)
		Ext.RegisterUIInvokeListener(ui, "onEventDown", mouseIconEvent)
		Ext.Print("[LLWEAPONEX:Client:UI.lua:MouseTest] Found (Public/Game/GUI/mouseIcon.swf).")
	else
		Ext.Print("[LLWEAPONEX:Client:UI.lua:MouseTest] Failed to get (Public/Game/GUI/mouseIcon.swf).")
	end
end

local function Client_UIDebugTest()
	---@type UIObject
	local ui = nil
	-- local ui = Ext.GetBuiltinUI("Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/mouseIcon_WithCallback.swf")
	-- if ui == nil then
	-- 	Ext.Print("[LLWEAPONEX:Client:UI.lua:SetupOptionsSettings] Failed to get (Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/mouseIcon_WithCallback.swf).")
	ui = Ext.GetBuiltinUI("Public/Game/GUI/skills.swf")
	if ui ~= nil then
		Ext.RegisterUICall(ui, "showSkillTooltip", OnSheetEvent)
	end
	ui = Ext.GetBuiltinUI("Public/Game/GUI/characterSheet.swf")
	if ui ~= nil then
		Ext.RegisterUICall(ui, "setPlayerInfo", OnSheetEvent)
		Ext.RegisterUICall(ui, "showSkillTooltip", OnSheetEvent)
		Ext.RegisterUICall(ui, "showStatTooltip", OnSheetEvent)
		--Ext.RegisterUIInvokeListener(ui, "addSecondaryStat", OnCharacterSheetUpdating)
		Ext.RegisterUIInvokeListener(ui, "updateArraySystem", OnCharacterSheetUpdating)
		Ext.RegisterUICall(ui, "selectCharacter", OnCharacterSelected)
		--Ext.RegisterUIInvokeListener(ui, "selectCharacter", OnCharacterSelected)
		--Ext.RegisterUIInvokeListener(ui, "updateCharList", OnCharacterSelected)
		--Ext.RegisterUIInvokeListener(ui, "cycleCharList", OnCharacterSelected)
	end
	ui = Ext.GetBuiltinUI("Public/Game/GUI/playerInfo.swf")
	if ui ~= nil then
		Ext.RegisterUICall(ui, "showStatusTooltip", OnSheetEvent)
		Ext.RegisterUICall(ui, "charSel", OnCharacterSelected)
	end
	ui = Ext.GetBuiltinUI("Public/Game/GUI/examine.swf")
	if ui ~= nil then
		Ext.RegisterUICall(ui, "showTooltip", OnSheetEvent)
		Ext.RegisterUICall(ui, "showStatusTooltip", OnSheetEvent)
	end
end

return {
	MouseTest = MouseTest,
	Client_UIDebugTest = Client_UIDebugTest
}