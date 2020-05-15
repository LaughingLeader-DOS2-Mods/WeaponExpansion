local defaultPos = {[1] = 0.0, [2] = 0.0, [3] = 0.0,}

---@type ui UIObject
---@type item EsvCharacter
---@type character EsvCharacter
---@type setupTooltip table
---@type weaponTypeName string
---@type scaleText string
---@type damageRange table<string,number[]>
---@type attackCost integer
local function CreateFakeWeaponTooltip(ui, item, character, setupTooltip, weaponTypeName, scaleText, damageRange, attackCost, weaponRange)
-- [37] = ArmorSlotType | 42
	-- [38] = ["Belt"]
	-- [39] = [true]
	-- [40] = [""]
	local index = setupTooltip.FindTooltipTypeIndex(ui, LeaderLib.Data.UI.TOOLTIP_TYPE.ArmorSlotType)
	if index ~= nil then
		local itemType = ui:GetValue("tooltip_array", "string", index+1)
		ui:SetValue("tooltip_array", weaponTypeName, index+1)
		--[41] = Equipped | 88
		--[42] = ["Harken"]
		--[43] = ["Equipped"]
		--[44] = [""]
		index = setupTooltip.FindTooltipTypeIndex(ui, LeaderLib.Data.UI.TOOLTIP_TYPE.Equipped)
		if index ~= nil then
			ui:SetValue("tooltip_array", itemType, index+3)
		end
	end
	index = setupTooltip.FindFreeIndex(ui)
	-- [15] = ItemAttackAPCost | 8
	-- [16] = [Attack]
	-- [17] = [2.0]
	-- [18] = [""]
	-- [19] = [true]
	ui:SetValue("tooltip_array", LeaderLib.Data.UI.TOOLTIP_TYPE.ItemAttackAPCost, index)
	index = index + 1
	ui:SetValue("tooltip_array", Text.Game.Attack.Value, index)
	index = index + 1
	ui:SetValue("tooltip_array", attackCost, index)
	index = index + 1
	ui:SetValue("tooltip_array", "", index)
	index = index + 1
	ui:SetValue("tooltip_array", true, index)
	index = index + 1
	-- [24] = APCostBoost | 16
	-- [25] = ["Action Points"]
	-- [26] = [2.0]
	-- [27] = [""]
	ui:SetValue("tooltip_array", LeaderLib.Data.UI.TOOLTIP_TYPE.APCostBoost, index)
	index = index + 1
	ui:SetValue("tooltip_array", Text.Game.ActionPoints.Value, index)
	index = index + 1
	ui:SetValue("tooltip_array", attackCost, index)
	index = index + 1
	ui:SetValue("tooltip_array", "", index)
	index = index + 1
	-- [28] = ItemRequirement | 28
	--  [29] = ["Scales With Strength"]
	--  [30] = [""]
	--  [31] = [true]
	ui:SetValue("tooltip_array", LeaderLib.Data.UI.TOOLTIP_TYPE.ItemRequirement, index)
	index = index + 1
	ui:SetValue("tooltip_array", scaleText, index)
	index = index + 1
	ui:SetValue("tooltip_array", "", index)
	index = index + 1
	ui:SetValue("tooltip_array", true, index)
	index = index + 1
	-- [32] = WeaponDamage | 29
	--  [33] = [7.0]
	--  [34] = [8.0]
	--  [35] = ["Physical"]
	--  [36] = [1.0]
	--  [37] = [""]
	ui:SetValue("tooltip_array", LeaderLib.Data.UI.TOOLTIP_TYPE.WeaponDamage, index)
	index = index + 1
	for damageType,data in pairs(damageRange) do
		ui:SetValue("tooltip_array", data[1], index)
		index = index + 1
		ui:SetValue("tooltip_array", data[2], index)
		index = index + 1
		ui:SetValue("tooltip_array", damageType, index)
		index = index + 1
		ui:SetValue("tooltip_array", LeaderLib.Data.DamageTypeEnums[damageType], index)
		index = index + 1
		ui:SetValue("tooltip_array", "", index)
		index = index + 1
	end
	-- [38] = WeaponCritMultiplier | 31
	--  [39] = [Critical Damage]
	--  [40] = [2.0]
	--  [41] = []
	--  [42] = [true]
	--  [43] = [200%]
	ui:SetValue("tooltip_array", LeaderLib.Data.UI.TOOLTIP_TYPE.WeaponCritMultiplier, index)
	index = index + 1
	ui:SetValue("tooltip_array", Text.Game.CriticalDamage.Value, index)
	index = index + 1
	ui:SetValue("tooltip_array", 2, index)
	index = index + 1
	ui:SetValue("tooltip_array", "", index)
	index = index + 1
	ui:SetValue("tooltip_array", true, index)
	index = index + 1
	ui:SetValue("tooltip_array", "100%", index)
	index = index + 1
	-- [44] = WeaponRange | 33
	--  [45] = [Range]
	--  [46] = []
	--  [47] = [2.9m]
	--  [48] = [true]
	if weaponRange ~= nil then
		ui:SetValue("tooltip_array", LeaderLib.Data.UI.TOOLTIP_TYPE.WeaponRange, index)
		index = index + 1
		ui:SetValue("tooltip_array", Text.Game.Range.Value, index)
		index = index + 1
		ui:SetValue("tooltip_array", "", index)
		index = index + 1
		ui:SetValue("tooltip_array", weaponRange, index)
		index = index + 1
		ui:SetValue("tooltip_array", true, index)
		index = index + 1
	end
	--local text = LeaderLib.UI.Tooltip.FormatDamageRange(damageRange)
	---@type EsvItem
	-- local item = Ext.GetItem(CLIENT_UI.LAST_ITEM)
	-- if item ~= nil then
	-- 	print(item.NetID, item.MyGuid, item.StatsId)
	-- 	-- ---@type StatItem
	-- 	-- local stats = item.Stats
	-- 	-- if stats ~= nil then
	-- 	-- 	print(stats.DynamicStats[1])
	-- 	-- end
	-- end
end

---@type TranslatedString
local TranslatedString = LeaderLib.Classes.TranslatedString

local LLWEAPONEX_HandCrossbow = TranslatedString:Create("hd8d02aa1g5c35g48b5gbde6ga76293ef2798", "Hand Crossbow")
local LLWEAPONEX_Pistol = TranslatedString:Create("h9ead3ee9g63e6g4fdbg987dg87f8c9f5220c", "Pistol")

local WeaponTypeNames = {
	{Tag = "LLWEAPONEX_Banner", Text = TranslatedString:Create("hbe8ca1e2g4683g4a93g8e20g984992e30d22", "Banner")},
	{Tag = "LLWEAPONEX_BattleBook", Text = TranslatedString:Create("he053a3abge5d8g4d14g9333ga18d6eba3df1", "Battle Book")},
	{Tag = "LLWEAPONEX_Blunderbuss", Text = TranslatedString:Create("h59b52860gd0e3g4e65g9e61gd66b862178c3", "Blunderbuss")},
	{Tag = "LLWEAPONEX_DualShields", Text = TranslatedString:Create("h00157a58g9ae0g4119gba1ag3f1e9f11db14", "Dual Shields")},
	{Tag = "LLWEAPONEX_Firearm", Text = TranslatedString:Create("h8d02e345ged4ag4d60g9be9g68a46dda623b", "Firearm")},
	{Tag = "LLWEAPONEX_Greatbow", Text = TranslatedString:Create("h52a81f92g3549g4cb4g9b18g066ba15399c0", "Greatbow")},
	{Tag = "LLWEAPONEX_Katana", Text = TranslatedString:Create("he467f39fg8b65g4136g828fg949f9f3aef15", "Katana")},
	{Tag = "LLWEAPONEX_Quarterstaff", Text = TranslatedString:Create("h8d11d8efg0bb8g4130g9393geb30841eaea5", "Quarterstaff")},
	{Tag = "LLWEAPONEX_Polearm", Text = TranslatedString:Create("hd61320b6ge4e6g4f51g8841g132159d6b282", "Polearm")},
	{Tag = "LLWEAPONEX_Rapier", Text = TranslatedString:Create("h84b2d805gff5ag44a5g9f81g416aaf5abf18", "Rapier")},
	{Tag = "LLWEAPONEX_Runeblade", Text = TranslatedString:Create("hb66213fdg1a98g4127ga55fg429f9cde9c6a", "Runeblade")},
	{Tag = "LLWEAPONEX_Scythe", Text = TranslatedString:Create("h1e98bd0bg867dg4a57gb2d4g6d820b4e7dfa", "Scythe")},
	{Tag = "LLWEAPONEX_Unarmed", Text = TranslatedString:Create("h1e98bcebg2e42g4699gba2bg6f647d428699", "Unarmed")},
	--{Tag = "LLWEAPONEX_Bludgeon", Text = TranslatedString:Create("h448753f3g7785g4681gb639ga0e9d58bfadd", "Bludgeon")},
}

---@type ui UIObject
---@type item EsvItem
---@type character EsvCharacter
---@type setupTooltip table
local function TryOverrideItemTooltip(ui, item, character, setupTooltip)
	if item:HasTag("LLWEAPONEX_Pistol") then
		local damageRange = Skills.Damage.GetPistolDamage(character, true)
		local apCost = Ext.StatGetAttribute("Target_LLWEAPONEX_Pistol_Shoot", "ActionPoints")
		local weaponRange = string.format("%sm", Ext.StatGetAttribute("Target_LLWEAPONEX_Pistol_Shoot", "TargetRadius"))
		CreateFakeWeaponTooltip(ui, item, character, setupTooltip, LLWEAPONEX_Pistol.Value, Text.WeaponScaling.Pistol.Value, damageRange, apCost, weaponRange)
	elseif item:HasTag("LLWEAPONEX_HandCrossbow") then
		local damageRange = Skills.Damage.GetHandCrossbowDamage(character, true)
		local apCost = Ext.StatGetAttribute("Projectile_LLWEAPONEX_HandCrossbow_Shoot", "ActionPoints")
		local weaponRange = string.format("%sm", Ext.StatGetAttribute("Projectile_LLWEAPONEX_HandCrossbow_Shoot", "TargetRadius"))
		CreateFakeWeaponTooltip(ui, item, character, setupTooltip, LLWEAPONEX_HandCrossbow.Value, Text.WeaponScaling.HandCrossbow.Value, damageRange, apCost, weaponRange)
	else
		for i,entry in ipairs(WeaponTypeNames) do
			if item:HasTag(entry.Tag) then
				local index = setupTooltip.FindTooltipTypeIndex(ui, LeaderLib.Data.UI.TOOLTIP_TYPE.ArmorSlotType)
				if index ~= nil then
					print("Item", item.StatsId, "has tag", entry.Tag)
					local itemType = ui:GetValue("tooltip_array", "string", index+1)
					ui:SetValue("tooltip_array", entry.Text.Value, index+1)
				end
				break
			end
		end
	end
end
return {
	TryOverrideItemTooltip = TryOverrideItemTooltip
}