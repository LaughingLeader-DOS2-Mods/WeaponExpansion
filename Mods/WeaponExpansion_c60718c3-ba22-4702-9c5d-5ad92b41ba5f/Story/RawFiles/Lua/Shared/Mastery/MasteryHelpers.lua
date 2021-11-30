
---@param character EsvCharacter|string
---@param mastery string
---@return integer
local function GetHighestMasteryRank(character, mastery)
	character = GameHelpers.GetCharacter(character)
	if character then
		for i=Mastery.Variables.MaxRank,1,-1 do
			local tag = string.format("%s_Mastery%i", mastery, i)
			if character:HasTag(tag) then
				return i
			end
		end
	end
	return 0
end

Mastery.GetHighestMasteryRank = GetHighestMasteryRank

---@param character EsvCharacter|string
---@param mastery string
---@return integer
function Mastery.GetMasteryRank(character, mastery)
	character = GameHelpers.GetCharacter(character)
	if character then
		for i=Mastery.Variables.MaxRank,1,-1 do
			local tag = string.format("%s_Mastery%i", mastery, i)
			if GameHelpers.CharacterOrEquipmentHasTag(character, tag) then
				return i
			end
		end
	end
	return 0
end

---@param character UUID|EsvCharacter|EclCharacter
---@param mastery string
---@param minLevel integer
---@return boolean
local function HasMinimumMasteryLevel(character,mastery,minLevel)
	if Vars.LeaderDebugMode then
		return true
	end
	if Ext.IsServer() then
		local uuid = GameHelpers.GetUUID(character)
		if uuid then
			--DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience(_Player, _WeaponType, _Level, _Experience)
			local dbEntry = Osi.DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience:Get(uuid, mastery, nil, nil)
			if dbEntry ~= nil then
				local masteryLevel = dbEntry[1][3]
				if masteryLevel ~= nil and masteryLevel >= minLevel then
					return true
				end
			end
		end
	elseif Ext.IsClient() then
		local tag = string.format("%s_Mastery_%s", mastery, minLevel)
		local character = GameHelpers.GetCharacter(character)
		if character ~= nil and GameHelpers.CharacterOrEquipmentHasTag(character, tag) then
			return true
		end
	end
	return false
end

Mastery.HasMinimumMasteryLevel = HasMinimumMasteryLevel

--- @param character EsvCharacter|StatCharacter
--- @param tag string
--- @return boolean
local function TryCheckMasteryRequirement(character, tag)
	if type(tag) == "string" then
		if character ~= nil and GameHelpers.CharacterOrEquipmentHasTag(character, tag) == true then
			local a,b,mastery = string.find(tag,"(.+)_Mastery")
			if mastery ~= nil and Mastery.PermanentMasteries[mastery] == true then
				return true
			else
				if Ext.IsClient() then
					return (MasteryMenu.DisplayingSkillTooltip == true and MasteryMenu.SelectedMastery == mastery) or GameHelpers.CharacterOrEquipmentHasTag(character, mastery)
				else
					return GameHelpers.CharacterOrEquipmentHasTag(character, mastery)
				end
			end
		end
	elseif type(tag) == "table" then
		for k,v in pairs(tag) do
			if type(k) == "string" then
				local hasReq = TryCheckMasteryRequirement(character, k)
				if hasReq then
					return true
				end
			else
				local hasReq = TryCheckMasteryRequirement(character, v)
				if hasReq then
					return true
				end
			end
		end
	end

	return false
end

--- @param character EsvCharacter|StatCharacter
--- @param tag string
--- @return boolean
function Mastery.HasMasteryRequirement(character, tag)
	if Debug.MasteryTests or Vars.LeaderDebugMode then
		return true
	end
	if type(character) == "string" then
		character = Ext.GetCharacter(character)
		if character == nil then
			return false
		end
	end
	local status,result = xpcall(TryCheckMasteryRequirement, debug.traceback, character, tag)
	if not status then
		Ext.PrintError("Error checking mastery requirements:\n", result)
	else
		return result
	end
	return false
end

---@param character EsvCharacter|StatCharacter
---@return table<string,boolean>
function Mastery.GetMasteryActiveDictionary(character)
	local active = {}
	for mastery,masteryData in pairs(Masteries) do
		active[mastery] = GameHelpers.CharacterOrEquipmentHasTag(character,mastery)
	end
	return active
end

--- @param character EsvCharacter|StatCharacter
---@return string[]
function Mastery.GetActiveMasteries(character)
	local active = {}
	for mastery,masteryData in pairs(Masteries) do
		if GameHelpers.CharacterOrEquipmentHasTag(character,mastery) then
			active[#active+1] = mastery
		end
	end
	return active
end