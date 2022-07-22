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

---@param item EsvItem
---@param attribute string
local function ChangeItemScaling(item, attribute)
	for _,req in pairs(item.Stats.Requirements) do
		if Data.AttributeEnum[req.Requirement] then
			req.Requirement = attribute
		end
	end
	PersistentVars.AttributeRequirementChanges[item.MyGuid] = attribute
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

Ext.Events.AfterCraftingExecuteCombination:Subscribe(function (e)
	fprint(LOGLEVEL.TRACE, "[AfterCraftingExecuteCombination] Succeeded(%s) CombinationId(%s) e.CraftingStation(%s) Quantity(%s)\nItems:\n%s", e.Succeeded, e.CombinationId, e.CraftingStation, e.Quantity, Lib.serpent.block(e.Items))
	if e.Succeeded then
		if e.CombinationId == "LLWEAPONEX_Token_ChangeScalingAttribute" then
			local targetWeapon = nil
			local attribute = nil
			for _,v in pairs(e.Items) do
				if v.Stats and v.Stats.ItemType == "Weapon" then
					targetWeapon = v
				else
					local template = attributeTokenStats[v.StatsId] or GameHelpers.GetTemplate(v)
					local att = attributeTokenTemplates[template]
					if att then
						attribute = att
					end
				end
			end
			if targetWeapon and attribute then
				ChangeItemScaling(targetWeapon, attribute)
			end
		elseif e.CombinationId == "LLWEAPONEX_Token_CreateAttributeToken" then
			-- 3 shards = a new attribute token of choice
			CharacterGiveQuestReward(e.Character.MyGuid, "LLWEAPONEX_Rewards_AttributeToken", "QuestReward")
		end
	end
end)