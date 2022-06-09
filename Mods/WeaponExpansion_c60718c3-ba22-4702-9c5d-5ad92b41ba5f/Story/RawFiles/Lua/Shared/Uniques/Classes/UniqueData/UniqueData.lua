local isClient = Ext.IsClient()

---@alias UniqueData UniqueDataBase|UniqueDataServerSide

---@class UniqueDataBase
---@field ID string A name for this unique.
---@field UUID string The current UUID for the unique.
---@field DefaultUUID string The default UUID for the unique (the initial global item).
---@field Owner string
---@field Copies table<string,string> Item UUID to owner object UUID for copies of this unique.
local UniqueData = {
	Type = "UniqueData",
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
	CanMoveToVendingMachine = true,
	---@type UniqueData
	LinkedItem = nil,
	Tag = "",
	Events = {
		ItemAddedToCharacter = {},
		ItemEquipped = {},
		ItemUnEquipped = {},
	},
	EquippedCallbacks = {}
}

---@param data UniqueData
---@param k string
local function UniqueDataGetter(data, k)
	if k == "UUID" then
		if data.DefaultUUID and GameHelpers.ObjectExists(data.DefaultUUID) then
			return data.DefaultUUID
		end
		if not isClient then
			for uuid,tag in pairs(PersistentVars.Uniques) do
				if tag == data.Tag and GameHelpers.ObjectExists(uuid) then
					return uuid
				end
			end
		end
		return StringHelpers.NULL_UUID
	elseif k == "Owner" then
		if data.DefaultOwner and GameHelpers.ObjectExists(data.DefaultOwner) then
			return data.DefaultOwner
		end
		for uuid,tag in pairs(PersistentVars.Uniques) do
			if tag == data.Tag and GameHelpers.ObjectExists(uuid) then
				local owner = GameHelpers.Item.GetOwner(uuid, true)
				if GameHelpers.ObjectExists(owner) then
					return owner
				end
			end
		end
		return StringHelpers.NULL_UUID
	elseif k == "Copies" then
		local copies = {}
		if not isClient then
			for uuid,tag in pairs(PersistentVars.Uniques) do
				if tag == data.Tag and GameHelpers.ObjectExists(uuid) then
					copies[uuid] = GameHelpers.Item.GetOwner(uuid, true)
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
	if self.Owner == owner then
		return self.UUID
	end
	local copies = self.Copies
	for uuid,copyOwner in pairs(copies) do
		if copyOwner == owner then
			return uuid
		end
	end
	if returnDefault then
		return self.UUID
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
	assert(item ~= nil, "[WeaponExpansion:UniqueData:Locate] uuid must be a valid item UUID.")
	local x,y,z = table.unpack(item.WorldPos)
	fprint(LOGLEVEL.DEFAULT, "[WeaponExpansion:UniqueData:Locate] Unique (%s) is at position x %s y %s z %s", uuid, x, y, z)
	fprint(LOGLEVEL.DEFAULT, "[WeaponExpansion:UniqueData:Locate] Characters nearby:")
	if not isClient then
		for _,v in pairs(item:GetNearbyCharacters(6.0)) do
			local char = Ext.GetCharacter(v)
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
	local item = Ext.GetItem(self:GetUUID(nil,true))
	if item and item.WorldPos then
		fprint(LOGLEVEL.WARNING, "[Unique:%s]\n%s", self.ID, Lib.serpent.block({
			[SharedData.RegionData.Current] = {
				IsDefault = true,
				Position = item.WorldPos,
				Rotation = {item.Stats.Rotation[7],item.Stats.Rotation[8],item.Stats.Rotation[9]}
			}
		}))
	end
end

---@param callback BasicAttackOnWeaponTagHitCallback
---@param priority integer Optional priority to assign to this callback.
function UniqueData:RegisterOnWeaponTagHit(callback, priority)
	if not isClient then
		AttackManager.OnWeaponTagHit.Register(self.Tag, function(tag, attacker, target, data, targetIsObject, skill)
			local b,err = xpcall(callback, debug.traceback, tag, attacker, target, data, targetIsObject, skill, self)
			if not b then
				Ext.PrintError(err)
			end
		end, priority)
	end
end

---@param callback OnHealCallback
---@param checkTarget boolean If true, the unique tag is checked on the target instead.
function UniqueData:RegisterHealListener(callback, checkTarget)
	if not isClient then
		RegisterHealListener(function(target, source, heal, originalAmount, handle, skill, healingSourceStatus)
			local runCallback = false
			if not checkTarget and source ~= nil then
				runCallback = GameHelpers.CharacterOrEquipmentHasTag(source, self.Tag)
			else
				runCallback = GameHelpers.CharacterOrEquipmentHasTag(target, self.Tag)
			end
			if runCallback then
				local b,err = xpcall(callback, debug.traceback, target, source, heal, originalAmount, handle, skill, healingSourceStatus, self)
				if not b then
					Ext.PrintError(err)
				end
			end
		end)
	end
end

---@param skill string|string[]
---@param callback LeaderLibSkillListenerCallback
function UniqueData:RegisterSkillListener(skill, callback)
	if not isClient then
		RegisterSkillListener(skill, function(skill, char, state, data)
			if GameHelpers.CharacterOrEquipmentHasTag(char, self.Tag) then
				local b,err = xpcall(callback, debug.traceback, skill, char, state, data, self)
				if not b then
					Ext.PrintError(err)
				end
			end
		end)
	end
end

---Lazy way of registering a timer listener if we're on the server side.
---@param name string|string[]|fun(e:TimerFinishedEventArgs) Timer name or the callback if a ganeric listener.
---@param callback fun(e:TimerFinishedEventArgs)
function UniqueData:RegisterTimerListener(name, callback)
	if not isClient then
		Timer.Subscribe(name, callback)
	end
end

---Lazy way of registering a DeathManager listener if we're on the server side.
---@param id string The ID for the death event, specified in ListenForDeath.
---@param callback fun(target:string, attacker:string, success:boolean):void
function UniqueData:RegisterDeathManagerListener(id, callback)
	if not isClient then
		DeathManager.RegisterListener(id, function(target, attacker, success)
			local b,err = xpcall(callback, debug.traceback, target, attacker, success, self)
			if not b then
				Ext.PrintError(err)
			end
		end)
	end
end

UniqueManager.Classes.UniqueData = UniqueData

Ext.Require("Shared/Uniques/Classes/UniqueData/ServerSide.lua")