local function sortTagParams(a,b)
	return a:upper() < b:upper()
end

---@param character EsvCharacter
---@param data MasteryData
local function GetDescriptionText(character, data)
	local descriptionText = ""
	local namePrefix = ""
	if data.Tags ~= nil then
		local tagKeys = {}
		for tagName,tagData in pairs(data.Tags) do
			table.insert(tagKeys, tagName)
		end
		local count = #tagKeys
		table.sort(tagKeys, sortTagParams)
		for i,tagName in ipairs(tagKeys) do
			local tagData = data.Tags[tagName]
			if Mastery.HasMasteryRequirement(character, tagName) then
				if tagData.NamePrefix ~= nil then
					if namePrefix ~= "" then
						namePrefix = namePrefix .. " "
					end
					namePrefix = namePrefix .. tagData.NamePrefix
				end
				local paramText = ""
				--local tagLocalizedName = Text.MasteryRankTagText[tagName]
				local tagLocalizedName = Ext.GetTranslatedStringFromKey(tagName)
				if tagLocalizedName == nil then 
					tagLocalizedName = ""
				else
					tagLocalizedName = tagLocalizedName .. "<br>"
				end
				if tagData.Param ~= nil then
					if tagLocalizedName ~= "" then
						paramText = tagLocalizedName..tagData.Param.Value
					else
						paramText = tagData.Param.Value
					end
				end
				paramText = Tooltip.ReplacePlaceholders(paramText)
				if tagData.GetParam ~= nil then
					local status,result = xpcall(tagData.GetParam, debug.traceback, character.Stats, tagName, tagLocalizedName, paramText)
					if status and result ~= nil then
						paramText = result
					elseif not status then
						Ext.PrintError("Error calling GetParam function for "..tagName..":\n", result)
					end
				end
				if descriptionText ~= "" then descriptionText = descriptionText .. "<br>" end
				descriptionText = descriptionText .. paramText
			end
		end
	end
	return descriptionText
end

---@param character EsvCharacter
---@param skill string
---@param tooltip TooltipData
local function OnSkillTooltip(character, skill, tooltip)
	CLIENT_UI.ACTIVE_CHARACTER = character.MyGuid
	local descriptionElement = tooltip:GetElement("SkillDescription")
	local description = ""
	if descriptionElement ~= nil then
		description = descriptionElement.Label
	end

	local data = Mastery.Params.SkillData[skill]
	if data ~= nil then
		local descriptionText = GetDescriptionText(character, data)
		if descriptionText ~= "" then
			if descriptionElement ~= nil then
				if description == nil then 
					description = ""
				else
					description = description.."<br>"
				end
				description = description..descriptionText
				descriptionElement.Label = description
			else
				local descriptionElement = {
					Label = descriptionText
				}
				tooltip:AppendElement(descriptionElement)
			end
		end
	end

	if character:HasTag("LLWEAPONEX_Firearm_Equipped") then
		if not LeaderLib.StringHelpers.IsNullOrEmpty(description) then
			description = description:gsub("arrow", "bullet"):gsub("Arrow", "Bullet")
			descriptionElement.Label = description
		end
	end
end

---@param character EsvCharacter
---@param status EsvStatus
---@param tooltip TooltipData
local function OnStatusTooltip(character, status, tooltip)
	local data = Mastery.Params.StatusData[status.StatusId]
	if data ~= nil then
		local bonusIsActive = true
		if data.Active ~= nil then
			if data.Active.Type == "Tag" then
				bonusIsActive = character:HasTag(data.Active.Value)
			end
		end
		if bonusIsActive then
			local descriptionText = GetDescriptionText(character, data)
			if descriptionText ~= "" then
				local existingDescription = tooltip:GetElement("StatusDescription")
				if existingDescription ~= nil then
					local description = existingDescription.Label
					if description == nil then 
						description = "" 
					else
						description = description.."<br>"
					end
					description = description..descriptionText
					existingDescription.Label = description
				else
					local description = {
						Label = descriptionText
					}
					tooltip:AppendElement(description)
				end
			end
		end
	end
end

---@type tooltip TooltipData
---@type item EsvCharacter
---@type weaponTypeName string
---@type scaleText string
---@type damageRange table<string,number[]>
---@type attackCost integer
local function CreateFakeWeaponTooltip(tooltip, item, weaponTypeName, scaleText, damageRange, attackCost, weaponRange, equippedLabel)
	local armorSlotType = tooltip:GetElement("ArmorSlotType")
	if armorSlotType ~= nil then
		local itemType = armorSlotType.Label
		armorSlotType.Label = weaponTypeName
		local equipped = tooltip:GetElement("Equipped")
		if equipped ~= nil then
			if equippedLabel ~= nil then
				equipped.Warning = equippedLabel
			else
				--equipped.Label = itemType
				equipped.Warning = itemType
			end
		elseif equippedLabel ~= nil then
			-- local element = {
			-- 	Type = "Equipped",
			-- 	EquippedBy = "",
			-- 	Label = "",
			-- 	Warning = equippedLabel,
			-- }
			-- tooltip:AppendElement(element)
		end
	end
	
	local element = {
		Type = "ItemAttackAPCost",
		Value = attackCost,
		Label = Text.Game.Attack.Value,
		RequirementMet = true,
		Warning = "",
	}
	tooltip:AppendElement(element)
	element = {
		Type = "APCostBoost",
		Value = attackCost,
		Label = Text.Game.ActionPoints.Value,
	}
	tooltip:AppendElement(element)
	element = {
		Type = "ItemRequirement",
		Label = scaleText,
		RequirementMet = true
	}
	tooltip:AppendElement(element)
	print("damageRange", Common.Dump(damageRange))
	for damageType,data in pairs(damageRange) do
		element = {
			Type = "WeaponDamage",
			Label = LeaderLib.LocalizedText.DamageTypeNames[damageType].Text.Value,
			MinDamage = data[1],
			MaxDamage = data[2],
			DamageType = LeaderLib.Data.DamageTypeEnums[damageType],
		}
		tooltip:AppendElement(element)
	end
	element = {
		Type = "WeaponCritMultiplier",
		Label = Text.Game.CriticalDamage.Value,
		Value = "100%",
	}
	tooltip:AppendElement(element)
	if weaponRange ~= nil then
		element = {
			Type = "WeaponRange",
			Label = Text.Game.Range.Value,
			Value = weaponRange,
		}
		tooltip:AppendElement(element)
	end
end

Game.Tooltip.EncodeTooltipElement = function(tt, spec, element)
	for i,field in pairs(spec) do
		local name = field[1]
		local fieldType = field[2]
		local val = element[name]
		if name == nil then
			table.insert(tt, "")
		else
			if fieldType ~= nil and type(val) ~= fieldType then
				Ext.PrintWarning("Type of field " .. element.Type .. "." .. name .. " differs: " .. type(val) .. " vs " .. fieldType .. ":", val)
				val = nil
			end

			if val == nil then
				if fieldType == "boolean" then
					val = false
				elseif fieldType == "number" then
					val = 0
				else
					val = ""
				end
			end

			table.insert(tt, val)
		end
	end
end

---@type TranslatedString
local TranslatedString = LeaderLib.Classes.TranslatedString

local LLWEAPONEX_HandCrossbow = TranslatedString:Create("hd8d02aa1g5c35g48b5gbde6ga76293ef2798", "Hand Crossbow")
local LLWEAPONEX_Pistol = TranslatedString:Create("h9ead3ee9g63e6g4fdbg987dg87f8c9f5220c", "Pistol")
local LLWEAPONEX_Unarmed = TranslatedString:Create("h1e98bcebg2e42g4699gba2bg6f647d428699", "Unarmed")
local LLWEAPONEX_UnarmedWeapon = TranslatedString:Create("h4eb213a7g4793g4007g95c6gbaf47584f29d", "Unarmed Weapon[1]")
local GlovesSlot = TranslatedString:Create("h185545eagdaf0g4286ga411gd50cbdcabc8b", "Gloves")

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
	{Tag = "LLWEAPONEX_Unarmed", Text = LLWEAPONEX_Unarmed},
	{Tag = "LLWEAPONEX_Rod", Text = TranslatedString:Create("heb1c0428g158fg46d6gafa3g6d6143534f37", "One-Handed Scepter")},
	--{Tag = "LLWEAPONEX_Bludgeon", Text = TranslatedString:Create("h448753f3g7785g4681gb639ga0e9d58bfadd", "Bludgeon")},
}

---@param item EsvItem
---@param tooltip TooltipData
local function OnItemTooltip(item, tooltip)
	if item ~= nil then
		if item:HasTag("LLWEAPONEX_Pistol") then
			local character = Ext.GetCharacter(CLIENT_UI.ACTIVE_CHARACTER)
			local damageRange = Skills.Damage.GetPistolDamage(character, true)
			local apCost = Ext.StatGetAttribute("Target_LLWEAPONEX_Pistol_Shoot", "ActionPoints")
			local weaponRange = string.format("%sm", Ext.StatGetAttribute("Target_LLWEAPONEX_Pistol_Shoot", "TargetRadius"))
			CreateFakeWeaponTooltip(tooltip, item, LLWEAPONEX_Pistol.Value, Text.WeaponScaling.Pistol.Value, damageRange, apCost, weaponRange)
		elseif item:HasTag("LLWEAPONEX_HandCrossbow") then
			local character = Ext.GetCharacter(CLIENT_UI.ACTIVE_CHARACTER)
			local damageRange = Skills.Damage.GetHandCrossbowDamage(character, true)
			local apCost = Ext.StatGetAttribute("Projectile_LLWEAPONEX_HandCrossbow_Shoot", "ActionPoints")
			local weaponRange = string.format("%sm", Ext.StatGetAttribute("Projectile_LLWEAPONEX_HandCrossbow_Shoot", "TargetRadius"))
			CreateFakeWeaponTooltip(tooltip, item, LLWEAPONEX_HandCrossbow.Value, Text.WeaponScaling.HandCrossbow.Value, damageRange, apCost, weaponRange)
		elseif item:HasTag("LLWEAPONEX_Unarmed") then
			local character = Ext.GetCharacter(CLIENT_UI.ACTIVE_CHARACTER)
			local damageRange,highestAttribute = GetUnarmedWeaponDamageRange(character.Stats, item.Stats)
			--local highestAttribute = "Finesse"
			--local bonusWeapon = Skills.CreateWeaponTable("WPN_LLWEAPONEX_Rapier_1H_A", character.Stats.Level, highestAttribute)
			--local damageRange = CalculateWeaponDamageRangeTest(character.Stats, bonusWeapon)
			local apCost = Ext.StatGetAttribute("NoWeapon", "AttackAPCost")
			local weaponRange = string.format("%sm", Ext.StatGetAttribute("NoWeapon", "WeaponRange") / 100)
			local scalesWithText = Text.WeaponScaling.General.Value:gsub("%[1%]", LeaderLib.LocalizedText.AttributeNames[highestAttribute].Value)
			local slotInfoText = ""
			local equipped = tooltip:GetElement("Equipped")
			if equipped == nil then
				slotInfoText = string.format(" (%s)", LeaderLib.LocalizedText.Slots[item.Stats.Slot].Value)
			end
			local typeText = LLWEAPONEX_UnarmedWeapon.Value:gsub("%[1%]", slotInfoText)
			CreateFakeWeaponTooltip(tooltip, item, typeText, scalesWithText, damageRange, apCost, weaponRange)
		else
			for i,entry in ipairs(WeaponTypeNames) do
				if item:HasTag(entry.Tag) then
					local armorSlotType = tooltip:GetElement("ArmorSlotType")
					if armorSlotType ~= nil then
						armorSlotType.Label = entry.Text.Value
					end
					break
				end
			end
		end
	end
end

local totalDamageText = Ext.GetTranslatedString("h1035c3e5gc73dg4cc4ga914ga03a8a31e820", "Total damage: [1]-[2]")
--local weaponDamageText = Ext.GetTranslatedString("hfa8c138bg7c52g4b7fgaccdgbe39e6a3324c", "<br>From Weapon: [1]-[2]")
--local offhandWeaponDamageText = Ext.GetTranslatedString("hfe5601bdg2912g4beag895eg6c28772311fb", "From Offhand Weapon: [1]-[2]")
local fromFistsText = Ext.GetTranslatedString("h0881bb60gf067g4223ga925ga343fa0f2cbd", "<br>From Fists: [1]-[2]")
local fromUnarmedWeaponText = Ext.GetTranslatedString("h6d1ce292g842cg4decg89deg09ec0e293e5e", "<br>From Unarmed Weapon: [1]-[2]")

---@param character EsvCharacter
---@param tooltip TooltipData
local function OnDamageStatTooltip(character, stat, tooltip)
	CLIENT_UI.ACTIVE_CHARACTER = character.MyGuid
	--print(character, tooltip, Common.Dump(tooltip))
	if IsUnarmed(character.Stats) then
		local weapon,boost,unarmedMasteryRank,highestAttribute,hasUnarmedWeapon = GetUnarmedWeapon(character.Stats)
		local baseMin,baseMax,totalMin,totalMax = Math.GetTotalBaseAndCalculatedWeaponDamage(character.Stats, weapon)

		local totalDamageFinalText = totalDamageText:gsub("%[1%]", totalMin):gsub("%[2%]", totalMax)
	
		local weaponDamageFinalText = ""
		if not hasUnarmedWeapon then
			weaponDamageFinalText = fromFistsText:gsub("%[1%]", baseMin):gsub("%[2%]", baseMax)
		else
			weaponDamageFinalText = fromUnarmedWeaponText:gsub("%[1%]", baseMin):gsub("%[2%]", baseMax)
		end

		local element = tooltip:GetElement("StatsTotalDamage")
		element.Label = totalDamageFinalText
		-- From Fists
		element = tooltip:GetElement("StatsGearBoostNormal")
		element.Label = weaponDamageFinalText
		local fromText = Ext.GetTranslatedString("h36a3adf0g9aebg448cga0degff9d9226bb56", "From [1]: [2][3]%")
		local elements = tooltip:GetElements("StatsPercentageBoost")
		if highestAttribute ~= "Strength" then
			local strengthText = Ext.GetTranslatedString("hb4e3a075g5f82g4a0dgaffbg456e5c15c3db", "Strength")
			local attributeText = strengthText
			if highestAttribute == "Finesse" then
				attributeText = LeaderLib.LocalizedText.AttributeNames.Finesse.Value
			elseif highestAttribute == "Constituton" then
				attributeText = LeaderLib.LocalizedText.AttributeNames.Constituton.Value
			end
			local addedAttBoost = false
			local attPercentage = math.floor(Game.Math.ScaledDamageFromPrimaryAttribute(character.Stats[highestAttribute]) * 100)
			local valueSymbol = "+"
			if attPercentage < 0 then
				valueSymbol = ""
			end
			for i,v in pairs(elements) do
				if string.find(v.Label, strengthText) then
					addedAttBoost = true
					v.Label = fromText:gsub("%[1%]", attributeText):gsub("%[2%]", valueSymbol):gsub("%[3%]", attPercentage)
					break
				end
			end
			if not addedAttBoost then
				element = {
					Type = "StatsPercentageBoost",
					Label = fromText:gsub("%[1%]", attributeText):gsub("%[2%]", valueSymbol):gsub("%[3%]", attPercentage)
				}
				tooltip:AppendElementAfter(element, "StatsPercentageBoost")
			end
		end
		if boost > 0 then
			local valueSymbol = "+"
			if boost < 0 then
				valueSymbol = ""
			end
			local rankText = Ext.GetTranslatedStringFromKey(string.format("LLWEAPONEX_Unarmed_Mastery%i", unarmedMasteryRank))
			element = {
				Type = "StatsPercentageBoost",
				Label = fromText:gsub("%[1%]", rankText):gsub("%[2%]", valueSymbol):gsub("%[3%]", boost)
			}
			tooltip:AppendElementAfter(element, "StatsPercentageBoost")
		end
	end
end

local function Init()
	Game.Tooltip.RegisterListener("Stat", "Damage", OnDamageStatTooltip)
	Game.Tooltip.RegisterListener("Skill", nil, OnSkillTooltip)
	Game.Tooltip.RegisterListener("Status", nil, OnStatusTooltip)
	Game.Tooltip.RegisterListener("Item", nil, OnItemTooltip)
end
return {
	Init = Init
}