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
	if item.InventoryHandle ~= nil then
		local object = Ext.GetGameObject(item.InventoryHandle)
		if object ~= nil then
			return object.MyGuid
		end
	end
	if inventoryOnly ~= true then
		if item.OwnerHandle ~= nil then
			local object = Ext.GetGameObject(item.OwnerHandle)
			if object ~= nil then
				return object.MyGuid
			end
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
	return ObjectGetFlag(self.UUID, "LLWEAPONEX_UniqueData_ReleaseFromOwner") == 1
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

function UniqueData:Initialize(region)
	if ObjectExists(self.UUID) == 1 then
		local item = Ext.GetItem(self.UUID)
		if not self:IsReleasedFromOwner() then
			self.Initialized = ObjectGetFlag(self.UUID, "LLWEAPONEX_UniqueData_Initialized") == 1
			if item.CurrentLevel ~= region then
				if not self.Initialized then
					self:ApplyProgression(self.ProgressionData, false, item)
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
		else
			if item.CurrentLevel ~= region then
				MoveToRegionPosition(self, region, item)
			end
		end
		if self.Owner == nil then
			local owner = TryGetOwner(item)
			if owner ~= nil then
				self.Owner = owner
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
	self.Initialized = true
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
	if entry.Attribute == "ExtraProperties" then
		if entry.Append == true then
			local props = stat.ExtraProperties or {}
			table.insert(props, entry.Value)
		else
			stat.ExtraProperties = {entry.Value}
		end
	else
		if entry.Append == true then
			local current = stat[entry.Attribute]
			if entry.Attribute == "Boosts" or entry.Attribute == "Skills" then
				stat[entry.Attribute] = current .. ";" .. entry.Value
			else
				stat[entry.Attribute] = current + entry.Value
			end
		else
			stat[entry.Attribute] = entry.Value
		end
	end
end

---@param progressionTable table<integer,UniqueProgressionEntry|UniqueProgressionEntry[]>
---@param persist boolean
function UniqueData:ApplyProgression(progressionTable, persist, item)
	if item == nil then
		item = Ext.GetItem(self.UUID)
		if item == nil then
			Ext.PrintError("[WeaponExpansion] Failed to get item object for,", self.UUID)
			return
		end
	end
	local level = item.Stats.Level
	self.LastProgressionLevel = level
	if progressionTable ~= nil and #progressionTable > 0 then
		local stat = Ext.GetStat(item.StatsId, level)
		for i=self.LastProgressionLevel,level do
			local entries = progressionTable[i]
			if entries ~= nil then
				if entries.Type == "UniqueProgressionEntry" then
					ApplyProgressionEntry(entries, stat)
				elseif #entries > 0 then
					for i,v in pairs(entries) do
						ApplyProgressionEntry(v, stat)
					end
				end
			end
		end
		Ext.SyncStat(item.StatsId, persist or false)
	end
	self.LastProgressionLevel = level
end

return UniqueData