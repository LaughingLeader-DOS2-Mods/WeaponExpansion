---@param guid CharacterParam
---@param mastery string
---@param level integer
function TagMasteryRanks(guid,mastery,level)
	local guid = GameHelpers.GetUUID(guid)
	if level > 0 then
		for i=1,level do
			local tag = string.format(MasteryBonusManager.MasteryRankTagFormatString, mastery, i)
			SetTag(guid, tag)
		end
	end
end

---@param guid CharacterParam
---@param mastery string
function ClearAllMasteryRankTags(guid,mastery)
	local maxRank = Mastery.Variables.MaxRank
	if mastery then
		for i=0,maxRank do
			local tag = string.format(MasteryBonusManager.MasteryRankTagFormatString, mastery, i)
			ClearTag(guid, tag)
		end
	else
		for mastery,_ in pairs(Masteries) do
			for i=0,maxRank do
				local tag = string.format(MasteryBonusManager.MasteryRankTagFormatString, mastery, i)
				ClearTag(guid, tag)
			end
		end
	end
end

local function HasRequirement(val, matchAny)
	if matchAny == nil then
		return val ~= nil and val ~= "None" and val ~= ""
	else
		if val ~= nil and val ~= "None" and val ~= "" then
			for i,v in pairs(matchAny) do
				if val == v then
					return true
				end
			end
		end
		return false
	end
end

---@param skill string|StatEntrySkillData
function IsWeaponSkill(skill)
	---@type StatEntrySkillData
	local stat = nil
	if type(skill) == "userdata" then
		stat = skill
	else
		if skill == nil or skill == "" then
			return false
		end
		stat = Ext.Stats.Get(skill, nil, false)
	end

	if stat then
		if (stat.UseWeaponDamage == "Yes" 
		or stat.UseWeaponProperties == "Yes")
		or (HasRequirement(stat.Requirement) and stat["Damage Multiplier"] > 0) then
			return true
		end
	end
	return false
end

---@param skill string|StatEntrySkillData
function IsMeleeWeaponSkill(skill)
	---@type StatEntrySkillData
	local stat = nil
	if type(skill) == "userdata" then
		stat = skill
	else
		if skill == nil or skill == "" then
			return false
		end
		stat = Ext.Stats.Get(skill, nil, false)
	end

	if stat then
		if (stat.UseWeaponDamage == "Yes" 
		or stat.UseWeaponProperties == "Yes")
		or (HasRequirement(stat.Requirement, {"MeleeWeapon", "DaggerWeapon", "StaffWeapon", "ShieldWeapon"}) and stat["Damage Multiplier"] > 0) then
			return true
		end
	end
	return false
end

--- @param guid string
--- @param mastery string
--- @param minLevel integer
function HasMasteryLevel(guid,mastery,minLevel)
	if type(guid) == "userdata" then
		guid = guid.MyGuid
	end
	local dbEntry = Osi.DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience:Get(guid, mastery, nil, nil)
	if dbEntry ~= nil then
		local playerEntry = dbEntry[1]
		if playerEntry ~= nil then
			local currentLevel = playerEntry[3]
			--currentExp = playerEntry[4]
			return currentLevel >= minLevel
		end
	end
	return false
end

function HasMasteryRequirement_QRY(call, guid, tag)
	return Mastery.HasMasteryRequirement(GameHelpers.GetCharacter(guid), tag)
end

---@param character CharacterParam
---@param mastery string|nil
---@param clearTags boolean|nil
function MasterySystem.TagMasteryRanks(character, mastery, clearTags)
    character = GameHelpers.GetCharacter(character)
    if character then
        if clearTags then
			ClearAllMasteryRankTags(character.MyGuid)
		end
        local masteryData = Osi.DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience:Get(character.MyGuid, mastery, nil, nil)
        if masteryData then
            for _,db in pairs(masteryData) do
                --_Player, _Mastery, _Level, _Experience
                local _,mastery,level,exp = table.unpack(db)
                TagMasteryRanks(character.MyGuid, mastery, level)
            end
        end
    end
end