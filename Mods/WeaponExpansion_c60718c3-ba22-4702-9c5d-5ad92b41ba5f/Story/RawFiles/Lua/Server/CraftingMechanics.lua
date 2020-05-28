local attributeTokenStats = {
	LOOT_LLWEAPONEX_Token_Strength = "c77de879-b29b-4707-a75c-2c42adc0712b",
	LOOT_LLWEAPONEX_Token_Finesse = "95284549-f8c1-496b-af36-9d96565f6c0f",
	LOOT_LLWEAPONEX_Token_Intelligence = "bc8c81a1-106d-49ef-beac-e97678ba9b16",
	LOOT_LLWEAPONEX_Token_Constitution = "d360798f-50e3-4c9e-b0e5-0c69345b1a92",
	LOOT_LLWEAPONEX_Token_Memory = "1a3acb90-a152-4ebd-8b02-c5fe99f6c0e3",
	LOOT_LLWEAPONEX_Token_Wits = "dfb3db93-2562-46d2-9cd1-5ea5b57b72b9",
}

local attributeToTokenTemplate = {
	Strength = "c77de879-b29b-4707-a75c-2c42adc0712b",
	Finesse = "95284549-f8c1-496b-af36-9d96565f6c0f",
	Intelligence = "bc8c81a1-106d-49ef-beac-e97678ba9b16",
	Constitution = "d360798f-50e3-4c9e-b0e5-0c69345b1a92",
	Memory = "1a3acb90-a152-4ebd-8b02-c5fe99f6c0e3",
	Wits = "dfb3db93-2562-46d2-9cd1-5ea5b57b72b9",
}

local attributeTokenTemplates = {
	["c77de879-b29b-4707-a75c-2c42adc0712b"] = "Strength",
	["95284549-f8c1-496b-af36-9d96565f6c0f"] = "Finesse",
	["bc8c81a1-106d-49ef-beac-e97678ba9b16"] = "Intelligence",
	["d360798f-50e3-4c9e-b0e5-0c69345b1a92"] = "Constitution",
	["1a3acb90-a152-4ebd-8b02-c5fe99f6c0e3"] = "Memory",
	["dfb3db93-2562-46d2-9cd1-5ea5b57b72b9"] = "Wits",
}

local attributes = {
	Strength = true,
	Finesse = true,
	Intelligence = true,
	Constitution = true,
	Memory = true,
	Wits = true,
}

local function getTemplateUUID(str)
	local startIndex,endIndex = string.find(str, "[^_]+$")
	if startIndex ~= nil and endIndex ~= nil then
		return string.sub(str, startIndex, endIndex)
	end
	return str
end

local function getAttributeTokenAttribute(entries)
	for i,v in pairs(entries) do
		local template = getTemplateUUID(GetTemplate(v))
		local attribute = attributeTokenTemplates[template]
		if attribute ~= nil then
			return v
		end
	end
	return nil
end

local function getUniqueItems(entries)
	local uniques = {}
	for i,entry in ipairs(entries) do
		local template,item = table.unpack(entry)
		if ObjectExists(item) == 1 then
			local stat = NRD_ItemGetStatsId(item)
			if stat ~= nil and Ext.StatGetAttribute(stat, "Unique") == 1 then
				uniques[#uniques+1] = {item, stat}
			end
		end
	end
	return uniques
end

---@param char string
---@param a string
---@param b string
---@param c string
---@param d string
---@param e string
---@param requestIDStr string
function CanCombineItem(char, a, b, c, d, e, requestIDStr)
	--local requestID = tonumber(requestIDStr)
	
end

local craftingActions = {}

---@param char string
function OnCraftingProcessed(char, ...)
	--local requestID = tonumber(requestIDStr)
	local itemArgs = {...}
	local items = {}
	for i,v in ipairs(itemArgs) do
		local template = getTemplateUUID(GetTemplate(v))
		items[#items+1] = {
			template,
			v
		}
	end
	craftingActions[char] = items
end

---@param char string
---@param a string|nil	Combined template
---@param b string|nil	Combined template
---@param c string|nil	Combined template
---@param d string|nil	Combined template
---@param e string|nil	Combined template
---@param newItem string
function ItemTemplateCombinedWithItemTemplate(char, a, b, c, d, e, newItem)
	local craftingEntry = craftingActions[char]
	if craftingEntry ~= nil then
		local attribute = getAttributeTokenAttribute({a,b,c,d,e})
		if attribute ~= nil then
			local uniques = getUniqueItems(craftingEntry)
			for i,v in pairs(uniques) do
				local item,stat = table.unpack(v)
				Ext.Print("[WeaponExpansion] "..string.format("Changing unique item scaling for (%s)[%s] to (%s)", item, stat, attribute))
				ChangeItemScaling(item, attribute, stat)
			end
		end
		craftingActions[char] = nil
	end
end

function ChangeItemScaling(item, attribute, itemStat)
	if itemStat == nil then
		itemStat = NRD_ItemGetStatsId(item)
	end
	---@type StatEntryWeapon
	local stat = Ext.GetStat(itemStat)
	if stat.Requirements ~= nil then
		local addedRequirement = false
		if #stat.Requirements > 0 then
			for i,req in pairs(stat.Requirements) do
				if attributeTokens[req.Requirement] ~= nil then
					req.Requirement = attribute
					addedRequirement = true
				end
			end
		end
		if not addedRequirement then
			table.insert(stat.Requirements, {
				Requirement = attribute,
				Param = 0,
				Not = false
			})
		end
	else
		stat.Requirements = {
			{
				Requirement = attribute,
				Param = 0,
				Not = false
			}
		}
	end
    Ext.SyncStat(stat)
end