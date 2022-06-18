local self = EquipmentManager

---@class EquipmentChangedEventArgs
---@field Character EsvCharacter
---@field Item EsvItem
---@field Equipped boolean
---@field Template string

EquipmentManager.Events = {}

---@type SubscribableEvent<EquipmentChangedEventArgs>
EquipmentManager.Events.EquipmentChanged = Classes.SubscribableEvent:Create("EquipmentChanged")

local _tagListeners = {}
local _templateListeners = {}

---@param callback fun(e:EquipmentChangedEventArgs|SubscribableEventArgs)
---@param opts {Tag:string, Template:string}
function EquipmentManager:RegisterEquipmentChangedListener(callback, opts)
	opts = opts or {}
	if opts.Tag then
		if _tagListeners[opts.Tag] == nil then
			_tagListeners[opts.Tag] = {}
		end
		table.insert(_tagListeners[opts.Tag], callback)
	end
	if opts.Template then
		opts.Template = StringHelpers.GetUUID(opts.Template)
		if _templateListeners[opts.Template] == nil then
			_templateListeners[opts.Template] = {}
		end
		table.insert(_templateListeners[opts.Template], callback)
	end
end

---@param character EsvCharacter
---@param item EsvItem
function EquipmentManager:OnItemEquipped(character, item)
	if not character or not item or GameHelpers.Item.IsObject(item) then
		return
	end

	
	local db = Osi.DB_LLWEAPONEX_Equipment_ActiveTags:Get(character.MyGuid, "LLWEAPONEX_Unarmed", "NULL_00000000-0000-0000-0000-000000000000")
	if db and #db > 0 then
		Osi.DB_LLWEAPONEX_Equipment_ActiveTags:Delete(character.MyGuid, "LLWEAPONEX_Unarmed", "NULL_00000000-0000-0000-0000-000000000000")
		Osi.DB_LLWEAPONEX_WeaponMastery_Temp_ActiveMasteries:Delete(character.MyGuid, "NULL_00000000-0000-0000-0000-000000000000", "LLWEAPONEX_Unarmed")
		Osi.LLWEAPONEX_WeaponMastery_Internal_CheckRemovedMasteries(character.MyGuid, "LLWEAPONEX_Unarmed")
	end
	
	local isPlayer = GameHelpers.Character.IsPlayer(character)
	local itemTags = GameHelpers.GetItemTags(item, true, false)
	local statType = item.ItemType
	local template = GameHelpers.GetTemplate(item)

	if not itemTags["LLWEAPONEX_TaggedWeaponType"]
	and (SharedData.GameMode == GAMEMODE.GAMEMASTER or isPlayer)
	and (statType == "Weapon" or statType == "Shield") then
		self:TagWeapon(item, statType, item.Stats.Name, itemTags)
	end

	if isPlayer and statType == "Weapon" then
		self:CheckWeaponRequirementTags(character)
		self:CheckForUnarmed(character, isPlayer, item)
	end

	if not itemTags["LLWEAPONEX_NoTracking"] then
		for tag,data in pairs(Masteries) do
			--PrintDebug("[WeaponExpansion] Checking item for tag ["..tag.."] on ["..character.MyGuid.."]")
			if itemTags[tag] then
				local equippedTag = Tags.WeaponTypes[tag]
				if equippedTag then
					if not character:HasTag(equippedTag) and not itemTags[equippedTag] then
						SetTag(character.MyGuid, equippedTag)
						fprint(LOGLEVEL.TRACE, "[WeaponExpansion:OnItemEquipped] Setting weapon equipped tag [%s] on [%s]", equippedTag, character.MyGuid)
					end
				end
				if isPlayer then
					if equippedTag then
						Osi.LLWEAPONEX_Equipment_TrackItem(character.MyGuid, item.MyGuid, tag, equippedTag, isPlayer)
					end
					Osi.LLWEAPONEX_WeaponMastery_TrackMastery(character.MyGuid, item.MyGuid, tag)
					if not character:HasTag(equippedTag) and not itemTags[tag] then
						--Set "Mastery Active" tag, like LLWEAPONEX_Axe
						SetTag(character.MyGuid, tag)
						fprint(LOGLEVEL.TRACE, "[WeaponExpansion:OnItemEquipped] Setting mastery tag [%s] on [%s]", tag, character.MyGuid)
					end
				end
				Osi.LLWEAPONEX_Equipment_OnTaggedItemEquipped(character.MyGuid, item.MyGuid, tag, isPlayer)
			end
		end
	end

	self:CheckWeaponAnimation(character, item, itemTags)

	Osi.LLWEAPONEX_OnItemTemplateEquipped(character.MyGuid, item.MyGuid, template)

	for k,unique in pairs(Uniques) do
		if itemTags[unique.Tag] then
			unique:OnEquipped(character, item)
			if unique.UUID ~= item.MyGuid then
				unique:AddCopy(item.MyGuid)
				unique:ApplyProgression(nil, nil, item, true)
			end
			if not unique:IsReleasedFromOwner(item.MyGuid) then
				unique:ReleaseFromOwner(item.MyGuid)
			end
		end
	end

	if isPlayer then
		if item.Stats.Unique == 1 or item.Stats.ItemTypeReal == "Unique" then
			UniqueManager.LevelUpUnique(character, item)
		end
		EquipmentManager.CheckFirearmProjectile(character, item)
	end

	local callbacks = _templateListeners[template]
	if callbacks ~= nil then
		if Vars.DebugMode then
			Ext.Print(string.format("[WeaponExpansion:EquipmentChanged.Template] Template(%s) Stat(%s) Character(%s) Equipped(true)", template, item.Stats.Name, character.MyGuid))
		end
		for i,callback in pairs(callbacks) do
			local b,err = xpcall(callback, debug.traceback, character, item, template, true)
			if not b then
				Ext.PrintError(err)
			end
		end
	end

	for tag,callbacks in pairs(_tagListeners) do
		if itemTags[tag] then
			if Vars.DebugMode then
				Ext.Print(string.format("[WeaponExpansion:EquipmentChanged.Tag] Tag(%s) Stat(%s) Character(%s) Equipped(true)", tag, item.Stats.Name, character.MyGuid))
			end
			for i,callback in pairs(callbacks) do
				local b,err = xpcall(callback, debug.traceback, character, item, tag, true)
				if not b then
					Ext.PrintError(err)
				end
			end
		end
	end
end

---@param character EsvCharacter
---@param item EsvItem
function EquipmentManager:OnItemUnEquipped(character, item)
	if not character or not item or GameHelpers.Item.IsObject(item) then
		return
	end

	local isPlayer = GameHelpers.Character.IsPlayer(character)
	local template = GameHelpers.GetTemplate(item)
	local itemTags = GameHelpers.GetItemTags(item, true, false)

	--TODO Refactor to Lua stuff
	Osi.LLWEAPONEX_OnItemTemplateUnEquipped(character.MyGuid, item.MyGuid, template)
	Osi.LLWEAPONEX_Equipment_ClearItem(character.MyGuid, item.MyGuid, isPlayer)
	Osi.LLWEAPONEX_WeaponMastery_RemovedTrackedMasteries(character.MyGuid, item.MyGuid)

	if isPlayer then
		self:CheckWeaponRequirementTags(character)
	end
	self:CheckForUnarmed(character, isPlayer)

	local callbacks = _templateListeners[template]
	if callbacks ~= nil then
		if Vars.DebugMode then
			Ext.Print(string.format("[WeaponExpansion:EquipmentChanged.Template] Template(%s) Stat(%s) Character(%s) Equipped(false)", template, item.Stats.Name, character.MyGuid))
		end
		for i,callback in pairs(callbacks) do
			local b,err = xpcall(callback, debug.traceback, character, item, template, false)
			if not b then
				Ext.PrintError(err)
			end
		end
	end
	for tag,callbacks in pairs(_tagListeners) do
		if itemTags[tag] then
			if Vars.DebugMode then
				Ext.Print(string.format("[WeaponExpansion:EquipmentChanged.Tag] Tag(%s) Stat(%s) Character(%s) Equipped(false)", tag, item.Stats.Name, character.MyGuid))
			end
			for i,callback in pairs(callbacks) do
				local b,err = xpcall(callback, debug.traceback, character, item, tag, false)
				if not b then
					Ext.PrintError(err)
				end
			end
		end
	end
end

local function Ignore(character, item)
	if character == NPC.VendingMachine 
	or ObjectExists(character) == 0
	or ObjectExists(item) == 0
	or Osi.LeaderLib_Helper_QRY_IgnoreCharacter(character)
	or Osi.LeaderLib_Helper_QRY_IgnoreItem(item)
	then
		return true
	end
	return false
end

RegisterProtectedOsirisListener("ItemEquipped", Data.OsirisEvents.ItemEquipped, "after", function(item,character)
	if ObjectExists(character) == 0 or ObjectExists(item) == 0 then
		return
	end
	item = StringHelpers.GetUUID(item); character = StringHelpers.GetUUID(character)
	if not Ignore(character, item) then self:OnItemEquipped(Ext.GetCharacter(character), Ext.GetItem(item)) end
end)
RegisterProtectedOsirisListener("ItemUnEquipped", Data.OsirisEvents.ItemUnEquipped, "after", function(item,character)
	if ObjectExists(character) == 0 or ObjectExists(item) == 0 then
		return
	end
	item = StringHelpers.GetUUID(item); character = StringHelpers.GetUUID(character)
	if not Ignore(character, item) then self:OnItemUnEquipped(Ext.GetCharacter(character), Ext.GetItem(item)) end
end)

RegisterProtectedOsirisListener("ItemAddedToCharacter", Data.OsirisEvents.ItemAddedToCharacter, "after", function(item, character)
	if ObjectExists(character) == 0 or ObjectExists(item) == 0 then
		return
	end
	local item = Ext.GetItem(item)
	local character = Ext.GetCharacter(character)
	if character and item then
		if not GameHelpers.Item.IsObject(item) and (item.Stats.Unique == 1 or item.Stats.ItemTypeReal == "Unique") then
			local unique = UniqueManager.GetDataByItem(item)
			if unique then
				if GameHelpers.Character.IsPlayer(character) and not unique:IsReleasedFromOwner(item.MyGuid) then
					unique:ReleaseFromOwner(item.MyGuid)
					ItemSetOwner(item.MyGuid, character.MyGuid)
				end
				unique:InvokeEventListeners("ItemAddedToCharacter", item.MyGuid, character.MyGuid)
			end
		end
	end
end)

RegisterProtectedOsirisListener("CharacterItemEvent", Data.OsirisEvents.CharacterItemEvent, "after", function(character, item, event)
	if ObjectExists(character) == 0 or ObjectExists(item) == 0 then
		return
	end
	item = Ext.GetItem(item); character = Ext.GetCharacter(character)
	if not GameHelpers.Item.IsObject(item) then
		if item.Stats.Unique == 1 or item.Stats.ItemTypeReal == "Unique" then
			local unique = UniqueManager.GetDataByItem(item)
			if unique then
				if event == "LeaderLib_Events_ItemLeveledUp" then
					unique:OnItemLeveledUp(item)
				else
					unique:InvokeEventListeners("CharacterItemEvent", character, item, event)
				end
			end
		end
	end
end)