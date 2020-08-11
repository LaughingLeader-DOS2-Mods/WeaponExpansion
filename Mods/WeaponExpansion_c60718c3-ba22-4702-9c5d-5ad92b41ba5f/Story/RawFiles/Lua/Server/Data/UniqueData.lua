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
	OnGotOwner = nil
}
UniqueData.__index = UniqueData

---@param uuid string
---@param leveldata table<string,number[]>
---@param defaultNPCOwner string An NPC that should have the unique until a player takes it.
---@param autoEquip boolean Whether to automatically equip the unique on the default owner.
---@return UniqueData
function UniqueData:Create(uuid, leveldata, defaultNPCOwner, autoEquip, params)
	if leveldata == nil then
		leveldata = {}
	end
    local this =
    {
		UUID = uuid,
		LevelData = leveldata,
		Owner = nil,
		DefaultOwner = defaultNPCOwner,
		AutoEquipOnOwner = false,
		Initialized = false,
		OnEquipped = nil,
		OnGotOwner = nil,
	}
	setmetatable(this, self)
	if autoEquip ~= nil then
		this.AutoEquipOnOwner = autoEquip
	end
	if params ~= nil then
		for prop,value in pairs(params) do
			this[prop] = value
		end
	end
    return this
end

local function CanMoveToOwner(item, owner)
	if self.DefaultOwner ~= nil 
	and (ObjectExists(self.DefaultOwner) == 1
	and CharacterIsDead(self.DefaultOwner) == 0
	and GetInventoryOwner(self.UUID) ~= self.DefaultOwner)
	then
		return true
	end
	return false
end

function UniqueData:OnLevelChange(region)
	if ObjectExists(self.UUID) == 1 then
		self.Initialized = ObjectGetFlag(self.UUID, "LLWEAPONEX_UniqueData_Initialized") == 1
		if not self.Initialized then
			if CanMoveToOwner(self.UUID, self.DefaultOwner) then
				ItemToInventory(self.UUID, self.DefaultOwner, 1, 0, 1)
				if self.AutoEquipOnOwner then
					local targetSlot = Ext.GetItem(self.UUID).Stats.Slot
					local currentItem = CharacterGetEquippedItem(self.DefaultOwner, targetSlot)
					if currentItem == nil then
						CharacterEquipItem(self.DefaultOwner, self.UUID)
						if self.OnEquipped ~= nil then
							pcall(self.OnEquipped, self, self.DefaultOwner)
						end
					else
						ItemToInventory(self.UUID, self.DefaultOwner, 1, 0, 1)
					end
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
				if CanMoveToOwner(self.UUID, self.DefaultOwner) and	GetRegion(self.DefaultOwner) == region then
					ItemToInventory(self.UUID, self.DefaultOwner, 1, 0, 1)
					if self.AutoEquipOnOwner then
						local targetSlot = Ext.GetItem(self.UUID).Stats.Slot
						local currentItem = CharacterGetEquippedItem(self.DefaultOwner, targetSlot)
						if currentItem == nil then
							CharacterEquipItem(self.DefaultOwner, self.UUID)
							if self.OnEquipped ~= nil then
								pcall(self.OnEquipped, self, self.DefaultOwner)
							end
						else
							ItemToInventory(self.UUID, self.DefaultOwner, 1, 0, 1)
						end
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

function UniqueData:Transfer(target, equip)
	self.Initialized = true
	self.Owner = target
	ItemToInventory(self.UUID, target, 1, 1, 1)
	if equip == true then
		CharacterEquipItem(target, self.UUID)
		if self.OnEquipped ~= nil then
			pcall(self.OnEquipped, self, target)
		end
	end
end
return UniqueData