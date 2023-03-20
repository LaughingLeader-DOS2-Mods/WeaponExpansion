
local _ISCLIENT = Ext.IsClient()

---@class WeaponExpansionCustomRequirements
local CustomRequirements = {}

---@param req StatsRequirement
---@param character EclCharacter|EsvCharacter
---@param ctx CustomRequirementContext
---@return boolean
local function _GetMasteryRequirement(req, character, ctx)
	local masteryID = req.Tag
	local level = Mastery.Experience.GetMasteryExperience(character, masteryID)
	if level then
		return level >= req.Param
	end
	return false
end

---@param req StatsRequirement
---@param character EclCharacter|EsvCharacter
---@param ctx CustomRequirementContext
---@return boolean
local function _GetWeaponRequirement(req, character, ctx)
	local weaponType = req.Tag
	local _TAGS = GameHelpers.GetAllTags(character, true, true)
	return _TAGS[weaponType] == true
end

---@param reqs StatsRequirement[]
---@return nil|StatsRequirement[]
function CustomRequirements.OverrideRequirements(reqs)
	local len = #reqs
	if len > 0 then
		local changed = false
		for i=1,len do
			local req = reqs[i]
			if req.Requirement == "Tag" and not StringHelpers.IsNullOrEmpty(req.Tag) then
				local _,_,masteryTag,rank = string.find(req.Tag, "(.+)_Mastery(%d+)")
				if masteryTag and Masteries[masteryTag] and rank then
					changed = true
					req.Requirement = "LLWEAPONEX_MasteryRank"
					req.Tag = masteryTag
					req.Param = tonumber(rank)
				else
					local _,_,masteryTag = string.find(req.Tag, "(.+)_Equipped")
					if masteryTag and Masteries[masteryTag] then
						changed = true
						req.Requirement = "LLWEAPONEX_WeaponType"
						req.Tag = masteryTag
						req.Param = -1
					end
				end
			end
		end
		if changed then
			return reqs
		end
	end
	return nil
end

---@param customReq CustomRequirementDescriptor 
---@param callback function
local function RegisterContextCallback(customReq, callback)
	if _ISCLIENT then
		---@param req StatsRequirement
		---@param ctx CustomRequirementContext
		customReq.Callbacks.EvaluateCallback = function (req, ctx)
			return callback(req, ctx.ClientCharacter, ctx)
		end
	else
		---@param req StatsRequirement
		---@param ctx CustomRequirementContext
		customReq.Callbacks.EvaluateCallback = function (req, ctx)
			return callback(req, ctx.ServerCharacter, ctx)
		end
	end
end

function CustomRequirements.Register()
	local req = Ext.Stats.AddRequirement("LLWEAPONEX_MasteryRank", false)
	if req then
		req.Description = "LLWEAPONEX_Requirement_MasteryRank"
		RegisterContextCallback(req, _GetMasteryRequirement)
	else
		fprint(LOGLEVEL.ERROR, "[WeaponExpansion:CustomRequirements.Register] Failed to register requirment 'LLWEAPONEX_MasteryRank'")
	end
	req = Ext.Stats.AddRequirement("LLWEAPONEX_WeaponType", false)
	if req then
		req.Description = "LLWEAPONEX_Requirement_WeaponType"
		RegisterContextCallback(req, _GetWeaponRequirement)
	else
		fprint(LOGLEVEL.ERROR, "[WeaponExpansion:CustomRequirements.Register] Failed to register requirment 'LLWEAPONEX_WeaponType'")
	end
	--[[ req = Ext.Stats.AddRequirement("LLWEAPONEX_EnemyDiedInCombat", true)
	req.Description = "Defeating an Enemy in Combat"
	req.DescriptionHandle = "hc7f8dca2gb752g4627g9351ge185459bc219"
	RegisterContextCallback(req, _GetEnemyDiedInCombatRequirement) ]]
end

return CustomRequirements