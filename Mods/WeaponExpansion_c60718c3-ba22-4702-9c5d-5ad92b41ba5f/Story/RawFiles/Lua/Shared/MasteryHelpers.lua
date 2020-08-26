
---@param character EsvCharacter|string
---@param mastery string
---@return integer
local function GetHighestMasteryRank(character, mastery)
	if type(character) == "string" then
		character = Ext.GetCharacter(character)
	end
	if character ~= nil then
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

---@param uuid string
---@param mastery string
---@param minLevel integer
---@return boolean
local function HasMinimumMasteryLevel(uuid,mastery,minLevel)
	if Ext.IsServer() then
		--DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience(_Player, _WeaponType, _Level, _Experience)
		local dbEntry = Osi.DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience:Get(uuid, mastery, nil, nil)
		if dbEntry ~= nil then
			local masteryLevel = dbEntry[1][3]
			if masteryLevel ~= nil and masteryLevel >= minLevel then
				return true
			end
		end
	elseif Ext.IsClient() then
		local tag = mastery.."_Mastery"..tostring(minLevel)
		local character = Ext.GetCharacter(uuid)
		if character ~= nil and character:HasTag(tag) then
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
		if character:HasTag(tag) == true then
			local a,b,mastery = string.find(tag,"(.+)_Mastery")
			--print("TryCheckMasteryRequirement character", character, "tag", tag, "mastery", mastery, character:HasTag(mastery))
			if mastery ~= nil and Mastery.PermanentMasteries[mastery] == true then
				return true
			else
				if Ext.IsClient() then
					return (MasteryMenu.DisplayingSkillTooltip == true and MasteryMenu.SelectedMastery == mastery) or character:HasTag(mastery)
				else
					return character:HasTag(mastery)
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
	if Debug.MasteryTests then
		return true
	end
	if type(character) == "string" then
		character = Ext.GetCharacter(character)
	end
	local status,result = xpcall(TryCheckMasteryRequirement, debug.traceback, character, tag)
	if not status then
		Ext.PrintError("Error checking mastery requirements:\n", result)
	else
		return result
	end
	return false
end