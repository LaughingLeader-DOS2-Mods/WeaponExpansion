

local function HasMinimumMasteryLevel(uuid,mastery,minLevel)
	--DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience(_Player, _WeaponType, _Level, _Experience)
	local dbEntry = Osi.DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience:Get(uuid, mastery, nil, nil)
	if dbEntry ~= nil then
		local masteryLevel = dbEntry[1][3]
		if masteryLevel ~= nil and masteryLevel >= minLevel then
			return masteryLevel
		end
	end
end

Ext.NewQuery(HasMinimumMasteryLevel, "LLWEAPONEX_Ext_QRY_HasMinimumMasteryLevel", "[in](CHARACTERGUID)_Character, [in](STRING)_Mastery, [in](INTEGER)_MinLevel, [out](INTEGER)_Level")

---@param uuid CharacterParam
---@param mastery string
---@param level integer
function TagMasteryRanks(uuid,mastery,level)
	uuid = GameHelpers.GetUUID(uuid)
	if level > 0 then
		for i=1,level do
			local tag = string.format(MasteryBonusManager.MasteryRankTagFormatString, mastery, i)
			SetTag(uuid, tag)
		end
	end
end

---@param uuid CharacterParam
---@param mastery string
function ClearAllMasteryRankTags(uuid,mastery)
	local maxRank = Mastery.Variables.MaxRank
	if mastery then
		for i=0,maxRank do
			local tag = string.format(MasteryBonusManager.MasteryRankTagFormatString, mastery, i)
			ClearTag(uuid, tag)
		end
	else
		for mastery,_ in pairs(Masteries) do
			for i=0,maxRank do
				local tag = string.format(MasteryBonusManager.MasteryRankTagFormatString, mastery, i)
				ClearTag(uuid, tag)
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

--- @param uuid string
--- @param mastery string
function OnMasteryActivated(uuid,mastery)
	uuid = StringHelpers.GetUUID(uuid)
	PrintDebug("[WeaponExpansion] Activated mastery ["..mastery.."] on ["..uuid.."].")
	local character = GameHelpers.GetCharacter(uuid)
	if character then
		Mastery.Events.MasteryChanged:Invoke({
			ID = mastery,
			Character = character,
			CharacterGUID = character.MyGuid,
			Enabled = true
		})
	end
	MasterySystem.TagMasteryRanks(uuid, mastery)
end

--- @param uuid string
--- @param mastery string
function OnMasteryDeactivated(uuid,mastery)
	ClearTag(uuid,mastery)
	PrintDebug("[WeaponExpansion] Cleared mastery tag ["..mastery.."] on ["..uuid.."].")
	local character = GameHelpers.GetCharacter(uuid)
	if character then
		Mastery.Events.MasteryChanged:Invoke({
			ID = mastery,
			Character = character,
			CharacterGUID = character.MyGuid,
			Enabled = false
		})
	end
end

--- @param uuid string
--- @param mastery string
--- @param minLevel integer
function HasMasteryLevel(uuid,mastery,minLevel)
	if type(uuid) == "userdata" then
		uuid = uuid.MyGuid
	end
	local dbEntry = Osi.DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience:Get(uuid, mastery, nil, nil)
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

function HasMasteryRequirement_QRY(call, uuid, tag)
	return Mastery.HasMasteryRequirement(Ext.GetCharacter(uuid), tag)
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