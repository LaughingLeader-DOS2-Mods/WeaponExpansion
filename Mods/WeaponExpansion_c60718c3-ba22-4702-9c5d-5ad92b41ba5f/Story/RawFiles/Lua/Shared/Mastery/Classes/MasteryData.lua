---@class MasteryRankNameData
---@field Name TranslatedString
---@field Color string

---@class MasteryData
---@field ID string
---@field Name TranslatedString
---@field Color string
---@field Ranks table<integer,MasteryRankNameData>
---@field RankBonuses table<integer,MasteryRankData>
local MasteryData = {}

---@param id string
---@param name TranslatedString
---@param color? string
---@param ranks? MasteryRankDisplayInfo[]
---@param bonuses? MasteryBonusData[]
---@return MasteryData
function MasteryData:Create(id,name,color,ranks,bonuses)
    local this =
    {
		ID = id or "",
		Name = name or "",
		Color = color or "#FFFFFF",
		Ranks = ranks or {},
		RankBonuses = bonuses or {}
	}
	setmetatable(this, {
		__index = MasteryData	
	})
    return this
end

MasteryDataClasses.MasteryData = MasteryData

---@class CharacterMasteryDataEntry
local CharacterMasteryDataEntry = {
	XP = 0,
	Rank = 0
}
CharacterMasteryDataEntry.__index = CharacterMasteryDataEntry

---@param xp integer
---@param rank integer
---@return CharacterMasteryDataEntry
function CharacterMasteryDataEntry:Create(xp,rank)
	local this = {}
	setmetatable(this, self)
	if xp ~= nil then
		this.XP = xp
	end
	if rank ~= nil then
		this.Rank = rank
	end
    return this
end

MasteryDataClasses.CharacterMasteryDataEntry = CharacterMasteryDataEntry

---@class CharacterMasteryData
CharacterMasteryData = {
	UUID = "",
	---@type table<string,CharacterMasteryDataEntry>
	Masteries = {},
	---Character Handle as a double. Used for tooltips.
	---@type number
	Handle = nil
}
CharacterMasteryData.__index = CharacterMasteryData

local function CreateDefaultData(masteryData)
	for mastery,_ in pairs(Masteries) do
		masteryData.Masteries[mastery] = CharacterMasteryDataEntry:Create(0,0)
	end
end

---@param uuid string
---@param masteries table
---@return CharacterMasteryData
function CharacterMasteryData:Create(uuid,masteries)
	local this = {
		UUID = uuid or "",
		Masteries = {}
	}
	CreateDefaultData(this)
	if masteries ~= nil then
		for mastery,data in pairs(masteries) do
			this.Masteries[mastery].Rank = data.Rank
			this.Masteries[mastery].XP = data.XP
		end
	end
	setmetatable(this, self)
    return this
end

---@param data string
---@return CharacterMasteryData|nil
function CharacterMasteryData:LoadFromString(data)
	if data ~= nil then
		local tbl = Common.JsonParse(data)
		if tbl.UUID ~= nil then
			self.UUID = tbl.UUID
		end
		if tbl.Masteries ~= nil then
			for mastery,data in pairs(tbl.Masteries) do
				self.Masteries[mastery].Rank = data.Rank
				self.Masteries[mastery].XP = data.XP
			end
		end
	end
end

MasteryDataClasses.CharacterMasteryData = CharacterMasteryData