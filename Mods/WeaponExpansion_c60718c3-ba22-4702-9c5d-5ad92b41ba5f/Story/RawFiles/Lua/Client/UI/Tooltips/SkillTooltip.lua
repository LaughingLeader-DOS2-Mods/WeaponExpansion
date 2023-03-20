---@type TranslatedString
local ts = Classes.TranslatedString

---@type table<string,fun(character:EsvCharacter):string>
local AlternativeScaling = {
	---@param character EsvCharacter
	Target_LLWEAPONEX_Steal = function(character)
		return Text.SkillScaling.AttributeAndAbility:ReplacePlaceholders(LocalizedText.AbilityNames.RogueLore.Value, LocalizedText.AttributeNames[Skills.GetHighestAttribute(character.Stats, AttributeScaleTables.NoMemory)].Value)
	end
}

---@type table<string, TranslatedString>
local AbilitySchool = {
	Target_LLWEAPONEX_Steal = Text.NewAbilitySchools.Pirate,
	Shout_LLWEAPONEX_OpenMenu = Text.Game.WeaponExpansion,
}

local darkFireballEmptyLevelText = ts:Create("h83e65b1fg30c2g4e9ega9bag005eb17c5d75", "<font color='#FF2200'>[1]/[2] Death Charges</font>")
local darkFireballLevelText = ts:Create("h67e6fbecg1cafg4202ga78ag45db47880450", "<font color='#AA00FF'>[1]/[2] Death Charges</font>")
local heavyBoltText = ts:Create("hb931f729g9df1g461bg887fgb7eae7662e12", "Heavy Bolt (+AP Cost)")

local AppendedText = {
	---@param character EsvCharacter
	Projectile_LLWEAPONEX_DarkFireball = function(character)
		if PersistentVars ~= nil and PersistentVars.SkillData ~= nil and PersistentVars.SkillData.DarkFireballCount ~= nil then
			local count = PersistentVars.SkillData.DarkFireballCount[character.NetID] or 0
			local max = GameHelpers.GetExtraData("LLWEAPONEX_DarkFireball_MaxKillCount", 10)
			if count > 0 then
				return darkFireballLevelText:ReplacePlaceholders(count, max)
			else
				return darkFireballEmptyLevelText:ReplacePlaceholders(count, max)
			end
		end
	end,
}

---@param checkText string
---@param character EclCharacter
---@param element table
---@param func fun(character:EclCharacter):string
local function ReplaceScalingText(checkText, character, element, func)
	local _,_,replaceText = string.find(element.Label, checkText)
	if replaceText ~= nil then
		local newText = func(character)
		if newText ~= nil then
			element.Label = string.gsub(element.Label, replaceText, newText)
			return true
		end
	end
	return false
end

Config.Skill.DisplayScalingStatSkills = {
	Projectile_LLWEAPONEX_Pistol_Shoot = true,
	Projectile_LLWEAPONEX_Pistol_Shoot_Enemy = true,
	Projectile_LLWEAPONEX_HandCrossbow_Shoot = true,
	Projectile_LLWEAPONEX_HandCrossbow_Shoot_Enemy = true,
}

---@param character EclCharacter
---@param skill string
---@param tooltip TooltipData
local function OnSkillTooltip(character, skill, tooltip)
	local skillRequirements = tooltip:GetElements("SkillRequiredEquipment")

	--print(skill, Ext.JsonStringify(tooltip.Data))
	local descriptionElement = tooltip:GetElement("SkillDescription") or {Type="SkillDescription", Label = ""}
	if skill == "Target_LLWEAPONEX_RemoteMine_Detonate" then
		if GetSettings().Global:FlagEquals("LLWEAPONEX_RemoteChargeDetonationCountDisabled", true) then
			descriptionElement.Label = Text.SkillTooltip.RemoteMineNoRestrictionDescription:ReplacePlaceholders(GameHelpers.Stats.GetAttribute("Target_LLWEAPONEX_RemoteMine_Detonate", "TargetRadius", 1))
		end
	end

	local skillPropsElement = tooltip:GetElement("SkillProperties", {Properties={}, Resistances={}})

	if character then
		local getAltScalingText = AlternativeScaling[skill]
		if getAltScalingText ~= nil then
			for i,prop in pairs(skillPropsElement.Properties) do
				for key,text in pairs(Text.DefaultSkillScaling) do
					local checkText = text.Value:gsub("%[1%]", "(%%w+)")
					local b,r = pcall(ReplaceScalingText, checkText, character, prop, getAltScalingText)
					if b and r then
						break
					end
				end
			end
		end
	end
	
	if AbilitySchool[skill] ~= nil then
		local element = tooltip:GetElement("SkillSchool")
		if element ~= nil then
			element.Label = AbilitySchool[skill].Value
		end
	end

	if AppendedText[skill] ~= nil then
		local b,text,appendToSkillProperties = xpcall(AppendedText[skill], debug.traceback, character, skill)
		if b then
			if text ~= nil then
				if appendToSkillProperties == true then
					table.insert(skillPropsElement.Properties, {
						Label = text
					})
				else
					if not StringHelpers.IsNullOrWhitespace(descriptionElement.Label) then
						descriptionElement.Label = string.format("%s<br>%s", descriptionElement.Label, text)
					else
						descriptionElement.Label = text
					end
				end
			end
		else
			Ext.Utils.PrintError(text)
		end
	end

	local characterTags = GameHelpers.GetAllTags(character, true, true)

	for tag,callback in pairs(Tags.SkillBonusText) do
		if characterTags[tag] then
			local b,text,appendToSkillProperties = xpcall(callback, debug.traceback, character, skill, tag, tooltip)
			if b then
				if text ~= nil then
					text = GameHelpers.Tooltip.ReplacePlaceholders(text, character)
					if appendToSkillProperties == true then
						table.insert(skillPropsElement.Properties, {
							Label = text
						})
					else
						if not StringHelpers.IsNullOrWhitespace(descriptionElement.Label) then
							descriptionElement.Label = string.format("%s<br>%s", descriptionElement.Label, text)
						else
							descriptionElement.Label = text
						end
					end
				end
			else
				Ext.Utils.PrintError(text)
			end
		end
	end

	-- These lines alter the "Incompatible with" text that's a result of using an inverse condition tag.
	-- We want these skills to work unless the tags are set.
	if Skills.WarfareMeleeSkills[skill] == true then
		local requirementName = Text.Game.MeleeWeaponRequirement.Value
		for i,element in pairs(skillRequirements) do
			if element.RequirementMet == false then
				if element.Label == Text.Game.NotImmobileRequirement.Value then
					tooltip:RemoveElement(element)
				elseif string.find(element.Label, requirementName) then
					element.Label = StringHelpers.Trim(Text.Game.RequiresTag:ReplacePlaceholders("", requirementName))
				end
			end
		end
	elseif Skills.ScoundrelMeleeSkills[skill] == true then
		tooltip:MarkDirty()
		for i,element in pairs(skillRequirements) do
			if string.find(element.Label, Text.Game.MeleeWeaponRequirement.Value) then
				if tooltip:IsExpanded() then
					if Mastery.HasMasteryRequirement(character, "LLWEAPONEX_Axe_Mastery4") then
						element.Label = StringHelpers.Trim(Text.Game.RequiresTag:ReplacePlaceholders("", Text.Game.ScoundrelWeaponRequirementExpandedAxe.Value))
					else
						element.Label = StringHelpers.Trim(Text.Game.RequiresTag:ReplacePlaceholders("", Text.Game.ScoundrelWeaponRequirementExpanded.Value))
					end
				else
					element.Label = StringHelpers.Trim(Text.Game.RequiresTag:ReplacePlaceholders("", Text.Game.ScoundrelWeaponRequirement.Value))
				end
			elseif not element.RequirementMet and element.Label == Text.Game.NotImmobileRequirement.Value then
				tooltip:RemoveElement(element)
			end
		end
	end

	if not GameHelpers.Skill.IsAction(skill) then
		local customRequirements = {
			Total = 0,
			---@type table<string,StatsRequirement>
			MasteryRank = {},
			---@type table<string,StatsRequirement>
			WeaponType = {},
		}

		local propElements = {}
		local hasRuneProps = false
		local stat = Ext.Stats.Get(skill, nil, false) --[[@as StatEntrySkillData]]
		if stat then
			local requirements = GameHelpers.Stats.GetAttribute(skill, "Requirements", nil, true) --[=[@as StatsRequirement[]]=]
			local memorizationRequirements = GameHelpers.Stats.GetAttribute(skill, "MemorizationRequirements", nil, true) --[=[@as StatsRequirement[]]=]
			if requirements then
				for _,v in pairs(requirements) do
					if v.Requirement == "LLWEAPONEX_MasteryRank" then
						customRequirements.MasteryRank[v.Tag] = v
						customRequirements.Total = customRequirements.Total + 1
					elseif v.Requirement == "LLWEAPONEX_WeaponType" then
						customRequirements.WeaponType[v.Tag] = v
						customRequirements.Total = customRequirements.Total + 1
					end
				end
			end
			if memorizationRequirements then
				for _,v in pairs(memorizationRequirements) do
					if v.Requirement == "LLWEAPONEX_MasteryRank" then
						customRequirements.MasteryRank[v.Tag] = v
						customRequirements.Total = customRequirements.Total + 1
					elseif v.Requirement == "LLWEAPONEX_WeaponType" then
						customRequirements.WeaponType[v.Tag] = v
						customRequirements.Total = customRequirements.Total + 1
					end
				end
			end
			if stat.SkillProperties then
				for i,v in pairs(stat.SkillProperties) do
					if v.Action == "LLWEAPONEX_ApplyBulletProperties" then
						local rune,weaponBoostStat = Skills.GetPistolRuneBoost(character.Stats)
						if weaponBoostStat ~= nil then
							---@type StatProperty[]
							local props = Ext.Stats.Get(weaponBoostStat).ExtraProperties
							if props ~= nil then
								hasRuneProps = true
								for i,v in pairs(props) do
									if v.Type == "Status" then
										local name = GameHelpers.Stats.GetDisplayName(v.Action, "StatusData")
										if not StringHelpers.IsNullOrWhitespace(name) then
											local chance = math.min(100, math.ceil(v.StatusChance * 100))
											local turns = v.Duration
											local text = ""
											local chanceText = ""
											if chance > 0 then
												chanceText = LocalizedText.Tooltip.ChanceToSucceed:ReplacePlaceholders(chance)
											end
											if turns > 0 then
												turns = math.ceil(v.Duration / 6.0)
												text = LocalizedText.Tooltip.ExtraPropertiesWithTurns:ReplacePlaceholders(name, "", chanceText, turns)
											else
												text = LocalizedText.Tooltip.ExtraPropertiesPermanent:ReplacePlaceholders(name, "", chanceText)
											end
											table.insert(propElements, {
												Warning="",
												Label=text
											})
										end
									end
								end
							end
						end
					elseif v.Action == "LLWEAPONEX_ApplyBoltProperties" then
						local rune,weaponBoostStat = Skills.GetHandCrossbowRuneBoost(character.Stats)
						if weaponBoostStat ~= nil then
							local weaponBoost = Ext.Stats.Get(weaponBoostStat, nil, false)
							---@type StatProperty[]
							local props = weaponBoost.ExtraProperties
							if props then
								hasRuneProps = true
								for i,v in pairs(props) do
									if v.Type == "Status" then
										local name = GameHelpers.Stats.GetDisplayName(v.Action, "StatusData")
										if not StringHelpers.IsNullOrWhitespace(name) then
											local chance = math.min(100, math.ceil(v.StatusChance * 100))
											local turns = v.Duration
											local text = ""
											local chanceText = ""
											if chance > 0 then
												chanceText = LocalizedText.Tooltip.ChanceToSucceed:ReplacePlaceholders(chance)
											end
											if turns > 0 then
												turns = math.ceil(v.Duration / 6.0)
												text = LocalizedText.Tooltip.ExtraPropertiesWithTurns:ReplacePlaceholders(name, "", chanceText, turns)
											else
												text = LocalizedText.Tooltip.ExtraPropertiesPermanent:ReplacePlaceholders(name, "", chanceText)
											end
											table.insert(propElements, {
												Warning="",
												Label=text
											})
										end
									end
								end
							end
							local isHeavyBolt = string.find(weaponBoost.Tags, "LLWEAPONEX_HeavyAmmo")
							if isHeavyBolt then
								table.insert(propElements, {
									Label=heavyBoltText.Value,
									Warning=""
								})
								hasRuneProps = true
							end
						end
					end
				end
			end
			if hasRuneProps then
				for i,v in pairs(propElements) do
					skillPropsElement.Properties[#skillPropsElement.Properties+1] = v
				end
			end
		end

		if customRequirements.Total > 0 then
			---@type SkillRequiredEquipment[]
			local reworkedRequirements = {}
			local hasCustomWeaponType = false
			for _,element in ipairs(skillRequirements) do
				local _,_,rankNum = string.find(element.Label, "LLWEAPONEX_Requirement_MasteryRank%s+(%d+)")
				if rankNum then
					rankNum = tonumber(rankNum)
					for mastery,v in pairs(customRequirements.MasteryRank) do
						if v.Param == rankNum and Masteries[mastery] then
							local masteryName = Masteries[mastery].Name.Value
							element.Label = Text.SkillTooltip.MasteryRankRequirement:ReplacePlaceholders(masteryName, v.Param)
							reworkedRequirements[#reworkedRequirements+1] = element
							element.Sort = 9999
						end
					end
				else
					local _,_,weaponName = string.find(element.Label, "LLWEAPONEX_Requirement_WeaponType%s+(.+)")
					if weaponName then
						for mastery,v in pairs(customRequirements.WeaponType) do
							if Masteries[mastery] then
								reworkedRequirements[#reworkedRequirements+1] = {Type="SkillRequiredEquipment", RequirementMet=element.RequirementMet, Label = LocalizedText.SkillTooltip.SkillRequiredEquipment:ReplacePlaceholders(Masteries[mastery].Name.Value)}
								hasCustomWeaponType = true
							end
						end
					else
						reworkedRequirements[#reworkedRequirements+1] = element
					end
				end
				--Requirement is met, so it isn't added to the tooltip since Param is -1
				if not hasCustomWeaponType then
					for mastery,v in pairs(customRequirements.WeaponType) do
						if Masteries[mastery] then
							reworkedRequirements[#reworkedRequirements+1] = {Type="SkillRequiredEquipment", RequirementMet=true, Label = LocalizedText.SkillTooltip.SkillRequiredEquipment:ReplacePlaceholders(Masteries[mastery].Name.Value)}
							hasCustomWeaponType = true
						end
					end
				end
			end
			if hasCustomWeaponType then
				for i,v in pairs(reworkedRequirements) do
					for id,tstring in pairs(LocalizedText.SkillRequirement) do
						if string.find(v.Label, tstring.Value) then
							table.remove(reworkedRequirements, i)
							break
						end
					end
				end
			end
			table.sort(reworkedRequirements, function(a,b) local s1 = a.Sort or 0; local s2 = b.Sort or 0; return s1 < s2 end)
			tooltip:RemoveElements("SkillRequiredEquipment")
			tooltip:AppendElements(reworkedRequirements)
			skillRequirements = reworkedRequirements
		end
	end

	if string.find(skill, "Banner") then
		local staffText = LocalizedText.WeaponType.Staff.Value
		local staffTextCompare = string.lower(staffText)
		for _,element in pairs(skillRequirements) do
			if string.find(element.Label:lower(), staffTextCompare) then
				element.Label = string.gsub(element.Label, staffText, Text.WeaponType.Banner.Value):gsub(staffTextCompare, Text.WeaponType.Banner.Value:lower())
			end
		end
	end

	local bonusText = nil

	if MasteryMenu.ActiveTooltipBonus then
		local bonus = MasteryBonusManager.GetBonusByID(MasteryMenu.ActiveTooltipBonus)
		if bonus then
			bonusText = ""
			local rankTag = string.format("%s_Mastery%s", bonus.Mastery, bonus.Rank)
			local rankName = GameHelpers.GetStringKeyText(rankTag, "")
			if not StringHelpers.IsNullOrEmpty(rankName) then
				bonusText = rankName .. "<br>"
			end
			local tooltipText = GameHelpers.Tooltip.ReplacePlaceholders(bonus:GetMenuTooltipText(character, skill, "skill", tooltip.IsFromItem == true), character)
			if not StringHelpers.IsNullOrEmpty(tooltipText) then
				bonusText = bonusText .. tooltipText
			end
		end
	else
		bonusText = MasteryBonusManager.GetBonusText(character, skill, "skill", tooltip.IsFromItem == true)
	end

	if not StringHelpers.IsNullOrEmpty(bonusText) then
		---@cast bonusText string
		if not StringHelpers.IsNullOrWhitespace(descriptionElement.Label) then
			descriptionElement.Label = descriptionElement.Label .. "<br>"
		end
		descriptionElement.Label = descriptionElement.Label .. bonusText
	end

	if Mastery.Experience.HasMinimumLevel(character, MasteryID.Crossbow, 1)
	and characterTags["LLWEAPONEX_Crossbow_Equipped"]
	and MasteryBonusManager.Vars.IsStillStanceSkill(skill) then
		local bonus = MasteryBonusManager.Vars.GetStillStanceBonus(character)
		if bonus > 0 then
			local rankName = StringHelpers.StripFont(GameHelpers.GetStringKeyText(Masteries.LLWEAPONEX_Crossbow.RankBonuses[1].Tag, "Crossbow I"))
			table.insert(skillPropsElement.Properties, {
				Label = Text.SkillTooltip.StillStance:ReplacePlaceholders(string.format("+%s", bonus), rankName),
				Warning = ""
			})
		end
	end

	if characterTags["LLWEAPONEX_Firearm_Equipped"] and not StringHelpers.IsNullOrEmpty(descriptionElement.Label) then
		descriptionElement.Label = descriptionElement.Label:gsub("arrow", "bullet"):gsub("Arrow", "Bullet")
	end

	if Config.Skill.DisplayScalingStatSkills[skill] then
		local text = Skills.Params.LLWEAPONEX_ScalingStat(skill, character.Stats)
		if not StringHelpers.IsNullOrEmpty(text) then
			skillPropsElement.Properties[#skillPropsElement.Properties+1] = {Label = text, Warning = ""}
		end
	end
end

return OnSkillTooltip