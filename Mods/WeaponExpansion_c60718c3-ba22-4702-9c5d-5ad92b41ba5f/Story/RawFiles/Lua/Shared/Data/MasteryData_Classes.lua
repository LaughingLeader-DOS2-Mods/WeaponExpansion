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

---@param uuid string
---@param masteries table
---@return CharacterMasteryData
function CharacterMasteryData:Create(uuid,masteries)
	local this = {}
	setmetatable(this, self)
	if uuid ~= nil then
		this.UUID = uuid
	end
	if masteries ~= nil then
		this.Masteries = masteries
	end
    return this
end

---@param data string
---@return CharacterMasteryData
function CharacterMasteryData:LoadFromString(data)
	local status,result = xpcall(function()
		if data ~= nil then
			local tbl = Ext.JsonParse(data)
			if tbl["UUID"] ~= nil then
				self.UUID = tbl.UUID
			end
			if tbl["Masteries"] ~= nil then
				self.Masteries = tbl.Masteries
			end
			return true
		end
		return false
	end, debug.traceback)
	if not status then
		LeaderLib.PrintDebug("[WeaponExpansion:MasteryData_Classes:CharacterMasteryData:LoadFromString] Error parsing data:", result)
	end
    return this
end

MasteryDataClasses.CharacterMasteryData = CharacterMasteryData

---@class CharacterMasteryData
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
		if character:HasTag(tag) then
			return true
		end
	end
	return false
end

MasteryDataClasses.BonusIDEntry = BonusIDEntry