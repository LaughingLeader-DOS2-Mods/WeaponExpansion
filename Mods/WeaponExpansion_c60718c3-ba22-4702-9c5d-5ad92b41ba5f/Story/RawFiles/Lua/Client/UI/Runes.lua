local _lastRuneDoubleHandle = nil
local _lastRuneSlot = -1

local BACKGROUND_COLOR = 0XFF0B0907

local SLOT_SETTINGS = {
	Inventory = {Offset=-1, Size=51},
	Container = {Offset=-1, Size=64},
	Trade = {Offset=-1, Size=51},
	Crafting = {Offset=-1, Size=64},
}

---@param slot_mc FlashMovieClip
---@param enabled? boolean
local function _SetSlotGreyedOut(slot_mc, enabled)
	local gfx = slot_mc.graphics
	if enabled then
		local posOffset = SLOT_SETTINGS.Crafting.Offset
		local slotSize = SLOT_SETTINGS.Crafting.Size
		gfx.clear()
		gfx.beginFill(BACKGROUND_COLOR, 0.5)
		gfx.drawRect(posOffset,posOffset,slotSize,slotSize)
		gfx.endFill()
	else
		gfx.clear()
	end
end

local function _SetSlotIcon(slot_mc, icon, slotIndex)
	if icon == "" then
		slot_mc.name = ("slot%s"):format(slotIndex)
	else
		slot_mc.name = ("iggy_%s"):format(icon)
	end
end

Ext.RegisterUITypeInvokeListener(Data.UIType.uiCraft, "setCraftResultHandle", function (ui, event, doubleHandle, runeSlot)
	_lastRuneDoubleHandle = doubleHandle
	_lastRuneSlot = runeSlot
end, "Before")

local function _ResetSlotsFade(ui)
	local this = ui:GetRoot()
	local inv = this.craftPanel_mc.runesPanel_mc.inventory_mc.inv
	for i=0,#inv.content_array-1 do
		--ui:ClearCustomIcon(("runeInv_slot_%s"):format(i))
		local slot_mc = inv.content_array[i]
		if slot_mc then
			_SetSlotGreyedOut(slot_mc, false)
		end
	end
end

Ext.RegisterUITypeInvokeListener(Data.UIType.uiCraft, "showCraftPanel", _ResetSlotsFade, "Before")
Ext.RegisterUITypeInvokeListener(Data.UIType.uiCraft, "clearSlots", _ResetSlotsFade, "Before")

local _MATERIALS = {
	UIBase = "9169b076-6e8d-44a4-bb52-95eedf9eab63",
	Grid = "ddaeb42d-e781-4c89-a356-40587e4e5b3c",
	LeaderLibUICell = "578416d1-7a23-4e6c-8817-2fea044470c6",
	--partyInvCell = "002ae43c-5c54-4fc5-808c-01f729dc68dc",
}

---@class WeaponExpansionGetRuneInventoryEntry
---@field Index integer
---@field Slot integer
---@field Item EclItem
---@field Hide (fun(self:WeaponExpansionGetRuneInventoryEntry, inv:FlashMovieClip))

---@param ui UIObject
---@param arr FlashArray
---@param arrLen integer
---@param entries WeaponExpansionGetRuneInventoryEntry[]
---@param inv FlashMovieClip|table
local function _RebuildSlots(ui, arr, arrLen, entries, inv)
	local slot = 0
	for i=0,#inv.content_array-1 do
		ui:ClearCustomIcon(("runeInv_slot_%s"):format(i))
	end
	for i=0,arrLen,4 do
		local currentSlot = arr[i]
		if currentSlot and currentSlot ~= -1 then
			arr[i] = slot
			local slot_mc = inv.content_array[slot]
			if slot_mc then
				local entryData = entries[i]
				local icon = entryData.Item.CurrentTemplate.Icon
				if StringHelpers.IsNullOrEmpty(icon) then
					local template = GameHelpers.GetTemplate(entryData.Item, true) --[[@as ItemTemplate]]
					if template then
						icon = template.Icon
					end
				end
				if not StringHelpers.IsNullOrEmpty(icon) then
					local iggyName = ("runeInv_slot_%s"):format(slot)
					_SetSlotIcon(slot_mc, iggyName, slot)
					ui:SetCustomIcon(iggyName, icon, 64, 64, _MATERIALS.LeaderLibUICell)
				end
			end
			slot = slot + 1
		end
	end
end

---@param ui UIObject
---@param inv FlashMovieClip|table
---@param arr FlashArray
---@param arrLen integer
---@return (fun():WeaponExpansionGetRuneInventoryEntry)
---@return table<integer, WeaponExpansionGetRuneInventoryEntry>
local function _GetRuneInventory(ui, inv, arr, arrLen)
	local entries = {}
	local mappedSlots = {}
	local len = 0
	for i=0,arrLen,4 do
		local slot = arr[i]
		local itemHandleDouble = arr[i+1]
		local amount = arr[i+2] or 0
		local unused = arr[i+3]
		if amount > 0 then
			local item = GameHelpers.Client.TryGetItemFromDouble(itemHandleDouble)
			if item then
				local entry = {
					Index = i,
					Item = item,
					Slot = slot,
					Hide = function (self, inv_mc)
						--arr[self.Index] = -1
						arr[self.Index+2] = 0
						local slot_mc = inv.content_array[slot]
						if slot_mc then
							_SetSlotGreyedOut(slot_mc, true)
						end
					end
				}
				len = len + 1
				entries[len] = entry
				mappedSlots[i] = entry
			else
				local slot_mc = inv.content_array[slot]
				if slot_mc then
					_SetSlotGreyedOut(slot_mc, false)
				end
			end
		end
	end
	local i = 0
	local func = function ()
		i = i + 1
		if i <= len then
			return entries[i]
		end
	end
	return func,mappedSlots
end

---@param entry WeaponExpansionGetRuneInventoryEntry
---@param _TAGS table<string, boolean>
local function _MaybeHideItem(entry, _TAGS, inv)
	local template = GameHelpers.GetTemplate(entry.Item)
	for groupName,data in pairs(Config.Runes) do
		if data.RestrictTag and data.RootTemplates and data.RootTemplates[template] then
			for _,tag in pairs(data.RestrictTag) do
				if not _TAGS[tag] then
					entry:Hide(inv)
					return true
				end
			end
		end
	end
end

local function _TryGetRuneTarget(runesPanel_mc)
	local result = nil
	if runesPanel_mc.targetHit_mc ~= nil then
		result = runesPanel_mc.targetHit_mc.itemHandle
		if result and result ~= 0 then
			return result
		end
	end
	if runesPanel_mc.inventory_mc ~= nil and runesPanel_mc.inventory_mc.selectecItemMC ~= nil then
		result = runesPanel_mc.inventory_mc.selectecItemMC.itemHandle
		if result and result ~= 0 then
			return result
		end
	end
	return _lastRuneDoubleHandle
end

Ext.RegisterUITypeInvokeListener(Data.UIType.uiCraft, "updateItems", function (ui, event, ...)
	local this = ui:GetRoot()
	if this.craftPanel_mc.currentPanel == this.runesPanelID then
		local arr = this.itemsUpdateList
		local len = #arr-1
		if len > 0 then
			local runesPanel_mc = this.craftPanel_mc.runesPanel_mc
			local targetItemHandle = _TryGetRuneTarget(runesPanel_mc)
			if targetItemHandle == 0 or targetItemHandle == nil then
				return
			end
			local targetItem = GameHelpers.Client.TryGetItemFromDouble(targetItemHandle)
			if not targetItem then
				--Don't bother trying to hide any runes
				return
			end

			local _TAGS = GameHelpers.GetItemTags(targetItem, true)

			local updateIcons = false

			local restrictTemplates = nil
			if _TAGS.LLWEAPONEX_HandCrossbow_Equipped then
				restrictTemplates = Config.Runes.HandCrossbowArrows.RootTemplates
			elseif _TAGS.LLWEAPONEX_Pistol_Equipped then
				restrictTemplates = Config.Runes.PistolBullets.RootTemplates
			end
			local inv = runesPanel_mc.inventory_mc.inv

			local iterator,mappedSlots = _GetRuneInventory(ui, inv, arr, len)
			print(iterator, mappedSlots, type(iterator))

			if restrictTemplates then
				for entry in iterator do
					local template = GameHelpers.GetTemplate(entry.Item)
					if not restrictTemplates[template] then
						entry:Hide(inv)
						updateIcons = true
					end
				end
			else
				--Hide bullets/arrows if the target item isn't the correct item
				for entry in iterator do
					if _MaybeHideItem(entry, _TAGS, inv) then
						updateIcons = true
					end
					--print(entry.Index, GameHelpers.GetDisplayName(entry.Item), arr[entry.Index], arr[entry.Index+1], arr[entry.Index+2], arr[entry.Index+3])
				end
			end
			-- if updateIcons then
			-- 	_RebuildSlots(ui, arr, len, mappedSlots, inv)
			-- 	fprint(LOGLEVEL.DEFAULT, "id(%s) m_CustomIggyName(%s) m_IggyImageHolder.name(%s)", inv.id, inv.m_CustomIggyName, inv.m_IggyImageHolder.name)
			-- 	if inv.m_CustomIggyName == "inventoryIcons" then
			-- 		inv.customIggyName = ""
			-- 	end
			-- elseif inv.m_CustomIggyName == "" then
			-- 	inv.customIggyName = "inventoryIcons"
			-- end
		end
	end
end, "Before")

Events.BeforeLuaReset:Subscribe(function (e)
	local ui = Ext.UI.GetByType(Data.UIType.uiCraft)
	if ui then
		local this = ui:GetRoot()
		local inv = this.craftPanel_mc.runesPanel_mc.inventory_mc.inv
		inv.customIggyName = "inventoryIcons"
		for i=0,#inv.content_array-1 do
			local slot_mc = inv.content_array[i]
			if slot_mc then
				_SetSlotGreyedOut(slot_mc, false)
			end
		end
	end
end)