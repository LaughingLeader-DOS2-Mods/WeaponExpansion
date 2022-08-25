local attributeTokenStats = {
	LOOT_LLWEAPONEX_Token_Strength = "c77de879-b29b-4707-a75c-2c42adc0712b",
	LOOT_LLWEAPONEX_Token_Finesse = "95284549-f8c1-496b-af36-9d96565f6c0f",
	LOOT_LLWEAPONEX_Token_Intelligence = "bc8c81a1-106d-49ef-beac-e97678ba9b16",
	LOOT_LLWEAPONEX_Token_Constitution = "d360798f-50e3-4c9e-b0e5-0c69345b1a92",
	LOOT_LLWEAPONEX_Token_Memory = "1a3acb90-a152-4ebd-8b02-c5fe99f6c0e3",
	LOOT_LLWEAPONEX_Token_Wits = "dfb3db93-2562-46d2-9cd1-5ea5b57b72b9",
}

local attributeToTokenTemplate = {
	Strength = "c77de879-b29b-4707-a75c-2c42adc0712b",
	Finesse = "95284549-f8c1-496b-af36-9d96565f6c0f",
	Intelligence = "bc8c81a1-106d-49ef-beac-e97678ba9b16",
	Constitution = "d360798f-50e3-4c9e-b0e5-0c69345b1a92",
	Memory = "1a3acb90-a152-4ebd-8b02-c5fe99f6c0e3",
	Wits = "dfb3db93-2562-46d2-9cd1-5ea5b57b72b9",
}

local attributeTokenTemplates = {
	["c77de879-b29b-4707-a75c-2c42adc0712b"] = "Strength",
	["95284549-f8c1-496b-af36-9d96565f6c0f"] = "Finesse",
	["bc8c81a1-106d-49ef-beac-e97678ba9b16"] = "Intelligence",
	["d360798f-50e3-4c9e-b0e5-0c69345b1a92"] = "Constitution",
	["1a3acb90-a152-4ebd-8b02-c5fe99f6c0e3"] = "Memory",
	["dfb3db93-2562-46d2-9cd1-5ea5b57b72b9"] = "Wits",
}

local _RESET_TOKEN = {
	Stat = "LLWEAPONEX_Transform_Reset",
	Category = "LLWEAPONEX_Transform_Reset",
	Template = "27dbe9dd-bf08-4c9f-b79a-01f806e24759"
}

if Vars.DebugMode then
	Ext.RegisterConsoleCommand("llweaponex_tokens", function(cmd)
		local host = CharacterGetHostCharacter()
		for k,template in pairs(attributeToTokenTemplate) do
			local count = CharacterGetItemTemplateCount(host, template) or 0
			print("llweaponex_tokens", template, count)
			if count < 5 then
				ItemTemplateAddTo(template, host, 5 - count, 1)
			end
		end
	end)
end

local _DEFAULT_ATTRIBUTE = {
	None = "Strength",
	Sentinel = "Strength",
	Sword = "Strength",
	Club = "Strength",
	Knife = "Finesse",
	Spear = "Finesse",
	Bow = "Finesse",
	Crossbow = "Finesse",
	Rifle = "Finesse",
	Arrow = "Finesse",
	Wand = "Intelligence",
	Staff = "Intelligence",
}

local _ATTRIBUTE_COLOR = {
	Strength = "#ff9b00",
	Finesse = "#33FF66",
	Intelligence = "#00e4ff",
	Constitution = "#ff0080",
	Memory = "#ffd500",
	Wits = "#ae00ff",
}

---@param item EsvItem
---@param attribute string
---@param character EsvCharacter
local function ChangeItemScaling(item, attribute, character)
	if attribute == "RESET" then
		PersistentVars.AttributeRequirementChanges[item.MyGuid] = nil
		for _,req in pairs(item.StatsFromName.Requirements) do
			if Data.AttributeEnum[req.Requirement] then
				attribute = req.Requirement
				break
			end
		end
		if attribute == "RESET" then
			attribute = _DEFAULT_ATTRIBUTE[item.Stats.WeaponType]
			fprint(LOGLEVEL.ERROR, "[WeaponExpansion:ChangeItemScaling] Can't reset scaling attribute for item (%s) - no attribute requirements found. Setting to default attribute for weapon type (%s).", item.StatsId, attribute)
		end
		local itemName = GameHelpers.GetDisplayName(item)
		local attributeName = LocalizedText.AttributeNames[attribute].Value
		local rarityColor = Data.Colors.Rarity[item.Rarity]
		local attributeColor = _ATTRIBUTE_COLOR[attribute]
		CharacterStatusText(character.MyGuid, Text.StatusText.WeaponAttributeReset:ReplacePlaceholders(itemName, attributeName, rarityColor, attributeColor))
		PlaySound(character.MyGuid, "GP_ScriptedEvent_Unlock_SourcePoint")
	else
		for _,req in pairs(item.Stats.Requirements) do
			if Data.AttributeEnum[req.Requirement] then
				req.Requirement = attribute
			end
		end
		PersistentVars.AttributeRequirementChanges[item.MyGuid] = attribute

		local itemName = GameHelpers.GetDisplayName(item)
		local attributeName = LocalizedText.AttributeNames[attribute].Value
		local rarityColor = Data.Colors.Rarity[item.Rarity]
		local attributeColor = _ATTRIBUTE_COLOR[attribute]
		CharacterStatusText(character.MyGuid, Text.StatusText.WeaponAttributeChanged:ReplacePlaceholders(itemName, attributeName, rarityColor, attributeColor))
		PlaySound(character.MyGuid, "SE_FX_GP_ScriptedEvent_ARX_Endgame_Transform_Impact")
	end
	EffectManager.PlayEffect("RS3_FX_GP_Status_CloseTheDoor_ApplyEffect_01", character, {Bone="Dummy_OverheadFX"})
	EffectManager.PlayEffect("RS3_FX_GP_Status_Encouraged_01", character, {Bone="Dummy_OverheadFX"})

	GameHelpers.Net.Broadcast("LLWEAPONEX_ChangeAttributeRequirement", {Item=item.NetID, Attribute=attribute})
end

--[[ Ext.Osiris.RegisterListener("ItemTemplateCombinedWithItemTemplate", 7, "after", function (...)
	local GUIDs = {}
	local args = {...}
	local len = #args
	for i=1,len do
		local v = args[i]
		if v ~= StringHelpers.NULL_UUID then
			if i == 6 then
				GUIDs[i] = GameHelpers.GetCharacter(v)
			elseif i == 7 then
				GUIDs[i] = GameHelpers.GetItem(v)
			else
				GUIDs[i] = StringHelpers.GetUUID(v)
			end
		else
			--Will be nil
			--GUIDs[i] = v
		end
	end
	OnItemTemplateCombinedWithItemTemplate(table.unpack(GUIDs, 1, len))
end) ]]

Ext.Events.BeforeCraftingExecuteCombination:Subscribe(function (e)
	fprint(LOGLEVEL.TRACE, "[BeforeCraftingExecuteCombination] Processed(%s) CombinationId(%s) e.CraftingStation(%s) Quantity(%s)\nItems:\n%s", e.Processed, e.CombinationId, e.CraftingStation, e.Quantity, Lib.serpent.block(e.Items))
end)

---@alias _WeaponExpansionCraftingRecipePatternMatch {(Type:"Category"|"Stat"|"Template"), Value:string}
---@alias _WeaponExpansionCraftingRecipePattern {Length:integer, Matches:_WeaponExpansionCraftingRecipePatternMatch[]}

---@vararg _WeaponExpansionCraftingRecipePatternMatch[]
---@return _WeaponExpansionCraftingRecipePattern
local function _CreateRecipePattern(...)
	local entries = {...}
	return {
		Length = #entries,
		Matches = entries
	}
end


local _RECIPE_ATTRIBUTE_SCALING = _CreateRecipePattern(
	{Type = "Category", Value = "Weapon"},
	{Type = "Category", Value = "LLWEAPONEX_Token_Attribute"}
)

local _RECIPE_TOKEN_SHARD = _CreateRecipePattern(
	{Type = "Stat", Value = "LOOT_LLWEAPONEX_Token_Shard"},
	{Type = "Stat", Value = "LOOT_LLWEAPONEX_Token_Shard"},
	{Type = "Stat", Value = "LOOT_LLWEAPONEX_Token_Shard"}
)

---@param items EsvItem[]
---@param pattern _WeaponExpansionCraftingRecipePattern
local function RecipeMatch(items, pattern)
	local len = #items
	if len ~= pattern.Length then
		return false
	end
	---@type EsvItem[]
	local matchItems = TableHelpers.Clone(items)
	local remaining = len

	for i=1,len do
		local m = pattern.Matches[i]
		for j=1,len do
			local item = matchItems[j]
			if m.Type == "Category" then
				local comboCategories = item.StatsFromName.ComboCategories
				if comboCategories then
					for _,v in pairs(comboCategories) do
						if v == m.Value then
							matchItems[j] = nil
							remaining = remaining - 1
							break
						end
					end
				end
			elseif m.Type == "Stat" then
				if GameHelpers.Item.GetItemStat(item) == m.Value then
					matchItems[j] = nil
					remaining = remaining - 1
					break
				end
			elseif m.Type == "Template" then
				if GameHelpers.GetTemplate(item) == m.Value then
					matchItems[j] = nil
					remaining = remaining - 1
					break
				end
			end
			if remaining <= 0 then
				return true
			end
		end
	end

	return remaining <= 0
end

Ext.Events.AfterCraftingExecuteCombination:Subscribe(function (e)
	fprint(LOGLEVEL.TRACE, "[AfterCraftingExecuteCombination] Succeeded(%s) CombinationId(%s) e.CraftingStation(%s) Quantity(%s)\nItems:\n%s", e.Succeeded, e.CombinationId, e.CraftingStation, e.Quantity, Lib.serpent.block(e.Items))
	if e.Succeeded then
		--if e.CombinationId == "LLWEAPONEX_Token_ChangeScalingAttribute" then
		if RecipeMatch(e.Items, _RECIPE_ATTRIBUTE_SCALING) then
			local targetWeapon = nil
			local attribute = nil
			for _,v in pairs(e.Items) do
				if v.Stats and v.Stats.ItemType == "Weapon" then
					targetWeapon = v
				else
					local template = GameHelpers.GetTemplate(v)
					if v.StatsId == _RESET_TOKEN.Stat or template == _RESET_TOKEN.Template then
						attribute = "RESET"
					else
						template = attributeTokenStats[v.StatsId] or template
						local att = attributeTokenTemplates[template]
						if att then
							attribute = att
						end
					end
				end
			end
			if targetWeapon and attribute then
				ChangeItemScaling(targetWeapon, attribute, e.Character)
			end
		--elseif e.CombinationId == "LLWEAPONEX_Token_CreateAttributeToken" then
		elseif RecipeMatch(e.Items, _RECIPE_TOKEN_SHARD) then
			-- 3 shards = a new attribute token of choice
			CharacterGiveQuestReward(e.Character.MyGuid, "LLWEAPONEX_Rewards_AttributeToken", "QuestReward")
		end
	end
end)