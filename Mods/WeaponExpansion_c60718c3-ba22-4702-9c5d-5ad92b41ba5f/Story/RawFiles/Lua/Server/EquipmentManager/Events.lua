local self = EquipmentManager
EquipmentManager.Events = {}

local _listenerTags = {
	EquipmentChanged = {},
	UnsheathedChanged = {},
}

local _listenerTemplates = {
	EquipmentChanged = {},
	UnsheathedChanged = {},
}

---@class EquipmentChangedEventArgs
---@field Character EsvCharacter
---@field Item EsvItem
---@field Equipped boolean
---@field Template string|nil
---@field Tag string|nil
---@field AllTags table<string,boolean>

---@type LeaderLibSubscribableEvent<EquipmentChangedEventArgs>
EquipmentManager.Events.EquipmentChanged = Classes.SubscribableEvent:Create("WeaponExpansion.EquipmentChanged", {
	OnSubscribe = function (callback, opts, matchArgs, matchArgsType)
		if matchArgsType == "table" then
			if matchArgs.Tag then
				_listenerTags.EquipmentChanged[matchArgs.Tag] = true
			end
			if matchArgs.Template then
				_listenerTemplates.EquipmentChanged[matchArgs.Template] = true
			end
		end
	end,
})

---@class UnsheathedChangedEventArgs
---@field Character EsvCharacter
---@field Item EsvItem
---@field Unsheathed boolean
---@field Template string|nil
---@field Tag string|nil
---@field AllTags table<string,boolean>
---@type LeaderLibSubscribableEvent<UnsheathedChangedEventArgs>
EquipmentManager.Events.UnsheathedChanged = Classes.SubscribableEvent:Create("WeaponExpansion.UnsheathedChanged", {
	OnSubscribe = function (callback, opts, matchArgs, matchArgsType)
		if matchArgsType == "table" then
			if matchArgs.Tag then
				_listenerTags.UnsheathedChanged[matchArgs.Tag] = true
			end
			if matchArgs.Template then
				_listenerTemplates.UnsheathedChanged[matchArgs.Template] = true
			end
		end
	end,
})

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

	for tag,b in pairs(activatedMasteries) do
		Mastery.Events.MasteryChanged:Invoke({
			Character = character,
			Enabled = true,
			ID = tag,
			IsPlayer = isPlayer
		})
	end

	Osi.LLWEAPONEX_OnItemTemplateEquipped(character.MyGuid, item.MyGuid, template)

	for k,unique in pairs(Uniques) do
		if _ITEM_TAGS[unique.Tag] then
			unique:OnEquipped(character, item)
			if not item:HasTag("LLWEAPONEX_Testing") then
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
		if item.Stats.Unique == 1 or item.Stats.ItemTypeReal == "Unique" then
			UniqueManager.LevelUpUnique(character, item)
		end
		EquipmentManager.CheckFirearmProjectile(character, item)
	end

	local invokedTemplate = false

	for tag,_ in pairs(_listenerTags.EquipmentChanged) do
		if _ITEM_TAGS[tag] then
			EquipmentManager.Events.EquipmentChanged:Invoke({
				Character = character,
				Item = item,
				AllTags = _ITEM_TAGS,
				Template = template,
				Tag = tag,
				Equipped = true
			})
			invokedTemplate = true
		end
	end

	if not invokedTemplate then
		if _listenerTemplates.EquipmentChanged[template] then
			EquipmentManager.Events.EquipmentChanged:Invoke({
				Character = character,
				Item = item,
				AllTags = _ITEM_TAGS,
				Template = template,
				Equipped = true
			})
		end
	end

	if character.FightMode or character:GetStatus("UNSHEATHED") then
		invokedTemplate = false
	
		for tag,_ in pairs(_listenerTags.UnsheathedChanged) do
			if _ITEM_TAGS[tag] then
				EquipmentManager.Events.UnsheathedChanged:Invoke({
					Character = character,
					Item = item,
					AllTags = _ITEM_TAGS,
					Template = template,
					Tag = tag,
					Unsheathed = true
				})
				invokedTemplate = true
			end
		end

		if not invokedTemplate then
			if _listenerTemplates.UnsheathedChanged[template] then
				EquipmentManager.Events.UnsheathedChanged:Invoke({
					Character = character,
					Item = item,
					AllTags = _ITEM_TAGS,
					Template = template,
					Unsheathed = true
				})
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
	local _ITEM_TAGS = GameHelpers.GetItemTags(item, true, false)

	--TODO Refactor to Lua stuff
	Osi.LLWEAPONEX_OnItemTemplateUnEquipped(character.MyGuid, item.MyGuid, template)
	Osi.LLWEAPONEX_Equipment_ClearItem(character.MyGuid, item.MyGuid, isPlayer)
	Osi.LLWEAPONEX_WeaponMastery_RemovedTrackedMasteries(character.MyGuid, item.MyGuid)

	if isPlayer then
		self:CheckWeaponRequirementTags(character)
	end
	self:CheckForUnarmed(character, isPlayer)

	local invokedTemplate = false

	for tag,_ in pairs(_listenerTags.EquipmentChanged) do
		if _ITEM_TAGS[tag] then
			EquipmentManager.Events.EquipmentChanged:Invoke({
				Character = character,
				Item = item,
				AllTags = _ITEM_TAGS,
				Template = template,
				Tag = tag,
				Equipped = false
			})
			invokedTemplate = true
		end
	end

	if not invokedTemplate then
		if _listenerTemplates.EquipmentChanged[template] then
			EquipmentManager.Events.EquipmentChanged:Invoke({
				Character = character,
				Item = item,
				AllTags = _ITEM_TAGS,
				Template = template,
				Equipped = false
			})
		end
	end

	if character.FightMode or character:GetStatus("UNSHEATHED") then
		invokedTemplate = false
		Timer.Cancel("LLWEAPONEX_FireUnsheathedRemoved", character)
	
		for tag,_ in pairs(_listenerTags.UnsheathedChanged) do
			if _ITEM_TAGS[tag] then
				EquipmentManager.Events.UnsheathedChanged:Invoke({
					Character = character,
					Item = item,
					AllTags = _ITEM_TAGS,
					Template = template,
					Tag = tag,
					Unsheathed = false
				})
				invokedTemplate = true
			end
		end

		if not invokedTemplate then
			if _listenerTemplates.UnsheathedChanged[template] then
				EquipmentManager.Events.UnsheathedChanged:Invoke({
					Character = character,
					Item = item,
					AllTags = _ITEM_TAGS,
					Template = template,
					Unsheathed = false
				})
			end
		end
	end
end

local function _InvokeUnsheathed(enabled, weapon, character)
	local invokedTemplate = false
	local _ITEM_TAGS = GameHelpers.GetItemTags(weapon, true)
	local template = GameHelpers.GetTemplate(weapon)

	for tag,_ in pairs(_listenerTags.UnsheathedChanged) do
		if _ITEM_TAGS[tag] then
			EquipmentManager.Events.UnsheathedChanged:Invoke({
				Character = character,
				Item = weapon,
				AllTags = _ITEM_TAGS,
				Template = template,
				Tag = tag,
				Unsheathed = enabled
			})
			invokedTemplate = true
		end
	end

	if not invokedTemplate then
		if _listenerTemplates.UnsheathedChanged[template] then
			EquipmentManager.Events.UnsheathedChanged:Invoke({
				Character = character,
				Item = weapon,
				AllTags = _ITEM_TAGS,
				Template = template,
				Unsheathed = false
			})
		end
	end
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
		if character.FightMode or character:GetStatus("UNSHEATHED") then
			local mainhand,offhand = GameHelpers.Character.GetEquippedWeapons(character)
			if mainhand then
				_InvokeUnsheathed(true, mainhand, character)
			end
			if offhand then
				_InvokeUnsheathed(true, offhand, character)
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