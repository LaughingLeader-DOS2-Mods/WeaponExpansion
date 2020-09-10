---@return StatTreasureCategory
local function CreateBasicCategory(name, isTable, rarities)
	local tbl = {Frequency = 1}

	if isTable == true then
		--tbl.TreasureTable = "T_"..name
		tbl.TreasureTable = name
	else
		tbl.TreasureCategory = name
	end

	if rarities ~= nil then
		for key,v in pairs(rarities) do
			tbl[key] = v
		end
	end
	return tbl
end

---@type table<string, table<string, StatTreasureCategory[]>>
local TreasureTableOverrides = {
	ST_WandNormal = {
		Categories = {
			CreateBasicCategory("ST_LLWEAPONEX_RodsNormal", true, {Common=1})
		}
	},
	ST_TwoHandedNormal = {
		Categories = {
			CreateBasicCategory("ST_LLWEAPONEX_TwoHandedNormal", true, {Common=1})
		}
	},
	ST_OneHandedNormal = {
		Categories = {
			CreateBasicCategory("ST_LLWEAPONEX_OneHandedNormal", true, {Common=1})
		}
	},
	ST_RangedNormal = {
		Categories = {
			CreateBasicCategory("ST_LLWEAPONEX_RangedNormal", true, {Common=1})
		}
	},
	ST_RingAmuletBelt = {
		Categories = {
			CreateBasicCategory("ST_LLWEAPONEX_RingAmuletBelt", true, {Common=1})
		}
	},
	ST_Trader_OneHandedNormal = {
		Categories = {
			CreateBasicCategory("ST_LLWEAPONEX_Trader_OneHandedNormal", true, {Common=1})
		}
	},
	ST_Trader_TwoHandedNormal = {
		Categories = {
			CreateBasicCategory("ST_LLWEAPONEX_Trader_TwoHandedNormal", true, {Common=1})
		}
	},
	ST_Trader_RangedNormal = {
		Categories = {
			CreateBasicCategory("ST_LLWEAPONEX_Trader_RangedNormal", true, {Common=1})
		}
	},
	ST_Trader_RingAmuletBeltNormal = {
		Categories = {
			CreateBasicCategory("ST_LLWEAPONEX_Trader_RingAmuletBeltNormal", true, {Common=1})
		}
	},
}

Ext.RegisterListener("SessionLoaded", function()
	for statName,data in pairs(TreasureTableOverrides) do
		local treasureTable = Ext.GetTreasureTable(statName)
		if treasureTable ~= nil then
			local sub = treasureTable.SubTables[1]
			if sub ~= nil and data.Categories ~= nil then
				for _,entry in pairs(data.Categories) do
					table.insert(sub.Categories, entry)
					if sub.TotalFrequency ~= nil then
						sub.TotalFrequency = sub.TotalFrequency + entry.Frequency
					end
					if Ext.IsDeveloperMode() then
						Ext.Print("Added category",entry.TreasureTable or entry.TreasureCategory,"to",statName)
					end
				end
				Ext.UpdateTreasureTable(treasureTable)
			end
		end
	end
end)