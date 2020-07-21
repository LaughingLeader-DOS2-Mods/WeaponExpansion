---@class UniqueData
local UniqueData = {
	UUID = "",
	LevelData = {},
	Owner = nil,
	DefaultOwner = nil,
	CurrentLevel = nil,
	AutoEquipOnOwner = false
}
UniqueData.__index = UniqueData

---@param uuid string
---@param leveldata table<string,number[]>
---@param defaultNPCOwner string An NPC that should have the unique until a player takes it.
---@param autoEquip boolean Whether to automatically equip the unique on the default owner.
---@return UniqueData
function UniqueData:Create(uuid, leveldata, defaultNPCOwner, autoEquip)
	if leveldata == nil then
		leveldata = {}
	end
    local this =
    {
		UUID = uuid,
		LevelData = leveldata,
		Owner = nil,
		DefaultOwner = defaultNPCOwner,
		AutoEquipOnOwner = false
	}
	setmetatable(this, self)
	if autoEquip ~= nil then
		this.AutoEquipOnOwner = autoEquip
	end
    return this
end

function UniqueData:OnLevelChange(region)
	if ObjectExists(self.UUID) == 1 and GetRegion(self.UUID) ~= region then
		if self.Owner == nil then
			if self.DefaultOwner ~= nil and 
				ObjectExists(self.DefaultOwner) == 1 and 
				CharacterIsDead(self.DefaultOwner) == 0 and 
				GetRegion(self.DefaultOwner) == region 
			then
				ItemToInventory(self.UUID, self.DefaultOwner, 1, 0, 1)
				---@type EsvCharacter
				-- local character = Ext.GetCharacter(self.DefaultOwner)
				-- for i,v in pairs(character:GetInventoryItems()) do

				-- end
				--local currentWeapon = CharacterGetEquippedItem(self.DefaultOwner, "Weapon")
				--local currentOffhandWeapon = CharacterGetEquippedItem(self.DefaultOwner, "Shield")
				if self.AutoEquipOnOwner then
					CharacterEquipItem(self.DefaultOwner, self.UUID)
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

function UniqueData:AddPosition(region,x,y,z,rx,ry,rz)
	self.LevelData[region] = {
		x,y,z,
		0.0174533 * rx,
		0.0174533 * ry,
		0.0174533 * rz
	}
end

return UniqueData