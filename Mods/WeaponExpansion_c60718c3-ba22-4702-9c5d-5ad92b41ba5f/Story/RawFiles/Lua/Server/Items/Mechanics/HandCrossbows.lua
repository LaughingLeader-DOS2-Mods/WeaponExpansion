---@param character EsvCharacter
---@param item EsvItem
---@param runeBolt EsvItem|nil
local function _TryInsertBolt(character, item, runeBolt)
	local insertedRunes = GameHelpers.Item.GetRunes(item)
	if insertedRunes[1] == nil then
		if not runeBolt then
			local bolts = GameHelpers.Character.GetTaggedItems(character, "LLWEAPONEX_HandCrossbowBolt", true)
			runeBolt = bolts[1]
		end
		if runeBolt then
			---@cast runeBolt EsvItem
			ItemInsertRune(character.MyGuid, item.MyGuid, GameHelpers.GetTemplate(runeBolt), 0)
			if GameHelpers.Item.GetRunes(item)[1] then
				ItemRemove(runeBolt.MyGuid)
				CharacterStatusText(character.MyGuid, "LLWEAPONEX_StatusText_Handcrossbow_BoltAutoInserted")
			end
		end
	end
end

EquipmentManager.Events.EquipmentChanged:Subscribe(function (e)
	if ObjectGetFlag(e.ItemGUID, "LLWEAPONEX_HandCrossbow_DisableAutoInsert") == 0 then
		_TryInsertBolt(e.Character, e.Item)
	end
end, {MatchArgs={Tag="LLWEAPONEX_HandCrossbow"}})

Events.CharacterUsedItem:Subscribe(function (e)
	local handCrossbow = nil
	for item in GameHelpers.Character.GetEquipment(e.Character) do
		if GameHelpers.ItemHasTag(item, "LLWEAPONEX_HandCrossbow") then
			handCrossbow = item
			break
		end
	end
	if handCrossbow then
		local rune = ItemRemoveRune(e.CharacterGUID, handCrossbow.MyGuid, 0)
		if rune then
			ItemToInventory(rune, e.CharacterGUID, 1, 0, 1)
		end
		_TryInsertBolt(e.Character, handCrossbow, e.Item)
	else
		ShowNotification(e.CharacterGUID, "LLWEAPONEX_Notifications_HandCrossbow_InsertBolts_NotEquipped")
	end
end, {MatchArgs=function (e)
	return e.Success and e.Item:HasTag("LLWEAPONEX_HandCrossbowBolt")
end})

Events.RuneChanged:Subscribe(function (e)
	ObjectSetFlag(e.ItemGUID, "LLWEAPONEX_HandCrossbow_DisableAutoInsert", 0)
end, {
---@param e RuneChangedEventArgs
MatchArgs=function(e)
	return not e.Inserted and e.Item:HasTag("LLWEAPONEX_HandCrossbow")
end})