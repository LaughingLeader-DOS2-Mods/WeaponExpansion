local defaultProps = {
	["Common"] = 0,
	["Divine"] = 0,
	["Epic"] = 0,
	["Frequency"] = 1,
	["Legendary"] = 0,
	["Rare"] = 0,
	["Uncommon"] = 0,
	["Unique"] = 0
}

---@return StatTreasureCategory
local function CreateBasicCategory(name, isTable, params)
	local tbl = {}
	for key,v in pairs(defaultProps) do
		tbl[key] = v
	end

	if isTable == true then
		--tbl.TreasureTable = "T_"..name
		tbl.TreasureTable = name
	else
		tbl.TreasureCategory = name
	end

	if params ~= nil then
		for key,v in pairs(params) do
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

local function ApplyTreasureTableOverrides()
	for statName,data in pairs(TreasureTableOverrides) do
		local treasureTable = Ext.GetTreasureTable(statName)
		if treasureTable ~= nil then
			local sub = treasureTable.SubTables[1]
			if sub then
				if data.Categories ~= nil then
					local categories = {}
					local totalFrequency = 0
					--Make the default stuff more common than the new stuff
					for i,v in pairs(sub.Categories) do
						local id = v.TreasureCategory or v.TreasureTable
						if not string.find(id, "LLWEAPONEX") then
							if v.Frequency and v.Frequency == 1 then
								v.Frequency = v.Frequency + 1
								totalFrequency = totalFrequency + v.Frequency
							end
							table.insert(categories, v)
						end
					end
					for _,entry in pairs(data.Categories) do
						local id = entry.TreasureCategory or entry.TreasureTable
						local inTable = false
						for i,v in pairs(categories) do
							local id2  = v.TreasureCategory or v.TreasureTable
							if id2 == id then
								inTable = true
								break
							end
						end
						if not inTable then
							table.insert(categories, entry)
							totalFrequency = totalFrequency + entry.Frequency
						end
					end
					sub.Categories = categories
					if sub.TotalFrequency then
						sub.TotalFrequency = totalFrequency
					end
					if Vars.DebugMode then
						print(Ext.JsonStringify(treasureTable))
					end
					Ext.UpdateTreasureTable(treasureTable)
				end
			end
		end
	end
end
Ext.RegisterListener("SessionLoaded", ApplyTreasureTableOverrides)