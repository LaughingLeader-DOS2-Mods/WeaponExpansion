--S_LLWEAPONEX_VendingMachine_A_680d2702-721c-412d-b083-4f5e816b945a
local VENDING_MACHINE = "680d2702-721c-412d-b083-4f5e816b945a"

UniqueManager = {
	Classes = {},
	---@type table<string,UniqueData>
	TagToUnique = {},
	FirstLoad = true,
}

local isClient = Ext.IsClient()

Ext.Require("Shared/Uniques/Classes/UniqueData/UniqueData.lua")

---@type UniqueData
local UniqueData = UniqueManager.Classes.UniqueData

---@type AllUniqueProgressionData
local ProgressionData = Ext.Require("Shared/Uniques/Progression.lua")


local function CheckForAnvilWeightChange(data, character)

end

local function OnTattoosEquipped(data, character)
	ItemLockUnEquip(data.UUID, 1)
end

---@param data UniqueData
---@param owner string
local function ScatterOnDeath(data, owner)
	local x,y,z = GetPosition(owner)
	ItemScatterAt(data.UUID, x, y, z)
end

---@type table<string, UniqueData>
Uniques = {
	AnatomyBook = UniqueData:Create(ProgressionData.AnatomyBook, {Tag="LLWEAPONEX_UniqueAnatomyBook"}),
	AnvilMace = UniqueData:Create(ProgressionData.AnvilMace, {Tag="LLWEAPONEX_UniqueAnvilMace"}),
	ArmCannon = UniqueData:Create(ProgressionData.ArmCannon, {Tag="LLWEAPONEX_RunicCannonGloves"}),
	AssassinHandCrossbow = UniqueData:Create(ProgressionData.AssassinHandCrossbow, {Tag="LLWEAPONEX_AssassinHandCrossbow_Equipped"}),
	BalrinAxe = UniqueData:Create(ProgressionData.BalrinAxe, {Tag="LLWEAPONEX_UniqueThrowingAxeA"}),
	BeholderSword = UniqueData:Create(ProgressionData.BeholderSword, {Tag="LLWEAPONEX_UniqueBeholderGreatsword"}),
	Bible = UniqueData:Create(ProgressionData.Bible, {Tag="LLWEAPONEX_UniqueBible"}),
	Blunderbuss = UniqueData:Create(ProgressionData.Blunderbuss, {Tag="LLWEAPONEX_UniqueBlunderbuss"}),
	PacifistsWrath = UniqueData:Create(ProgressionData.PacifistsWrath, {Tag="LLWEAPONEX_UniqueBokken2H"}),
	ChaosEdge = UniqueData:Create(ProgressionData.ChaosEdge, {Tag="LLWEAPONEX_UniqueRunebladeChaosGreatsword"}),
	BasilusDagger = UniqueData:Create(ProgressionData.BasilusDagger, {Tag="LLWEAPONEX_UniqueBasilusDagger"}),
	DeathEdge = UniqueData:Create(ProgressionData.DeathEdge, {Tag="LLWEAPONEX_UniqueDeathEdge"}),
	DemoBackpack = UniqueData:Create(ProgressionData.DemoBackpack, {Tag="LLWEAPONEX_DemolitionBackpack"}),
	DemonGauntlet = UniqueData:Create(ProgressionData.DemonGauntlet, {Tag="LLWEAPONEX_DemonGauntlet"}),
	DivineBanner = UniqueData:Create(ProgressionData.DivineBanner, {Tag="LLWEAPONEX_UniqueDivineBanner"}),
	FireRunebladeKatana = UniqueData:Create(ProgressionData.FireRunebladeKatana, {Tag="LLWEAPONEX_UniqueRunebladeFireKatana"}),
	Frostdyne = UniqueData:Create(ProgressionData.Frostdyne, {Tag="LLWEAPONEX_UniqueRunebladeRapier"}),
	HarkenPowerGloves = UniqueData:Create(ProgressionData.HarkenPowerGloves, {OnEquipped=CheckForAnvilWeightChange, Tag="LLWEAPONEX_UniquePowerGauntlets"}),
	HarkenTattoos = UniqueData:Create(ProgressionData.HarkenTattoos, {Tag="LLWEAPONEX_UniqueStrengthTattoos", OnEquipped=OnTattoosEquipped}),
	Harvest = UniqueData:Create(ProgressionData.Harvest, {Tag="LLWEAPONEX_UniqueHarvestScythe"}),
	LoneWolfBanner = UniqueData:Create(ProgressionData.LoneWolfBanner, {Tag="LLWEAPONEX_UniqueLoneWolfBanner"}),
	MagicMissileWand = UniqueData:Create(ProgressionData.MagicMissileWand, {Tag="LLWEAPONEX_UniqueMagicMissileWand"}),
	MonkBlindfold = UniqueData:Create(ProgressionData.MonkBlindfold, {Tag="LLWEAPONEX_UniqueBlindfold"}),
	Muramasa = UniqueData:Create(ProgressionData.Muramasa, {Tag="LLWEAPONEX_UniqueMuramasaKatana"}),
	OgreScroll = UniqueData:Create(ProgressionData.OgreScroll, {Tag="LLWEAPONEX_UniqueOgreScroll"}),
	Omnibolt = UniqueData:Create(ProgressionData.Omnibolt, {Tag="LLWEAPONEX_UniqueOmniboltGreatbow"}),
	PowerPole = UniqueData:Create(ProgressionData.PowerPole, {Tag="LLWEAPONEX_UniquePowerPole"}),
	WarchiefHalberd = UniqueData:Create(ProgressionData.WarchiefHalberd, {Tag="LLWEAPONEX_UniqueWarchiefHalberdSpear"}),
	Wraithblade = UniqueData:Create(ProgressionData.Wraithblade, {Tag="LLWEAPONEX_UniqueWraithblade"}),
	Victory = UniqueData:Create(ProgressionData.Victory, {Tag="LLWEAPONEX_UniqueSwordofVictory"}),
}

Uniques.MagicMissileRod = UniqueData:Create(ProgressionData.MagicMissileRod, {Tag="LLWEAPONEX_UniqueMagicMissileRod", LinkedItem=Uniques.MagicMissileWand, CanMoveToVendingMachine=false, IsLinkedItem=true})
Uniques.PacifistsWrath1H = UniqueData:Create(ProgressionData.PacifistsWrath1H, {Tag="LLWEAPONEX_UniqueBokken1H", LinkedItem=Uniques.PacifistsWrath, CanMoveToVendingMachine=false, IsLinkedItem=true})
Uniques.PacifistsWrath.LinkedItem = Uniques.PacifistsWrath1H
Uniques.WarchiefAxe = UniqueData:Create(ProgressionData.WarchiefAxe, {Tag="LLWEAPONEX_UniqueWarchiefHalberdAxe", LinkedItem=Uniques.WarchiefHalberd, CanMoveToVendingMachine=false, IsLinkedItem=true})
Uniques.WarchiefHalberd.LinkedItem = Uniques.WarchiefAxe

for id,v in pairs(Uniques) do
	v.ID = id
end

---@param tag string
---@return UniqueData
function UniqueManager.GetDataByTag(tag)
	for k,v in pairs(Uniques) do
		if v.Tag == tag then
			return v
		end
	end
	return nil
end

---@param item EsvItem|string
---@return UniqueData
function UniqueManager.GetDataByItem(item)
	local t = type(item)
	if t == "string" then
		local tryItem = Ext.GetItem(item)
		if tryItem then
			item = tryItem
			t = "userdata"
		else
			for k,v in pairs(Uniques) do
				if v.UUID == item or v.Copies[item] or GameHelpers.ItemHasTag(item, v.Tag) then
					return v
				end
			end
		end
	end
	if t == "userdata" then
		for k,v in pairs(Uniques) do
			if v.UUID == item.MyGuid or v.Copies[item.MyGuid] then
				return v
			elseif GameHelpers.ItemHasTag(item, v.Tag) then
				return v
			end
		end
	end
	return nil
end

---For getting unique data by UUID.
---@type table<string,UniqueData>
AllUniques = {}

local LinkedUniques = {}

---@param item1 string
---@param item2 string
---@param skipSave boolean|nil
function UniqueManager.LinkItems(item1, item2, skipSave)
	local b,err = xpcall(function()
		fassert(not StringHelpers.IsNullOrWhitespace(item1) and not StringHelpers.IsNullOrWhitespace(item2), "UUID 1 (%s) or 2 (%s) is nil", item1, item2)
		LinkedUniques[item1] = item2
		LinkedUniques[item2] = item1
		if skipSave ~= true then
			PersistentVars.LinkedUniques = LinkedUniques
		end
	end, debug.traceback)
	if not b then
		Ext.PrintError(err)
	end
end

function UniqueManager.LoadLinkedUniques()
	UniqueManager.LinkItems(Uniques.MagicMissileWand.DefaultUUID, Uniques.MagicMissileRod.DefaultUUID, true)
	UniqueManager.LinkItems(Uniques.WarchiefAxe.DefaultUUID, Uniques.WarchiefHalberd.DefaultUUID, true)
	UniqueManager.LinkItems(Uniques.PacifistsWrath.DefaultUUID, Uniques.PacifistsWrath1H.DefaultUUID, true)
	if PersistentVars.LinkedUniques ~= nil then
		for uuid,uuid2 in pairs(PersistentVars.LinkedUniques) do
			if ObjectExists(uuid) == 1 and ObjectExists(uuid2) == 1 then
				UniqueManager.LinkItems(uuid,uuid2,true)
			else
				LinkedUniques[uuid] = nil
				LinkedUniques[uuid2] = nil
			end
		end
	end
	PersistentVars.LinkedUniques = LinkedUniques
end

function UniqueManager.GetLinkedUnique(uuid)
	return LinkedUniques[uuid]
end

-- CharacterSetVisualElement(Mods.WeaponExpansion.Origin.Harken, 3, "LLWEAPONEX_Dwarves_Male_Body_Naked_A_UpperBody_Tattoos_Magic_A")

function UniqueManager.OnDeath(char)
	if not IsPlayer(char) then
		for key,unique in pairs(Uniques) do
			if unique.Owner == char then
				if unique.OnOwnerDeath == nil then
					ItemToInventory(unique.UUID, char, 1, 0, 1)
				else
					local b,result = xpcall(unique.OnOwnerDeath, debug.traceback, unique, char)
					if not b then
						Ext.PrintError(result)
					end
				end
			end
		end
	end
end

local function CanAutoLevelUnique(item)
	return (item:HasTag("LeaderLib_AutoLevel") or item:HasTag("LLWEAPONEX_AutoLevel")) and GetSettings().Global:FlagEquals("LLWEAPONEX_UniqueAutoLevelingDisabled", false)
end

---@param character EsvCharacter
---@param item EsvItem
function UniqueManager.LevelUpUnique(character, item)
	if CanAutoLevelUnique(item) then
		if item.Stats.Level < character.Stats.Level then
			ItemLevelUpTo(item.MyGuid, character.Stats.Level)
		end
		local uniqueData = UniqueManager.GetDataByItem(item)
		if uniqueData ~= nil then
			uniqueData:OnItemLeveledUp(item.MyGuid)
		end
	end
end

function UniqueManager.FindOrphanedUniques()
	for uuid,tag in pairs(PersistentVars.Uniques) do
        if ObjectExists(uuid) == 0 then
            PersistentVars.Uniques[uuid] = nil
        else
            local data = UniqueManager.GetDataByTag(tag)
			if data ~= nil then
				if data.UUID ~= uuid then
					local owner = data:GetOwner(uuid)
					data.Copies[uuid] = owner
				else
					PersistentVars.Uniques[uuid] = nil
				end
            end
        end
	end
end

function UniqueManager.SaveRequirementChanges()
	if PersistentVars.UniqueRequirements ~= nil then
		local payload = Ext.JsonStringify(PersistentVars.UniqueRequirements)
		--Ext.SaveFile("WeaponExpansion_UniqueRequirementChanges.json", payload)
		Ext.BroadcastMessage("LLWEAPONEX_SaveUniqueRequirementChanges", payload)
	end
end

--[[
event ItemAddedToCharacter((ITEMGUID)_Item, (CHARACTERGUID)_Character) (3,0,497,1)
event ItemDropped((ITEMGUID)_Item) (3,0,505,1)
event ItemEnteredTrigger((ITEMGUID)_Item, (TRIGGERGUID)_Trigger, (CHARACTERGUID)_Mover) (3,0,506,1)
event ItemTemplateEnteredTrigger((STRING)_ItemTemplate, (ITEMGUID)_Item, (TRIGGERGUID)_Trigger, (CHARACTERGUID)_Owner, (CHARACTERGUID)_Mover) (3,0,507,1)
event ItemLeftTrigger((ITEMGUID)_Item, (TRIGGERGUID)_Trigger, (CHARACTERGUID)_Mover) (3,0,508,1)
event ItemTemplateLeftTrigger((STRING)_ItemTemplate, (ITEMGUID)_Item, (TRIGGERGUID)_Trigger, (CHARACTERGUID)_Owner, (CHARACTERGUID)_Mover) (3,0,509,1)
event ItemAddedToContainer((ITEMGUID)_Item, (ITEMGUID)_Container) (3,0,510,1)
event ItemTemplateAddedToCharacter((GUIDSTRING)_ItemTemplate, (ITEMGUID)_Item, (CHARACTERGUID)_Character) (3,0,511,1)
event ItemTemplateAddedToContainer((STRING)_ItemTemplate, (ITEMGUID)_Item, (ITEMGUID)_Container) (3,0,512,1)
event ItemRemovedFromCharacter((ITEMGUID)_Item, (CHARACTERGUID)_Character) (3,0,513,1)
event ItemTemplateRemovedFromCharacter((STRING)_ItemTemplate, (ITEMGUID)_Item, (CHARACTERGUID)_Character) (3,0,514,1)
event ItemRemovedFromContainer((ITEMGUID)_Item, (ITEMGUID)_Container) (3,0,515,1)
event ItemTemplateRemovedFromContainer((STRING)_ItemTemplate, (ITEMGUID)_Item, (ITEMGUID)_Container) (3,0,516,1)
event ItemEquipped((ITEMGUID)_Item, (CHARACTERGUID)_Character) (3,0,517,1)
event ItemUnEquipped((ITEMGUID)_Item, (CHARACTERGUID)_Character) (3,0,518,1)

call ItemScatterAt((ITEMGUID)_Item, (REAL)_X, (REAL)_Y, (REAL)_Z) (1,0,411,1)
]]

local itemEvents = {
	["ItemDropped"] = {arity = 1, itemArg = 1},
	["ItemAddedToContainer"] = {arity = 2, itemArg = 1},
	["ItemRemovedFromContainer"] = {arity = 2, itemArg = 1},
	--["ItemAddedToCharacter"] = {arity = 2, itemArg = 1},
	["ItemRemovedFromCharacter"] = {arity = 2, itemArg = 1},
	["ItemEquipped"] = {arity = 2, itemArg = 1},
	["ItemUnEquipped"] = {arity = 2, itemArg = 1},
	["ItemMovedFromTo"] = {arity = 4, itemArg = 1},
	["ItemUnEquipFailed"] = {arity = 2, itemArg = 1},
	["ItemMoved"] = {arity = 1, itemArg = 1},
	["RuneInserted"] = {arity = 4, itemArg = 2},
	["RuneRemoved"] = {arity = 4, itemArg = 2},
	["CharacterUsedItem"] = {arity = 2, itemArg = 2},
	["CharacterMovedItem"] = {arity = 2, itemArg = 2},
	["CharacterPreMovedItem"] = {arity = 2, itemArg = 2},
	["CharacterPickpocketSuccess"] = {arity = 4, itemArg = 3},
	["ItemSendToHomesteadEvent"] = {arity = 2, itemArg = 2},
	["CharacterStoleItem"] = {arity = 8, itemArg = 2},
	--["ItemScatterAt"] = {arity = 4, itemArg = 1}
}

local function RunItemEvent(event, item, ...)
	local unique = UniqueManager.GetDataByItem(item)
	if unique then
		unique:InvokeEventListeners(event, ...)
	end
end

---Registers an Osiris listener for an pre-configured event.
---The purpose of this is so we don't have to listen to all of these events normally until a script needs to wait for a unique to be involved in some event.
---@param event string
function UniqueManager.EnableEvent(event)
	local data = itemEvents[event]
	if data and not data.enabled then
		Ext.RegisterOsirisListener(event, data.arity, "after", function(...)
			local args = {...}
			for i=1,#args do
				if type(args[i]) == "string" then
					args[i] = StringHelpers.GetUUID(args[i])
				end
			end
			local item = args[data.itemArg]
			RunItemEvent(event, item, table.unpack(args))
		end)
		data.enabled = true
	end
end

function UniqueManager.EnableAllEvents()
	for event,data in pairs(itemEvents) do
		UniqueManager.EnableEvent(event)
	end
end

if not isClient then
	Ext.RegisterConsoleCommand("llweaponex_teleportunique", function(command, id)
		local unique = Uniques[id]
		if unique ~= nil then
			local host = CharacterGetHostCharacter()
			unique:Transfer(host)
		else
			Ext.PrintError("[llweaponex_teleportunique]",id,"is not a valid unique item ID!")
		end
	end)

	function SwapUnique(char, id)
		local uuid = nil
		local uniqueData = Uniques[id]
		if uniqueData ~= nil then
			uuid = uniqueData:GetUUID(char)
		end
		if uuid == nil then
			return false
		end
		local equipped = nil
		local next = nil
		local link = LinkedUniques[uuid]
		if link ~= nil then
			if GameHelpers.Item.ItemIsEquipped(char, uuid) then
				next = link
				equipped = uuid
			else
				next = uuid
				equipped = link
			end
		end
		if equipped ~= nil and next ~= nil and ObjectExists(equipped) == 1 and ObjectExists(next) == 1 then
			local stat = NRD_ItemGetStatsId(next)
			local statType = NRD_StatGetType(stat)
			local isTwoHanded = false
			local locked = Ext.GetItem(equipped).UnEquipLocked
			if statType == "Weapon" then
				isTwoHanded = Ext.StatGetAttribute(stat, "IsTwoHanded") == "Yes"
			end
			local slot = GameHelpers.Item.GetEquippedSlot(char,equipped) or GameHelpers.Item.GetEquippedSlot(char,next) or "Weapon"
	
			ItemLockUnEquip(equipped, 0)
			ItemLockUnEquip(next, 0)
			--CharacterUnequipItem(char, equipped)
	
			if not isTwoHanded then
				local currentEquipped = StringHelpers.GetUUID(CharacterGetEquippedItem(char, slot))
				if not StringHelpers.IsNullOrEmpty(currentEquipped) and currentEquipped ~= equipped then
					ItemLockUnEquip(currentEquipped, 0)
					CharacterUnequipItem(char, currentEquipped)
				end
				NRD_CharacterEquipItem(char, next, slot, 0, 0, 1, 1)
			else
				local mainhand = StringHelpers.GetUUID(CharacterGetEquippedItem(char, "Weapon"))
				local offhand = StringHelpers.GetUUID(CharacterGetEquippedItem(char, "Shield"))
				if not StringHelpers.IsNullOrEmpty(mainhand) and mainhand ~= equipped then
					ItemLockUnEquip(mainhand, 0)
					CharacterUnequipItem(char, mainhand)
				end
				if not StringHelpers.IsNullOrEmpty(offhand) and offhand ~= equipped then
					ItemLockUnEquip(offhand, 0)
					CharacterUnequipItem(char, offhand)
				end
				NRD_CharacterEquipItem(char, next, "Weapon", 0, 0, 1, 1)
			end
	
			if locked then
				ItemLockUnEquip(next, 1)
			end
	
			--S_LLWEAPONEX_Chest_ItemHolder_A_80976258-a7a5-4430-b102-ba91a604c23f
			Osi.LeaderLib_Timers_StartObjectObjectTimer(equipped, "80976258-a7a5-4430-b102-ba91a604c23f", 50, "Timers_LLWEAPONEX_MoveUniqueToUniqueHolder", "LeaderLib_Commands_ItemToInventory")
		end
	end

	function UniqueManager.InitializeUniques()
		local region = SharedData.RegionData.Current
		InitOriginsUniques(region)
		UniqueManager.LoadLinkedUniques()
		UniqueManager.FindOrphanedUniques()
		for id,unique in pairs(Uniques) do
			unique:FindPlayerCopies()
			unique:Initialize(region, UniqueManager.FirstLoad)
		end
		-- in case equipment events have changed and need to fire again
		for player in GameHelpers.Character.GetPlayers(false) do
			for _,slotid in LeaderLib.Data.VisibleEquipmentSlots:Get() do
				local itemid = CharacterGetEquippedItem(player.MyGuid, slotid)
				if not StringHelpers.IsNullOrEmpty(itemid) then
					EquipmentManager:OnItemEquipped(player, Ext.GetItem(itemid))
				end
			end
		end
		UniqueManager.FirstLoad = false

		for id,v in pairs(Uniques) do
			if not StringHelpers.IsNullOrEmpty(v.DefaultUUID) then
				AllUniques[v.DefaultUUID] = v
			end
		end
	end
	
	Timer.RegisterListener("Timers_LLWEAPONEX_InitUniques", UniqueManager.InitializeUniques)
end

---@param originalItem EsvItem|string
---@param newItem EsvItem|string
function UniqueManager.UpdateUniqueUUID(originalItem, newItem, replaceMainUUID)
	local uniqueData = UniqueManager.GetDataByItem(originalItem)
	local uuid = GameHelpers.GetUUID(newItem)
	if uniqueData and uuid then
		uniqueData:AddCopy(uuid)
		AllUniques[uuid] = uniqueData
		if replaceMainUUID then
			uniqueData.UUID = uuid
		end
	end
end

local UniqueScripts = {
	"AnatomyBook",
	"AnvilMace",
	"BalrinThrowingAxe",
	"BasilusDagger",
	"DeathEdge",
	"GnakSpellScroll",
	"MagicMissileWand",
	"Muramasa",
	"Omnibolt",
	"PacifistsWrath",
	"PirateGloves",
	"PowerGauntlets",
	"RunicCannon",
	"SoulHarvest",
	"Victory",
}

for _,v in pairs(UniqueScripts) do
	Ext.Require(string.format("Shared/Uniques/Logic/%s.lua", v))
end