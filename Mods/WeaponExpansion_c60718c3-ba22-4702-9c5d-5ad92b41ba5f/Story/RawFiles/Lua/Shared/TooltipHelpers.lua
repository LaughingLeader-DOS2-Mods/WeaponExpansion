if Tooltip == nil then Tooltip = {} end

---Replace placeholder text in strings.
---@param str string
---@return string
local function ReplacePlaceholders(str)
	local output = str
	for v in string.gmatch(output, "%[ExtraData.-%]") do
		local key = v:gsub("%[ExtraData:", ""):gsub("%]", "")
		local value = LeaderLib.Game.GetExtraData(key, "")
		if value ~= "" then
			value = string.format("%i", value)
		end
		-- The parameter brackets will be considered for pattern matching unless we escape them with a percentage sign.
		local escapedReplace = v:gsub("%[", "%%["):gsub("%]", "%%]")
		output = string.gsub(output, escapedReplace, value)
	end
	for v in string.gmatch(output, "%[Stats:.-%]") do
		local value = ""
		local statFetcher = v:gsub("%[Stats:", ""):gsub("%]", "")
		local props = LeaderLib.Common.StringSplit(":", statFetcher)
		local stat = props[1]
		local property = props[2]
		if stat ~= nil and property ~= nil then
			value = Ext.StatGetAttribute(stat, property)
		end
		if value ~= "" then
			if type(value) == "number" then
				value = string.format("%i", value)
			end
		end
		-- The parameter brackets will be considered for pattern matching unless we escape them with a percentage sign.
		local escapedReplace = v:gsub("%[", "%%["):gsub("%]", "%%]")
		output = string.gsub(output, escapedReplace, value)
	end
	for v in string.gmatch(output, "%[Key.-%]") do
		local key = v:gsub("%[Key:", ""):gsub("%]", "")
		local translatedText = Ext.GetTranslatedStringFromKey(key)
		if translatedText == nil then translatedText = "" end
		-- The parameter brackets will be considered for pattern matching unless we escape them with a percentage sign.
		local escapedReplace = v:gsub("%[", "%%["):gsub("%]", "%%]")
		output = string.gsub(output, escapedReplace, translatedText)
	end
	return output
end

Tooltip.ReplacePlaceholders = ReplacePlaceholders