local Qualifiers = {
	StrengthBoost = true,
	FinesseBoost = true,
	IntelligenceBoost = true,
	ConstitutionBoost = true,
	MemoryBoost = true,
	WitsBoost = true,
	MagicPointsBoost = true,
}

---@param tbl table
local function SetItemStats(target, tbl)
	for k,v in pairs(tbl) do
		if k == "Requirements" then
			target.Requirements = v
		else
			if type(v) == "table" then
				SetItemStats(target[k], v)
			else
				local b,err = xpcall(function()
					if target[k] ~= nil then
						if Qualifiers[k] == true then
							if v == "None" then
								target[k] = "0"
							else
								target[k] = tostring(v)
							end
						else
							print(k,v)
							target[k] = v
						end
					end
				end, debug.traceback)
				if not b then
					Ext.PrintError(err)
				end
			end
		end
	end
end

Ext.RegisterNetListener("LLWEAPONEX_SetItemStats", function(cmd, payload)
	local data = Common.JsonParse(payload)
	if data ~= nil then
		---@type EclItem
		local item = nil
		---@type StatItem
		local stats = nil
		if data.NetID ~= nil then
			item = Ext.GetItem(data.NetID)
		end
		if item == nil and data.MyGuid ~= nil then
			item = Ext.GetItem(data.MyGuid)
		end
		if item == nil and data.Owner ~= nil and data.Slot ~= nil then
			local character = Ext.GetCharacter(data.Owner)
			if character ~= nil then
				stats = character.Stats:GetItemBySlot(data.Slot)
			end
		end
		if item ~= nil and stats == nil then
			stats = item.Stats
		end
		
		if stats ~= nil then
			if Ext.Version() < 53 then
				Ext.EnableExperimentalPropertyWrites()
			end
			if data.DynamicIndex ~= nil then
				SetItemStats(stats.DynamicStats[data.DynamicIndex], data.Stats)
			else
				SetItemStats(stats, data.Stats)
			end
			stats.ShouldSyncStats = true
			if Vars.DebugEnabled then
				print(string.format("[LLWEAPONEX_SetItemStats] Synced Item [%s]", stats.Name))
			end
		else
			Ext.PrintError(string.format("[LLWEAPONEX_SetItemStats] Failed to get item. NetID(%s) UUID(%s) Slot(%s) Owner(%s)", data.NetID, data.UUID, data.Slot, data.Owner))
		end
	end
end)