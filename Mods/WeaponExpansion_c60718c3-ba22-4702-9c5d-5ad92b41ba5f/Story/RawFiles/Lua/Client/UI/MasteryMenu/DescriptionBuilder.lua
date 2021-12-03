local iconElementPattern = "(<icon.-/>)"

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

local function GetStringValue(str, pattern)
	local _,_,value = string.find(str, pattern)
	if value == nil then
		value = ""
	end
	return value
end

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
						for _,v in pairs(StringHelpers.Split(iconId, ";")) do
							local icon = Ext.StatGetAttribute(v, "Icon")
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
							iconName = Ext.StatGetAttribute(iconId, "Icon") or ""
						else
							iconName = "LLWEAPONEX_UI_PassiveBonus"
						end
					end
					print(iconId, iconName, iconType)
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

function MasteryMenu:BuildDescription(this, mastery, character)
	this.masteryMenuMC.descriptionList.clearElements()

	local characterMasteryData = self.Variables.MasteryData

	fassert(characterMasteryData ~= nil and characterMasteryData.Masteries[mastery] ~= nil, "Character MasteryData is nil for mastery %s!\n%s", mastery)

	local data = Masteries[mastery]
	local rank = characterMasteryData.Masteries[mastery].Rank
	if Vars.LeaderDebugMode then
		rank = Mastery.Variables.MaxRank
	end

	for i=1,Mastery.Variables.MaxRank,1 do
		local rankDisplayName = GameHelpers.GetStringKeyText(string.format("LLWEAPONEX_UI_MasteryMenu_Rank%i", i))

		local rankName = data.Ranks[i]
		if type(rankName) == "table" then
			if rankName.Type == "TranslatedString" then
				rankName = rankName.Value
			elseif rankName.Name then
				rankName = rankName.Name.Value
			end
		end

		local rankHeader = ""
		if not StringHelpers.IsNullOrWhitespace(rankName) then
			rankHeader = string.format("<font size='24'>%s: %s</font>", rankDisplayName, rankName)
		else
			rankHeader = string.format("<font size='24'>%s</font>", rankDisplayName)
		end

		this.masteryMenuMC.descriptionList.addText(rankHeader, false)

		local rankDescription = GameHelpers.GetStringKeyText(string.format("%s_Rank%i_Description", mastery, i))

		local hasDescription = true
		if StringHelpers.IsNullOrWhitespace(rankDescription) then
			rankDescription = Text.MasteryMenu.RankPlaceholder.Value
			hasDescription = false
		elseif i > rank then
			rankDescription = Text.MasteryMenu.RankLocked.Value
			hasDescription = false
		end

		if hasDescription then
			local extraTextTable = GetAdditionalMasteryRankText(mastery, i)
			if extraTextTable ~= nil then
				for stringKey,enabled in pairs(extraTextTable) do
					if enabled ~= false then
						local text = GameHelpers.GetStringKeyText(stringKey, "")
						if not StringHelpers.IsNullOrEmpty(stringKey) then
							rankDescription = rankDescription .. "<br>" .. text
						end
					end
				end
			end

			ParseDescription(this, rankDescription, character)
		else
			rankDescription = GameHelpers.Tooltip.ReplacePlaceholders(rankDescription, character)
			this.masteryMenuMC.descriptionList.addText(rankDescription, false)
		end
	end
end