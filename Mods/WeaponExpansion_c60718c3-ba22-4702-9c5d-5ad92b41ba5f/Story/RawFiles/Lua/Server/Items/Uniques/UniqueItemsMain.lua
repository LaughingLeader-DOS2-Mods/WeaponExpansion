--S_LLWEAPONEX_VendingMachine_A_680d2702-721c-412d-b083-4f5e816b945a
local VENDING_MACHINE = "680d2702-721c-412d-b083-4f5e816b945a"

---@type UniqueData
local UniqueData = Ext.Require("Server/Data/UniqueData.lua")

if UniqueManager == nil then
	UniqueManager = {}
end

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

---@type AllUniqueProgressionData
local ProgressionData = Ext.Require("Server/Items/Uniques/UniqueItemsProgression.lua")

---@type table<string, UniqueData>
Uniques = {
	AnvilMace = UniqueData:Create("f3c71d85-1cc3-431f-b236-ad838bf2e418", ProgressionData.AnvilMace, {Tag="LLWEAPONEX_UniqueAnvilMace", DefaultOwner=Origin.Harken, AutoEquipOnOwner=true}),
	ArmCannon = UniqueData:Create("a1ce4c1c-a535-4184-a1df-268eb4035fe8", ProgressionData.ArmCannon, {Tag="LLWEAPONEX_RunicCannonGloves"}),
	AssassinHandCrossbow = UniqueData:Create("70c59769-2838-4137-9421-4e251fecdc89", ProgressionData.AssassinHandCrossbow, {Tag="LLWEAPONEX_UniqueHandCrossbow"}),
	BalrinAxe = UniqueData:Create("e4dc654c-db51-4b55-a342-83a864cfeff9", ProgressionData.BalrinAxe, {Tag="LLWEAPONEX_UniqueThrowingAxeA"}),
	BeholderSword = UniqueData:Create("ddf11ed0-126f-4bec-8360-455ddf9cef12", ProgressionData.BeholderSword, {Tag="LLWEAPONEX_UniqueBeholderGreatsword"}),
	Bible = UniqueData:Create("bcc43f30-b009-4b42-a4de-1c85a25b522a", ProgressionData.Bible, {Tag="LLWEAPONEX_UniqueBible"}),
	Blunderbuss = UniqueData:Create("cd6c2b7d-ee74-401b-9866-409c45ae9413", ProgressionData.Blunderbuss, {Tag="LLWEAPONEX_UniqueBlunderbuss"}),
	Bokken = UniqueData:Create("6d75d449-e021-4b4d-ad2d-c0873127c3b3", ProgressionData.Bokken, {Tag="LLWEAPONEX_UniqueBokken2H"}),
	ChaosEdge = UniqueData:Create("61bbcd14-82a2-4efc-9a66-ac4b8a1310cf", ProgressionData.ChaosEdge, {Tag="LLWEAPONEX_UniqueRunebladeChaosGreatsword"}),
	BasilusDagger = UniqueData:Create("5b5c20e1-cef4-40a2-b367-a984c38c1f03", ProgressionData.BasilusDagger, {Tag="LLWEAPONEX_UniqueBasilusDagger"}),
	DeathEdge = UniqueData:Create("ea775987-18a6-4947-bb7c-3eea55a6f875", ProgressionData.DeathEdge, {Tag="LLWEAPONEX_UniqueDeathEdge"}),
	DemoBackpack = UniqueData:Create("253e14da-cdb9-4cda-b9d4-352d8ed784c5", ProgressionData.DemoBackpack, {Tag="LLWEAPONEX_DemolitionBackpack"}),
	DemonGauntlet = UniqueData:Create("0ac0d813-f58c-4399-99a8-1626a419bc53", ProgressionData.DemonGauntlet, {Tag="LLWEAPONEX_DemonGauntlet"}),
	DivineBanner = UniqueData:Create("3113b901-340a-4f24-a38b-473e61d23371", ProgressionData.DivineBanner, {DefaultOwner=NPC.BishopAlexander, AutoEquipOnOwner=true, Tag="LLWEAPONEX_UniqueDivineBanner"}),
	FireRunebladeKatana = UniqueData:Create("6f735ef9-524c-4514-b37f-c48a20b313c5", ProgressionData.FireRunebladeKatana, {Tag="LLWEAPONEX_UniqueRunebladeFireKatana"}),
	Frostdyne = UniqueData:Create("S5d8ec362-618e-48e9-87c2-dbc18ea4e779", ProgressionData.Frostdyne, {DefaultOwner=NPC.Slane, AutoEquipOnOwner=false, Tag="LLWEAPONEX_UniqueRunebladeRapier"}),
	HarkenPowerGloves = UniqueData:Create("1d71ffda-51a4-4404-ae08-e4d2d4f13b9f", ProgressionData.HarkenPowerGloves, {DefaultOwner=Origin.Harken, AutoEquipOnOwner=true, OnEquipped=CheckForAnvilWeightChange, Tag="LLWEAPONEX_UniquePowerGauntlets"}),
	--HarkenTattoos = UniqueData:Create("40039552-3aae-4beb-8cca-981809f82988", ProgressionData.HarkenTattoos, {DefaultOwner = Origin.Harken, AutoEquipOnOwner=true, OnEquipped=OnTattoosEquipped}),
	Harvest = UniqueData:Create("d1cb1583-ffb1-43f3-b9af-e1673e7ea4e1", ProgressionData.Harvest, {Tag="LLWEAPONEX_UniqueHarvestScythe"}),
	LoneWolfBanner = UniqueData:Create("aa63e570-695a-461b-bb35-60cf7c915570", ProgressionData.LoneWolfBanner, {Tag="LLWEAPONEX_UniqueLoneWolfBanner"}),
	MagicMissileWand = UniqueData:Create("f8958c1e-1c9d-4fa9-b03f-b883c65f95c3", ProgressionData.MagicMissileWand, {Tag="LLWEAPONEX_UniqueMagicMissileWand"}),
	MonkBlindfold = UniqueData:Create("4258f164-b548-471f-990d-ae641960a842", ProgressionData.MonkBlindfold, {Tag="LLWEAPONEX_UniqueBlindfold"}),
	Muramasa = UniqueData:Create("52c0b4a4-3906-4229-93a9-b83aea9e657c", ProgressionData.Muramasa, {Tag="LLWEAPONEX_UniqueMuramasaKatana"}),
	OgreScroll = UniqueData:Create("cc4d26df-c8c4-458e-b88f-610387741533", ProgressionData.OgreScroll, {Tag="LLWEAPONEX_UniqueOgreScroll"}),
	Omnibolt = UniqueData:Create("dec81eed-fcab-48cc-bd67-0431abe4260c", ProgressionData.Omnibolt, {Tag="LLWEAPONEX_UniqueOmniboltGreatbow"}),
	PowerPole = UniqueData:Create("da0ac3e5-8a9e-417c-b516-dc8cd9245d0e", ProgressionData.PowerPole, {Tag="LLWEAPONEX_UniquePowerPole"}),
	WarchiefHalberd = UniqueData:Create("6c52f44e-1c27-4409-9bfe-f89ee5af4a0d", ProgressionData.WarchiefHalberd, {Tag="LLWEAPONEX_UniqueWarchiefHalberdSpear"}),
	Wraithblade = UniqueData:Create("c68b5afa-2574-471d-85ac-0738ee0a6393", ProgressionData.Wraithblade, {Tag="LLWEAPONEX_UniqueWraithblade"}),
}

--Uniques.ArmCannonWeapon = UniqueData:Create("a1ce4c1c-a535-4184-a1df-268eb4035fe8", ProgressionData.ArmCannonWeapon, {Tag="LLWEAPONEX_RunicCannonWeapon", LinkedItem=Uniques.ArmCannon, CanMoveToVendingMachine=false})
--Uniques.ArmCannonWeapon.CanMoveToVendingMachine = false
Uniques.MagicMissileRod = UniqueData:Create("292b4b04-4ba1-4fa3-96df-19eab320c50f", ProgressionData.MagicMissileRod, {Tag="LLWEAPONEX_UniqueMagicMissileRod", LinkedItem=Uniques.MagicMissileWand, CanMoveToVendingMachine=false})

Uniques.BokkenOneHanded = UniqueData:Create("a5e7e46f-b83a-47a7-8bd6-f16f16fe5f42", ProgressionData.BokkenOneHanded, {Tag="LLWEAPONEX_UniqueBokken1H", LinkedItem=Uniques.Bokken, CanMoveToVendingMachine=false})
Uniques.Bokken.LinkedItem = Uniques.BokkenOneHanded

Uniques.WarchiefAxe = UniqueData:Create("056c2c38-b7be-4e06-be41-99b79ffe83c2", ProgressionData.WarchiefAxe, {Tag="LLWEAPONEX_UniqueWarchiefHalberdAxe", LinkedItem=Uniques.WarchiefHalberd, CanMoveToVendingMachine=false})
Uniques.WarchiefHalberd.LinkedItem = Uniques.WarchiefAxe

function UniqueManager.GetDataByTag(tag)
	for k,v in pairs(Uniques) do
		if v.Tag == tag then
			return v
		end
	end
	return nil
end

---@param item EsvItem
function UniqueManager.GetDataByItem(item)
	for i,tag in pairs(item:GetTags()) do
		local data = UniqueManager.GetDataByTag(tag)
		if data ~= nil then
			return data
		end
	end
	return nil
end

---For getting unique data by UUID.
---@type table<string,UniqueData>
AllUniques = {}

for id,v in pairs(Uniques) do
	if not StringHelpers.IsNullOrEmpty(v.UUID) then
		AllUniques[v.UUID] = v
	end
end

Ext.RegisterConsoleCommand("llweaponex_teleportunique", function(command, id)
	local unique = Uniques[id]
	if unique ~= nil then
		local host = CharacterGetHostCharacter()
		unique:Transfer(host)
	else
		Ext.PrintError("[llweaponex_teleportunique]",id,"is not a valid unique item ID!")
	end
end)

local LinkedUniques = {}

---@param item1 string
---@param item2 string
---@param skipSave boolean|nil
function UniqueManager.LinkItems(item1, item2, skipSave)
	LinkedUniques[item1] = item2
	LinkedUniques[item2] = item1
	if skipSave ~= true then
		PersistentVars.LinkedUniques = LinkedUniques
	end
end

UniqueManager.LinkItems(Uniques.MagicMissileWand.UUID, Uniques.MagicMissileRod.UUID, true)
UniqueManager.LinkItems(Uniques.WarchiefAxe.UUID, Uniques.WarchiefHalberd.UUID, true)
UniqueManager.LinkItems(Uniques.Bokken.UUID, Uniques.BokkenOneHanded.UUID, true)

function UniqueManager.LoadLinkedUniques()
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
			NRD_CharacterEquipItem(char, next, slot, 0, 0, 1, 1)
		else
			NRD_CharacterEquipItem(char, next, "Weapon", 0, 0, 1, 1)
		end

		if locked then
			ItemLockUnEquip(next, 1)
		end

		--S_LLWEAPONEX_Chest_ItemHolder_A_80976258-a7a5-4430-b102-ba91a604c23f
		Osi.LeaderLib_Timers_StartObjectObjectTimer(equipped, "80976258-a7a5-4430-b102-ba91a604c23f", 50, "Timers_LLWEAPONEX_MoveUniqueToUniqueHolder", "LeaderLib_Commands_ItemToInventory")
	end
end

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
	return (item:HasTag("LeaderLib_AutoLevel") or item:HasTag("LLWEAPONEX_AutoLevel")) and Settings.Global:FlagEquals("LLWEAPONEX_UniqueAutoLevelingDisabled", false)
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
	for uuid,tag in pairs(PersistentVars.ExtraUniques) do
        if ObjectExists(uuid) == 0 then
            PersistentVars.ExtraUniques[uuid] = nil
        else
            local data = UniqueManager.GetDataByTag(tag)
			if data ~= nil then
				if data.UUID ~= uuid then
					local owner = data:GetOwner(uuid)
					data.Copies[uuid] = owner
				else
					PersistentVars.ExtraUniques[uuid] = nil
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