---@class UniqueProgressionEntry
local UniqueProgressionEntry = {
	Type = "UniqueProgressionEntry",
	Attribute = "",
	Value = "",
	IsBoost = true,
	MatchStat = "",
	MatchTemplate = "",
	GetAttribute = nil
}
UniqueProgressionEntry.__index = UniqueProgressionEntry

local Qualifiers = {
	StrengthBoost = true,
	FinesseBoost = true,
	IntelligenceBoost = true,
	ConstitutionBoost = true,
	MemoryBoost = true,
	WitsBoost = true,
	MagicPointsBoost = true,
}

---@param attribute string
---@param value integer|string|any
---@param append boolean
---@return UniqueProgressionEntry
function UniqueProgressionEntry:Create(attribute, value, params)
    local this =
    {
		Attribute = attribute,
		Value = value,
		IsBoost = true
	}
	if Qualifiers[attribute] == true then
		this.Value = tostring(value)
	end
	if params ~= nil and type(params) == "table" then
		for k,v in pairs(params) do
			this[k] = v
		end
	end
	setmetatable(this, self)
	return this
end

---@param stat StatEntryWeapon|StatEntryArmor
function UniqueProgressionEntry:GetBoostAttribute(stat)
	if self.GetAttribute ~= nil then
		local b,val = pcall(self.GetAttribute, stat, self.Attribute)
		if b and val ~= nil then
			return val
		end
	end
	return self.Attribute
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