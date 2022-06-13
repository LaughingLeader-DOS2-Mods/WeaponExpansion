function OnItemTemplateAddedToCharacter(char, item, template)

end

local containerItems = {}

function CanParseContainerTreasure(item)
	return ItemIsContainer(item) == 1 and ObjectGetFlag(item, "LLWEAPONEX_ParsedGeneratedItems") == 0
end

local function storeContainerItem(item, container)
	if containerItems[container] == nil then
		containerItems[container] = {}
	end
	table.insert(containerItems[container], item)
end

function SaveContainerItem(item)
	local container = GetInventoryOwner(item)
	if container ~= nil then
		container = GetUUID(container)
		storeContainerItem(item, container)
	end
end

function OnItemTemplateOpening(char, item, template)
	containerItems[item] = {}
	InventoryLaunchIterator(item, "LLWEAPONEX_Iterator_StoreFoundItem", "")
	FireOsirisEvents()
	for i,v in pairs(containerItems[item]) do
		SwapDeltaMods(v)
	end

	containerItems[item] = nil
end

function CanParseCorpseTreasure(char)
	return CharacterIsPlayer(char) == 0 
		and CharacterIsSummon(char) == 0
		and NRD_CharacterGetInt(char, "Resurrected") == 0
		and ObjectGetFlag(char, "LLWEAPONEX_ParsedGeneratedItems") == 0
end

function CheckCharacterDeathTreasure(char)
	---@type EsvCharacter
	local character = Ext.GetCharacter(char)
	local items = character:GetInventoryItems()
	for i,v in pairs(items) do
		SwapDeltaMods(v)
	end
end

local function GetPlayerDataPreset(char)
	local character = Ext.GetCharacter(char)
	if character ~= nil and character.PlayerCustomData ~= nil then
		return character.PlayerCustomData.ClassType
	end
	return nil
end

function OnSmugglersBagOpened(char, item)
	local owner = ItemGetOriginalOwner(item)
	local preset =  GetVarFixedString(owner, "LeaderLib_CurrentPreset") or GetVarString(owner, "LeaderLib_CurrentPreset")
	if StringHelpers.IsNullOrEmpty(preset) then
		preset = GetPlayerDataPreset(char)
		if StringHelpers.IsNullOrEmpty(preset) then
			preset = GetVarFixedString(owner, "LeaderLib_CharacterCreationPreset")
		end
	end
	if not StringHelpers.IsNullOrEmpty(preset) then
		if preset == "LLWEAPONEX_Assassin" then
			CharacterGiveReward(char, "ST_LLWEAPONEX_SmugglersBag_AssassinLoot", 1)
		elseif preset == "LLWEAPONEX_Pirate" then
			CharacterGiveReward(char, "ST_LLWEAPONEX_SmugglersBag_PirateLoot", 1)
		elseif "LLWEAPONEX_Helaene_Marauder" then
			CharacterGiveReward(char, "ST_LLWEAPONEX_SmugglersBag_MarauderLoot", 1)
		else
			CharacterGiveReward(char, "ST_LLWEAPONEX_SmugglersBag_Random", 1)
		end
	else
		CharacterGiveReward(char, "ST_LLWEAPONEX_SmugglersBag_Random", 1)
	end
	ItemDestroy(item)
end

--Mods.WeaponExpansion.GenerateTradeTreasure("680d2702-721c-412d-b083-4f5e816b945a", "ST_LLWEAPONEX_VendingMachine_OrderWeapon")
--GenerateItems(me.MyGuid, "680d2702-721c-412d-b083-4f5e816b945a")
function GenerateTradeTreasure(uuid, treasure)
	local object = GameHelpers.TryGetObject(uuid)
	if ObjectIsCharacter(uuid) == 1 then
		local x,y,z = GetPosition(uuid)
		--LOOT_LeaderLib_BackPack_Invisible_98fa7688-0810-4113-ba94-9a8c8463f830
		local backpackGUID = CreateItemTemplateAtPosition("98fa7688-0810-4113-ba94-9a8c8463f830", x, y, z)
		Timer.StartOneshot("", 50, function ()
			fprint(LOGLEVEL.TRACE, "[WeaponExpansion:GenerateTradeTreasure] Generating treasure table (%s) for (%s)", treasure, object.DisplayName, uuid)
			local backpack = Ext.GetItem(backpackGUID)
			if backpack then
				GenerateTreasure(backpackGUID, treasure, object.Stats.Level, uuid)
				ContainerIdentifyAll(backpackGUID)
				for i,v in pairs(backpack:GetInventoryItems()) do
					local tItem = Ext.GetItem(v)
					if tItem ~= nil then
						tItem.UnsoldGenerated = true -- Trade treasure flag
						ItemToInventory(v, uuid, tItem.Amount, 0, 0)
					else
						ItemToInventory(v, uuid, 1, 0, 0)
					end
					ItemSetOwner(v, uuid)
					ItemSetOriginalOwner(v, uuid)
				end
				ItemRemove(backpackGUID)
			else
				Ext.PrintError("[WeaponExpansion:GenerateTradeTreasure] Failed to create backpack from root template 'LOOT_LeaderLib_BackPack_Invisible_98fa7688-0810-4113-ba94-9a8c8463f830'")
				CharacterGiveReward(uuid, treasure, 1)
			end
		end)
	elseif ObjectIsItem(uuid) == 1 then
		GenerateTreasure(uuid, treasure, Ext.GetItem(uuid).Stats.Level or 1, uuid)
	end
end