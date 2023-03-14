
local _ISCLIENT = Ext.IsClient()

---@class WeaponExpansionCustomRequirements
local CustomRequirements = {}

---@param req StatsRequirement
---@param character EclCharacter|EsvCharacter
---@param ctx CustomRequirementContext
---@return boolean
local function _GetMasteryRequirement(req, character, ctx)
	Ext.DumpShallow({Context=ctx, Requirement=req})
	local masteryID = req.Tag
	local masteryRanks = character.UserVars.LLWEAPONEX_Masteries
	if masteryRanks then
		---@cast masteryRanks table<string, MasteryExperienceData>
		local rankData = masteryRanks[masteryID]
		if rankData then
			return rankData.Level >= req.Param
		end
	end
	return false
end

---@param req StatsRequirement
---@param character EclCharacter|EsvCharacter
---@param ctx CustomRequirementContext
---@return boolean
local function _GetWeaponRequirement(req, character, ctx)
	Ext.DumpShallow(ctx);Ext.DumpShallow(req)
	local weaponType = req.Tag
	--[[ local mainhand,offhand = GameHelpers.Character.GetEquippedWeapons(character)
	if mainhand and GameHelpers.ItemHasTag(mainhand, weaponType) then
		return true
	end
	if offhand and GameHelpers.ItemHasTag(offhand, weaponType) then
		return true
	end
	return false
	]]
	local _TAGS = GameHelpers.GetAllTags(character, true, true)
	return _TAGS[weaponType] == true
end

-- local skill = Ext.Stats.Get("Shout_LLWEAPONEX_Rapier_DuelistStance");skill.Requirements = {{Not = false, Param = 0, Requirement = "LLWEAPONEX_WeaponType", Tag = "LLWEAPONEX_Rapier"}};skill.MemorizationRequirements = {{Not = false, Param = 1, Requirement = "LLWEAPONEX_MasteryRank", Tag = "LLWEAPONEX_Rapier"}};Ext.Stats.Sync("Shout_LLWEAPONEX_Rapier_DuelistStance", false)

---@param reqs StatsRequirement[]
---@return nil|StatsRequirement[]
function CustomRequirements.OverrideRequirements(reqs)
	local len = #reqs
	if len > 0 then
		---@type StatsRequirement[]
		local newRequirements = TableHelpers.Clone(reqs)
		local changed = false
		for i=1,len do
			local req = newRequirements[i]
			if req.Requirement == "Tag" then
				local _,_,masteryTag,rank = string.find(req.Tag, "(.+)_Mastery(%d-)")
				if masteryTag and Masteries[masteryTag] then
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
					end
				end
			end
		end
		if changed then
			return newRequirements
		end
	end
	return nil
end

---@param req CustomRequirementDescriptor 
---@param callback function
local function RegisterContextCallback(req, callback)
	if _ISCLIENT then
		---@param req StatsRequirement
		---@param ctx CustomRequirementContext
		req.Callbacks.EvaluateCallback = function (req, ctx)
			return callback(req, ctx.ClientCharacter, ctx)
		end
	else
		---@param req StatsRequirement
		---@param ctx CustomRequirementContext
		req.Callbacks.EvaluateCallback = function (req, ctx)
			return callback(req, ctx.ServerCharacter, ctx)
		end
	end
end

function CustomRequirements.Register()
	local req = Ext.Stats.AddRequirement("LLWEAPONEX_MasteryRank", true)
	req.Description = "Mastery Rank"
	RegisterContextCallback(req, _GetMasteryRequirement)
	req = Ext.Stats.AddRequirement("LLWEAPONEX_WeaponType", true)
	req.Description = "Weapon"
	RegisterContextCallback(req, _GetWeaponRequirement)
	--[[ req = Ext.Stats.AddRequirement("LLWEAPONEX_EnemyDiedInCombat", true)
	req.Description = "Defeating an Enemy in Combat"
	req.DescriptionHandle = "hc7f8dca2gb752g4627g9351ge185459bc219"
	RegisterContextCallback(req, _GetEnemyDiedInCombatRequirement) ]]
end

return CustomRequirements