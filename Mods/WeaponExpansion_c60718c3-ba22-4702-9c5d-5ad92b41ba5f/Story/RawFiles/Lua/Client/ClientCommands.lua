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
			local stat = Ext.GetStat(target.Name)
			if stat ~= nil then
				stat.Requirements = v
			end
			--target.Requirements = v
		else
			if type(v) == "table" and target[k] ~= nil then
				SetItemStats(target[k], v)
			else
				local b,err = xpcall(function()
					if k == "Damage Type" then
						k = "DamageType"
					end
					if target[k] ~= nil then
						if Qualifiers[k] == true then
							if v == "None" then
								target[k] = "0"
							else
								target[k] = tostring(v)
							end
						else
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

Ext.RegisterNetListener("LLWEAPONEX_SaveUniqueRequirementChanges", function(cmd, payload)
	Ext.SaveFile("WeaponExpansion_UniqueRequirementChanges.json", payload)
end)

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

			if data.Changes ~= nil then
				local changes = data.Changes
				if changes.Boosts ~= nil and stats.DynamicStats[2] ~= nil then
					SetItemStats(stats.DynamicStats[2], changes.Boosts)
				end
				if changes.Stats ~= nil then
					SetItemStats(stats.DynamicStats[1], changes.Stats)
				end
				if changes.DynamicStats ~= nil then
					SetItemStats(stats.DynamicStats, changes.DynamicStats)
				end
			end
			--stats.ShouldSyncStats = true
			if Vars.DebugEnabled then
				Ext.Print(string.format("[LLWEAPONEX_SetItemStats] Synced Item [%s]", stats.Name))
			end
		elseif Vars.DebugEnabled then
			Ext.PrintError(string.format("[LLWEAPONEX_SetItemStats] Failed to get item. NetID(%s) UUID(%s) Slot(%s) Owner(%s)", data.NetID, data.UUID, data.Slot, data.Owner))
		end
	end
end)