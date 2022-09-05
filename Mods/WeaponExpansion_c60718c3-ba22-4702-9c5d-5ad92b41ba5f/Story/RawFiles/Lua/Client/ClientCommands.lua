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
			local stat = Ext.Stats.Get(target.Name, nil, false)
			if stat ~= nil then
				stat.Requirements = v
			end
			--target.Requirements = v
		elseif k == "Damage Range" or k == "DamageRange" then
			local damage = Game.Math.GetLevelScaledWeaponDamage(target.Level)
			local minDamage = 0
			local maxDamage = 0
			local baseDamage = damage * (target.DamageFromBase * 0.01)
			local range = baseDamage * (v * 0.01)
			minDamage = Ext.Round(baseDamage - (range/2))
			maxDamage = Ext.Round(baseDamage + (range/2))
			target.MinDamage = minDamage
			target.MaxDamage = maxDamage
		elseif k == "Boosts" then
			local stat = Ext.Stats.Get(target.Name, nil, false)
			if stat ~= nil then
				stat.Boosts = v
			end
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

Ext.RegisterNetListener("LLWEAPONEX_ChangeAttributeRequirement", function(cmd, payload)
	local data = Common.JsonParse(payload, true)
	if data and data.Item and data.Attribute then
		local item = GameHelpers.GetItem(data.Item)
		if item then
			for _,req in pairs(item.Stats.Requirements) do
				if Data.AttributeEnum[req.Requirement] then
					req.Requirement = data.Attribute
				end
			end
		end
	end
end)

Ext.RegisterNetListener("LLWEAPONEX_SetItemStats", function(cmd, payload)
	local data = Common.JsonParse(payload)
	if data ~= nil then
		---@type EclItem
		local item = nil
		---@type StatItem
		local stats = nil
		if data.UUID ~= nil then
			item = GameHelpers.GetItem(data.UUID)
		end
		if item == nil and data.NetID ~= nil then
			item = GameHelpers.GetItem(data.NetID)
		end
		if item == nil and data.Owner ~= nil then
			local owner = GameHelpers.TryGetObject(data.Owner)
			if owner ~= nil then
				if data.Slot ~= nil then
					stats = owner.Stats:GetItemBySlot(data.Slot)
				end
			end
		end
		if item ~= nil and stats == nil then
			stats = item.Stats
		end

		if stats ~= nil then
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
			if Vars.DebugMode then
				Ext.Print(string.format("[LLWEAPONEX_SetItemStats] Synced Item [%s]", stats.Name))
			end
		elseif Vars.DebugMode then
			--Ext.PrintError(string.format("[LLWEAPONEX_SetItemStats] Failed to get item. NetID(%s) UUID(%s) Slot(%s) Owner(%s)", data.NetID, data.UUID, data.Slot, data.Owner))
			fprint(LOGLEVEL.ERROR, "[LLWEAPONEX_SetItemStats] Failed to get item. ID(%s) UUID(%s) NetID(%s)", data.ID, data.UUID, data.NetID)
		end
	end
end)

local rewardScreenItems = {}
local syncUpdateScreenItems = {}

local function SyncItemBoostChanges(item, changes)
	local boostMap = {}
	for i=2,#item.Stats.DynamicStats do
		local boost = item.Stats.DynamicStats[i]
		--PrintLog("[SyncItemBoostChanges] [%s] BoostName(%s) ObjectInstanceName(%s)", i, boost.BoostName, boost.ObjectInstanceName)
		if not StringHelpers.IsNullOrEmpty(boost.ObjectInstanceName) then
			boostMap[boost.ObjectInstanceName] = boost
		end
	end
	for boostName,boosts in pairs(changes) do
		local boostEntry = boostMap[boostName]
		if boostEntry ~= nil then
			for k,v in pairs(boosts) do
				boostEntry[k] = v
			end
		else
			Ext.PrintError(string.format("[LLWEAPONEX_DeltaModSwapper_SyncBoosts] No DynamicStats entry for boost (%s)", boostName))
		end
	end
end

Ext.RegisterNetListener("LLWEAPONEX_DeltaModSwapper_SyncBoosts", function(cmd, payload)
	local data = Common.JsonParse(payload)
	if data ~= nil then
		local item = Ext.GetItem(data.NetID) or rewardScreenItems[data.NetID]
		if item ~= nil then
			SyncItemBoostChanges(item, data.Changes)
		else
			syncUpdateScreenItems[data.NetID] = data.Changes
			if Vars.DebugMode then
				Ext.PrintError(string.format("[LLWEAPONEX_SetItemStats] Failed to get item. NetID(%s)", data.NetID))
			end
		end
	end
end)

local function CaptureRewardScreenItems(ui, method)
	rewardScreenItems = {}
	local main = ui:GetRoot()
	local i = 0
	while i < #main.items_array do
		if main.items_array[i+4] > 0 then
			local handle = main.items_array[i+3]
			if handle ~= nil then
				---@type EclItem
				local item = Ext.GetItem(Ext.DoubleToHandle(handle))
				if item ~= nil then
					if Vars.DebugMode then
						PrintLog("MyGuid(%s) StatsId(%s) ItemType(%s) NetID(%s) WorldPos(%s)", item.MyGuid, item.StatsId, item.ItemType, item.NetID, Common.Dump(item.WorldPos))
					end
					rewardScreenItems[item.NetID] = item
					local changes = syncUpdateScreenItems[item.NetID]
					if changes ~= nil then
						SyncItemBoostChanges(item, changes)
						syncUpdateScreenItems[item.NetID] = nil
					end
				end
			end
		end
		
		i = i + 5
	end
end

Ext.Events.SessionLoaded:Subscribe(function()
	local reward = 136
	local reward_c = 137

	local onRewardScreenClosed = function(ui, call)
		rewardScreenItems = {}
		syncUpdateScreenItems = {}
	end

	if not Vars.ControllerEnabled then
		Ext.RegisterUITypeInvokeListener(reward, "updateItems", CaptureRewardScreenItems)
		Ext.RegisterUITypeCall(reward, "acceptClicked", onRewardScreenClosed)
	else
		Ext.RegisterUITypeInvokeListener(reward_c, "updateItems", CaptureRewardScreenItems)
		Ext.RegisterUITypeCall(reward_c, "acceptClicked", onRewardScreenClosed)
	end
end)

Ext.RegisterNetListener("LLWEAPONEX_PacifistWrath_UpdateDamage", function(cmd, netid)
	netid = tonumber(netid)
	local item = Ext.GetItem(netid)
	if item then
		item.Stats.DynamicStats[1].MinDamage = 1
		item.Stats.DynamicStats[1].MaxDamage = 1
	end
end)

RegisterListener("DebugCommand", "uiext", function (cmd, isClient, data)
	if isClient then
		data.WeaponExpansion = {
			ToggleButton = MasteryMenu.ToggleButton.Instance,
			MasteryMenu = MasteryMenu.Instance,
		}
	end
end)