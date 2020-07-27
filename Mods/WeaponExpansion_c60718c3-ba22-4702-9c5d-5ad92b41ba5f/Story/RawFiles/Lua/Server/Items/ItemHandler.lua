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

function OnSmugglersBagOpened(char, item)
	local owner = ItemGetOriginalOwner(item)
	local preset = GetVarFixedString(owner, "LeaderLib_CurrentPreset")
	if preset == "" or preset == nil then
		preset = GetVarFixedString(owner, "LeaderLib_CharacterCreationPreset")
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
		ItemDestroy(item)
	end
end