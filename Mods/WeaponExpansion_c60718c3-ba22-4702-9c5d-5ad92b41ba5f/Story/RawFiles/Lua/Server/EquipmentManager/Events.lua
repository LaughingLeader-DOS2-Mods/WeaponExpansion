local self = EquipmentManager
EquipmentManager.Events = {}

---@class EquipmentChangedEventArgs
---@field Character EsvCharacter
---@field Item EsvItem
---@field CharacterGUID Guid
---@field ItemGUID Guid
---@field Equipped boolean
---@field Template string
---@field Tag string|"" The specific tag this listener matched with, otherwise it's empty. 
---@field AllTags table<string,boolean> All the tags on the item. Use this when checking for tags instead of e.Tag.

---@type LeaderLibSubscribableEvent<EquipmentChangedEventArgs>
EquipmentManager.Events.EquipmentChanged = Classes.SubscribableEvent:Create("WeaponExpansion.EquipmentChanged")

---@class UnsheathedChangedEventArgs
---@field Character EsvCharacter
---@field Item EsvItem
---@field CharacterGUID Guid
---@field ItemGUID Guid
---@field Unsheathed boolean
---@field Template string
---@field Tag string|"" The specific tag this listener matched with, otherwise it's empty.
---@field AllTags table<string,boolean> All the tags on the item. Use this when checking for tags instead of e.Tag.
---@type LeaderLibSubscribableEvent<UnsheathedChangedEventArgs>
EquipmentManager.Events.UnsheathedChanged = Classes.SubscribableEvent:Create("WeaponExpansion.UnsheathedChanged")

local function _GetTagMatcher(_ITEM_TAGS)
	return function (self, argKey, matchedValue)
		--Consider any "Tag" match valid / return the tag if it's in _ITEM_TAGS
		if argKey == "Tag" then
			if _ITEM_TAGS[matchedValue] then
				--For the matched listeners
				self.Tag = matchedValue
				return matchedValue
			end
		end
	end
end

local function _InvokeEquipmentChanged(character, item, template, _ITEM_TAGS, equipped)
	EquipmentManager.Events.EquipmentChanged:Invoke({
		Character = character,
		CharacterGUID = character.MyGuid,
		Item = item,
		ItemGUID = item.MyGuid,
		AllTags = _ITEM_TAGS,
		Template = template,
		Tag = "",
		Equipped = equipped,
	}, nil, _GetTagMatcher(_ITEM_TAGS))
end

local function _InvokeUnsheathed(enabled, weapon, character, _ITEM_TAGS, template)
	local _ITEM_TAGS = _ITEM_TAGS or GameHelpers.GetItemTags(weapon, true)
	local template = template or GameHelpers.GetTemplate(weapon)

	EquipmentManager.Events.UnsheathedChanged:Invoke({
		Character = character,
		CharacterGUID = character.MyGuid,
		Item = weapon,
		ItemGUID = weapon.MyGuid,
		AllTags = _ITEM_TAGS,
		Template = template,
		Unsheathed = enabled,
		Tag = ""
	}, nil, _GetTagMatcher(_ITEM_TAGS))
end

---@param character EsvCharacter
---@param item EsvItem
function EquipmentManager:OnItemEquipped(character, item)
	if not character or not item or not item.Stats then
		return
	end

	local isPlayer = GameHelpers.Character.IsPlayer(character)

	local _CHARACTER_TAGS = GameHelpers.GetAllTags(character, true, false)
	local _ITEM_TAGS = GameHelpers.GetItemTags(item, true, false)
	---@cast _CHARACTER_TAGS table<string,boolean>
	---@cast _ITEM_TAGS table<string,boolean>

	local statType = item.Stats.ItemType
	local template = GameHelpers.GetTemplate(item)

	if not _ITEM_TAGS.LLWEAPONEX_TaggedWeaponType
	and (SharedData.GameMode == GAMEMODE.GAMEMASTER or isPlayer)
	and (statType == "Weapon" or statType == "Shield") then
		self:TagWeapon(item, statType, item.Stats.Name, _ITEM_TAGS)
	end

	if isPlayer and statType == "Weapon" then
		self:CheckWeaponRequirementTags(character)
		self:CheckForUnarmed(character, isPlayer, item)
	end

	local activatedMasteries = {}

	if not _ITEM_TAGS.LLWEAPONEX_NoTracking then
		for tag,_ in pairs(Masteries) do
			--PrintDebug("[WeaponExpansion] Checking item for tag ["..tag.."] on ["..character.MyGuid.."]")
			if _ITEM_TAGS[tag] then
				local equippedTag = Tags.WeaponTypes[tag]
				if equippedTag and not _CHARACTER_TAGS[equippedTag] and not _ITEM_TAGS[equippedTag] then
					SetTag(character.MyGuid, equippedTag)
					fprint(LOGLEVEL.TRACE, "[WeaponExpansion:OnItemEquipped] Setting weapon equipped tag [%s] on [%s]", equippedTag, character.MyGuid)
				end
				activatedMasteries[tag] = true
				if not _CHARACTER_TAGS[tag] then
					SetTag(character.MyGuid, tag)
				end
			end
		end
	end

	self:CheckWeaponAnimation(character, item, _ITEM_TAGS)

	if PersistentVars.ActiveMasteries[character.MyGuid] == nil then
		PersistentVars.ActiveMasteries[character.MyGuid] = {}
	end

	local persistentActivatedMasteries = PersistentVars.ActiveMasteries[character.MyGuid]

	for tag,b in pairs(activatedMasteries) do
		persistentActivatedMasteries[tag] = true
		Mastery.Events.MasteryChanged:Invoke({
			Character = character,
			CharacterGUID = character.MyGuid,
			Enabled = true,
			ID = tag,
			IsPlayer = isPlayer
		})
	end

	if Timer.IsObjectTimerActive("LLWEAPONEX_UpdateActiveMasteries", character) then
		Timer.RestartObjectTimer("LLWEAPONEX_UpdateActiveMasteries", character, 250)
	end
	
	if not _ITEM_TAGS.LLWEAPONEX_Testing then
		for k,unique in pairs(Uniques) do
			if _ITEM_TAGS[unique.Tag] then
				if unique.UUID ~= item.MyGuid then
					unique:AddCopy(item.MyGuid)
					unique:ApplyProgression(nil, nil, item, true)
				end
				if not unique:IsReleasedFromOwner(item.MyGuid) then
					unique:ReleaseFromOwner(item.MyGuid)
				end
			end
		end
	end

	if isPlayer then
		if item.Stats.StatsEntry.Unique == 1 or item.Stats.ItemTypeReal == "Unique" then
			UniqueManager.LevelUpUnique(character, item)
		end
		EquipmentManager.CheckFirearmProjectile(character, item)
	end

	_InvokeEquipmentChanged(character, item, template, _ITEM_TAGS, true)
	
	if character.FightMode or character:GetStatus("UNSHEATHED") then
		_InvokeUnsheathed(true, item, character, _ITEM_TAGS, template)
	end

	if character.MyGuid == Origin.Harken and statType == "Armor" then
		--Defer tattoo checks in case armor is being shuffled out
		Timer.StartObjectTimer("LLWEAPONEX_Harken_CheckTattoos", Origin.Harken, 500)
	end
end

---@param character EsvCharacter
local function _UpdateActiveMasteries(character)
	local data = PersistentVars.ActiveMasteries[character.MyGuid]
	if data then
		local activeMasteries = 0
		local nextData = {}
		local _CHARACTER_TAGS = GameHelpers.GetAllTags(character, true, true)
		local isPlayer = GameHelpers.Character.IsPlayer(character)

		for tag,_ in pairs(Masteries) do
			if _CHARACTER_TAGS[tag] then
				activeMasteries = activeMasteries + 1
				nextData[tag] = true
				if not data[tag] then
					Mastery.Events.MasteryChanged:Invoke({
						Character = character,
						CharacterGUID = character.MyGuid,
						Enabled = true,
						ID = tag,
						IsPlayer = isPlayer
					})
				end
			end
		end

		for tag,_ in pairs(data) do
			if not nextData[tag] then
				Mastery.Events.MasteryChanged:Invoke({
					Character = character,
					CharacterGUID = character.MyGuid,
					Enabled = false,
					ID = tag,
					IsPlayer = isPlayer
				})
			end
		end

		if activeMasteries > 0 then
			PersistentVars.ActiveMasteries[character.MyGuid] = nextData
		else
			PersistentVars.ActiveMasteries[character.MyGuid] = nil
		end
	end
end

Timer.Subscribe("LLWEAPONEX_UpdateActiveMasteries", function (e)
	if e.Data.Object then
		_UpdateActiveMasteries(e.Data.Object)
	end
end)

---@param character EsvCharacter
---@param item EsvItem
function EquipmentManager:OnItemUnEquipped(character, item)
	if not character then
		return
	end

	Timer.StartObjectTimer("LLWEAPONEX_UpdateActiveMasteries", character, 250)

	if not item or not item.Stats then
		return
	end

	local isPlayer = GameHelpers.Character.IsPlayer(character)
	local template = GameHelpers.GetTemplate(item)
	local _ITEM_TAGS = GameHelpers.GetItemTags(item, true, false)

	if isPlayer then
		self:CheckWeaponRequirementTags(character)
	end
	self:CheckForUnarmed(character, isPlayer)

	_InvokeEquipmentChanged(character, item, template, _ITEM_TAGS, false)
	_InvokeUnsheathed(false, item, character, _ITEM_TAGS, template)
	Timer.Cancel("LLWEAPONEX_FireUnsheathedRemoved", character)
end

StatusManager.Subscribe.Applied("UNSHEATHED", function (e)
	if GameHelpers.Ext.ObjectIsCharacter(e.Target) then
		Timer.Cancel("LLWEAPONEX_FireUnsheathedRemoved", e.Target)
		local mainhand,offhand = GameHelpers.Character.GetEquippedWeapons(e.Target)
		if mainhand then
			_InvokeUnsheathed(true, mainhand, e.Target)
		end
		if offhand then
			_InvokeUnsheathed(true, offhand, e.Target)
		end
	end
end)

StatusManager.Subscribe.Removed("UNSHEATHED", function (e)
	if GameHelpers.Ext.ObjectIsCharacter(e.Target) then
		Timer.Cancel("LLWEAPONEX_FireUnsheathedRemoved", e.Target)
		Timer.StartObjectTimer("LLWEAPONEX_FireUnsheathedRemoved", e.Target, 250)
	end
end)

Timer.Subscribe("LLWEAPONEX_FireUnsheathedRemoved", function (e)
	if ObjectExists(e.Data.UUID) and e.Data.Object then
		local character = e.Data.Object
		---@cast character EsvCharacter
		if not character.FightMode or character:GetStatus("UNSHEATHED") then
			local mainhand,offhand = GameHelpers.Character.GetEquippedWeapons(character)
			if mainhand then
				_InvokeUnsheathed(false, mainhand, character)
			end
			if offhand then
				_InvokeUnsheathed(false, offhand, character)
			end
		end
	end
end)

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

Ext.Osiris.RegisterListener("ItemEquipped", 2, "after", function(itemGUID,characterGUID)
	itemGUID = StringHelpers.GetUUID(itemGUID); characterGUID = StringHelpers.GetUUID(characterGUID)
	if not Ignore(characterGUID, itemGUID) then self:OnItemEquipped(GameHelpers.GetCharacter(characterGUID), GameHelpers.GetItem(itemGUID)) end
end)
Ext.Osiris.RegisterListener("ItemUnEquipped", 2, "after", function(itemGUID,characterGUID)
	itemGUID = StringHelpers.GetUUID(itemGUID); characterGUID = StringHelpers.GetUUID(characterGUID)
	if not Ignore(characterGUID, itemGUID) then self:OnItemUnEquipped(GameHelpers.GetCharacter(characterGUID), GameHelpers.GetItem(itemGUID)) end
end)

RegisterProtectedOsirisListener("ItemAddedToCharacter", Data.OsirisEvents.ItemAddedToCharacter, "after", function(item, character)
	if ObjectExists(character) == 0 or ObjectExists(item) == 0 then
		return
	end
	local item = GameHelpers.GetItem(item)
	local character = GameHelpers.GetCharacter(character)
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
	item = GameHelpers.GetItem(item); character = GameHelpers.GetCharacter(character)
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