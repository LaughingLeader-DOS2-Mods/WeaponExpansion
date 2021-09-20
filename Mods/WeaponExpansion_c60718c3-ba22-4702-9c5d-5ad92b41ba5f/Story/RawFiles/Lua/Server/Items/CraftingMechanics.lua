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

if Vars.DebugMode then
	Ext.RegisterConsoleCommand("llweaponex_tokens", function(cmd)
		local host = CharacterGetHostCharacter()
		for k,template in pairs(attributeToTokenTemplate) do
			local count = CharacterGetItemTemplateCount(host, template) or 0
			if count < 5 then
				ItemTemplateAddTo(template, host, 5 - count, 0)
			end
		end
	end)
end

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
	for i,entry in pairs(entries) do
		local template,item = table.unpack(entry)
		local attribute = attributeTokenTemplates[template]
		if attribute ~= nil then
			return attribute,item
		end
	end
	return nil
end

local function getUniqueItems(entries)
	local uniques = {}
	for i,entry in pairs(entries) do
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

local function craftingTemplateMatch(entries, template, minCount)
	local count = 0
	for i,v in pairs(entries) do
		if template == "NULL_00000000-0000-0000-0000-000000000000" and v == template then
			count = count + 1
		elseif not StringHelpers.IsNullOrEmpty(v) and string.find(v, template) then
			count = count + 1
		end
	end
	return count >= minCount
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
	Ext.Print("[WeaponExpansion:CanCombineItem]",char, a, b, c, d, e, requestIDStr)
end

local craftingActions = {}

---@param char string
function OnCraftingProcessed(char, ...)
	--local requestID = tonumber(requestIDStr)
	local itemArgs = {...}
	Ext.Print("[WeaponExpansion:OnCraftingProcessed]",char, table.unpack(itemArgs))
	local items = {}
	for i,v in pairs(itemArgs) do
		if not StringHelpers.IsNullOrEmpty(v) then
			local template = getTemplateUUID(GetTemplate(v))
			items[#items+1] = {
				template,
				v
			}
		end
	end
	craftingActions[char] = items
	Ext.Print("[WeaponExpansion:OnCraftingProcessed]"..string.format("%s", Ext.JsonStringify(craftingActions)))
end

---@param char string
---@param a string|nil	Combined template
---@param b string|nil	Combined template
---@param c string|nil	Combined template
---@param d string|nil	Combined template
---@param e string|nil	Combined template
---@param newItem string
function ItemTemplateCombinedWithItemTemplate(char, a, b, c, d, e, newItem)
	--Ext.Print("[WeaponExpansion:ItemTemplateCombinedWithItemTemplate]",char, a, b, c, d, e, newItem)
	local craftingEntry = craftingActions[char]
	if craftingEntry ~= nil then
		local attribute,tokenItem = getAttributeTokenAttribute(craftingEntry)
		if attribute ~= nil then
			local uniques = getUniqueItems(craftingEntry)
			for i,v in pairs(uniques) do
				local itemuuid,stat = table.unpack(v)
				local item = Ext.GetItem(itemuuid)
				Ext.Print("[WeaponExpansion:ItemTemplateCombinedWithItemTemplate] "..string.format("Changing unique item scaling for (%s)[%s] to (%s)", itemuuid, stat, attribute))
				ChangeItemScaling(item, attribute, stat)
			end
		end
		craftingActions[char] = nil
	end

	local templates = {a,b,c,d,e}
	-- LOOT_LLWEAPONEX_Token_Shard_dcd92e16-80a6-43bc-89c5-8e147d95606c
	-- 3 shards = a new attribute token of choice
	if craftingTemplateMatch(templates, "dcd92e16%-80a6%-43bc%-89c5%-8e147d95606c", 3) and craftingTemplateMatch(templates, "NULL_00000000-0000-0000-0000-000000000000", 2) then
		CharacterGiveQuestReward(char, "LLWEAPONEX_Rewards_AttributeToken", "QuestReward")
	end
end

---@param item EsvItem
---@param attribute string
---@param itemStat string
function ChangeItemScaling(item, attribute, itemStat)
	if itemStat == nil then
		itemStat = item.Stats.Name
	end
	if itemStat ~= nil then
		---@type StatEntryWeapon
		local stat = Ext.GetStat(itemStat)
		local requirements = stat.Requirements
		if requirements ~= nil then
			local addedRequirement = false
			if #stat.Requirements > 0 then
				for i,req in pairs(requirements) do
					if attributes[req.Requirement] == true then
						req.Requirement = attribute
						addedRequirement = true
					end
				end
			end
			if not addedRequirement then
				table.insert(requirements, {
					Requirement = attribute,
					Param = 0,
					Not = false
				})
			end
		else
			requirements = {
				{
					Requirement = attribute,
					Param = 0,
					Not = false
				}
			}
		end
		stat.Requirements = requirements
		item.Stats.ShouldSyncStats = true
		Ext.Print("[WeaponExpansion:ChangeItemScaling] Changed requirements:"..string.format("%s\n%s", stat.Name, Ext.JsonStringify(stat.Requirements)))
		Ext.SyncStat(itemStat, false)
		PersistentVars.UniqueRequirements[stat.Name] = requirements
		UniqueManager.SaveRequirementChanges()
		--EquipmentManager.SyncItemStatChanges(item, {Stats={Requirements=requirements}})

		local inventory = GetInventoryOwner(item.MyGuid)
		local slot = ObjectIsCharacter(inventory) == 1 and GameHelpers.Item.GetEquippedSlot(inventory,item.MyGuid) or nil
		local clone = GameHelpers.Item.Clone(item)
		if clone then
			if inventory ~= nil then
				if slot ~= nil then
					GameHelpers.Item.EquipInSlot(inventory, clone.MyGuid, slot)
				else
					ItemToInventory(clone.MyGuid, inventory, 1, 0, 0)
				end
			end
			UniqueManager.UpdateUniqueUUID(item, clone, true)
			ItemRemove(item.MyGuid)
		end
	end
end