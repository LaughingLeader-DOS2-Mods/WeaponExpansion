function OnItemTemplateAddedToCharacter(char, item, template)

end

local containerItems = {}

function CanParseContainerTreasure(item)
	return ItemIsContainer(item) == 1 
		and ObjectGetFlag(item, "LLWEAPONEX_ParsedGeneratedItems") == 0
		--and ItemIsInInventory(item) == 0
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
	print("OnItemTemplateOpening["..item.."]("..template..")")
	print(Ext.JsonStringify(containerItems[item]))

	for i,v in pairs(containerItems[item]) do
		SwapDeltamods(v)
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
	print("CheckCharacterDeathTreasure["..char.."]")
	print(Ext.JsonStringify(items))

	for i,v in pairs(items) do
		SwapDeltamods(v)
	end
end

function OnSmugglersBagOpened(char, item)
	local owner = ItemGetOriginalOwner(item)
	local preset = GetVarFixedString(owner, "LeaderLib_CurrentPreset")
	if not StringHelpers.IsNullOrEmpty(preset) then
		if preset == "LLWEAPONEX_Assassin" then
			CharacterGiveReward(char, "ST_LLWEAPONEX_SmugglersBag_AssassinLoot", 1)
		elseif preset == "LLWEAPONEX_Pirate" then
			CharacterGiveReward(char, "ST_LLWEAPONEX_SmugglersBag_PirateLoot", 1)
		else
			CharacterGiveReward(char, "ST_LLWEAPONEX_SmugglersBag_Random", 1)
		end
		ItemDestroy(item)
	end
end