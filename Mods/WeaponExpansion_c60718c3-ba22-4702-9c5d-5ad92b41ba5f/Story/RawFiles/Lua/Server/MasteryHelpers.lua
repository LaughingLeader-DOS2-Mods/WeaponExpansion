---@deprecated
---@param guid CharacterParam
---@param mastery string
---@param level integer
function TagMasteryRank(guid,mastery,level)
	local guid = GameHelpers.GetUUID(guid)
	if level > 0 then
		for i=1,level do
			local tag = string.format(MasteryBonusManager.MasteryRankTagFormatString, mastery, i)
			SetTag(guid, tag)
		end
	end
end

---@param guid CharacterParam
---@param mastery string|nil
function ClearAllMasteryRankTags(guid,mastery)
	local maxRank = Mastery.Variables.MaxRank
	if mastery then
		for i=0,maxRank do
			local tag = string.format(MasteryBonusManager.MasteryRankTagFormatString, mastery, i)
			Osi.ClearTag(guid, tag)
		end
	else
		for mastery,_ in pairs(Masteries) do
			for i=0,maxRank do
				local tag = string.format(MasteryBonusManager.MasteryRankTagFormatString, mastery, i)
				Osi.ClearTag(guid, tag)
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

---@deprecated
---@param player CharacterParam
---@param mastery string|nil
---@param clearTags boolean|nil
function Mastery.Experience.TagMasteryRanks(player, mastery, clearTags)
    local player = GameHelpers.GetCharacter(player)
    if player then
        if clearTags then
			ClearAllMasteryRankTags(player)
		end
		if mastery then
			local currentLevel = Mastery.Experience.GetMasteryExperience(player, mastery)
			TagMasteryRank(player, mastery, currentLevel)
		else
			local experienceData = PersistentVars.MasteryExperience[player.MyGuid]
			if experienceData then
				for mastery,data in pairs(experienceData) do
					TagMasteryRank(player, mastery, data.Level or 0)
				end
			end
		end
    end
end