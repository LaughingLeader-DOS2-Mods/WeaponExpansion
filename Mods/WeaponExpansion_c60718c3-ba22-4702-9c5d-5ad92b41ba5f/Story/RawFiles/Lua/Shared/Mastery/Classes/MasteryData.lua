local TranslatedString = LeaderLib.Classes["TranslatedString"]

MasteryDataClasses = {}

---@class MasteryData
local MasteryData = {
	ID = "",
	---@type TranslatedString
	Name = {},
	Color = "#FFFFFF",
	---@type table<integer,TranslatedString>
	Ranks = {}
}
MasteryData.__index = MasteryData

---@param id string
---@param name string
---@return MasteryData
function MasteryData:Create(id,name,color,ranks)
    local this =
    {
		ID = id,
		Name = name,
		Color = color,
		Ranks = ranks
	}
	setmetatable(this, self)
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
---@return CharacterMasteryData
function CharacterMasteryData:LoadFromString(data)
	if data ~= nil then
		local tbl = Ext.JsonParse(data)
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

local BonusIDEntry = {
	ID = "",
	---@type table<string,table>
	Tags = {},
}
BonusIDEntry.__index = BonusIDEntry

---@param id string
---@return BonusIDEntry
function BonusIDEntry:Create(id)
	local this = {
		ID = id,
		Tags = {}
	}
	setmetatable(this, self)
    return this
end

---@param character EsvCharacter
---@return boolean
function BonusIDEntry:HasTag(character)
	for tag,_ in pairs(self.Tags) do
		if GameHelpers.CharacterOrEquipmentHasTag(character, tag) then
			return true
		end
	end
	return false
end

MasteryDataClasses.BonusIDEntry = BonusIDEntry