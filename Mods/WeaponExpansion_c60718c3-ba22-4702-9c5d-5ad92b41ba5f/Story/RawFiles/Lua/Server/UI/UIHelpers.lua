---@type MessageData
local MessageData = LeaderLib.Classes["MessageData"]

Ext.RegisterNetListener("LLWEAPONEX_SetWorldTooltipText_Request", function(cmd, datastr)
	local data = Ext.JsonParse(datastr)
	Ext.PostMessageToUser(data.Client, "LLWEAPONEX_SetWorldTooltipText", data.Text)
end)