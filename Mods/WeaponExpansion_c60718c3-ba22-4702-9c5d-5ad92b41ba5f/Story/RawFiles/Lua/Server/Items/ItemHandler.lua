local function _GetPreset(character)
	local preset = nil
	if character.PlayerCustomData then
		preset = character.PlayerCustomData.ClassType
	else
		preset = GetVarFixedString(character.MyGuid, "LeaderLib_CurrentPreset") or GetVarString(character.MyGuid, "LeaderLib_CurrentPreset") or GetVarFixedString(character.MyGuid, "LeaderLib_CharacterCreationPreset")
	end
	return preset
end

ItemProcessor.SmugglersBagPresetToTreasure = {
	LLWEAPONEX_Assassin = "ST_LLWEAPONEX_SmugglersBag_AssassinLoot",
	LLWEAPONEX_Pirate = "ST_LLWEAPONEX_SmugglersBag_PirateLoot",
	LLWEAPONEX_Helaene_Marauder = "ST_LLWEAPONEX_SmugglersBag_MarauderLoot",
	Default = "ST_LLWEAPONEX_SmugglersBag_Random",
}

Events.ObjectEvent:Subscribe(function (e)
	local character,item = table.unpack(e.Objects)
	---@cast character EsvCharacter
	---@cast item EsvItem

	local owner = GameHelpers.Item.GetOwner(item)
	local preset = _GetPreset(character)
	local treasure = ItemProcessor.SmugglersBagTreasure[preset]
	if not treasure and owner then
		preset = _GetPreset(owner)
		treasure = ItemProcessor.SmugglersBagTreasure[preset]
	end

	if not treasure then
		treasure = ItemProcessor.SmugglersBagTreasure.Default
	end
	CharacterGiveReward(character.MyGuid, treasure, 1)
	ItemDestroy(item.MyGuid)
end, {MatchArgs={Event="LLWEAPONEX_OpenSmugglersBag", EventType="CharacterItemEvent"}})

--Mods.WeaponExpansion.GenerateTradeTreasure("680d2702-721c-412d-b083-4f5e816b945a", "ST_LLWEAPONEX_VendingMachine_OrderWeapon")
--GenerateItems(me.MyGuid, "680d2702-721c-412d-b083-4f5e816b945a")
function GenerateTradeTreasure(traderGUID, treasure)
	if ObjectIsCharacter(traderGUID) == 1 then
		local x,y,z = GetPosition(traderGUID)
		--LOOT_LeaderLib_BackPack_Invisible_98fa7688-0810-4113-ba94-9a8c8463f830
		local backpackGUID = CreateItemTemplateAtPosition("98fa7688-0810-4113-ba94-9a8c8463f830", x, y, z)
		Timer.StartOneshot("", 50, function ()
			local trader = GameHelpers.GetCharacter(traderGUID)
			fprint(LOGLEVEL.TRACE, "[WeaponExpansion:GenerateTradeTreasure] Generating treasure table (%s) for (%s)", treasure, trader.DisplayName, traderGUID)
			local backpack = GameHelpers.GetItem(backpackGUID)
			if backpack then
				GenerateTreasure(backpackGUID, treasure, trader.Stats.Level, traderGUID)
				ContainerIdentifyAll(backpackGUID)
				for i,v in pairs(backpack:GetInventoryItems()) do
					local tItem = GameHelpers.GetItem(v)
					if tItem ~= nil then
						tItem.UnsoldGenerated = true -- Trade treasure flag
						ItemToInventory(v, traderGUID, tItem.Amount, 0, 0)
					else
						ItemToInventory(v, traderGUID, 1, 0, 0)
					end
					ItemSetOwner(v, traderGUID)
					ItemSetOriginalOwner(v, traderGUID)
				end
				ItemRemove(backpackGUID)
			else
				Ext.Utils.PrintError("[WeaponExpansion:GenerateTradeTreasure] Failed to create backpack from root template 'LOOT_LeaderLib_BackPack_Invisible_98fa7688-0810-4113-ba94-9a8c8463f830'")
				CharacterGiveReward(traderGUID, treasure, 1)
			end
		end)
	elseif ObjectIsItem(traderGUID) == 1 then
		GenerateTreasure(traderGUID, treasure, GameHelpers.Item.GetItemLevel(traderGUID), traderGUID)
	end
end