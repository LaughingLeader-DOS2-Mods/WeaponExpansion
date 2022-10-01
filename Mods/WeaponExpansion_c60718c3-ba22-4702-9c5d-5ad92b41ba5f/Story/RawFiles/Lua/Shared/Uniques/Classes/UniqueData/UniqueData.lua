local isClient = Ext.IsClient()

---@alias UniqueData UniqueDataBase|UniqueDataServerSide

---@class UniqueDataBase
---@field ID string A name for this unique.
---@field UUID string The current UUID for the unique.
---@field DefaultUUID GUID|nil The default UUID for the unique (the initial global item).
---@field Owner GUID|nil
---@field Copies table<GUID,GUID> Item UUID to owner object UUID for copies of this unique.
---@field OnEquipped function|nil
---@field OnOwnerDeath function|nil
---@field OnGotOwner function|nil
---@field LinkedItem UniqueData|nil
local UniqueData = {
	Type = "UniqueData",
	LevelData = {},
	AutoEquipOnOwner = false,
	Initialized = false,
	LastProgressionLevel = 0,
	ProgressionData = nil,
	CanMoveToVendingMachine = true,
	Tag = "",
	Events = {
		ItemAddedToCharacter = {}
	}
}

---@param data UniqueData
---@param k string
local function UniqueDataGetter(data, k)
	if k == "UUID" then
		local defaultGUID = rawget(data, "DefaultUUID")
		if not StringHelpers.IsNullOrEmpty(defaultGUID) and GameHelpers.ObjectExists(defaultGUID) then
			return defaultGUID
		end
		if not isClient then
			for uuid,tag in pairs(PersistentVars.Uniques) do
				if tag == data.Tag and GameHelpers.ObjectExists(uuid) then
					return uuid
				end
			end
		end
		return nil
	elseif k == "Owner" then
		local defaultOwner = rawget(data, "DefaultOwner")
		if not StringHelpers.IsNullOrEmpty(defaultOwner) and GameHelpers.ObjectExists(defaultOwner) then
			return defaultOwner
		end
		for uuid,tag in pairs(PersistentVars.Uniques) do
			if tag == data.Tag and GameHelpers.ObjectExists(uuid) then
				local owner = GameHelpers.Item.GetOwner(uuid)
				if owner then
					return owner.MyGuid
				end
			end
		end
		return nil
	elseif k == "Copies" then
		local copies = {}
		if not isClient then
			for uuid,tag in pairs(PersistentVars.Uniques) do
				if tag == data.Tag and GameHelpers.ObjectExists(uuid) then
					copies[uuid] = GameHelpers.GetUUID(GameHelpers.Item.GetOwner(uuid), true)
				end
			end
		end
		return copies
	end
	return UniqueData[k]
end

---@param data UniqueData
---@param k string
---@param value any
local function UniqueDataSetter(data, k, value)
	if k == "UUID" then
		fprint(LOGLEVEL.WARNING, "[WeaponExpansion:UniqueData:__newindex] UUID is being set manually for unique (%s) DefaultUUID(%s) => (%s)", data.Tag, data.DefaultUUID, value)
		rawset(data, "DefaultUUID", value)
	end
	rawset(data, k, value)
end

local function ConfigureMetadata(tbl)
	setmetatable(tbl, {
		__index = UniqueDataGetter,
		__newindex = UniqueDataSetter,
	})
end

---@param progressionData table<string, UniqueProgressionEntry[]>
---@param params table<string,any>
---@return UniqueData
function UniqueData:Create(progressionData, params)
    local this =
    {
		ID = "",
		DefaultUUID = "",
		LevelData = {},
		DefaultOwner = StringHelpers.NULL_UUID,
		AutoEquipOnOwner = false,
		Initialized = false,
		OnEquipped = nil,
		OnGotOwner = nil,
		OnOwnerDeath = nil,
		LastProgressionLevel = 0,
		ProgressionData = progressionData,
		CanMoveToVendingMachine = true,
		Tag = "",
		LinkedItem = nil,
		Events = {
			ItemAddedToCharacter = {},
			ItemEquipped = {},
			ItemUnEquipped = {},
		},
		EquippedCallbacks = {}
	}
	ConfigureMetadata(this)
	if params then
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
	and GameHelpers.ObjectExists(owner)
	--and CharacterIsDead(owner) == 0
	and GetRegion(owner) == region
	then
		return true
	end
	return false
end

---Returns true if the UUID is a valid UUID for this unique, or if the item has the associated tag.
---@param uuid UUID
---@return boolean
function UniqueData:IsValid(uuid)
	if self.UUID == uuid then
		return true
	end
	local copies = self.Copies
	for copyUUID,copyOwner in pairs(copies) do
		if copyUUID == uuid then
			return true
		end
	end
	if GameHelpers.ItemHasTag(uuid, self.Tag) then
		return true
	end
	return false
end

---Gets the UUID of this unique owned by the owner, or the default value.
---@param owner string
---@param returnDefault boolean|nil If true, the regular UUID value is returned instead of nil.
---@return UUID
function UniqueData:GetUUID(owner, returnDefault)
	local currentDefaultOwner = GameHelpers.Item.GetOwner(self.DefaultUUID)
	if currentDefaultOwner and currentDefaultOwner.MyGuid == owner then
		return self.DefaultUUID
	end
	local copies = self.Copies
	for uuid,copyOwner in pairs(copies) do
		if copyOwner == owner then
			return uuid
		end
	end
	if returnDefault or currentDefaultOwner == NPC.UniqueHoldingChest then
		return self.DefaultUUID
	end
	return nil
end

---Gets the owner of the unique UUID.
---@param uuid UUID
---@param returnDefault boolean|nil
---@return UUID
function UniqueData:GetOwner(uuid, returnDefault)
	if self.UUID == uuid then
		return self.Owner
	end
	local copies = self.Copies
	local copyOwner = copies[uuid]
	if copyOwner then
		return copyOwner
	end
	if returnDefault then
		return self.Owner
	end
	return nil
end

---Checks if a UUID is a valid owner of this unique.
---@param owner UUID
---@return boolean
function UniqueData:IsOwner(owner)
	if self.Owner == owner then
		return true
	else
		for uuid,ownerId in pairs(self.Copies) do
			if ownerId == owner then
				return true
			end
		end
	end
	return false
end

function UniqueData:AddPosition(region,x,y,z,rx,ry,rz)
	self.LevelData[region] = {
		x,y,z,
		0.0174533 * rx,
		0.0174533 * ry,
		0.0174533 * rz
	}
end

---@param uuid UUID|nil
function UniqueData:Locate(uuid)
	uuid = uuid or self.UUID
	local item = GameHelpers.GetItem(uuid)
	if item == nil then
		fprint(LOGLEVEL.ERROR, "[WeaponExpansion:UniqueData:Locate] uuid (%s) must be a valid item UUID.", uuid)
		return false
	end
	local x,y,z = table.unpack(item.WorldPos)
	fprint(LOGLEVEL.DEFAULT, "[WeaponExpansion:UniqueData:Locate] Unique (%s) is at position x %s y %s z %s", uuid, x, y, z)
	fprint(LOGLEVEL.DEFAULT, "[WeaponExpansion:UniqueData:Locate] Characters nearby:")
	if not isClient then
		for _,v in pairs(item:GetNearbyCharacters(6.0)) do
			local char = GameHelpers.GetCharacter(v)
			fprint(LOGLEVEL.DEFAULT, "%s (%s)", char.DisplayName, Common.Dump(char.WorldPos))
		end
	end

	local owner = GameHelpers.TryGetObject(self:GetOwner(uuid))
	if owner then
		local tx,ty,tz = table.unpack(owner.WorldPos)
		fprint(LOGLEVEL.DEFAULT, "[WeaponExpansion:UniqueData:Locate] Unique (%s) owner (%s) is at position x %s y %s z %s", owner, tx, ty, tz)
	end
end

function UniqueData:PrintPosition()
	local item = GameHelpers.GetItem(self:GetUUID(nil,true))
	if item and item.WorldPos then
		fprint(LOGLEVEL.WARNING, "[Unique:%s]\n%s", self.ID, Lib.serpent.block({
			[SharedData.RegionData.Current] = {
				IsDefault = true,
				Position = item.WorldPos,
				Rotation = {item.Rotation[7],item.ats.Rotation[8],item.Rotation[9]}
			}
		}))
	end
end

---@param callback fun(e:OnWeaponTagHitEventArgs|LeaderLibSubscribableEventArgs, self:UniqueData)
---@param priority integer|nil Optional priority to assign to this callback.
function UniqueData:RegisterOnWeaponTagHit(callback, priority)
	if not isClient then
		Events.OnWeaponTagHit:Subscribe(function (e)
			callback(e, self)
		end, {MatchArgs={Tag=self.Tag}, Priority=priority})
	end
end

---@param callback fun(e:OnHealEventArgs|LeaderLibSubscribableEventArgs, self:UniqueData)
---@param checkTarget boolean|nil If true, the unique tag is checked on the target instead.
function UniqueData:RegisterHealListener(callback, checkTarget)
	if not isClient then
		Events.OnHeal:Subscribe(function(e)
			local runCallback = false
			if not checkTarget and e.Source then
				runCallback = GameHelpers.CharacterOrEquipmentHasTag(e.Source, self.Tag)
			else
				runCallback = GameHelpers.CharacterOrEquipmentHasTag(e.Target, self.Tag)
			end
			if runCallback then
				callback(e, self)
			end
		end)
	end
end

UniqueManager.Classes.UniqueData = UniqueData

Ext.Require("Shared/Uniques/Classes/UniqueData/ServerSide.lua")