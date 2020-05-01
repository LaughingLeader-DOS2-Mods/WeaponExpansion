local TranslatedString = LeaderLib.Classes["TranslatedString"]

---@class MasteryData
MasteryData = {
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
    return this
end

---@class CharacterMasteryDataEntry
CharacterMasteryDataEntry = {
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