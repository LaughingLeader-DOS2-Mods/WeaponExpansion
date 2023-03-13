local DualShields = {
	Data = {
		ShieldToCombatShield = {
			WPN_LLWEAPONEX_DualShields_Blackring_A = "WPN_LLWEAPONEX_CombatShield_Blackring_A",
			WPN_LLWEAPONEX_DualShields_Common_A = "WPN_LLWEAPONEX_CombatShield_Common_A",
			WPN_LLWEAPONEX_DualShields_Start = "WPN_LLWEAPONEX_CombatShield_Common_A",
			WPN_LLWEAPONEX_DualShields_Dwarves_A = "WPN_LLWEAPONEX_CombatShield_Dwarves_A",
			WPN_LLWEAPONEX_DualShields_Elves_B = "WPN_LLWEAPONEX_CombatShield_Elves_B",
			WPN_LLWEAPONEX_DualShields_Humans_A = "WPN_LLWEAPONEX_CombatShield_Humans_A",
			WPN_LLWEAPONEX_DualShields_Lizards_C = "WPN_LLWEAPONEX_CombatShield_Lizards_C",
		},
		AllUncommonDualShields = {
			"WPN_LLWEAPONEX_DualShields_Blackring_A",
			"WPN_LLWEAPONEX_DualShields_Dwarves_A",
			"WPN_LLWEAPONEX_DualShields_Elves_B",
			"WPN_LLWEAPONEX_DualShields_Humans_A",
			"WPN_LLWEAPONEX_DualShields_Lizards_C",
		},
		AllUncommonCombatShields = {
			"WPN_LLWEAPONEX_CombatShield_Blackring_A",
			"WPN_LLWEAPONEX_CombatShield_Dwarves_A",
			"WPN_LLWEAPONEX_CombatShield_Elves_B",
			"WPN_LLWEAPONEX_CombatShield_Humans_A",
			"WPN_LLWEAPONEX_CombatShield_Lizards_C",
		},
		RarityToBoostGroups = {
			Uncommon = {"Uncommon", "Normal", "NonEpic", "RuneEmpty"},
			Rare = {"Rare", "Exceptional", "NonLegendary", "Normal", "NonEpic", "RuneEmpty"},
			Epic = {"Epic", "Exceptional", "NonLegendary", "Normal", "RuneEmpty"},
			Legendary = {"Legendary", "Exceptional", "Normal", "RuneEmpty"},
			Divine = {"Divine", "Legendary", "Exceptional", "Normal", "RuneEmpty"},
		},
		CombatShieldDeltaModGroupLimit = {
			Statuses = 1,
			Skills = 1,
			Runes = 1
		},
		CombatShieldDeltaMods = {
			RuneEmpty = {
				Boost_Weapon_EmptyRuneSlot = {Chance = 1, Group = "Runes"},
			},
			Normal = {
				Boost_Weapon_LLWEAPONEX_Ability_OneHanded_CombatShield = {Chance = 60},
				Boost_Weapon_LLWEAPONEX_Ability_Perserverance_CombatShield = {Chance = 45},
				Boost_Weapon_LLWEAPONEX_Ability_PainReflection_CombatShield = {Chance = 10},
				Boost_Weapon_LLWEAPONEX_Ability_WarriorLore_CombatShield = {Chance = 10},
				Boost_Weapon_Ability_RogueLore_Spear = {Chance = 1},
				Boost_Weapon_Ability_Summoning_Staff = {Chance = 1},
				Boost_Weapon_Damage_Bonus = {Chance = 10},
				Boost_Weapon_Secondary_CriticalModifier = {Chance = 10},
				Boost_Weapon_Secondary_Initiative = {Chance = 1},
				Boost_Weapon_Status_Set_Bleeding = {Chance = 1, Group = "Statuses"},
				Boost_Weapon_Status_Set_Poisoned_Axe = {Chance = 1, Group = "Statuses"},
				Boost_Weapon_Skill_Whirlwind_Club = {Chance = 1, Group = "Skills"},
			},
			NonEpic = {
				Boost_Weapon_LLWEAPONEX_Status_Set_Crippled_CombatShield_Rare = {Chance = 1, Group = "Statuses"},
				Boost_Weapon_LLWEAPONEX_Primary_Constitution_CombatShield = {Chance = 60},
				Boost_Weapon_LLWEAPONEX_Skill_CripplingBlow_CombatShield = {Chance = 45},
				Boost_Weapon_Secondary_Vitality = {Chance = 5},
				Boost_Weapon_LLWEAPONEX_Damage_ArmourPiercing_Small_CombatShield = {Chance = 5},
				Boost_Weapon_Ability_Telekinesis_Wand = {Chance = 1},
			},
			Exceptional = {
				Boost_Weapon_LLWEAPONEX_Status_Set_Crippled_CombatShield_Epic = {Chance = 1, Group = "Statuses"},
				Boost_Weapon_LLWEAPONEX_Primary_Constitution_CombatShield_Medium = {Chance = 60, MinLevel = 10},
				Boost_Weapon_Secondary_Vitality_Normal = {Chance = 10},
				Boost_Weapon_Secondary_CriticalChance = {Chance = 10},
				Boost_Weapon_Ability_Necromancy_Wand = {Chance = 10},
				Boost_Weapon_Damage_ArmourPiercing = {Chance = 10},
				Boost_Weapon_Rune_LOOT_Rune_Masterwork_Small = {Chance = 5, Group = "Runes"},
				Boost_Weapon_Rune_LOOT_Rune_Masterwork_Medium = {Chance = 1, Group = "Runes"},
				Boost_Weapon_Rune_LOOT_Rune_Flame_Small = {Chance = 5, Group = "Runes"},
				Boost_Weapon_Rune_LOOT_Rune_Flame_Medium = {Chance = 1, Group = "Runes"},
				Boost_Weapon_Rune_LOOT_Rune_Frost_Small = {Chance = 5, Group = "Runes"},
				Boost_Weapon_Rune_LOOT_Rune_Frost_Medium = {Chance = 1, Group = "Runes"},
				Boost_Weapon_Rune_LOOT_Rune_Thunder_Small = {Chance = 5, Group = "Runes"},
				Boost_Weapon_Rune_LOOT_Rune_Thunder_Medium = {Chance = 1, Group = "Runes"},
				Boost_Weapon_Rune_LOOT_Rune_Rock_Small = {Chance = 5, Group = "Runes"},
				Boost_Weapon_Rune_LOOT_Rune_Rock_Medium = {Chance = 1, Group = "Runes"},
				Boost_Weapon_Rune_LOOT_Rune_Venom_Small = {Chance = 5, Group = "Runes"},
				Boost_Weapon_Rune_LOOT_Rune_Venom_Medium = {Chance = 1, Group = "Runes"},
			},
			Legendary = {
				Boost_Weapon_LLWEAPONEX_Status_Set_Crippled_CombatShield_Legendary = {Chance = 1, Group = "Statuses"},
				Boost_Weapon_Status_Set_Acid = {Chance = 1, Group = "Statuses"},
				Boost_Weapon_Status_Set_Suffocating = {Chance = 1, Group = "Statuses"},
				Boost_Weapon_Status_Set_Disarmed = {Chance = 1, Group = "Statuses"},
				Boost_Weapon_Status_Set_Muted = {Chance = 1, Group = "Statuses"},
				Boost_Weapon_Status_Set_Blind = {Chance = 1, Group = "Statuses"},
				Boost_Weapon_LLWEAPONEX_Skill_DeflectiveBarrier_CombatShield = {Chance = 10, MinLevel = 10},
				Boost_Weapon_LLWEAPONEX_Skill_ThickOfTheFight_CombatShield = {Chance = 50},
				Boost_Weapon_Secondary_CriticalModifier_Large = {Chance = 10},
				Boost_Weapon_LifeSteal_Large = {Chance = 10},
				Boost_Weapon_Damage_ArmourPiercing_Medium = {Chance = 10},
				Boost_Weapon_Rune_LOOT_Rune_Masterwork_Large = {Chance = 3, Group = "Runes"},
				Boost_Weapon_Rune_LOOT_Rune_Masterwork_Giant = {Chance = 1, Group = "Runes"},
				Boost_Weapon_Rune_LOOT_Rune_Flame_Large = {Chance = 3, Group = "Runes"},
				Boost_Weapon_Rune_LOOT_Rune_Flame_Giant = {Chance = 1, Group = "Runes"},
				Boost_Weapon_Rune_LOOT_Rune_Frost_Large = {Chance = 3, Group = "Runes"},
				Boost_Weapon_Rune_LOOT_Rune_Frost_Giant = {Chance = 1, Group = "Runes"},
				Boost_Weapon_Rune_LOOT_Rune_Thunder_Large = {Chance = 3, Group = "Runes"},
				Boost_Weapon_Rune_LOOT_Rune_Thunder_Giant = {Chance = 1, Group = "Runes"},
				Boost_Weapon_Rune_LOOT_Rune_Rock_Large = {Chance = 3, Group = "Runes"},
				Boost_Weapon_Rune_LOOT_Rune_Rock_Giant = {Chance = 1, Group = "Runes"},
				Boost_Weapon_Rune_LOOT_Rune_Venom_Large = {Chance = 3, Group = "Runes"},
				Boost_Weapon_Rune_LOOT_Rune_Venom_Giant = {Chance = 1, Group = "Runes"},
			},
		}
	}
}

---@param statId string
---@param shieldStat StatEntryShield
---@return string|nil
function DualShields._FindCombatShieldMatch(statId, shieldStat)
	local combatShieldStat = DualShields.Data.ShieldToCombatShield[statId]
	if combatShieldStat then
		return combatShieldStat
	end
	if not shieldStat or StringHelpers.IsNullOrEmpty(shieldStat.Using) then
		return nil
	else
		local stat = Ext.Stats.Get(shieldStat.Using, nil, false) --[[@as StatEntryShield]]
		return DualShields._FindCombatShieldMatch(shieldStat.Using, stat)
	end
end

---@param rarity ItemDataRarity
---@param level integer
---@param parentBoosts integer
---@return string[]|nil
---@return string[]|nil
function DualShields._GetRandomCombatShieldDeltaMods(rarity, level, parentBoosts)
	local rarityNum = Data.ItemRarity[rarity]
	if rarityNum > 0 then
		local boostGroups = DualShields.Data.RarityToBoostGroups[rarity]
		local maxDeltaMods = GameHelpers.GetExtraData("LLWEAPONEX_CombatShields_MaxGeneratedDeltaMods", 2)
		if maxDeltaMods <= 0 or not boostGroups then
			return nil
		end
		maxDeltaMods = math.max(maxDeltaMods, parentBoosts)
		local runeBoosts = {}
		local deltamods = {}
		local groupCount = {}
		local deltaModCount = 0
		local fails = 0
		local bonusRolls = 0
		for _,v in pairs(boostGroups) do
			local boostmods = DualShields.Data.CombatShieldDeltaMods[v]
			if boostmods then
				for id,settings in pairs(boostmods) do
					local skip = false
					if settings.MinLevel and level < settings.MinLevel then
						skip = true
					end
					local count = groupCount[settings.Group]
					local isRune = false
					if settings.Group then
						isRune = settings.Group == "Runes"
						local limit = DualShields.Data.CombatShieldDeltaModGroupLimit[settings.Group]
						if not skip and limit then
							if not count then
								groupCount[settings.Group] = 0
								count = 0
							end
							if count >= limit then
								skip = true
							end
						end
					end

					if not skip then
						if fails > 5 then
							bonusRolls = 1
						end
						if GameHelpers.Math.Roll(settings.Chance, bonusRolls) then
							deltaModCount = deltaModCount + 1
							if isRune then
								runeBoosts[#runeBoosts+1] = id
							else
								deltamods[deltaModCount] = id
							end
							if count then
								count = count + 1
								groupCount[settings.Group]  = count
							end
						else
							fails = fails + 1
						end
					end
				end
			end
		end
		if deltaModCount <= maxDeltaMods then
			return deltamods,runeBoosts
		else
			--Shuffle table, then use unpack to splice it with the first n elements
			return {table.unpack(Common.ShuffleTable(deltamods), 1, maxDeltaMods-#runeBoosts)}, runeBoosts
		end
	end
	return nil
end

---@param shield EsvItem
---@return EsvItem|nil combatShield
function DualShields._GenerateCombatShield(shield)
	local combatShieldStat = DualShields._FindCombatShieldMatch(shield.StatsFromName.Name, shield.StatsFromName.StatsEntry --[[@as StatEntryShield]])
	if not combatShieldStat then
		combatShieldStat = Common.GetRandomTableEntry(DualShields.Data.AllUncommonCombatShields)
	end
	local level = shield.Stats.Level
	local rarity = shield.Stats.Rarity
	local parentBoosts = 0
	for i=2,#shield.Stats.DynamicStats do
		if not StringHelpers.IsNullOrEmpty(shield.Stats.DynamicStats[i].ObjectInstanceName) then
			parentBoosts = parentBoosts + 1
		end
	end
	local deltamods,runeBoosts = DualShields._GetRandomCombatShieldDeltaMods(rarity, level, parentBoosts)
	if deltamods then
		Ext.Dump(deltamods)
		Ext.Dump(runeBoosts or {})
	end
	local itemGUID,combatShield = GameHelpers.Item.CreateItemByStat(combatShieldStat, {
		GenerationStatsId = combatShieldStat,
		StatsLevel=level,
		Amount = 1,
		GenerationItemType=rarity,
		ItemType=rarity,
		IsIdentified=true,
		DeltaMods = deltamods,
		GMFolding = false,
		HasGeneratedStats = false,
		RuneBoosts = runeBoosts
	})
	if combatShield then
		return combatShield
	end
	return nil
end

---@param shield EsvItem
---@param skipGeneration boolean|nil
---@param skipMoving boolean|nil
---@return EsvItem|nil combatShield
function DualShields.GetCombatShield(shield, skipGeneration, skipMoving)
	local combatShieldGUID = GetVarObject(shield.MyGuid, "LLWEAPONEX_CombatShield")
	if StringHelpers.IsNullOrWhitespace(combatShieldGUID) or ObjectExists(combatShieldGUID) == 0 then
		if skipGeneration ~= true then
			local combatShield = DualShields._GenerateCombatShield(shield)
			if combatShield then
				SetTag(combatShield.MyGuid, "LLWEAPONEX_CombatShield")
				SetVarObject(shield.MyGuid, "LLWEAPONEX_CombatShield", combatShield.MyGuid)
				SetVarObject(combatShield.MyGuid, "LLWEAPONEX_ParentDualShield", shield.MyGuid)
				if not skipMoving then
					ItemToInventory(combatShield.MyGuid, shield.MyGuid, 1, 0, 0)
				end
				return combatShield
			end
		end
	else
		local combatShield = GameHelpers.GetItem(combatShieldGUID)
		if combatShield then
			---@cast combatShield EsvItem
			return combatShield
		end
	end
	return nil
end

---@param shield EsvItem
---@return EsvItem|nil combatShield
function DualShields.GetShieldParent(shield)
	local shieldGUID = GetVarObject(shield.MyGuid, "LLWEAPONEX_ParentDualShield")
	if not StringHelpers.IsNullOrWhitespace(shieldGUID) and ObjectExists(shieldGUID) == 1 then
		local shield = GameHelpers.GetItem(shieldGUID)
		if shield then
			---@cast shield EsvItem
			return shield
		end
	end
	return nil
end

ItemProcessor.DualShields = DualShields

EquipmentManager.Events.EquipmentChanged:Subscribe(function (e)
	if not e.AllTags.LLWEAPONEX_CombatShield then
		local combatShield = ItemProcessor.DualShields.GetCombatShield(e.Item, e.Equipped == false, true)
		if combatShield then
			if e.Equipped then
				if not GameHelpers.Item.ItemIsEquipped(e.Character, combatShield) then
					local charGUID = e.Character.MyGuid
					local itemGUID = combatShield.MyGuid
					local currentWeapon = StringHelpers.GetUUID(CharacterGetEquippedItem(e.Character.MyGuid, "Weapon"))
					Ext.OnNextTick(function (e)
						if not StringHelpers.IsNullOrEmpty(currentWeapon) and currentWeapon ~= itemGUID then
							CharacterUnequipItem(charGUID, currentWeapon)
							--ItemToInventory(currentWeapon, charGUID, 1, 0, 0)
						end
						NRD_CharacterEquipItem(charGUID, itemGUID, "Weapon", 1, 0, 1, 1)
					end)
				end
			else
				local shieldGUID = e.Item.MyGuid
				local combatShieldGUID = combatShield.MyGuid
				Ext.OnNextTick(function (e)
					ItemLockUnEquip(combatShieldGUID, 0)
					ItemToInventory(combatShieldGUID, shieldGUID, 1, 0, 0)
				end)
			end
		end
	end
end, {MatchArgs={Tag="LLWEAPONEX_DualShields"}})

EquipmentManager.Events.EquipmentChanged:Subscribe(function (e)
	if not e.Equipped then
		--local visualID = string.format("%s%s", e.Character.NetID, GameHelpers.GetTemplate(e.Item))
		--VisualManager.RequestDeleteVisualByID(e.Character, visualID)

		local shield = DualShields.GetShieldParent(e.Item)
		if shield and GameHelpers.Item.ItemIsEquipped(e.Character, shield) then
			local charGUID = e.Character.MyGuid
			local combatShieldGUID = e.Item.MyGuid
			local shieldGUID = shield.MyGuid
			Ext.OnNextTick(function (e)
				ItemToInventory(combatShieldGUID, shieldGUID, 1, 0, 0)
			end)
			Ext.OnNextTick(function (e)
				if GameHelpers.Item.ItemIsEquipped(charGUID, shieldGUID) then
					ItemToInventory(shieldGUID, charGUID, 1, 0, 0)
				end
			end)
		end
	end
end, {MatchArgs={Tag="LLWEAPONEX_CombatShield"}})