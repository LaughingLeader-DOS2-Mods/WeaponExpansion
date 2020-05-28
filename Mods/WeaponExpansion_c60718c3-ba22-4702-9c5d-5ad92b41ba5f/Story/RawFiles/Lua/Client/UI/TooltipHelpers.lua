if Tooltip == nil then Tooltip = {} end

---Replace placeholder text in strings.
---@param str string
---@return string
local function ReplacePlaceholders(str)
	local output = str
	for v in string.gmatch(output, "%[ExtraData.-%]") do
		local key = v:gsub("%[ExtraData:", ""):gsub("%]", "")
		local value = GameHelpers.GetExtraData(key, "")
		if value ~= "" and type(value) == "number" then
			value = string.format("%i", value)
		end
		-- The parameter brackets will be considered for pattern matching unless we escape them with a percentage sign.
		local escapedReplace = v:gsub("%[", "%%["):gsub("%]", "%%]")
		output = string.gsub(output, escapedReplace, value)
	end
	for v in string.gmatch(output, "%[Stats:.-%]") do
		local value = ""
		local statFetcher = v:gsub("%[Stats:", ""):gsub("%]", "")
		local props = LeaderLib.StringHelpers.Split(statFetcher, ":")
		local stat = props[1]
		local property = props[2]
		if stat ~= nil and property ~= nil then
			value = Ext.StatGetAttribute(stat, property)
		end
		if value ~= nil and value ~= "" then
			if type(value) == "number" then
				value = string.format("%i", value)
			end
		else
			value = ""
		end
		-- The parameter brackets will be considered for pattern matching unless we escape them with a percentage sign.
		local escapedReplace = v:gsub("%[", "%%["):gsub("%]", "%%]")
		output = string.gsub(output, escapedReplace, value)
	end
	for v in string.gmatch(output, "%[SkillDamage:.-%]") do
		local value = ""
		local skillName = v:gsub("%[SkillDamage:", ""):gsub("%]", "")
		if skillName ~= nil and skillName ~= "" then
			local props = LeaderLib.StringHelpers.Split(skillName, ":")
			local param = "Damage"
			if props ~= nil and #props >= 1 then
				skillName = props[1]
				if props[2] ~= nil then
					param = props[2]
				end
			end
			local skill = Skills.CreateSkillTable(skillName)
			if skill ~= nil then
				if CLIENT_UI.ACTIVE_CHARACTER ~= nil then
					local character = Ext.GetCharacter(CLIENT_UI.ACTIVE_CHARACTER).Stats
					local paramText = SkillGetDescriptionParam(skill, character, false, param)
					if paramText == nil and param == "Damage" then
						local damageRange = Game.Math.GetSkillDamageRange(character, skill)
						value = LeaderLib.UI.Tooltip.FormatDamageRange(damageRange)
					else
						value = paramText
					end
				else
					Ext.PrintError("[WeaponExpansion:TooltipHelpers.lua] CLIENT_UI.ACTIVE_CHARACTER is nil!")
				end
			end
		end
		if value ~= nil and value ~= "" then
			if type(value) == "number" then
				value = string.format("%i", value)
			end
		else
			value = ""
		end
		local escapedReplace = v:gsub("%[", "%%["):gsub("%]", "%%]")
		output = string.gsub(output, escapedReplace, value)
	end
	for v in string.gmatch(output, "%[Key:.-%]") do
		local key = v:gsub("%[Key:", ""):gsub("%]", "")
		local translatedText = Ext.GetTranslatedStringFromKey(key)
		if translatedText == nil then translatedText = "" end
		-- The parameter brackets will be considered for pattern matching unless we escape them with a percentage sign.
		local escapedReplace = v:gsub("%[", "%%["):gsub("%]", "%%]")
		output = string.gsub(output, escapedReplace, translatedText)
	end
	for v in string.gmatch(output, "%[Handle:.-%]") do
		local text = v:gsub("%[Handle:", ""):gsub("%]", "")
		local props = LeaderLib.StringHelpers.Split(text, ":")
		if props[2] == nil then 
			props[2] = ""
		end
		local translatedText = Ext.GetTranslatedString(props[1], props[2])
		if translatedText == nil then 
			translatedText = "" 
		end
		-- The parameter brackets will be considered for pattern matching unless we escape them with a percentage sign.
		local escapedReplace = v:gsub("%[", "%%["):gsub("%]", "%%]")
		output = string.gsub(output, escapedReplace, translatedText)
	end
	return output
end

Tooltip.ReplacePlaceholders = ReplacePlaceholders