---@class UniqueData
local UniqueData = {
	UUID = "",
	LevelData = {},
	Owner = nil,
	DefaultOwner = nil,
	CurrentLevel = nil,
	AutoEquipOnOwner = false,
	Initialized = false,
	OnEquipped = nil,
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
		this.DefaultOwner = "680d2702-721c-412d-b083-4f5e816b945a"
	end
    return this
end

function UniqueData:CanMoveToOwner()
	if self.DefaultOwner ~= nil 
	and (ObjectExists(self.DefaultOwner) == 1
	and CharacterIsDead(self.DefaultOwner) == 0
	and StringHelpers.GetUUID(GetInventoryOwner(self.UUID)) ~= self.DefaultOwner)
	then
		return true
	end
	return false
end

function UniqueData:OnLevelChange(region)
	if ObjectExists(self.UUID) == 1 then
		local item = Ext.GetItem(self.UUID)
		self.Initialized = ObjectGetFlag(self.UUID, "LLWEAPONEX_UniqueData_Initialized") == 1
		if not self.Initialized then
			self:ApplyProgression(self.ProgressionData, false, item)
			if self:CanMoveToOwner() then
				ItemLockUnEquip(self.UUID, 0)
				ItemToInventory(self.UUID, self.DefaultOwner, 1, 0, 1)
				if self.AutoEquipOnOwner then
					self:Transfer(self.DefaultOwner, true)
				end
			else
				local targetPosition = self.LevelData[region]
				if targetPosition ~= nil then
					local x,y,z,pitch,yaw,roll = table.unpack(targetPosition)
					local host = CharacterGetHostCharacter()
					TeleportTo(self.UUID, host, "", 0, 1, 0)
					ItemToTransform(self.UUID, x,y,z,pitch,yaw,roll,1,nil)
				end
			end
			self.Initialized = true
			ObjectSetFlag(self.UUID, "LLWEAPONEX_UniqueData_Initialized", 0)
		else
			if GetRegion(self.UUID) ~= region and self.Owner == nil then
				if self:CanMoveToOwner() and GetRegion(self.DefaultOwner) == region then
					ItemLockUnEquip(self.UUID, 0)
					ItemToInventory(self.UUID, self.DefaultOwner, 1, 0, 1)
					if self.AutoEquipOnOwner then
						self:Transfer(self.DefaultOwner, true)
					end
				else
					local targetPosition = self.LevelData[region]
					if targetPosition ~= nil then
						local x,y,z,pitch,yaw,roll = table.unpack(targetPosition)
						local host = CharacterGetHostCharacter()
						TeleportTo(self.UUID, host, "", 0, 1, 0)
						ItemToTransform(self.UUID, x,y,z,pitch,yaw,roll,1,nil)
					end
				end
			end
		end
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
		print("[UniqueData:Equip] Item", self.UUID, "does not exist!")
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
		print("[UniqueData:Transfer] Item", self.UUID, "does not exist!")
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