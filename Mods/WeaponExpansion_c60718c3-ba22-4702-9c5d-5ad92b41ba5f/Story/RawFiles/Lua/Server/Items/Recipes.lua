Config.Recipes = {
	Kevin = {
		Entries = {
			"LLWEAPONEX_Kevin_Poisoned",
			"LLWEAPONEX_Kevin_Clear_Poison",
			"LLWEAPONEX_Kevin_Oiled",
			"LLWEAPONEX_Kevin_Clear_Oil",
			"LLWEAPONEX_Kevin_Nails",
			"LLWEAPONEX_Kevin_Clear_Nails",
		}
	},
	Shurikens = {
		Mastery = MasteryID.Throwing,
		MasteryLevel = 1,
		Entries = {
			"LLWEAPONEX_Shuriken_Normal",
			"LLWEAPONEX_Shuriken_Poisoned",
			"LLWEAPONEX_Shuriken_Clear_Poison",
			"LLWEAPONEX_Shuriken_Oiled",
			"LLWEAPONEX_Shuriken_Clear_Oil",
		},
	},
	Quarterstaffs = {
		Mastery = MasteryID.Quarterstaff,
		MasteryLevel = 1,
		Entries = {
			"LLWEAPONEX_Quarterstaff_Crafted_Wood",
			"LLWEAPONEX_Quarterstaff_Crafted_Metal",
		},
	},
	Runeblade_Inert = {
		Mastery = MasteryID.Runeblade,
		MasteryLevel = 1,
		Entries = {
			"LLWEAPONEX_Runeblade_Inert_1H_Air",
			"LLWEAPONEX_Runeblade_Inert_1H_Chaos",
			"LLWEAPONEX_Runeblade_Inert_1H_Earth",
			"LLWEAPONEX_Runeblade_Inert_1H_Fire",
			"LLWEAPONEX_Runeblade_Inert_1H_Poison",
			"LLWEAPONEX_Runeblade_Inert_1H_Water",
			"LLWEAPONEX_Runeblade_Inert_1H",
		},
	},
	BalrinAxe = {
		Entries = {
			"WPN_UNIQUE_LLWEAPONEX_Axe_1H_Throwable_A_Oil",
			"WPN_UNIQUE_LLWEAPONEX_Axe_1H_Throwable_A_Fire_Oven",
			"WPN_UNIQUE_LLWEAPONEX_Axe_1H_Throwable_A_Fire_Bonfire",
			"WPN_UNIQUE_LLWEAPONEX_Axe_1H_Throwable_Air_Anvil",
			"WPN_UNIQUE_LLWEAPONEX_Axe_1H_Throwable_A_Water_Anvil",
			"WPN_UNIQUE_LLWEAPONEX_Axe_1H_Throwable_A_Reset_Well",
			"WPN_UNIQUE_LLWEAPONEX_Axe_1H_Throwable_A_Reset_Water",
		},
	}
}

---@type table<WeaponExpansionMasteryID, {MinLevel:integer, Group:string, Flag:string}>
local _MasteryRecipeUnlockData = {}
local _flagPattern = "LLWEAPONEX_Recipes_Unlocked_%s"

Ext.Events.SessionLoaded:Subscribe(function (e)
	for group,data in pairs(Config.Recipes) do
		if data.Mastery then
			_MasteryRecipeUnlockData[data.Mastery] = {
				MinLevel = data.MasteryLevel or 0,
				Group = group,
				Flag = _flagPattern:format(group)
			}
		end
	end
end)

---@param player EsvCharacter
---@param group string
function UnlockRecipeGroup(player, group)
	local showNotification = player.CharacterControl and 1 or 0
	local data = Config.Recipes[group]
	if data then
		local len = #data.Entries
		for i=1,len do
			local v = data.Entries[i]
			Osi.CharacterUnlockRecipe(player.MyGuid, v, showNotification)
		end
	end
end

--Balrin's Throwing Axe recipes
EquipmentManager.Events.EquipmentChanged:Subscribe(function (e)
	if Osi.UserGetFlag(e.CharacterGUID, "LLWEAPONEX_AutoUnlockRecipesDisabled") == 0 and Osi.ObjectGetFlag(e.CharacterGUID, "LLWEAPONEX_Recipes_Unlocked_BalrinAxe") == 0 then
		Osi.ObjectSetFlag(e.CharacterGUID, "LLWEAPONEX_Recipes_Unlocked_BalrinAxe", 0)
		UnlockRecipeGroup(e.Character, "BalrinAxe")
	end
end, {MatchArgs={Template="8ff641b7-920a-4bbc-b1c1-d17a73312e53", Equipped=true}})

Mastery.Events.MasteryLeveledUp:Subscribe(function (e)
	if Osi.UserGetFlag(e.CharacterGUID, "LLWEAPONEX_AutoUnlockRecipesDisabled") == 0 then
		local data = _MasteryRecipeUnlockData[e.Mastery]
		if data and e.Current >= data.MinLevel and Osi.ObjectGetFlag(e.CharacterGUID, data.Flag) == 0 then
			UnlockRecipeGroup(e.Character, data.Group)
			Osi.ObjectSetFlag(e.CharacterGUID, data.Flag, 0)
		end
	end
end)