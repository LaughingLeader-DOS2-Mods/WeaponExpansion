local _ISCLIENT = Ext.IsClient()

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

local function DebugMasteryActive(character)
	character = GameHelpers.GetCharacter(character)
	if not character then
		return false
	end
	if character:HasTag("LLWEAPONEX_MasteryTestCharacter") then
		return true
	end
end

---@param character EsvCharacter|EclCharacter
---@param mastery string
function Mastery.IsActive(character, mastery)
	return GameHelpers.CharacterOrEquipmentHasTag(character, mastery)
end

---@param character UUID|EsvCharacter|EclCharacter
---@param mastery string
---@param minLevel integer
---@return boolean
function Mastery.HasMinimumMasteryLevel(character,mastery,minLevel)
	if DebugMasteryActive(character) then
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

---@param character EsvCharacter|EclCharacter
---@param tag string
---@param skipWeaponCheck boolean|nil
---@param tags table<string,boolean>|nil Optional cached table of all tags on the character / their equipment.
---@return boolean
local function TryCheckMasteryRequirement(character, tag, skipWeaponCheck, tags)
	local _TAGS = tags or GameHelpers.GetAllTags(character, true, true)
	if type(tag) == "string" then
		--Check if character is tagged with a rank tag, like LLWEAPONEX_Unarmed_Mastery2
		if character ~= nil and _TAGS[tag] then
			local _,_,mastery = string.find(tag,"(.+)_Mastery")
			--Check if character is tagged with a mastery tag, like LLWEAPONEX_Unarmed, which is set when the mastery is active
			--If skipWeaponCheck is true, skip looking for the "mastery is active" tag.
			if mastery then
				if _TAGS[mastery] or (Mastery.PermanentMasteries[mastery] == true or skipWeaponCheck) then
					return true
				elseif _ISCLIENT then
					--Skip checking for the "mastery is active" tag on the client,
					--if we're looking at a skill for an unlocked bonus, or we're in the mastery menu
					return (MasteryMenu.Variables.CurrentTooltip == "Skill" and MasteryMenu.Variables.SelectedMastery.Current == mastery)
				end
			end
		end
	elseif type(tag) == "table" then
		for k,v in pairs(tag) do
			if type(k) == "string" then
				local hasReq = TryCheckMasteryRequirement(character, k, skipWeaponCheck, _TAGS)
				if hasReq then
					return true
				end
			else
				local hasReq = TryCheckMasteryRequirement(character, v, skipWeaponCheck, _TAGS)
				if hasReq then
					return true
				end
			end
		end
	end

	return false
end

---@param char EsvCharacter|EclCharacter
---@param tag string
---@param skipWeaponCheck boolean|nil
---@param tags table<string,boolean>|nil Optional cached table of all tags on the character / their equipment.
---@return boolean
function Mastery.HasMasteryRequirement(char, tag, skipWeaponCheck, tags)
	local character = GameHelpers.GetCharacter(char)
	if not character then
		return false
	end
	if string.find(tag, "LLWEAPONEX_Unarmed") and not UnarmedHelpers.HasEmptyHands(character) then
		return false
	end
	if (tags and tags.LLWEAPONEX_MasteryTestCharacter) or character:HasTag("LLWEAPONEX_MasteryTestCharacter") then
		return true
	end
	local _TAGS = tags or GameHelpers.GetAllTags(character, true, true)
	local status,result = xpcall(TryCheckMasteryRequirement, debug.traceback, character, tag, skipWeaponCheck, _TAGS)
	if not status then
		Ext.Utils.PrintError("Error checking mastery requirements:\n", result)
	else
		return result
	end
	return false
end

---@param character EsvCharacter|StatCharacter
---@param allowDebug boolean|nil
---@return table<string,boolean>
function Mastery.GetMasteryActiveDictionary(character, allowDebug)
	local active = {}
	character = GameHelpers.GetCharacter(character)
	if character then
		for mastery,masteryData in pairs(Masteries) do
			active[mastery] = (allowDebug and DebugMasteryActive(character)) or GameHelpers.CharacterOrEquipmentHasTag(character,mastery)
		end
	end
	return active
end

---@param character EsvCharacter|StatCharacter
---@param allowDebug boolean|nil
---@return string[]
function Mastery.GetActiveMasteries(character, allowDebug)
	local active = {}
	character = GameHelpers.GetCharacter(character)
	if character then
		for mastery,masteryData in pairs(Masteries) do
			if (allowDebug and DebugMasteryActive(character)) or GameHelpers.CharacterOrEquipmentHasTag(character,mastery) then
				active[#active+1] = mastery
			end
		end
	end
	return active
end