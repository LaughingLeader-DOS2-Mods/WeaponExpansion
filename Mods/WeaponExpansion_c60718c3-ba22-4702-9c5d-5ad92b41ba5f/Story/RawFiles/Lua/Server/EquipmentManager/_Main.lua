if EquipmentManager == nil then
	EquipmentManager = {}
end
EquipmentManager.__index = EquipmentManager

local self = EquipmentManager

Ext.Require("Server/EquipmentManager/Events.lua")
Ext.Require("Server/EquipmentManager/Tagging.lua")
Ext.Require("Server/EquipmentManager/RodSkills.lua")

---@param character EsvCharacter
---@param item EsvItem
function EquipmentManager:CheckWeaponAnimation(character, item, itemTags)
	itemTags = itemTags or {}
	local isTwoHanded = item.Stats.IsTwoHanded
	if (itemTags["LLWEAPONEX_Rapier"] or item:HasTag("LLWEAPONEX_Rapier")) and not isTwoHanded then
		Osi.LLWEAPONEX_AnimationSetOverride_Set(character.MyGuid, "LLWEAPONEX_Override1", "LLWEAPONEX_Rapier")
	elseif (itemTags["LLWEAPONEX_Katana"] or item:HasTag("LLWEAPONEX_Katana")) and isTwoHanded then
		Osi.LLWEAPONEX_AnimationSetOverride_Set(character.MyGuid, "LLWEAPONEX_Override1", "LLWEAPONEX_Katana")
	end
end

--TODO Refactor for new system changes
function MagicMissileWeapon_Swap(char, wand, rod)
	local equippedItem = nil
	local targetItem = nil
	local slot = GameHelpers.Item.GetEquippedSlot(char,wand)
	if slot == nil then
		slot = GameHelpers.Item.GetEquippedSlot(char,rod)
		equippedItem = rod
		targetItem = wand
	else
		equippedItem = wand
		targetItem = rod
	end
	if equippedItem ~= nil and targetItem ~= nil then
		CharacterUnequipItem(char, equippedItem)
		--ItemToInventory(equippedItem, targetItem, 1, 0, 0)
		NRD_CharacterEquipItem(char, targetItem, slot, 0, 0, 1, 1)
		Osi.LeaderLib_Timers_StartObjectObjectTimer(equippedItem, targetItem, 50, "Timers_LLWEAPONEX_MoveMagicMissileWeapon", "LeaderLib_Commands_ItemToInventory")
	end
end

local blockTagCombinations = {
	ARROWS = {
		LLWEAPONEX_Firearm_Equipped = "LLWEAPONEX_Notifications_BlockedArrowOnGun"
	},
	LLWEAPONEX_HandCrossbow = {
		LLWEAPONEX_HandCrossbow_Equipped = "LLWEAPONEX_Notifications_BlockedHandCrossbow"
	}
}

---@param item EsvItem
---@param char EsvCharacter
local function ShouldBlockItem(item, char)
	for itemTag,characterTags in pairs(blockTagCombinations) do
		if item:HasTag(itemTag) then
			for tag,blockText in pairs(characterTags) do
				if char:HasTag(tag) then
					if blockText ~= "" and CharacterIsControlled(char.MyGuid) == 1 and (char.IsPlayer or char.IsGameMaster) then
						ShowNotification(char.MyGuid, blockText)
					end
					return true
				end
			end
		end
	end
	return false
end

RegisterProtectedOsirisListener("CanUseItem", 3, "before", function(charUUID, itemUUID, request)
	charUUID = StringHelpers.GetUUID(charUUID)
	itemUUID = StringHelpers.GetUUID(itemUUID)
	if ObjectExists(itemUUID) == 0 or ObjectExists(charUUID) == 0 then
		return
	end
	local item = GameHelpers.GetItem(itemUUID)
	local char = GameHelpers.GetCharacter(charUUID)

	if item ~= nil and char ~= nil then
		if ShouldBlockItem(item, char) then
			if SharedData.GameMode ~= GAMEMODE.GAMEMASTER then
				Osi.DB_CustomUseItemResponse(charUUID, itemUUID, 0)
			else
				RequestProcessed(charUUID, request, 0)
			end
		end
	end
end)

local bulletTemplates = {
	["0f0dea4a-4e3b-48b0-92c7-6f33bdc3f2df"] = true,
	["0a1fa669-d8fb-4767-a129-e14fbd91b195"] = true,
	["d1b28a79-ccd2-481b-b035-13e15346cefb"] = true,
	["bc37a903-547a-4010-a845-7ef244e6b2cb"] = true,
	["92862716-b0db-46b4-9356-9858f9e743f0"] = true,
	["932fb7ba-2634-4b8a-b40a-936077a08008"] = true,
	["6e569546-bd74-4856-819b-d40b08b026ba"] = true,
	["e1125176-cd00-4f7a-8298-ac862d12cf15"] = true,
	["6572eec4-eeb3-4b9d-9cdd-15952a9a8ca6"] = true,
	["6e597ce1-d8b8-4720-89b9-75f6a71d64ba"] = true,
	["b059c11d-458a-4f89-8f18-15b48a402008"] = true,
	["a38aa4e6-ee75-4bb4-8c98-b9f358a23c25"] = true,
	["7ce736c8-1e02-462d-bee2-36bd86bd8979"] = true,
	["7c31f878-1f04-47bb-b8b1-05e605dc0b60"] = true,
	["deb24a84-006f-4a3a-b4bb-b40fa52a447d"] = true,
	["d4eebf4d-4f0c-4409-8fe8-32efeca06453"] = true,
	["8814954c-b0d1-4cdf-b075-3313ac71cf20"] = true,
	["22cae5a3-8427-4526-aa7f-4f277d0ff67e"] = true,
	["e44859b2-d55f-47e2-b509-fd32d7d3c745"] = true,
	["fbf17754-e604-4772-813a-3593b4e7bec8"] = true,
}

---@param item EsvItem
function EquipmentManager.ItemIsNearPlayers(item)
	local target = item
	local parentInventory = GetInventoryOwner(item.MyGuid)
	if not StringHelpers.IsNullOrEmpty(parentInventory) then
		if GameHelpers.Character.IsPlayer(parentInventory) then
			return true
		end
		target = Ext.GetGameObject(parentInventory)
	end
	for player in GameHelpers.Character.GetPlayers() do
		local dist = GameHelpers.Math.GetDistance(player.WorldPos, target.WorldPos)
		if dist <= 30 then
			return true
		end
	end
	return false
end

---@param item EsvItem
---@param changes table
---@param dynamicIndex integer|nil
function EquipmentManager.SyncItemStatChanges(item, changes, dynamicIndex)
	if changes.Boosts ~= nil and changes.Boosts["Damage Type"] ~= nil then
		changes.Boosts["DamageType"] = changes.Boosts["Damage Type"]
		changes.Boosts["Damage Type"] = nil
	end
	local slot = nil
	local owner = nil
	if item.Slot < 14 and item.OwnerHandle ~= nil then
		local char = GameHelpers.GetCharacter(item.OwnerHandle)
		if char ~= nil then
			slot = GameHelpers.Item.GetEquippedSlot(char.MyGuid, item.MyGuid)
			owner = char.NetID
		end
	end
	if item ~= nil and item.NetID ~= nil then
		local data = {
			UUID = item.MyGuid,
			NetID = item.NetID,
			Slot = slot,
			Owner = owner,
			Changes = changes,
			ID = item.StatsId
		}
		if EquipmentManager.ItemIsNearPlayers(item) then
			GameHelpers.Net.Broadcast("LLWEAPONEX_SetItemStats", data, nil)
		else
			--Ext.PrintWarning(string.format("[WeaponExpansion:EquipmentManager.SyncItemStatChanges] Item[%s] NetID(%s) UUID(%s) is not near any players, and cannot be retrieved by clients.", item.StatsId, item.NetID, item.MyGuid))
		end
	end
end

---@param char EsvCharacter
---@param item EsvItem
function EquipmentManager.CheckFirearmProjectile(char, item)
	if item:HasTag("LLWEAPONEX_Firearm")
	and not item:HasTag("Musk_Rifle") -- Musketeer has its own rune projectile tweaks
	and item.Stats ~= nil and string.find(item.StatsId, "LLWEAPONEX")
	then
		local changedProjectile = false
		local statChanges = {
			DynamicStats = {}
		}
		local itemStat = item.StatsFromName.StatsEntry
		---@cast itemStat +StatEntryWeapon
		for i,v in pairs(item.Stats.DynamicStats) do
			if not StringHelpers.IsNullOrEmpty(v.BoostName)
			and not StringHelpers.IsNullOrEmpty(v.Projectile)
			and v.Projectile ~= itemStat.Projectile
			and bulletTemplates[v.Projectile] ~= true then
				v.Projectile = itemStat.Projectile
				changedProjectile = true
				statChanges.DynamicStats[i] = {
					Projectile = v.Projectile
				}
			end
		end
		if changedProjectile then
			item.Stats.ShouldSyncStats = true
			EquipmentManager.SyncItemStatChanges(item, statChanges)
		end
	end
end

RegisterProtectedOsirisListener("RuneInserted", 4, "after", function(charUUID, itemUUID, runeTemplate, slot)
	local char = GameHelpers.GetCharacter(charUUID)
	local item = GameHelpers.GetItem(itemUUID)
	if char and item then
		EquipmentManager.CheckFirearmProjectile(char, item)
		--LLWEAPONEX_RunebladeRune
		if string.find(runeTemplate, "LOOT_Rune_LLWEAPONEX_Runeblade") and not item:HasTag("LLWEAPONEX_Runeblade") then
			local timerName = string.format("LLWEAPONEX_RemoveRune_%s%s%s", Ext.Utils.MonotonicTime(), runeTemplate, itemUUID)
			Timer.StartOneshot(timerName, 100, function()
				local rune = ItemRemoveRune(charUUID, itemUUID, slot)
				if not StringHelpers.IsNullOrEmpty(rune) then
					local text = GameHelpers.GetStringKeyText("LLWEAPONEX_StatusText_RunebladeRuneBlocked", "<font color='#FF0000' size='22'>*This rune can only be inserted into a <font color='#40E0D0'>Runeblade</font>.*</font>")
					CharacterStatusText(charUUID, text)
				end
			end)
		end
	end
end)

RegisterProtectedOsirisListener("RuneRemoved", 4, "after", function(charUUID, itemUUID, runeUUID, slot)
	local char = GameHelpers.GetCharacter(charUUID)
	local item = GameHelpers.GetItem(itemUUID)
	if char and item then
		EquipmentManager.CheckFirearmProjectile(char, item)
	end
end)