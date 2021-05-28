local self = EquipmentManager

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

	if not itemTags["LLWEAPONEX_TaggedWeaponType"]
	and (SharedData.GameMode == GAMEMODE.GAMEMASTER or isPlayer)
	and (statType == "Weapon" or statType == "Shield") then
		self:TagWeapon(item, statType, item.StatsId, itemTags)
	end

	if isPlayer and statType == "Weapon" then
		self:CheckWeaponRequirementTags(character, item)
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
						SetTag(character.MyGuid, tag)
						fprint(LOGLEVEL.TRACE, "[WeaponExpansion:OnItemEquipped] Setting mastery tag [%s] on [%s]", tag, character.MyGuid)
					end
				end
				Osi.LLWEAPONEX_Equipment_OnTaggedItemEquipped(character.MyGuid, item.MyGuid, tag, isPlayer)
			end
		end
	end

	self:CheckWeaponAnimation(character, item, itemTags)

	Osi.LLWEAPONEX_OnItemTemplateEquipped(character.MyGuid, item.MyGuid, item.RootTemplate.Id)

	for k,unique in pairs(Uniques) do
		if itemTags[unique.Tag] then
			unique:OnEquipped(character, item)
			if unique.UUID ~= item.MyGuid then
				unique:AddCopy(item.MyGuid, character.MyGuid)
				unique:ApplyProgression(nil, nil, item, true)
			end
			if not unique:IsReleasedFromOwner(item.MyGuid) then
				unique:ReleaseFromOwner(false, item.MyGuid)
			end
			unique:SetOwner(item.MyGuid, character.MyGuid)
		end
	end

	if isPlayer then
		if item.Stats.Unique == 1 or item.Stats.ItemTypeReal == "Unique" then
			UniqueManager.LevelUpUnique(character, item)
		end
		EquipmentManager.CheckFirearmProjectile(character, item)
	end

	local callbacks = Listeners.EquipmentChanged.Template[item.RootTemplate.Id]
	if callbacks ~= nil then
		if Vars.DebugMode then
			Ext.Print(string.format("[WeaponExpansion:EquipmentChanged.Template] Template(%s) Stat(%s) Character(%s) Equipped(true)", item.RootTemplate.Id, item.StatsId, character.MyGuid))
		end
		for i,callback in pairs(callbacks) do
			local b,err = xpcall(callback, debug.traceback, character, item, item.RootTemplate.Id, true)
			if not b then
				Ext.PrintError(err)
			end
		end
	end
	for tag,callbacks in pairs(Listeners.EquipmentChanged.Tag) do
		if itemTags[tag] then
			if Vars.DebugMode then
				Ext.Print(string.format("[WeaponExpansion:EquipmentChanged.Tag] Tag(%s) Stat(%s) Character(%s) Equipped(true)", tag, item.StatsId, character.MyGuid))
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

	--TODO Refactor to Lua stuff
	Osi.LLWEAPONEX_OnItemTemplateUnEquipped(character.MyGuid, item.MyGuid, item.RootTemplate.Id)
	Osi.LLWEAPONEX_Equipment_ClearItem(character.MyGuid, item.MyGuid, isPlayer)
	Osi.LLWEAPONEX_WeaponMastery_RemovedTrackedMasteries(character.MyGuid, item.MyGuid)

	if isPlayer then
		self:CheckWeaponRequirementTags(character)
	end
	self:CheckForUnarmed(character, isPlayer)

	local callbacks = Listeners.EquipmentChanged.Template[template]
	if callbacks ~= nil then
		if Vars.DebugMode then
			Ext.Print(string.format("[WeaponExpansion:EquipmentChanged.Template] Template(%s) Stat(%s) Character(%s) Equipped(false)", template, item.StatsId, character.MyGuid))
		end
		for i,callback in pairs(callbacks) do
			local b,err = xpcall(callback, debug.traceback, character, item, template, false)
			if not b then
				Ext.PrintError(err)
			end
		end
	end
	for tag,callbacks in pairs(Listeners.EquipmentChanged.Tag) do
		if item:HasTag(tag) then
			if Vars.DebugMode then
				Ext.Print(string.format("[WeaponExpansion:EquipmentChanged.Tag] Tag(%s) Stat(%s) Character(%s) Equipped(false)", tag, item.StatsId, character.MyGuid))
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
	item = StringHelpers.GetUUID(item); character = StringHelpers.GetUUID(character)
	if not Ignore(character, item) then self:OnItemEquipped(Ext.GetCharacter(character), Ext.GetItem(item)) end
end)
RegisterProtectedOsirisListener("ItemUnEquipped", Data.OsirisEvents.ItemUnEquipped, "after", function(item,character)
	item = StringHelpers.GetUUID(item); character = StringHelpers.GetUUID(character)
	if not Ignore(character, item) then self:OnItemUnEquipped(Ext.GetCharacter(character), Ext.GetItem(item)) end
end)

RegisterProtectedOsirisListener("ItemAddedToCharacter", Data.OsirisEvents.ItemAddedToCharacter, "after", function(item, char)
	item = Ext.GetItem(item); char = Ext.GetCharacter(char)
	if char and item then
		if not GameHelpers.Item.IsObject(item) then
			for k,unique in pairs(Uniques) do
				if unique.Tag and GameHelpers.ItemHasTag(item, unique.Tag) then
					if GameHelpers.Character.IsPlayer(char) and not unique:IsReleasedFromOwner() then
						unique:ReleaseFromOwner()
					end
					unique:InvokeEventListeners("ItemAddedToCharacter", item.MyGuid, char.MyGuid)
				end
			end
		end
	end
end)

RegisterProtectedOsirisListener("CharacterItemEvent", Data.OsirisEvents.CharacterItemEvent, "after", function(char, item, event)
	item = Ext.GetItem(item); char = Ext.GetCharacter(char)
	if not GameHelpers.Item.IsObject(item) then
		if item.Stats.Unique == 1 or item.Stats.ItemTypeReal == "Unique" then
			local unique = UniqueManager.GetDataByItem(item)
			if unique then
				if event == "LeaderLib_Events_ItemLeveledUp" then
					unique:OnItemLeveledUp(item)
				else
					unique:InvokeEventListeners("CharacterItemEvent", char, item, event)
				end
			end
		end
	end
end)