---@class MasteryRankData
---@field Rank integer
---@field Tag string
---@field Bonuses MasteryBonusData[]
local MasteryRankData = {}

---@param rank integer
---@param tag string
---@return MasteryRankData
function MasteryRankData:Create(rank, tag)
    local this =
    {
		Rank = rank or 0,
		Tag = tag or "",
		Bonuses = {}
	}
	setmetatable(this, {
		__index = MasteryRankData	
	})
    return this
end

MasteryDataClasses.MasteryRankData = MasteryRankData