---@class UniqueData
local UniqueData = {
	UUID = "",
	LevelData = {},
	Owner = nil,
	---@type string|table<string,string>
	DefaultOwner = nil,
	CurrentLevel = nil,
	AutoEquipOnOwner = false,
	Initialized = false,
	---@type function
	OnEquipped = nil,
	---@type function
	OnOwnerDeath = nil,
	---@type function
	OnGotOwner = nil,
	LastProgressionLevel = 0,
	ProgressionData = nil,
	CanMoveToVendingMachine = true
}
UniqueData.__index = UniqueData

---@param uuid string
---@param progressionData table<string, table<int, UniqueProgressionEntry>>
---@param params table<string,any>
---@return UniqueData
function UniqueData:Create(uuid, progressionData, params)
    local this =
    {
		UUID = uuid,
		LevelData = {},
		Owner = nil,
		DefaultOwner = nil,
		AutoEquipOnOwner = false,
		Initialized = false,
		OnEquipped = nil,
		OnGotOwner = nil,
		OnOwnerDeath = nil,
		LastProgressionLevel = 0,
		ProgressionData = progressionData,
		CanMoveToVendingMachine = true
	}
	setmetatable(this, self)
	if params ~= nil then
		for prop,value in pairs(params) do
			this[prop] = value
		end
	end
	if this.DefaultOwner ~= nil or this.Owner ~= nil then
		this.CanMoveToVendingMachine = false
	elseif this.CanMoveToVendingMachine then
		-- Vending Machine
		this.DefaultOwner = NPC.VendingMachine
	end
    return this
end

function UniqueData:CanMoveToOwner(owner, region)
	if StringHelpers.IsNullOrEmpty(owner) then
		return false
	end
	--local inventoryOwner = GetInventoryOwner(self.UUID)
	if owner ~= nil 
	and ObjectExists(owner) == 1
	and CharacterIsDead(owner) == 0
	and GetRegion(owner) == region
	then
		return true
	end
	return false
end

---@param item EsvItem
---@return string
local function TryGetOwner(item, inventoryOnly)
	if inventoryOnly ~= true then
		if item.OwnerHandle ~= nil then
			local object = Ext.GetGameObject(item.OwnerHandle)
			if object ~= nil then
				return object.MyGuid
			end
		end
	end
	if item.ParentInventoryHandle ~= nil then
		local object = Ext.GetGameObject(item.ParentInventoryHandle)
		if object ~= nil then
			return object.MyGuid
		end
	end
	local inventory = StringHelpers.GetUUID(GetInventoryOwner(item.MyGuid))
	if not StringHelpers.IsNullOrEmpty(inventory) then
		return inventory
	end
	return nil
end

---@return boolean
function UniqueData:IsReleasedFromOwner()
	if ObjectGetFlag(self.UUID, "LLWEAPONEX_UniqueData_ReleaseFromOwner") == 1 then
		return true
	elseif self.Owner ~= nil and IsPlayer(self.Owner) then
		return true
	end
	return false
end

function UniqueData:ReleaseFromOwner(unequip)
	ObjectSetFlag(self.UUID, "LLWEAPONEX_UniqueData_ReleaseFromOwner", 0)
	if unequip == true and self.Owner ~= nil then
		ItemLockUnEquip(self.UUID, 0)
		CharacterUnequipItem(self.Owner, self.UUID)
		ItemClearOwner(self.UUID)
	end
	self.Owner = nil
end

function UniqueData:ResetRelease()
	ObjectClearFlag(self.UUID, "LLWEAPONEX_UniqueData_ReleaseFromOwner", 0)
end

---@param self UniqueData
---@param region string
---@param item EsvItem|nil
local function MoveToRegionPosition(self, region, item)
	local targetPosition = self.LevelData[region]
	if targetPosition ~= nil then
		local x,y,z,pitch,yaw,roll = table.unpack(targetPosition)
		local host = CharacterGetHostCharacter()
		TeleportTo(self.UUID, host, "", 0, 1, 0)
		ItemToTransform(self.UUID, x,y,z,pitch,yaw,roll,1,nil)
	else
		-- Fallback
		ItemToInventory(self.UUID, NPC.VendingMachine, 1, 0, 0)
	end
end

function UniqueData:OnItemLeveledUp(owner)
	self:ApplyProgression(self.ProgressionData)
end

function UniqueData:Initialize(region, firstLoad)
	if ObjectExists(self.UUID) == 1 then
		local item = Ext.GetItem(self.UUID)
		if self.Owner == nil then
			local owner = TryGetOwner(item)
			if owner == NPC.UniqueHoldingChest then
				owner = nil
			end
			if owner ~= nil then
				self.Owner = owner
			end
		end
		if firstLoad == true then
			self:ApplyProgression(self.ProgressionData, nil, item)
		end
		if not self:IsReleasedFromOwner() then
			self.Initialized = ObjectGetFlag(self.UUID, "LLWEAPONEX_UniqueData_Initialized") == 1
			if item.CurrentLevel ~= region then
				if not self.Initialized then
					local targetOwner = self.DefaultOwner
					if type(self.DefaultOwner) == "table" then
						targetOwner = self.DefaultOwner[region] or self.DefaultOwner["Any"]
					end
					if self:CanMoveToOwner(targetOwner, region) then
						self:Transfer(targetOwner, self.AutoEquipOnOwner)
					else
						MoveToRegionPosition(self, region, item)
					end
					ObjectSetFlag(self.UUID, "LLWEAPONEX_UniqueData_Initialized", 0)
				end
				self.Initialized = true
			end
		elseif self.Owner == nil then
			if item.CurrentLevel ~= region then
				MoveToRegionPosition(self, region, item)
			end
		end
		printd("Unique initialized:", self.UUID, item.DisplayName, self.Owner)
	end
end

function UniqueData:AddPosition(region,x,y,z,rx,ry,rz)
	self.LevelData[region] = {
		x,y,z,
		0.0174533 * rx,
		0.0174533 * ry,
		0.0174533 * rz
	}
end

function UniqueData:Equip(target)
	if ObjectExists(self.UUID) == 0 then
		Ext.PrintError("[UniqueData:Equip] Item", self.UUID, "does not exist!")
		return
	end
	local item = Ext.GetItem(self.UUID)
	local locked = item.UnEquipLocked
	ItemLockUnEquip(self.UUID, 0)
	CharacterEquipItem(target, self.UUID)
	if self.OnEquipped ~= nil then
		pcall(self.OnEquipped, self, target)
	end
	if locked then
		ItemLockUnEquip(self.UUID, 1)
	end
end

function UniqueData:Transfer(target, equip)
	if ObjectExists(self.UUID) == 0 then
		Ext.PrintError("[UniqueData:Transfer] Item", self.UUID, "does not exist!")
		return
	end
	self.Owner = target

	if GetInventoryOwner(self.UUID) ~= target then
		ItemLockUnEquip(self.UUID, 0)
		ItemToInventory(self.UUID, target, 1, 1, 1)
	end
	if equip == true then
		self:Equip(target)
	end
end

function UniqueData:ClearOwner()
	self.Owner = nil
end

---@param entry UniqueProgressionEntry
---@param stat StatEntryWeapon
local function ApplyProgressionEntry(entry, stat)
	local statChanged = false
	if not StringHelpers.IsNullOrEmpty(entry.MatchStat) then
		if stat ~= entry.MatchStat then
			return false
		end
	end
	if entry.Attribute == "ExtraProperties" then
		if entry.Append == true then
			local props = stat.ExtraProperties or {}
			if not string.find(Common.Dump(props), entry.Value.Action) then
				table.insert(props, entry.Value)
				statChanged = true
			end
		else
			stat.ExtraProperties = {entry.Value}
			statChanged = true
		end
	else
		if entry.Append == true then
			local current = stat[entry.Attribute]
			if entry.Attribute == "Boosts" or entry.Attribute == "Skills" then
				if current ~= "" then
					if not string.find(current, entry.Value) then
						stat[entry.Attribute] = current .. ";" .. entry.Value
						statChanged = true
					end
				else
					stat[entry.Attribute] = entry.Value
					statChanged = true
				end
			else
				stat[entry.Attribute] = current + entry.Value
				statChanged = true
			end
		else
			if stat[entry.Attribute] ~= entry.Value then
				stat[entry.Attribute] = entry.Value
				statChanged = true
			end
		end
	end
	printd(statChanged, entry.Attribute, entry.Value)
	return statChanged
end

---@param self UniqueData
---@param item EsvItem
---@param template string
---@param stat string
---@param level integer
local function CloneItem(self, item, template, stat, level)
	local constructor = Ext.CreateItemConstructor(item)
	---@type ItemDefinition
	local props = constructor[1]
	props.GoldValueOverwrite = math.floor(item.Stats.Value * 0.4)

	if item.ItemType == "Weapon" then
		-- Damage type fix
		-- Deltamods with damage boosts may make the weapon's damage type be all of that type, so overwriting the statType
		-- fixes this issue.
		local damageTypeString = Ext.StatGetAttribute(stat, "Damage Type")
		if damageTypeString == nil then damageTypeString = "Physical" end
		local damageTypeEnum = LeaderLib.Data.DamageTypeEnums[damageTypeString]
		props.DamageTypeOverwrite = damageTypeEnum
	end

	props.GenerationStatsId = stat
	props.StatsEntryName = stat
	props.IsIdentified = true
	props.OriginalRootTemplate = template
	props.RootTemplate = template
	props.DeltaMods = item.GetDeltaMods()
	props.GenerationLevel = level
	props.StatsLevel = level

	local cloned = constructor:Construct()
	if cloned ~= nil then
		ItemSetOwner(cloned.MyGuid, self.Owner)
		ItemToInventory(cloned, self.Owner, 1, 0, 0)
		PersistentVars.UniqueDataIDSwap[self.UUID] = cloned.MyGuid
		self.UUID = cloned.MyGuid
		ItemRemove(item.MyGuid)
	else
		print("Error constructing item?", item.MyGuid)
	end
end

---@param self UniqueData
---@param item EsvItem
---@param template string
---@param stat string
---@param level integer
local function TransformItem(self, item, template, stat, level, matchStat, matchTemplate)
	local currentTemplate = StringHelpers.GetUUID(GetTemplate(item.MyGuid))
	if currentTemplate == StringHelpers.GetUUID(template) then
		return true
	end
	if not StringHelpers.IsNullOrEmpty(matchTemplate) then
		if currentTemplate ~= matchTemplate then
			return false
		end
	end
	if not StringHelpers.IsNullOrEmpty(matchStat) then
		if item.StatsId ~= matchStat then
			return false
		end
	end
	local slot = ""
	local owner = GetInventoryOwner(item.MyGuid)
	if not StringHelpers.IsNullOrEmpty(owner) ~= nil and ObjectIsCharacter(owner) then
		local character = Ext.GetCharacter(owner)
		if character ~= nil then
			for _,slotid in LeaderLib.Data.VisibleEquipmentSlots:Get() do
				if StringHelpers.GetUUID(CharacterGetEquippedItem(character.MyGuid, slotid)) == item.MyGuid then
					slot = slotid
					break
				end
			end
			if slot ~= "" then
				CharacterUnequipItem(character.MyGuid, item.MyGuid)
			end
		end
	end
	local deltamods = item:GetDeltaMods()
	Transform(item.MyGuid, template, 1, 1, 1)
	if not StringHelpers.IsNullOrEmpty(stat) then
		item.StatsId = stat
	end

	for i,v in pairs(deltamods) do
		if not ItemHasDeltaModifier(item.MyGuid, v) then
			ItemAddDeltaModifier(item.MyGuid, v)
		end
	end

	ItemLevelUpTo(item.MyGuid, level)

	if slot ~= nil and owner ~= "" then
		StartOneshotTimer("Timers_LLWEAPONEX_PostTransformEquip", 250, function()
			NRD_CharacterEquipItem(owner, item.MyGuid, slot, 0, 0, 1, 1)
		end)
	end
	return true
end

if Ext.IsDeveloperMode() then
	function UniqueData:TryTransform(template)
		local item = Ext.GetItem(self.UUID)
		local level = CharacterGetLevel(CharacterGetHostCharacter())
		TransformItem(self, item, template, nil, level)
	end
end

local function EvaluateEntry(self, progressionTable, persist, item, level, stat, entry)
	local statChanged = false
	if entry.Type == "UniqueProgressionEntry" then
		if ApplyProgressionEntry(entry, stat) then
			statChanged = true
		end
	elseif entry.Type == "UniqueProgressionTransform" then
		if not StringHelpers.IsNullOrEmpty(entry.Template) then
			if TransformItem(self, item, entry.Template, entry.Stat, level, entry.MatchStat, entry.MatchTemplate) then
				statChanged = true
			end
		end
	elseif #entry > 0 then
		for i,v in pairs(entry) do
			if EvaluateEntry(self, progressionTable, persist, item, level, stat, v) then
				statChanged = true
			end
		end
	end
	return statChanged
end

---@param self UniqueData
---@param item EsvItem
local function TryApplyProgression(self, progressionTable, persist, item, level)
	local statChanged = false
	if progressionTable ~= nil then
		local stat = Ext.GetStat(item.StatsId, level)
		for i=1,level do
			local entries = progressionTable[i]
			if entries ~= nil then
				if EvaluateEntry(self, progressionTable, persist, item, level, stat, entries) then
					statChanged = true
				end
			end
		end
		if statChanged then
			if persist == nil then
				persist = false
			end
			Ext.SyncStat(item.StatsId, persist)
		end
		item.Stats.ShouldSyncStats = true
	end
	return statChanged
end

---@param progressionTable table<integer,UniqueProgressionEntry|UniqueProgressionEntry[]>
---@param persist boolean
---@param item EsvItem
function UniqueData:ApplyProgression(progressionTable, persist, item)
	progressionTable = progressionTable or self.ProgressionData
	if item == nil then
		item = Ext.GetItem(self.UUID)
		if item == nil then
			Ext.PrintError("[WeaponExpansion] Failed to get item object for,", self.UUID)
			return
		end
	end
	-- TODO - Testing. Making sure bonuses don't overlap if they're set to append when you save/load/change level/level up etc.
	-- Maybe they all need to be replacements to avoid that potential issue, in which case the stats need to be reviewed to make sure the progression
	-- enries aren't nerfing things.
	local level = item.Stats.Level
	if item:HasTag("LeaderLib_AutoLevel") and self.Owner ~= nil then
		if ObjectIsCharacter(self.Owner) == 1 then
			level = CharacterGetLevel(self.Owner)
			ItemLevelUpTo(item.MyGuid, level)
		end
	end
	local b,err = xpcall(TryApplyProgression, debug.traceback, self, progressionTable, persist, item, level)
	if not b then
		Ext.PrintError("[LLWEAPONEX] Error applying progression to unique", self.UUID, item.StatsId)
		Ext.PrintError(self.UUID, err)
	end
	self.LastProgressionLevel = level
end

return UniqueData