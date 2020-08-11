--S_LLWEAPONEX_VendingMachine_A_680d2702-721c-412d-b083-4f5e816b945a
local VENDING_MACHINE = "680d2702-721c-412d-b083-4f5e816b945a"

---@type UniqueData
local UniqueData = Ext.Require("Server/Data/UniqueData.lua")

local function OnTattoosEquipped(data, character)
	ItemLockUnEquip(data.UUID, 1)
end

---@type table<string, UniqueData>
Uniques = {
	ArmCannon = UniqueData:Create("a1ce4c1c-a535-4184-a1df-268eb4035fe8"),
	Muramasa = UniqueData:Create("52c0b4a4-3906-4229-93a9-b83aea9e657c"),
	Frostdyne = UniqueData:Create("S5d8ec362-618e-48e9-87c2-dbc18ea4e779"),
	MagicMissileWand = UniqueData:Create("f8958c1e-1c9d-4fa9-b03f-b883c65f95c3"),
	--MagicMissileRod = UniqueData:Create("292b4b04-4ba1-4fa3-96df-19eab320c50f"),
	ChaosEdge = UniqueData:Create("61bbcd14-82a2-4efc-9a66-ac4b8a1310cf"),
	DeathEdge = UniqueData:Create("ea775987-18a6-4947-bb7c-3eea55a6f875"),
	Harvest = UniqueData:Create("d1cb1583-ffb1-43f3-b9af-e1673e7ea4e1"),
	DivineBanner = UniqueData:Create("113b901-340a-4f24-a38b-473e61d23371"),
	LoneWolfBanner = UniqueData:Create("aa63e570-695a-461b-bb35-60cf7c915570"),
	BeholderSword = UniqueData:Create("ddf11ed0-126f-4bec-8360-455ddf9cef12"),
	Wraithblade = UniqueData:Create("c68b5afa-2574-471d-85ac-0738ee0a6393"),
	AnvilMace = UniqueData:Create("f3c71d85-1cc3-431f-b236-ad838bf2e418"),
	WarchiefHalberd = UniqueData:Create("6c52f44e-1c27-4409-9bfe-f89ee5af4a0d"),
	--WarchiefAxe = UniqueData:Create("056c2c38-b7be-4e06-be41-99b79ffe83c2"),
	Bible = UniqueData:Create("bcc43f30-b009-4b42-a4de-1c85a25b522a"),
	OgreScroll = UniqueData:Create("cc4d26df-c8c4-458e-b88f-610387741533"),
	Bokken = UniqueData:Create("6d75d449-e021-4b4d-ad2d-c0873127c3b3"),
	--BokkenOneHanded = UniqueData:Create("a5e7e46f-b83a-47a7-8bd6-f16f16fe5f42"),
	Blunderbuss = UniqueData:Create("cd6c2b7d-ee74-401b-9866-409c45ae9413"),
	Omnibolt = UniqueData:Create("dec81eed-fcab-48cc-bd67-0431abe4260c"),
	BalrinAxe = UniqueData:Create("e4dc654c-db51-4b55-a342-83a864cfeff9"),
	FireRunebladeKatana = UniqueData:Create("6f735ef9-524c-4514-b37f-c48a20b313c5"),
	PowerPole = UniqueData:Create("da0ac3e5-8a9e-417c-b516-dc8cd9245d0e"),
	DemoBackpack = UniqueData:Create("253e14da-cdb9-4cda-b9d4-352d8ed784c5"),
	MonkBlindfold = UniqueData:Create("4258f164-b548-471f-990d-ae641960a842"),
	DemonGauntlet = UniqueData:Create("0ac0d813-f58c-4399-99a8-1626a419bc53"),
	AssassinHandCrossbow = UniqueData:Create("70c59769-2838-4137-9421-4e251fecdc89"),
	DaggerBasilus = UniqueData:Create("5b5c20e1-cef4-40a2-b367-a984c38c1f03"),
	--S_EQ_UNIQUE_LLWEAPONEX_PowerGauntlets_Arms_A_Harken_1d71ffda-51a4-4404-ae08-e4d2d4f13b9f
	HarkenPowerGloves = UniqueData:Create("1d71ffda-51a4-4404-ae08-e4d2d4f13b9f"),
	HarkenTattoos = UniqueData:Create("40039552-3aae-4beb-8cca-981809f82988", nil, "e446752a-13cc-4a88-a32e-5df244c90d8b", true, {OnEquipped=OnTattoosEquipped}),
}

Ext.RegisterConsoleCommand("llweaponex_teleportunique", function(command, id)
	local unique = Uniques[id]
	if unique ~= nil then
		local host = CharacterGetHostCharacter()
		TeleportTo(unique, host, "", 0, 1, 0)
		ItemToInventory(unique, host, 1, 1, 1)
	else
		print("[llweaponex_teleportunique]",id,"is not a valid unique item ID!")
	end
end)

AllUniques = {
	"S_EQ_UNIQUE_LLWEAPONEX_ArmCannon_A_a1ce4c1c-a535-4184-a1df-268eb4035fe8",
	"S_WPN_UNIQUE_LLWEAPONEX_Dagger_Basilus_A_5b5c20e1-cef4-40a2-b367-a984c38c1f03",
	"S_WPN_UNIQUE_LLWEAPONEX_Katana_Dagger_Sword_2H_Muramasa_52c0b4a4-3906-4229-93a9-b83aea9e657c",
	"S_WPN_UNIQUE_LLWEAPONEX_Rapier_Dagger_Runeblade_Water_1H_5d8ec362-618e-48e9-87c2-dbc18ea4e779",
	--"S_WPN_UNIQUE_LLWEAPONEX_Rod_1H_MagicMissile_A_292b4b04-4ba1-4fa3-96df-19eab320c50f",
	"S_WPN_UNIQUE_LLWEAPONEX_Wand_1H_MagicMissile_A_f8958c1e-1c9d-4fa9-b03f-b883c65f95c3",
	"S_WPN_UNIQUE_LLWEAPONEX_Runeblade_Chaos_Sword_2H_61bbcd14-82a2-4efc-9a66-ac4b8a1310cf",
	"S_WPN_UNIQUE_LLWEAPONEX_Scythe_2H_DeathEdge_A_ea775987-18a6-4947-bb7c-3eea55a6f875",
	"S_WPN_UNIQUE_LLWEAPONEX_Scythe_2H_SoulHarvest_A_d1cb1583-ffb1-43f3-b9af-e1673e7ea4e1",
	"S_WPN_UNIQUE_LLWEAPONEX_Staff_Banner_DivineOrder_A_3113b901-340a-4f24-a38b-473e61d23371",
	"S_WPN_UNIQUE_LLWEAPONEX_Staff_Banner_Dwarves_A_aa63e570-695a-461b-bb35-60cf7c915570",
	"S_WPN_UNIQUE_LLWEAPONEX_Sword_2H_Beholder_A_ddf11ed0-126f-4bec-8360-455ddf9cef12",
	"S_WPN_UNIQUE_LLWEAPONEX_Wraithblade_Sword_2H_A_c68b5afa-2574-471d-85ac-0738ee0a6393",
	"S_WPN_UNIQUE_LLWEAPONEX_Anvil_Mace_2H_A_f3c71d85-1cc3-431f-b236-ad838bf2e418",
	"S_WPN_UNIQUE_LLWEAPONEX_Spear_Halberd_2H_Warchief_A_6c52f44e-1c27-4409-9bfe-f89ee5af4a0d",
	--"S_WPN_UNIQUE_LLWEAPONEX_Axe_Halberd_2H_Warchief_A_001_056c2c38-b7be-4e06-be41-99b79ffe83c2",
	"S_WPN_UNIQUE_LLWEAPONEX_BattleBook_2H_Bible_B_bcc43f30-b009-4b42-a4de-1c85a25b522a",
	"S_WPN_UNIQUE_LLWEAPONEX_BattleBook_2H_SpellScroll_A_cc4d26df-c8c4-458e-b88f-610387741533",
	--"S_WPN_UNIQUE_LLWEAPONEX_Bokken_Sword_1H_A_a5e7e46f-b83a-47a7-8bd6-f16f16fe5f42",
	"S_WPN_UNIQUE_LLWEAPONEX_Bokken_Sword_2H_A_6d75d449-e021-4b4d-ad2d-c0873127c3b3",
	"S_WPN_UNIQUE_LLWEAPONEX_Firearm_Blunderbuss_2H_A_cd6c2b7d-ee74-401b-9866-409c45ae9413",
	"S_WPN_UNIQUE_LLWEAPONEX_Greatbow_Lightning_Bow_2H_A_dec81eed-fcab-48cc-bd67-0431abe4260c",
	"S_WPN_UNIQUE_LLWEAPONEX_Humans_Axe_1H_A_e4dc654c-db51-4b55-a342-83a864cfeff9",
	"S_WPN_UNIQUE_LLWEAPONEX_Katana_Dagger_Runeblade_Fire_1H_A_6f735ef9-524c-4514-b37f-c48a20b313c5",
	"S_WPN_UNIQUE_LLWEAPONEX_Quarterstaff_Spear_2H_PowerPole_da0ac3e5-8a9e-417c-b516-dc8cd9245d0e",
	"S_EQ_UNIQUE_LLWEAPONEX_Backpack_Demolition_A_253e14da-cdb9-4cda-b9d4-352d8ed784c5",
	"S_EQ_UNIQUE_LLWEAPONEX_Blindfold_Monk_A_4258f164-b548-471f-990d-ae641960a842",
	"S_EQ_UNIQUE_LLWEAPONEX_DemonGauntlet_Arms_A_0ac0d813-f58c-4399-99a8-1626a419bc53",
	"S_EQ_UNIQUE_LLWEAPONEX_HandCrossbow_A_Ring_70c59769-2838-4137-9421-4e251fecdc89",
	--"S_EQ_UNIQUE_LLWEAPONEX_Upperbody_Tattoos_Magic_A_Harken_927669c3-b885-4b88-a0c2-6825fbf11af2",
	--"S_EQ_UNIQUE_LLWEAPONEX_Upperbody_Tattoos_Normal_A_Harken_40039552-3aae-4beb-8cca-981809f82988",
}

function MoveUniquesToVendingMachine()
	for i,item in pairs(AllUniques) do
		local owner = GetInventoryOwner(item)
		if not GameHelpers.Item.ItemIsEquippedByCharacter(item) and (owner == nil or (ObjectIsCharacter(owner) ~= 1 and owner ~= VENDING_MACHINE)) then
			ItemToInventory(item, VENDING_MACHINE, 1, 0, 0)
		end
	end
end

local LinkedUniques = {
	["MagicMissileWand"] = {
		--S_WPN_UNIQUE_LLWEAPONEX_Wand_1H_MagicMissile_A_f8958c1e-1c9d-4fa9-b03f-b883c65f95c3
		--S_WPN_UNIQUE_LLWEAPONEX_Rod_1H_MagicMissile_A_292b4b04-4ba1-4fa3-96df-19eab320c50f
		{"f8958c1e-1c9d-4fa9-b03f-b883c65f95c3", "292b4b04-4ba1-4fa3-96df-19eab320c50f"}
	},
	["Bokken"] = {
		--S_WPN_UNIQUE_LLWEAPONEX_Bokken_Sword_2H_A_6d75d449-e021-4b4d-ad2d-c0873127c3b3
		--S_WPN_UNIQUE_LLWEAPONEX_Bokken_Sword_1H_A_a5e7e46f-b83a-47a7-8bd6-f16f16fe5f42
		{"6d75d449-e021-4b4d-ad2d-c0873127c3b3", "a5e7e46f-b83a-47a7-8bd6-f16f16fe5f42"}
	},
	["Warchief"] = {
		--S_WPN_UNIQUE_LLWEAPONEX_Spear_Halberd_2H_Warchief_A_6c52f44e-1c27-4409-9bfe-f89ee5af4a0d
		--S_WPN_UNIQUE_LLWEAPONEX_Axe_Halberd_2H_Warchief_A_056c2c38-b7be-4e06-be41-99b79ffe83c2
		{"6c52f44e-1c27-4409-9bfe-f89ee5af4a0d", "056c2c38-b7be-4e06-be41-99b79ffe83c2"}
	},
	["HarkenTattoos"] = {
		--S_EQ_UNIQUE_LLWEAPONEX_Upperbody_Tattoos_Normal_A_Harken_40039552-3aae-4beb-8cca-981809f82988
		--S_EQ_UNIQUE_LLWEAPONEX_Upperbody_Tattoos_Magic_A_Harken_927669c3-b885-4b88-a0c2-6825fbf11af2
		{"40039552-3aae-4beb-8cca-981809f82988", "927669c3-b885-4b88-a0c2-6825fbf11af2"}
	}
}

local function AddLinkedUnique(id, item1, item2)
	if item1 ~= nil and item2 ~= nil then
		local tbl = LinkedUniques[id]
		if tbl ~= nil then
			local canAdd = true
			local uuid1 = GetUUID(item1)
			local uuid2 = GetUUID(item2)
			for i,v in pairs(tbl) do
				local a,b = table.unpack(v)
				if GetUUID(a) == uuid1 and GetUUID(b) == uuid2 then
					canAdd = false
					break
				end
			end
			if canAdd then
				table.insert(tbl, {item1,item2})
			end
		else
			LinkedUniques[id] = {
				{item1,item2}
			}
		end
		PersistentVars.LinkedUniques = LinkedUniques
	end
end

LoadPersistentVars[#LoadPersistentVars+1] = function()
	if PersistentVars.LinkedUniques ~= nil then
		for id,entry in pairs(PersistentVars.LinkedUniques) do
			if #entry >= 2 then
				for i,v in pairs(entry) do
					local item1,item2 = table.unpack(v)
					AddLinkedUnique(id, item1, item2)
				end
			end
		end
	else
		PersistentVars.LinkedUniques = LinkedUniques
	end
end

function SwapUnique(char, id)
	local equipped = nil
	local next = nil
	local tbl = LinkedUniques[id]
	if tbl ~= nil then
		for i,v in pairs(tbl) do
			local item1,item2 = table.unpack(v)
			if GameHelpers.Item.ItemIsEquipped(char, item1) then
				equipped = item1
				next = item2
				break
			elseif GameHelpers.Item.ItemIsEquipped(char, item2) then
				equipped = item2
				next = item1
				break
			end
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
		local slot = GameHelpers.Item.GetEquippedSlot(char,equipped)

		ItemLockUnEquip(equipped, 0)
		ItemLockUnEquip(next, 0)
		--CharacterUnequipItem(char, equipped)

		if not isTwoHanded then
			NRD_CharacterEquipItem(char, next, slot, 0, 1, 1, 1)
		else
			NRD_CharacterEquipItem(char, next, "Weapon", 0, 0, 1, 1)
		end

		if locked then
			ItemLockUnEquip(next, 1)
		end

		local uniqueData = Uniques[id]
		if uniqueData ~= nil and uniqueData.OnEquipped ~= nil then
			pcall(uniqueData.OnEquipped, uniqueData, char)
		end

		--S_LLWEAPONEX_Chest_ItemHolder_A_80976258-a7a5-4430-b102-ba91a604c23f
		Osi.LeaderLib_Timers_StartObjectObjectTimer(equipped, "80976258-a7a5-4430-b102-ba91a604c23f", 50, "Timers_LLWEAPONEX_MoveUniqueToUniqueHolder", "LeaderLib_Commands_ItemToInventory")
	end
end