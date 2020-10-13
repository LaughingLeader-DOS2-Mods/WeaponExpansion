---@class UniqueProgressionEntry
local UniqueProgressionEntry = {
	Type = "UniqueProgressionEntry",
	Attribute = "",
	Value = "",
	Append = false,
	MatchStat = "",
	MatchTemplate = "",
}
UniqueProgressionEntry.__index = UniqueProgressionEntry

---@param attribute string
---@param value integer|string|any
---@param append boolean
---@return UniqueProgressionEntry
function UniqueProgressionEntry:Create(attribute, value, params)
    local this =
    {
		Attribute = attribute,
		Value = value,
		Append = false
	}
	if params ~= nil and type(params) == "table" then
		for k,v in pairs(params) do
			this[k] = v
		end
	end
	setmetatable(this, self)
	return this
end

---@class UniqueProgressionTransform
local UniqueProgressionTransform = {
	Type = "UniqueProgressionTransform",
	Template = "",
	Stat = "",
	MatchStat = "",
	MatchTemplate = "",
}
UniqueProgressionTransform.__index = UniqueProgressionTransform

---@param template string
---@param stat string
---@return UniqueProgressionTransform
function UniqueProgressionTransform:Create(template, stat, params)
    local this =
    {
		Template = template or "",
		Stat = stat or ""
	}
	if params ~= nil and type(params) == "table" then
		for k,v in pairs(params) do
			this[k] = v
		end
	end
	setmetatable(this, self)
	return this
end

return {
	UniqueProgressionEntry = UniqueProgressionEntry,
	UniqueProgressionTransform = UniqueProgressionTransform
}