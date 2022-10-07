local _sfont = StringHelpers.StripFont
local iconElementPattern = "(<icon.-/>)"

---@deprecated
local function SplitDescriptionByPattern(str, pattern, includeMatch)
	local list = {};
	local pos = 1
	local lastMatch = ""
	if string.find("", pattern, 1) then
		return list
	end
	while 1 do
		local first,last,a,b = string.find(str, pattern, pos)
		if first then
			local s = string.sub(str, pos, first-1);
			if s ~= "" then
				if includeMatch == true then
					if lastMatch ~= "" then
						s = lastMatch..s
						lastMatch = ""
					elseif a ~= nil then
						s = a..s
					end
				end
				table.insert(list, s)
			elseif a ~= nil then
				lastMatch = a
			end
			pos = last+1
		else
			local s = string.sub(str, pos);
			if s ~= "" then
				if includeMatch == true then
					if lastMatch ~= "" then
						s = lastMatch..s
						lastMatch = ""
					elseif a ~= nil then
						s = a..s
					end
				end
				table.insert(list, s)
			elseif a ~= nil then
				lastMatch = a
			end
			break
		end
		lastMatch = a
	end
	return list
end

---@deprecated
local function GetStringValue(str, pattern)
	local _,_,value = string.find(str, pattern)
	if value == nil then
		value = ""
	end
	return value
end

---@deprecated
local function ParseDescription(this, text, character)
	local icons = {}
	local separatedText = SplitDescriptionByPattern(text,iconElementPattern)
	for v in string.gmatch(text, iconElementPattern) do
		icons[#icons+1] = v
	end
	local result = {}
	for i,v in pairs(separatedText) do
		local icon = icons[i]
		if icon == nil then 
			icon = "" 
		else
			icons[i] = nil
		end
		result[#result+1] = {
			Text = GameHelpers.Tooltip.ReplacePlaceholders(v),
			Icon = icon
		}
	end
	for _,v in pairs(icons) do
		result[#result+1] = {
			Text = "",
			Icon = v
		}
	end

	for i,v in pairs(result) do
		if v.Icon ~= "" then
			local iconId = GetStringValue(v.Icon, "id='(.-)'")
			local iconName = GetStringValue(v.Icon, "icon='(.-)'")
			local iconType = GetStringValue(v.Icon, "type='(.-)'")
			if not StringHelpers.IsNullOrWhitespace(iconId) then
				if string.find(iconId, ";") then
					if StringHelpers.IsNullOrWhitespace(iconName) and iconType ~= "3" then
						local iconNames = {}
						for _,statId in pairs(StringHelpers.Split(iconId, ";")) do
							local stat = Ext.Stats.Get(statId, nil, false)
							local icon = ""
							if stat then
								icon = stat.Icon
							end
							if not StringHelpers.IsNullOrWhitespace(icon) then
								iconNames[#iconNames+1] = icon
							else
								iconNames[#iconNames+1] = "LeaderLib_Placeholder"
							end
						end
						iconName = StringHelpers.Join(";", iconNames)
					end
					this.masteryMenuMC.descriptionList.addIconGroup(iconId, iconName, iconType, false, ";")
				else
					if not StringHelpers.IsNullOrWhitespace(iconType) then
						iconType = tonumber(iconType)
						if iconType == nil then
							iconType = 1
						end
					else
						iconType = 1
					end
					if StringHelpers.IsNullOrWhitespace(iconName) then
						if iconType ~= 3 then
							local stat = Ext.Stats.Get(iconId, nil, false)
							if stat then
								iconName = stat.Icon or ""
							else
								iconName = ""
							end
						else
							iconName = "LLWEAPONEX_UI_PassiveBonus"
						end
					end
					this.masteryMenuMC.descriptionList.addIcon(iconId, iconName, iconType, false)
				end
			end
		end
		this.masteryMenuMC.descriptionList.addText(v.Text, false)
	end
	this.masteryMenuMC.descriptionList.positionElements()
end

local function GetAdditionalMasteryRankText(mastery, rank)
	local parentTable = Mastery.AdditionalRankText[mastery]
	if parentTable ~= nil then
		local rankTable = parentTable[rank]
		if rankTable ~= nil then
			return rankTable
		end
	end
	return nil
end

local _ReplaceColors = {
	[LocalizedText.DamageTypeNames.Physical.Color] = "#756255",
}

local function _FormatFinalText(text, character)
	text = GameHelpers.Tooltip.ReplacePlaceholders(text, character)
	for s,v in pairs(_ReplaceColors) do
		text = StringHelpers.Replace(text, s, v)
	end
	return text
end

---@param bonus MasteryBonusData
---@param character EclCharacter
function MasteryMenu:GetPassiveText(bonus, character)
	local tooltipText = ""
	if not StringHelpers.IsNullOrEmpty(bonus.MasteryMenuSettings.TooltipSkill) then
		tooltipText = _sfont(bonus:GetMenuTooltipText(character, bonus.TooltipSkill, "skill"))
	elseif not StringHelpers.IsNullOrEmpty(bonus.MasteryMenuSettings.TooltipStatus) then
		tooltipText = _sfont(bonus:GetMenuTooltipText(character, bonus.TooltipStatus, "status"))
	else
		if bonus.MasteryMenuSettings.OnlyUseTable ~= "Status" then
			if bonus.Skills and #bonus.Skills > 0 then
				tooltipText = _sfont(bonus:GetMenuTooltipText(character, bonus.Skills[1], "skill"))
			end
		end
		if bonus.MasteryMenuSettings.OnlyUseTable ~= "Skill" then
			if bonus.Statuses and #bonus.Statuses > 0 then
				tooltipText = _sfont(bonus:GetMenuTooltipText(character, bonus.Statuses[1], "status"))
			end
		end
		--Generic passive tooltip
		if tooltipText == "" and not bonus.Skills and not bonus.Statuses and bonus.Tooltip then
			tooltipText = _sfont(bonus:GetMenuTooltipText(character, "", "generic"))
		end
	end
	return _FormatFinalText(tooltipText, character)
end

function MasteryMenu:BuildDescription(this, mastery, character)
	this.masteryMenuMC.descriptionList.clearElements()

	local characterMasteryData = self.Variables.MasteryData

	fassert(characterMasteryData ~= nil and characterMasteryData.Masteries[mastery] ~= nil, "Character MasteryData is nil for mastery %s!\n%s", mastery)

	local data = Masteries[mastery]
	local rank = characterMasteryData.Masteries[mastery].Rank
	if Vars.LeaderDebugMode then
		rank = Mastery.Variables.MaxRank
	end
	local len = Mastery.Variables.MaxRank

	local totalBonuses,totalEnabled,totalDisabled = 0,0,0

	for i=1,len,1 do
		local rankDisplayName = GameHelpers.GetStringKeyText(string.format("LLWEAPONEX_UI_MasteryMenu_Rank%i", i))

		local rankName = data.Ranks[i]
		if type(rankName) == "table" then
			if rankName.Type == "TranslatedString" then
				rankName = rankName.Value
			elseif rankName.Name then
				rankName = rankName.Name.Value
			end
		end

		---@cast rankName +string,-MasteryRankNameData,-table

		local rankHeader = ""
		if not StringHelpers.IsNullOrWhitespace(rankName) then
			rankHeader = string.format("<font size='24' color='#004672'>%s: %s</font>", rankDisplayName, rankName)
		else
			rankHeader = string.format("<font size='24' color='#004672'>%s</font>", rankDisplayName)
		end

		this.masteryMenuMC.descriptionList.addText(rankHeader, false, true)
		
		local rankDescription = ""
		local hasDescription = false

		local masteryRankID = string.format("%s_Mastery%s", mastery, i)
		local bonuses = Mastery.Bonuses[masteryRankID]

		if bonuses then
			if i > rank then
				rankDescription = Text.MasteryMenu.RankLocked.Value
				hasDescription = false
			else
				for _,bonus in ipairs(bonuses) do
					totalBonuses = totalBonuses + 1
					local bonusName = GameHelpers.GetStringKeyText(bonus.ID, "")
					local enabled = bonus:IsEnabled(character)
					this.masteryMenuMC.descriptionList.addBonusHeader(bonus.ID, bonusName, enabled)

					if enabled then
						totalEnabled = totalEnabled + 1
					else
						totalDisabled = totalDisabled + 1
					end

					if bonus.IsPassive then
						local tooltipText = self:GetPassiveText(bonus, character)
						if not StringHelpers.IsNullOrEmpty(tooltipText) then
							local finalText = string.format("%s: %s", Text.MasteryMenu.PassiveDisplayName.Value, tooltipText)
							this.masteryMenuMC.descriptionList.addIcon(bonus.ID, bonus.ID, "LLWEAPONEX_UI_PassiveBonus", self.Params.IconType.Passive, false)
							this.masteryMenuMC.descriptionList.addText(finalText, false)
							hasDescription = true
						end
					else
						local skillBonusText = ""
						local statusBonusText = ""

						local iconNames = {}
						local statIds = {}
						local iconTypes = {}

						local bonusTextSkills = {}
						local bonusTextStatuses = {}

						local usedIcons = {}
						local usedSkillNames = {}
						local usedStatusNames = {}

						local addedSkillText = false
						local addedStatusText = false

						if bonus.MasteryMenuSettings.OnlyUseTable ~= "Status" and bonus.Skills and #bonus.Skills > 0 then
							for _,skillId in ipairs(bonus.Skills) do
								local icon = Data.ActionSkills[skillId]
								if not icon then
									local stat = Ext.Stats.Get(skillId, nil, false)
									if stat and (not stat.IsEnemySkill or not string.find(skillId, "Enemy"))
									and not StringHelpers.IsNullOrEmpty(stat.Icon)
									and stat.Icon ~= "unknown"
									then
										icon = stat.Icon
									end
								end
								if icon and not usedIcons[icon] then
									usedIcons[icon] = true
									iconNames[#iconNames+1] = icon
									statIds[#statIds+1] = skillId
									iconTypes[#iconTypes+1] = self.Params.IconType.Skill
									if StringHelpers.IsNullOrEmpty(skillBonusText) then
										addedSkillText = true
										local tooltipText = _sfont(bonus:GetMenuTooltipText(character, skillId, "skill"))
										skillBonusText = _FormatFinalText(tooltipText, character)
									end
									local skillName = _sfont(GameHelpers.Stats.GetDisplayName(skillId, "SkillData"))
									if skillName and not usedSkillNames[skillName] then
										usedSkillNames[skillName] = true
										bonusTextSkills[#bonusTextSkills+1] = skillName
									end
								end
							end
						elseif bonus.AllSkills then
							--TODO
						end
						if #bonusTextSkills > 0 then
							skillBonusText = StringHelpers.Join("/", bonusTextSkills, true) .. ": " .. skillBonusText
						end
						if bonus.MasteryMenuSettings.OnlyUseTable ~= "Skill" and bonus.Statuses and #bonus.Statuses > 0 then
							for _,statusId in ipairs(bonus.Statuses) do
								local icon = nil

								if not Data.EngineStatus[statusId] then
									local stat = Ext.Stats.Get(statusId, nil, false)
									if stat and not StringHelpers.IsNullOrEmpty(stat.Icon) and stat.Icon ~= "unknown" and not usedIcons[stat.Icon] then
										icon = stat.Icon
										usedIcons[stat.Icon] = true
										iconNames[#iconNames+1] = stat.Icon
										statIds[#statIds+1] = statusId
										iconTypes[#iconTypes+1] = self.Params.IconType.Status

										local isDefaultTooltip = bonus.StatusTooltip == nil

										if not addedStatusText and (not isDefaultTooltip or not addedSkillText) then
											local tooltipText = _FormatFinalText(_sfont(bonus:GetMenuTooltipText(character, statusId, "status")), character)
											--Skip this if it's the same text already
											if not string.find(skillBonusText, tooltipText) then
												statusBonusText = tooltipText
												addedStatusText = true
											end
										end
									end
								else
									local engineIcon = Data.EngineStatusIcons[statusId]
									if engineIcon then
										icon = engineIcon
										usedIcons[engineIcon] = true
										iconNames[#iconNames+1] = engineIcon
										statIds[#statIds+1] = statusId
										iconTypes[#iconTypes+1] = self.Params.IconType.Status
	
										if not addedStatusText and (bonus.StatusTooltip == nil or bonus.StatusTooltip ~= bonus.Tooltip) then
											local tooltipText = _FormatFinalText(_sfont(bonus:GetMenuTooltipText(character, statusId, "status")), character)
											if not string.find(skillBonusText, tooltipText) then
												statusBonusText = tooltipText
												addedStatusText = true
											end
										end
									end
								end
								if icon ~= nil then
									local statusName = GameHelpers.Stats.GetDisplayName(statusId, "StatusData")
									if not StringHelpers.IsNullOrEmpty(statusName) then
										statusName = _sfont(statusName)
										if statusName and not usedStatusNames[statusName] then
											usedStatusNames[statusName] = true
											if usedSkillNames[statusName] then
												statusName = string.format("%s (%s)", statusName, GameHelpers.GetTranslatedString("hecdd4f2fga4beg4db6g8ae0gb0c77d38b6ee", "Status"))
											end
											bonusTextStatuses[#bonusTextStatuses+1] = statusName
										end
									end
								end
							end
						end
						if addedStatusText and #bonusTextStatuses > 0 then
							statusBonusText = StringHelpers.Join("/", bonusTextStatuses, true) .. ": " .. statusBonusText
						end
						local iconLen = #iconNames
						if iconLen > 1 then
							local allIds = StringHelpers.Join(";", statIds)
							local allIcons = StringHelpers.Join(";", iconNames)
							local allTypes = StringHelpers.Join(";", iconTypes)
							this.masteryMenuMC.descriptionList.addIconGroup(bonus.ID, allIds, allIcons, allTypes, false, ";")
						elseif iconLen == 1 then
							this.masteryMenuMC.descriptionList.addIcon(bonus.ID, statIds[1], iconNames[1], iconTypes[1], false)
						end
						if addedStatusText and not StringHelpers.IsNullOrEmpty(statusBonusText) then
							statusBonusText = "<br>" .. statusBonusText
						end
						local finalText = skillBonusText .. statusBonusText
						if not StringHelpers.IsNullOrEmpty(finalText) then
							this.masteryMenuMC.descriptionList.addText(finalText, false)
							hasDescription = true
						end
					end
				end
			end
		end

		if not hasDescription then
			if StringHelpers.IsNullOrWhitespace(rankDescription) then
				rankDescription = Text.MasteryMenu.RankPlaceholder.Value
				hasDescription = false
			elseif i > rank then
				rankDescription = Text.MasteryMenu.RankLocked.Value
				hasDescription = false
			end
			rankDescription = _FormatFinalText(rankDescription, character)
			this.masteryMenuMC.descriptionList.addText(rankDescription, false)
		else
			-- local rankDescriptionKey_deprecated = GameHelpers.GetStringKeyText(string.format("%s_Rank%i_Description", mastery, i), "")
			-- if not StringHelpers.IsNullOrEmpty(rankDescriptionKey_deprecated) then
			-- 	local extraTextTable = GetAdditionalMasteryRankText(mastery, i)
			-- 	if extraTextTable ~= nil then
			-- 		for stringKey,enabled in pairs(extraTextTable) do
			-- 			if enabled ~= false then
			-- 				local text = GameHelpers.GetStringKeyText(stringKey, "")
			-- 				if not StringHelpers.IsNullOrEmpty(stringKey) then
			-- 					rankDescription = rankDescription .. "<br>" .. text
			-- 				end
			-- 			end
			-- 		end
			-- 	end
	
			-- 	ParseDescription(this, rankDescription, character)
			-- end
		end
	end
	this.masteryMenuMC.descriptionList.sendDescriptionUpdateEvent(totalBonuses, totalEnabled, totalDisabled)
end