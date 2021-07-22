Ext.RegisterNetListener("LLWEAPONEX_SetWorldTooltipText_Request", function(cmd, datastr)
	local data = Ext.JsonParse(datastr)
	if data ~= nil and data.ID ~= nil then
		Ext.PostMessageToUser(data.ID, "LLWEAPONEX_SetWorldTooltipText", data.Text)
	end
end)