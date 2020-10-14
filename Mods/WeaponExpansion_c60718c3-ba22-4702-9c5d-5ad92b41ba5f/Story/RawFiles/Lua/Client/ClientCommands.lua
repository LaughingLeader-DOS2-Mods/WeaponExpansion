---@param tbl table
local function SetItemStats(target, tbl)
	for k,v in pairs(tbl) do
		if type(v) == "table" then
			SetItemStats(target[k], v)
		else
			target[k] = v
			print("SetItemStats", k, v)
		end
	end
end

Ext.RegisterNetListener("LLWEAPONEX_SetItemStats", function(cmd, payload)
	local data = Common.JsonParse(payload)
	if data ~= nil then
		if data.NetID ~= nil and data.Stats ~= nil then
			local item = Ext.GetItem(data.NetID)
			if item ~= nil then
				SetItemStats(item.Stats, data.Stats)
			else
				Ext.PrintError("[LLWEAPONEX_SetItemStats] Failed to get item from NetID", data.NetID)
			end
		end
	end
end)