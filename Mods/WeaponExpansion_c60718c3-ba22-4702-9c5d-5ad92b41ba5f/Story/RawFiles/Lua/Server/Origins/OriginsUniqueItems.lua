local ORIGINS_UNIQUES = {
	AnatomyBook = {UUID = "d4955fc9-41c8-4458-89c4-7ff199cdb6d2"},
	AnvilMace = {UUID = "f3c71d85-1cc3-431f-b236-ad838bf2e418", Target=Origin.Harken, Equip=true},
	ArmCannon = {UUID = "a1ce4c1c-a535-4184-a1df-268eb4035fe8"},
	AssassinHandCrossbow = {UUID = "70c59769-2838-4137-9421-4e251fecdc89"},
	BalrinAxe = {UUID = "e4dc654c-db51-4b55-a342-83a864cfeff9", Target = {
		FJ_FortJoy_Main = {
			IsDefault = true,
			Position = {262.64, -1.2, 205.60},
			Rotation = {math.rad(-20), math.rad(90), math.rad(-90)}
		}
	}},
	BasilusDagger = {UUID = "5b5c20e1-cef4-40a2-b367-a984c38c1f03", Target={
		--Next to the player's God
		FJ_FortJoy_Main = {
			IsDefault = true,
			Position = {
				53.51690673828125,
				15.027082443237305,
				686.8984375
			},
			Rotation = {
				3.2785706520080566,
				-9.613316535949707,
				-2.7614781856536865
			}
		}
	}},
	BeholderSword = {UUID = "ddf11ed0-126f-4bec-8360-455ddf9cef12", Target={
		FJ_FortJoy_Main = {
			IsDefault = true,
			Position = {474.75, -1.6000000238418579, 519.75},
			Rotation = {math.rad(-90), math.rad(-45), 0}
		},
		RC_Main = {
			--Mor the Trenchmouthed
			UUID = "01c5d4d3-425f-42fd-8200-528b14aafec8"
		}
	}},
	Bible = {UUID = "bcc43f30-b009-4b42-a4de-1c85a25b522a", Target={
		FJ_FortJoy_Main = {
			IsDefault = true,
			--Brother Bire, dwarf on tower
			UUID = "a449c179-1c96-4180-91d6-cb5d6c4cb9a7",
		}
	}},
	Blunderbuss = {UUID = "cd6c2b7d-ee74-401b-9866-409c45ae9413", Target={
		FJ_FortJoy_Main = {
			IsDefault = true,
			Position = {
					213.24302673339844,
					-13.507736206054688,
					591.645751953125
			},
			Rotation = {
					-3.8110156059265137,
					5.9931626319885254,
					21.183271408081055
			}
		}
	}},
	PacifistsWrath = {UUID = "6d75d449-e021-4b4d-ad2d-c0873127c3b3"},
	PacifistsWrath1H = {UUID = "a5e7e46f-b83a-47a7-8bd6-f16f16fe5f42", IsLinkItem=true},
	ChaosEdge = {UUID = "61bbcd14-82a2-4efc-9a66-ac4b8a1310cf"},
	DeathEdge = {UUID = "ea775987-18a6-4947-bb7c-3eea55a6f875"},
	DemoBackpack = {UUID = "253e14da-cdb9-4cda-b9d4-352d8ed784c5"},
	DemonGauntlet = {UUID = "0ac0d813-f58c-4399-99a8-1626a419bc53"},
	DivineBanner = {UUID = "3113b901-340a-4f24-a38b-473e61d23371", Target=NPC.BishopAlexander, Equip=true},
	FireRunebladeKatana = {UUID = "6f735ef9-524c-4514-b37f-c48a20b313c5", Target = {
		FJ_FortJoy_Main = {
			IsDefault = true,
			--Royal Fire Slug
			UUID = "bcf48455-9fc7-41cc-99d6-e55a75802ce8"
		}
	}},
	Frostdyne = {UUID = "S5d8ec362-618e-48e9-87c2-dbc18ea4e779", Target=NPC.Slane},
	HarkenPowerGloves = {UUID = "1d71ffda-51a4-4404-ae08-e4d2d4f13b9f", Target=Origin.Harken, Equip=true},
	Harvest = {UUID = "d1cb1583-ffb1-43f3-b9af-e1673e7ea4e1"},
	LoneWolfBanner = {UUID = "aa63e570-695a-461b-bb35-60cf7c915570", Target = {
		RC_Main = {
			IsDefault = true,
			--Lone Wolf camp, on of the towers
			Position = {505.75, 25.93, 413.25},
			Rotation = {math.rad(90), 0, 0}
		}
	}},
	MagicMissileRod = {UUID = "292b4b04-4ba1-4fa3-96df-19eab320c50f", IsLinkItem=true},
	MagicMissileWand = {UUID = "f8958c1e-1c9d-4fa9-b03f-b883c65f95c3"},
	MonkBlindfold = {UUID = "4258f164-b548-471f-990d-ae641960a842", Target = {
		FJ_FortJoy_Main = {
			IsDefault = true,
			--Verdas, decomposing elf in dungeon
			UUID = "8d839534-a039-4b5c-bfa6-6b88da149eb2",
			Equip = false,
		}
	}},
	Muramasa = {UUID = "52c0b4a4-3906-4229-93a9-b83aea9e657c"},
	OgreScroll = {UUID = "cc4d26df-c8c4-458e-b88f-610387741533", Target = {
		RC_Main = {
			IsDefault = true,
			--Grog the Troll
			UUID = "9671dad5-258d-4174-84c0-0141502b2938",
			Equip = true,
		}
	}},
	Omnibolt = {UUID = "dec81eed-fcab-48cc-bd67-0431abe4260c"},
	PowerPole = {UUID = "da0ac3e5-8a9e-417c-b516-dc8cd9245d0e"},
	WarchiefAxe = {UUID = "056c2c38-b7be-4e06-be41-99b79ffe83c2"},
	WarchiefHalberd = {UUID = "6c52f44e-1c27-4409-9bfe-f89ee5af4a0d", IsLinkItem=true},
	Wraithblade = {UUID = "c68b5afa-2574-471d-85ac-0738ee0a6393"},
	Victory = {UUID = "b4f84f81-c889-4aeb-b443-cbe2199387fe", Target = {
		FJ_FortJoy_Main = {
			IsDefault = true,
			--Paladin Cork
			UUID = "c01e16ca-ce9a-48c8-ac36-90ef7de12404",
			Equip = true,
		}
	}},
}

local REGIONS = {
	TUT_Tutorial = 0,
	FJ_FortJoy_Main = 1,
	LV_HoE_Main = 2,
	RC_Main = 3,
	CoS_Main = 4,
	ARX_Main = 5,
	ARX_Endgame = 6
}

local defaultRotation = {0,0,0}
local listenForDeath = {}

local function GetUniqueDefaultOwner(id, data, region)
	local t = type(data.Target)
	if t == "string" then
		if ObjectExists(data.Target) == 1 and GetRegion(data.Target) == region then
			return data.Target
		end
	elseif t == "table" then
		local targetData = data.Target[region]
		if targetData then
			if targetData.UUID and ObjectExists(targetData.UUID) == 1 then
				return targetData.UUID
			end
		end
	end
	return nil
end

local function InitializeUnique(id,data,region)
	local t = type(data.Target)
	if t == "string" then
		if ObjectExists(data.Target) == 1 and GetRegion(data.Target) == region then
			ItemToInventory(data.UUID, data.Target, 1, 0, 1)
			ObjectSetFlag(data.UUID, "LLWEAPONEX_UniqueData_Initialized", 0)
			listenForDeath[data.Target] = data.UUID
			if data.Equip 
			and ObjectIsCharacter(data.Target) == 1 
			and ItemIsEquipable(data.UUID) == 1 
			and CharacterIsDead(data.Target) == 0 then
				GameHelpers.Character.EquipItem(data.Target, data.UUID)
				Ext.GetCharacter(data.Target).RootTemplate.IsEquipmentLootable = true
			end
		end
	elseif t == "table" then
		local targetData = data.Target[region]
		if targetData then
			if targetData.Position then
				local x,y,z = table.unpack(targetData.Position)
				local rp,ry,rr = table.unpack(targetData.Rotation or defaultRotation)
				ItemToTransform(data.UUID, x, y, z, rp, ry, rr, 1, StringHelpers.NULL_UUID)
				ObjectSetFlag(data.UUID, "LLWEAPONEX_UniqueData_Initialized", 0)
			elseif targetData.UUID and ObjectExists(targetData.UUID) == 1 then
				listenForDeath[targetData.UUID] = data.UUID
				ItemToInventory(data.UUID, targetData.UUID, 1, 0, 1)
				ObjectSetFlag(data.UUID, "LLWEAPONEX_UniqueData_Initialized", 0)
				if targetData.Equip 
				and ObjectIsCharacter(targetData.UUID) == 1 
				and ItemIsEquipable(data.UUID) == 1
				and CharacterIsDead(targetData.UUID) == 0 then
					GameHelpers.Character.EquipItem(targetData.UUID, data.UUID)
					Ext.GetCharacter(targetData.UUID).RootTemplate.IsEquipmentLootable = true
				end
			end
		else
			local defaultRegion = nil
			if data.Target then
				for k,v in pairs(data.Target) do
					if v.IsDefault then
						defaultRegion = k
						break
					end
				end
			end
			local regionVal = REGIONS[defaultRegion] or -1
			local currentVal = REGIONS[region] or 999
			-- Region is in a past act
			if regionVal < currentVal then
				ItemToInventory(data.UUID, NPC.VendingMachine, 1, 0, 1)
				ObjectSetFlag(data.UUID, "LLWEAPONEX_UniqueData_Initialized", 0)
			end
		end
	end
end

--When the campaign isn't Origins
function InitGlobalUniques()
	for id,data in pairs(ORIGINS_UNIQUES) do
		if ObjectExists(data.UUID) == 1 then
			local uniqueData = Uniques[id]
			if uniqueData then
				uniqueData.DefaultUUID = data.UUID
			end
		end
	end
end

function InitOriginsUniques(region)
	if not REGIONS[region] then
		--Initialize DefaultUUID
		InitGlobalUniques()
		return
	end
	for id,data in pairs(ORIGINS_UNIQUES) do
		if ObjectExists(data.UUID) == 1 then
			local uniqueData = Uniques[id]
			if uniqueData then
				uniqueData.DefaultUUID = data.UUID
			end
			if not data.IsLinkItem then
				if (ObjectGetFlag(data.UUID, "LLWEAPONEX_UniqueData_Initialized") == 0 or Vars.DebugMode) then
					local owner = GameHelpers.Item.GetOwner(data.UUID)
					if owner and GameHelpers.Character.IsPlayer(owner) then
						ObjectSetFlag(data.UUID, "LLWEAPONEX_UniqueData_Initialized", 0)
					else
						local b,err = xpcall(InitializeUnique, debug.traceback, id, data, region)
						if not b then
							Ext.PrintError(err)
						end
					end
				else
					local owner = GetUniqueDefaultOwner(id,data,region)
					if owner then
						if CharacterIsDead(owner) == 0 then
							listenForDeath[owner] = data.UUID
						elseif GameHelpers.Item.ItemIsEquipped(owner, data.UUID) then
							ItemToInventory(data.UUID, owner, 1, 0, 1)
						end
					end
				end
			end
		end
	end
end

Ext.RegisterOsirisListener("CharacterDied", 1, "after", function(character)
	local uuid = GameHelpers.GetUUID(character)
	if listenForDeath[uuid] then
		if GameHelpers.Item.ItemIsEquipped(uuid, listenForDeath[uuid]) then
			ItemToInventory(listenForDeath[uuid], uuid, 1, 0, 1)
		end
		listenForDeath[uuid] = nil
	end
end)

--Un-initializing uniques so they can be moved in the next region
Ext.RegisterOsirisListener("RegionEnded", 1, "after", function(region)
	if not REGIONS[region] then
		return
	end
	for id,data in pairs(ORIGINS_UNIQUES) do
		if not data.IsLinkItem and ObjectExists(data.UUID) == 1 then
			if (ObjectGetFlag(data.UUID, "LLWEAPONEX_UniqueData_Initialized") == 1) then
				local item = Ext.GetItem(data.UUID)
				local owner = GameHelpers.Item.GetOwner(item)
				if not owner then
					ObjectClearFlag(data.UUID, "LLWEAPONEX_UniqueData_Initialized", 0)
					ItemToInventory(data.UUID, NPC.UniqueHoldingChest, 1, 0, 1)
				elseif owner.Global then
					ObjectClearFlag(data.UUID, "LLWEAPONEX_UniqueData_Initialized", 0)
					ItemToInventory(data.UUID, NPC.UniqueHoldingChest, 1, 0, 1)
				end
			end
		end
	end
end)