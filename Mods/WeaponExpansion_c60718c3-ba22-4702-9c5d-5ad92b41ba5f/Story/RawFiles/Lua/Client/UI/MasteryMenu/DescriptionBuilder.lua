local iconElementPattern = "(<icon.-/>)"

local function ParseDescription(this, text)
	local iconElements = StringHelpers.Split(text, iconElementPattern)
	if #iconElements > 0 then
		for _,str in ipairs(iconElements) do
			local _,_,iconId = string.find(str, "id='(.-)'")
			local _,_,iconName = string.find(str, "icon='(.-)'")
			local _,_,iconType = string.find(str, "type='(.-)'")
			if not StringHelpers.IsNullOrWhitespace(iconId) then
				if string.find(iconId, ";") then
					this.masteryMenuMC.descriptionList.addIconGroup(iconId, iconName, iconType, false, ";")
				else
					if not StringHelpers.IsNullOrWhitespace(iconType) then
						iconType = tonumber(iconType)
						if iconType == nil then
							iconType = 1
						end
					end
					iconName = iconName or ""
					this.masteryMenuMC.descriptionList.addIcon(iconId, iconName, iconType, false)
				end
			else
				this.masteryMenuMC.descriptionList.addText(str, false)
			end
		end
	else
		this.masteryMenuMC.descriptionList.addText(text, false)
	end
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

function MasteryMenu:BuildDescription(mastery)
	local this = self.Root

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

			ParseDescription(this, rankDescription)
		else
			this.masteryMenuMC.descriptionList.addText(rankDescription, false)
		end
	end
end