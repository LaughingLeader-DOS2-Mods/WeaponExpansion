local TranslatedString = LeaderLib.Classes["TranslatedString"]

---@class MasteryData
local MasteryData = {
	ID = "",
	---@type TranslatedString
	Name = {},
}
MasteryData.__index = MasteryData

---@param id string
---@param name string
---@return MasteryData
function MasteryData:Create(id,name)
    local this =
    {
		ID = id,
		Name = name
	}
	setmetatable(this, self)
	WeaponExpansion.Masteries[id] = this
    return this
end

return MasteryData