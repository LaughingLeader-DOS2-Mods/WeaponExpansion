local function MouseTest()
	---@type UIObject
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/mouseIcon.swf")
	if ui ~= nil then
		local mouseIconEvent = function(ui, call, ...)
			local params = {...}
			printd("[WeaponExpansion:UI/Init.lua:mouseIconEvent] Function running params("..Common.Dump(params)..")")
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
	ui = Ext.GetBuiltinUI("Public/Game/GUI/characterCreation.swf")
	if ui ~= nil then
		Ext.RegisterUICall(ui, "selectOption", function(ui, ...)
			--print("selectOptions", Ext.JsonStringify({...}))
		end)
	end
end

return {
	MouseTest = MouseTest,
	Client_UIDebugTest = Client_UIDebugTest
}