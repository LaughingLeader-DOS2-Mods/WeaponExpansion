local _ISCLIENT = Ext.IsClient()
local _type = type

---@alias MasteryBonusCheckTarget string|"Any"|"Target"|"Source"|"None"
---@alias WeaponExpansionMasterySkillListenerCallback fun(MasteryBonusCallbackBonuses, e:OnSkillStateAllEventArgs):void
---@alias MasteryBonusStatusCallback fun(bonuses:MasteryBonusCallbackBonuses, target:string, status:string, source:string, statusType:string)
---@alias MasteryBonusStatusBeforeAttemptCallback fun(bonuses:MasteryBonusCallbackBonuses, target:EsvCharacter|EsvItem, status:EsvStatus, source:EsvCharacter|EsvItem|nil, statusType:string):boolean

---@alias MasteryActiveBonusesTable table<string,table<UUID,boolean>>

---@class MasteryActiveBonuses
---@field HasBonus fun(id:string, target:CharacterParam|nil):boolean

MasteryBonusManager = {
	---Specific tables or variables used in bonus logic scripts. Made global so mods can access/change them.
	Vars = {
		RushSkills = {"Rush_BatteringRam", "Rush_BullRush", "Rush_EnemyBatteringRam", "Rush_EnemyBullRush"},
		BasicAttack = {"ActionAttackGround"},
		---Skills to enable piercing projectiles for at Bow rank 4. Should be RangedWeapon projectile skills that don't already pierce or fork.
		---@type table<string,boolean>
		CrossbowProjectilePiercingSkills = {},
		---Used for the Bow Rank 4 bonus BOW_FARSIGHT, in case a mod changed the status.
		FarsightAppliedStatuses = {"FARSIGHT"}
	},
	---The string format for mastery rank tags, set on a character.
	MasteryRankTagFormatString = "%s_Mastery%i"
}

---@class MasteryBonusManagerInternals
local _INTERNAL = {
	---@type table<UUID|NetId, table<string, boolean>>
	CharacterDisabledBonuses = {}
}
MasteryBonusManager._INTERNAL = _INTERNAL

if not _ISCLIENT then
	setmetatable(_INTERNAL.CharacterDisabledBonuses, {
		__index = function (_,k)
			return PersistentVars.DisabledBonuses[k]
		end,
		__newindex = function (_,k,v)
			PersistentVars.DisabledBonuses[k] = v
		end
	})
end

---Rank Tag to Bonuses
---@type table<string, MasteryBonusData[]>
local _registeredBonuses = {}
---@type table<string, MasteryBonusData>
local _BONUS_ID_MAP = {}

local masteryRankBonusPattern = "(.-)_Mastery(%d+)"

local _EMPTYBONUSES = {HasBonus = function() end}
setmetatable(_EMPTYBONUSES, {
	__index = function () return false end,
	__newindex = function () return nil end
})

---@deprecated
Mastery.Bonuses = {}
setmetatable(Mastery.Bonuses, {
	__index = _registeredBonuses,
	__newindex = function (tbl, k, v)
		Ext.Utils.PrintError("Please don't add to WeaponExpansion.Mastery.Bonuses directly. Use Mastery.Register.NewRankBonus or MasteryBonusManager.AddRankBonuses", k)
		local s,e,masteryId,rank = string.find(k, masteryRankBonusPattern)
		if masteryId and rank then
			rank = tonumber(rank)
			if rank then
				if v.Type ~= "MasteryBonusData" then
					local bonuses = {}
					for id,v in pairs(v) do
						local bonus = MasteryDataClasses.MasteryBonusData:Create(id, {
							Skills = v.Skills or {},
							Tooltip = v.Param
						})
						table.insert(bonuses, bonus)
					end
					MasteryBonusManager.AddRankBonuses(masteryId, rank, bonuses)
					fprint(LOGLEVEL.WARNING, "[WeaponExpansion] Registered bonuses using an unsupported registration method for mastery (%s) and rank (%s).", masteryId, rank)
				else
					MasteryBonusManager.AddRankBonuses(masteryId, rank, v)
				end
			end
		end
	end,
	__pairs = function()
		return function() end, {}, nil
	end,
	__ipairs = function ()
		return function() end, {}, 0
	end
})
--Deprecation help
MasteryDataClasses.BonusIDEntry = {
	Create = function ()
		Ext.Utils.PrintError("WeaponExpansion.MasteryDataClasses.BonusIDEntry is deprecated.")
		return {}
	end
}

---@param char CharacterParam
---@param skill string|nil Optional skill to filter with.
---@return table<string, boolean> bonuses
---@return boolean hasBonus
function MasteryBonusManager.GetMasteryBonuses(char, skill)
	---@type EsvCharacter|EclCharacter
	local character = GameHelpers.GetCharacter(char)
	local bonuses = {}
	local hasBonus = false
	if character then
		local _TAGS = GameHelpers.GetAllTags(character, true, true)
		for tag,tbl in pairs(_registeredBonuses) do
			if Mastery.HasMasteryRequirement(character, tag, false, _TAGS) then
				for _,v in pairs(tbl) do
					if v.ID then
						bonuses[v.ID] = true
						hasBonus = true
					else
						fprint(LOGLEVEL.ERROR, "[LLWEAPONEX] Bonus is lacking an ID parameter:\n%s", Ext.DumpExport(v))
						error("", 2)
					end
				end
			end
		end
	end
	return bonuses,hasBonus
end

---@param checkBonusOn MasteryBonusCheckTarget|nil
---@param source CharacterParam
---@param target CharacterParam
---@param extraParam string|nil Skill ID
---@param skipDisabledCheck boolean|nil If true, skip checking if the bonus is disabled. Otherwise, disabled bonuses won't be included.
---@return MasteryActiveBonusesTable|MasteryActiveBonuses
local function GatherMasteryBonuses(checkBonusOn, source, target, extraParam, skipDisabledCheck)
	local bonuses = {}
	local source = GameHelpers.TryGetObject(source)
	local sourceGUID = source and source.MyGuid or nil
	local target = GameHelpers.TryGetObject(target)
	local targetGUID = target and target.MyGuid or nil
	if sourceGUID and checkBonusOn ~= "Target" and GameHelpers.Ext.ObjectIsCharacter(source) then
		for bonus,_ in pairs(MasteryBonusManager.GetMasteryBonuses(source, extraParam)) do
			if skipDisabledCheck or not MasteryBonusManager.IsBonusDisabled(sourceGUID, bonus) then
				if bonuses[bonus] == nil then
					bonuses[bonus] = {}
				end
				bonuses[bonus][sourceGUID] = true
			end
		end
	end
	if targetGUID and (checkBonusOn ~= "Source" or StringHelpers.IsNullOrEmpty(sourceGUID))
	and GameHelpers.Ext.ObjectIsCharacter(target) then
		for bonus,_ in pairs(MasteryBonusManager.GetMasteryBonuses(target, extraParam)) do
			if skipDisabledCheck or not MasteryBonusManager.IsBonusDisabled(targetGUID, bonus) then
				if bonuses[bonus] == nil then
					bonuses[bonus] = {}
				end
				bonuses[bonus][targetGUID] = true
			end
		end
	end
	bonuses.HasBonus = function(id, t)
		if not t then
			return bonuses[id] ~= nil
		else
			local targets = bonuses[id]
			if targets then
				return targets[GameHelpers.GetUUID(t)] == true
			end
		end
		return false
	end
	return bonuses
end

_INTERNAL.GatherMasteryBonuses = GatherMasteryBonuses

---@param character UUID|NetId|EsvCharacter|EclCharacter|StatCharacter
---@param bonus string|string[]
---@param skipWeaponCheck boolean|nil
---@return boolean
function MasteryBonusManager.HasMasteryBonus(character, bonus, skipWeaponCheck)
	---@type EsvCharacter|EclCharacter
	local character = GameHelpers.GetCharacter(character)
	if character then
		local _TAGS = GameHelpers.GetAllTags(character, true, true)
		for tag,tbl in pairs(_registeredBonuses) do
			if Mastery.HasMasteryRequirement(character, tag, skipWeaponCheck, _TAGS) then
				for _,bonusData in pairs(tbl) do
					if bonusData.ID == bonus then
						return true
					end
				end
			end
		end
	end
	return false
end

---@param bonuses table
---@param matchBonuses string|string[]
local function HasMatchedBonuses(bonuses, matchBonuses)
	if matchBonuses == nil or matchBonuses == "" then
		return true
	end
	local t = _type(matchBonuses)
	if t == "string" then
		return bonuses[matchBonuses] ~= nil
	elseif t == "table" then
		for i,v in pairs(matchBonuses) do
			if bonuses[v] ~= nil then
				return true
			end
		end
	end
	return false
end

_INTERNAL.HasMatchedBonuses = HasMatchedBonuses

---@param state SKILL_STATE
---@param data any
---@return EsvCharacter|EsvItem|nil
local function _GetSkillTarget(state, data)
	if state == SKILL_STATE.HIT then
		if not StringHelpers.IsNullOrEmpty(data.Target) then
			return data.TargetObject
		end
	elseif state == SKILL_STATE.PROJECTILEHIT or state == SKILL_STATE.BEFORESHOOT then
		if Ext.Utils.IsValidHandle(data.Target) then
			return Ext.GetGameObject(data.Target)
		end
	elseif state == SKILL_STATE.SHOOTPROJECTILE then
		if Ext.Utils.IsValidHandle(data.TargetObjectHandle) then
			return Ext.GetGameObject(data.TargetObjectHandle)
		end
	elseif state == SKILL_STATE.USED or state == SKILL_STATE.CAST then
		--TODO Check all targets?
		if data.TargetObjects[1] then
			return Ext.GetGameObject(data.TargetObjects[1])
		end
	end
	return nil
end

---@deprecated
---@param skill string|string[]
---@param matchBonuses string|string[]
---@param callback fun(bonuses:MasteryBonusCallbackBonuses, skill:string, char:string, state:SKILL_STATE, data:any, dataType:string)
---@param checkBonusOn MasteryBonusCheckTarget
function MasteryBonusManager.RegisterSkillListener(skill, matchBonuses, callback, checkBonusOn)
	if _ISCLIENT then return end
	checkBonusOn = checkBonusOn or "Source"
	if _type(skill) == "table" then
		for i,v in pairs(skill) do
			MasteryBonusManager.RegisterSkillListener(v, matchBonuses, callback, checkBonusOn)
		end
	else
		SkillManager.Register.All(skill, function(e)
			local target = _GetSkillTarget(e.State, e.Data)
			local bonuses = GatherMasteryBonuses(checkBonusOn, e.Character, target, e.Skill)
			if checkBonusOn == "None" or HasMatchedBonuses(bonuses, matchBonuses) then
				callback(bonuses, e.Skill, e.Character, e.State, e.Data, e.DataType)
			end
		end)
	end
end

---@param state SKILL_STATE
---@param skill string|string[]
---@param matchBonuses string|string[]
---@param callback WeaponExpansionMasterySkillListenerCallback
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@param priority integer|nil
---@param once boolean|nil
function MasteryBonusManager.RegisterNewSkillListener(state, skill, matchBonuses, callback, checkBonusOn, priority, once)
	if _ISCLIENT then return end
	checkBonusOn = checkBonusOn or "Source"

	---@param e OnSkillStateAllEventArgs
	local wrapperCallback = function(e)
		local target = _GetSkillTarget(e.State, e.Data)
		local bonuses = GatherMasteryBonuses(checkBonusOn, e.Character, target, e.Skill)
		if checkBonusOn == "None" or HasMatchedBonuses(bonuses, matchBonuses) then
			callback(e, bonuses)
		end
	end
	SkillManager.Register.All(skill, wrapperCallback, state, priority, once)
end

---@param state SKILL_STATE|string
---@param skill string|string[]
---@param bonus MasteryBonusData
---@param callback fun(bonus:MasteryBonusData, e:OnSkillStateAllEventArgs, bonuses:MasteryActiveBonusesTable|MasteryActiveBonuses)
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@param priority integer|nil
---@param once boolean|nil
function MasteryBonusManager.RegisterBonusSkillListener(state, skill, bonus, callback, checkBonusOn, priority, once)
	if _ISCLIENT then return end
	checkBonusOn = checkBonusOn or "Source"

	---@param e OnSkillStateAllEventArgs
	local wrapperCallback = function(e)
		local target = _GetSkillTarget(e.State, e.Data)
		local bonuses = GatherMasteryBonuses(checkBonusOn, e.Character, target, e.Skill)
		if checkBonusOn == "None" or HasMatchedBonuses(bonuses, bonus.ID) then
			callback(bonus, e, bonuses)
		end
	end
	SkillManager.Register.All(skill, wrapperCallback, state, priority, once)
end

---@param matchBonuses string|string[]
---@param callback WeaponExpansionOnHealCallback
---@param checkBonusOn MasteryBonusCheckTarget
---@param priority integer|nil
---@param once boolean|nil
function MasteryBonusManager.RegisterOnHealListener(matchBonuses, callback, checkBonusOn, priority, once)
	if _ISCLIENT then return end
	checkBonusOn = checkBonusOn or "Source"

	---@param e OnHealEventArgs
	local wrapperCallback = function(e)
		local bonuses = GatherMasteryBonuses(checkBonusOn, e.Source, e.Target, e.Skill)
		if checkBonusOn == "None" or HasMatchedBonuses(bonuses, matchBonuses) then
			callback(e, bonuses)
		end
	end
	Events.OnHeal:Subscribe(wrapperCallback)
end

---@param statusEvent StatusEventID
---@param status string|string[]
---@param bonus MasteryBonusData
---@param callback fun(bonus:MasteryBonusData, e:EmptyEventArgs, bonuses:MasteryActiveBonusesTable|MasteryActiveBonuses)
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@param priority integer|nil
---@param once boolean|nil
function MasteryBonusManager.RegisterBonusStatusListener(statusEvent, status, bonus, callback, checkBonusOn, priority, once)
	if _ISCLIENT then return end
	checkBonusOn = checkBonusOn or "Any"

	if checkBonusOn ~= "None" then
		---@param e OnStatusEventArgs
		local wrapperCallback = function(e)
			local bonuses = GatherMasteryBonuses(checkBonusOn, e.Source, e.Target)
			if HasMatchedBonuses(bonuses, bonus.ID) then
				callback(bonus, e, bonuses)
			end
		end
		StatusManager.Subscribe.All(status, wrapperCallback, priority, statusEvent)
	else
		---@param e OnStatusEventArgs
		local wrapperCallback = function(e)
			callback(bonus, e, _EMPTYBONUSES)
		end
		StatusManager.Subscribe.All(status, wrapperCallback, priority, statusEvent)
	end
end

---@param statusEvent StatusEventID
---@param statusType string|string[]
---@param bonus MasteryBonusData
---@param callback fun(bonus:MasteryBonusData, e:EmptyEventArgs, bonuses:MasteryActiveBonusesTable|MasteryActiveBonuses)
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@param priority integer|nil
---@param once boolean|nil
function MasteryBonusManager.RegisterBonusStatusTypeListener(statusEvent, statusType, bonus, callback, checkBonusOn, priority, once)
	if _ISCLIENT then return end
	checkBonusOn = checkBonusOn or "Any"

	if checkBonusOn ~= "None" then
		---@param e OnStatusEventArgs
		local wrapperCallback = function(e)
			local bonuses = GatherMasteryBonuses(checkBonusOn, e.Source, e.Target)
			if HasMatchedBonuses(bonuses, bonus.ID) then
				callback(bonus, e, bonuses)
			end
		end	
		StatusManager.Subscribe.All(statusType, wrapperCallback, priority, statusEvent)
	else
		---@param e OnStatusEventArgs
		local wrapperCallback = function(e)
			callback(bonus, e, _EMPTYBONUSES)
		end
		StatusManager.Subscribe.All(statusType, wrapperCallback, priority, statusEvent)
	end
end

---@param callback function
---@param matchBonuses string[]
---@param target string
---@param status string
---@param source string
---@param statusType string
---@param checkBonusOn MasteryBonusCheckTarget
local function OnStatusCallback(callback, matchBonuses, target, status, source, statusType, checkBonusOn)
	checkBonusOn = checkBonusOn or "Any"
	local bonuses = GatherMasteryBonuses(checkBonusOn, source, target)
	if checkBonusOn == "None" or HasMatchedBonuses(bonuses, matchBonuses) then
		callback(bonuses, target, status, source, statusType)
	end
end

---@param event string
---@param status string|string[]
---@param matchBonuses string|string[]
---@param callback MasteryBonusStatusCallback
---@param checkBonusOn MasteryBonusCheckTarget
function MasteryBonusManager.RegisterStatusListener(event, status, matchBonuses, 
	callback, checkBonusOn)
	if _ISCLIENT then return end
	checkBonusOn = checkBonusOn or "Any"
	if _type(status) == "table" then
		for i,v in pairs(status) do
			MasteryBonusManager.RegisterStatusListener(event, v, matchBonuses, callback, checkBonusOn)
		end
	else
		local wrapperCallback = function(target, status, source, statusType)
			OnStatusCallback(callback, matchBonuses, target, status, source, statusType, checkBonusOn)
		end
		RegisterStatusListener(event, status, wrapperCallback)
	end
end

---@param event string
---@param statusType string|string[]
---@param matchBonuses string|string[]
---@param callback MasteryBonusStatusCallback
---@param checkBonusOn MasteryBonusCheckTarget
function MasteryBonusManager.RegisterStatusTypeListener(event, statusType, matchBonuses, 
	callback, checkBonusOn)
	if _ISCLIENT then return end
	checkBonusOn = checkBonusOn or "Any"
	if _type(statusType) == "table" then
		for i,v in pairs(statusType) do
			MasteryBonusManager.RegisterStatusTypeListener(event, v, matchBonuses, callback)
		end
	else
		local wrapperCallback = function(target, status, source, statusType)
			OnStatusCallback(callback, matchBonuses, target, status, source, statusType)
		end
		RegisterStatusTypeListener(event, statusType, wrapperCallback)
	end
end

---@param target EsvCharacter
---@param source EsvCharacter|nil
---@param checkBonusOn MasteryBonusCheckTarget
local function OnBeforeStatusAttemptCallback(callback, matchBonuses, target, status, source, statusType, skipBonusCheck, checkBonusOn)
	local targetGUID = GameHelpers.GetUUID(target)
	if targetGUID then
		if skipBonusCheck ~= true then
			checkBonusOn = checkBonusOn or "Any"
			local bonuses = GatherMasteryBonuses(checkBonusOn, source, target)
			if checkBonusOn == "None" or HasMatchedBonuses(bonuses, matchBonuses) then
				local b,result = xpcall(callback, debug.traceback, bonuses, target, status, source, statusType)
				if b then
					return result
				else
					Ext.Utils.PrintError(result)
				end
			end
		else
			local b,result = xpcall(callback, debug.traceback, _EMPTYBONUSES, target, status, source, statusType)
			if b then
				return result
			else
				Ext.Utils.PrintError(result)
			end
		end
	end
end

---@param status string|string[]
---@param matchBonuses string|string[]
---@param callback MasteryBonusStatusBeforeAttemptCallback
---@param skipBonusCheck boolean
---@param checkBonusOn MasteryBonusCheckTarget
function MasteryBonusManager.RegisterStatusBeforeAttemptListener(status, matchBonuses, callback,
	skipBonusCheck, checkBonusOn)
	if _ISCLIENT then return end
	checkBonusOn = checkBonusOn or "Source"
	if _type(status) == "table" then
		for i,v in pairs(status) do
			MasteryBonusManager.RegisterStatusBeforeAttemptListener(v, matchBonuses, callback, skipBonusCheck, checkBonusOn)
		end
	else
		StatusManager.Register.BeforeAttempt(status, function(target, status, source, statusType, statusEvent)
			OnBeforeStatusAttemptCallback(callback, matchBonuses, target, status, source, statusType, skipBonusCheck, checkBonusOn)
		end)
	end
end

---@class MasteryBonusManagerClosestEnemyData
---@field UUID string
---@field Dist number

---Get a table of enemies in combat, determined by distance to a source.
---@deprecated
---@param char UUID
---@param target UUID|EsvCharacter|EsvItem|number[]
---@param radius number
---@param sortByClosest boolean
---@param limit integer
---@param ignoreTarget UUID
---@return MasteryBonusManagerClosestEnemyData[]
function MasteryBonusManager.GetClosestEnemiesToObject(char, target, radius, sortByClosest, limit, ignoreTarget)
	if target == nil then
		return {}
	end
	if radius == nil then
		radius = 8
	end
	local lastDist = 999
	local targets = {}

	local t = _type(target)
	if t == "userdata" and target.WorldPos then
		target = target.WorldPos
	elseif t == "string" then
		target = {GetPosition(target)}
	end
	for _,enemy in pairs(Ext.GetAllCharacters()) do
		local dist = GameHelpers.Math.GetDistance(GameHelpers.GetCharacter(enemy).WorldPos, target)
		if enemy ~= char
		and enemy ~= ignoreTarget
		and dist <= radius
		and (CharacterIsEnemy(char, enemy) == 1 or IsTagged(enemy, "LLDUMMY_TrainingDummy") == 1)
		and CharacterIsDead(enemy) == 0
		and not GameHelpers.Status.IsSneakingOrInvisible(char)
		then
			if limit == 1 then
				if dist < lastDist then
					targets[1] = enemy
				end
			else
				table.insert(targets, {Dist = dist, UUID = enemy})
			end
			lastDist = dist
		end
	end
	if #targets > 1 then
		if sortByClosest then
			table.sort(targets, function(a,b)
				return a.Dist < b.Dist
			end)
		end
		if limit ~= nil and limit > 1 then
			local spliced = {}
			local count = #targets
			if limit < count then
				count = limit
			end
			for i=1,count,1 do
				spliced[#spliced+1] = targets[i]
			end
			return spliced
		end
	end
	return targets
end

---Get a table of enemies in combat, determined by distance to a source.
---@deprecated
---@param char UUID
---@param maxDistance number
---@param sortByClosest boolean
---@param limit integer
---@param ignoreTarget UUID
---@return MasteryBonusManagerClosestEnemyData[]
function MasteryBonusManager.GetClosestCombatEnemies(char, maxDistance, sortByClosest, limit, ignoreTarget)
	if maxDistance == nil then
		maxDistance = 30
	end
	local data = Osi.DB_CombatCharacters:Get(nil, CombatGetIDForCharacter(char))
	if data ~= nil then
		local lastDist = 999
		local targets = {}
		for i,v in pairs(data) do
			local enemy = v[1]
			if (enemy ~= char and enemy ~= ignoreTarget and
				CharacterIsEnemy(char, enemy) == 1 and 
				CharacterIsDead(enemy) == 0 and 
				not GameHelpers.Status.IsSneakingOrInvisible(char)) then
					local dist = GetDistanceTo(char,enemy)
					if dist <= maxDistance then
						if limit == 1 then
							if dist < lastDist then
								targets[1] = enemy
							end
						else
							table.insert(targets, {Dist = dist, UUID = enemy})
						end
						lastDist = dist
					end
			end
		end
		if #targets > 1 then
			if sortByClosest then
				table.sort(targets, function(a,b)
					return a.Dist < b.Dist
				end)
			end
			if limit ~= nil and limit > 1 then
				local spliced = {}
				local count = #targets
				if limit < count then
					count = limit
				end
				for i=1,count,1 do
					spliced[#spliced+1] = targets[i]
				end
				return spliced
			end
		end
		return targets
	end
end

local function _GetBonus(tbl)
	if tbl.Type == "MasteryBonusData" then
		return tbl
	elseif tbl.__self then -- Register table chaining support
		return tbl.__self
	end
	return nil
end

---@alias AddRankBonusesBonusType MasteryBonusData|MasteryBonusDataRegistrationFunctions

---@param mastery string
---@param rank integer
---@param bonuses AddRankBonusesBonusType|AddRankBonusesBonusType[]
function MasteryBonusManager.AddRankBonuses(mastery, rank, bonuses)
	local masteryRankID = string.format(MasteryBonusManager.MasteryRankTagFormatString, mastery, rank)
	if not _registeredBonuses[masteryRankID] then
		_registeredBonuses[masteryRankID] = {}
	end
	---@type MasteryData
	local masteryData = Masteries[mastery]
	if masteryData and not masteryData.RankBonuses[rank] then
		masteryData.RankBonuses[rank] = MasteryDataClasses.MasteryRankData:Create(rank, masteryRankID)
		masteryData.RankBonuses[rank].Bonuses = _registeredBonuses[masteryRankID]
	end
	local t = _type(bonuses)
	if t == "table" then
		local bonus = _GetBonus(bonuses)
		if bonus then
			bonus.Mastery = mastery
			bonus.Rank = rank
			_BONUS_ID_MAP[bonus.ID] = bonus
			_registeredBonuses[masteryRankID][#_registeredBonuses[masteryRankID]+1] = bonus
		else
			local len = #bonuses
			for i=1,len do
				local bonus = _GetBonus(bonuses[i])
				if bonus then
					bonus.Mastery = mastery
					bonus.Rank = rank
					_BONUS_ID_MAP[bonus.ID] = bonus
					_registeredBonuses[masteryRankID][#_registeredBonuses[masteryRankID]+1] = bonus
				end
			end
		end
	end
end

---@param mastery string
---@param rank integer
---@param id string Optional ID to look for.
---@return MasteryBonusData|MasteryBonusData[]
function MasteryBonusManager.GetRankBonus(mastery, rank, id)
	---@type MasteryData
	local masteryData = Masteries[mastery]
	if masteryData and masteryData.RankBonuses[rank] then
		if id then
			for _,v in pairs(masteryData.RankBonuses[rank].Bonuses) do
				if v.ID == id then
					return v
				end
			end
		else
			return masteryData.RankBonuses[rank].Bonuses
		end
	end
end

---@param id string
---@return MasteryBonusData
function MasteryBonusManager.GetBonusByID(id)
	return _BONUS_ID_MAP[id]
end

local function GetMasteryColor(mastery)
	local masteryData = Masteries[mastery]
	if masteryData then
		return masteryData.Color
	end
end

---@param data MasteryBonusData
---@param character EsvCharacter|EclCharacter
---@param skillOrStatus string
---@param tooltipType MasteryBonusDataTooltipID
---@param status EclStatus|nil
local function EvaluateEntryForBonusText(data, character, skillOrStatus, tooltipType, status, ...)
	if data.Type == "MasteryBonusData" then
		local bonusText = data:GetTooltipText(character, skillOrStatus, tooltipType, status, ...)
		if not StringHelpers.IsNullOrWhitespace(bonusText) then
			return bonusText
			--[[ local color = GetMasteryColor(data.Mastery)
			if color then
				return string.format("<font color='%s'>%s</font>", color, bonusText)
			else
				return bonusText
			end ]]
		end
	else
		local _TAGS = GameHelpers.GetAllTags(character, true, true)
		--Old style
		local bonusIsActive = true
		if data.Active ~= nil and data.Active.Type == "Tag" then
			if data.Active.Source == true and _type(status) == "userdata" then
				if GameHelpers.IsValidHandle(status.StatusSourceHandle) then
					local source = GameHelpers.GetCharacter(status.StatusSourceHandle)
					if source then
						bonusIsActive = GameHelpers.CharacterOrEquipmentHasTag(source, data.Active.Value)
					end
				end
			end
			if not bonusIsActive then
				bonusIsActive = _TAGS[data.Active.Value] == true
			end
		end
		if bonusIsActive then
			local descriptionText = TooltipParams.GetDescriptionText(character, data, status, "status")
			if not StringHelpers.IsNullOrWhitespace(descriptionText) then
				return descriptionText
			end
		end
	end
	return nil
end

local OrderedMasteries = {}

---@return fun():string,MasteryBonusData[]
function MasteryBonusManager.GetOrderedMasteryRanks()
	local rankOrder = {}
	for _,mastery in pairs(OrderedMasteries) do
		for i=1,Mastery.Variables.MaxRank do
			local masteryRankID = string.format("%s_Mastery%s", mastery, i)
			if _registeredBonuses[masteryRankID] and #_registeredBonuses[masteryRankID] > 0 then
				rankOrder[#rankOrder+1] = masteryRankID
			end
		end
	end
	local i = 0
	local count = #rankOrder
	return function ()
		i = i + 1
		if i <= count then
			return rankOrder[i],_registeredBonuses[rankOrder[i]]
		end
	end
end

---@param characters {Character:EclCharacter, Tags:table<string,boolean>}[]
---@param rankTag string
---@param len integer
---@return boolean hasRequirement
---@return EclCharacter|nil characterWithRequirement
local function _AnyCharacterHasMasteryRequirement(characters, rankTag, len)
	for i=1,len do
		local data = characters[i]
		if Mastery.HasMasteryRequirement(data.Character, rankTag, false, data.Tags) then
			return true,data.Character
		end
	end
	return false
end

---@param character EsvCharacter|EclCharacter
---@param skillOrStatus string
---@param tooltipType MasteryBonusDataTooltipID
---@param status EclStatus|nil
function MasteryBonusManager.GetBonusText(character, skillOrStatus, tooltipType, status, ...)
	local textEntries = {}
	local checkCharacters = {}
	local cLen = 0
	--Allow clients to view mastery bonuses for statuses affecting other objects
	local client = Client:GetCharacter()
	if not client then
		Ext.Utils.PrintError("[WeaponExpansion] Client character is nil!")
		return nil
	end
	if client.NetID ~= character.NetID then
		cLen = cLen + 1
		checkCharacters[cLen] = {Tags=GameHelpers.GetAllTags(client, true, true), Character=client}
	end
	cLen = cLen + 1
	checkCharacters[cLen] = {Tags=GameHelpers.GetAllTags(character, true, true), Character=character}

	if tooltipType == "status" and status then
		local source = GameHelpers.TryGetObject(status.StatusSourceHandle)
		if source and GameHelpers.Ext.ObjectIsCharacter(source) and source.NetID ~= character.NetID then
			cLen = cLen + 1
			---@cast source EclCharacter
			checkCharacters[cLen] = {Tags=GameHelpers.GetAllTags(source, true, true), Character=source}
		end
	end
	for rankTag,tbl in MasteryBonusManager.GetOrderedMasteryRanks() do
		local hasRequirement,masteryCharacter = _AnyCharacterHasMasteryRequirement(checkCharacters, rankTag, cLen)
		if hasRequirement then
			local addedRankName = false
			for i=1,#tbl do
				local v = tbl[i]
				local text = EvaluateEntryForBonusText(v, masteryCharacter, skillOrStatus, tooltipType, status, ...)
				if text then
					if not addedRankName then
						local rankName = GameHelpers.GetStringKeyText(rankTag, "")
						if not StringHelpers.IsNullOrWhitespace(rankName) then
							textEntries[#textEntries+1] = rankName
						end
					end
					textEntries[#textEntries+1] = text
				end
			end
		end
	end
	if #textEntries > 0 then
		return GameHelpers.Tooltip.ReplacePlaceholders(StringHelpers.Join("<br>", textEntries), character)
	else
		return nil
	end
end

local bonusScriptNames = {
	"Axe.lua",
	"Banner.lua",
	"BattleBook.lua",
	"Bludgeon.lua",
	"Bow.lua",
	"Crossbow.lua",
	"Dagger.lua",
	"DualShields.lua",
	"Firearm.lua",
	"Greatbow.lua",
	"HandCrossbow.lua",
	"Katana.lua",
	"Pistol.lua",
	"Polearm.lua",
	"Quarterstaff.lua",
	"Rapier.lua",
	"Runeblade.lua",
	"Scythe.lua",
	"Shield.lua",
	"Staff.lua",
	"Sword.lua",
	"Throwing.lua",
	"Unarmed.lua",
	"Wand.lua",
}

for i,v in pairs(bonusScriptNames) do
	Ext.Require("Shared/Mastery/Bonuses/"..v)
end

--deprecated tables
Mastery.BonusID = {}
Mastery.Params.SkillData = {}
Mastery.Params.StatusData = {}

function Mastery.InitializeHelperTables()
	local mID = {}
	for k,v in pairs(MasteryID) do
		mID[#mID+1] = v
	end
	table.sort(mID)
	OrderedMasteries = mID
end

Ext.RegisterListener("SessionLoaded", Mastery.InitializeHelperTables)

---@param character CharacterParam
---@param bonusID string
---@return boolean
function MasteryBonusManager.IsBonusDisabled(character, bonusID)
	character = GameHelpers.GetCharacter(character)
	local characterId = GameHelpers.GetObjectID(character)
	local targetTable = _INTERNAL.CharacterDisabledBonuses[characterId]
	if targetTable then
		return targetTable[bonusID] == true
	end
	return false
end

---@param character CharacterParam
---@param bonusID string
---@param disabled boolean|nil
---@return boolean
function MasteryBonusManager.SetBonusDisabled(character, bonusID, disabled)
	local b = disabled
	if disabled == nil then
		b = true
	end
	character = GameHelpers.GetCharacter(character)
	local characterId = GameHelpers.GetObjectID(character)
	local targetTable = _INTERNAL.CharacterDisabledBonuses[characterId]
	if not targetTable and b then
		_INTERNAL.CharacterDisabledBonuses[characterId] = {}
		targetTable = _INTERNAL.CharacterDisabledBonuses[characterId]
	end
	if targetTable then
		if disabled == nil then
			b = not targetTable[bonusID] == true
		end
		if b then
			targetTable[bonusID] = true
			return true
		else
			targetTable[bonusID] = nil
			if not Common.TableHasAnyEntry(targetTable) then
				_INTERNAL.CharacterDisabledBonuses[characterId] = nil
			end
		end
	end
	return false
end

if not _ISCLIENT then
	Events.SyncData:Subscribe(function (e)
		local data = PersistentVars.DisabledBonuses[e.UUID]
		if data then
			GameHelpers.Net.PostToUser(e.UserID, "LLWEAPONEX_MasteryBonusManager_SyncCharacterDisabledBonuses", {NetID=GameHelpers.GetNetID(e.UUID), Data=data})
		end
	end)

	Ext.RegisterNetListener("LLWEAPONEX_MasteryBonusManager_DisableBonus", function (cmd, payload)
		local data = Common.JsonParse(payload)
		if data and data.NetID then
			local character = GameHelpers.GetCharacter(data.NetID)
			MasteryBonusManager.SetBonusDisabled(character, data.Bonus, data.Disabled == true)
		end
	end)

	Ext.RegisterNetListener("LLWEAPONEX_MasteryBonusManager_DisableMultipleBonuses", function (cmd, payload)
		---@type {NetID:integer, Bonuses:table<string,boolean>}
		local data = Common.JsonParse(payload)
		if data and data.NetID then
			local character = GameHelpers.GetCharacter(data.NetID)
			for id,b in pairs(data.Bonuses) do
				MasteryBonusManager.SetBonusDisabled(character, id, b)
			end
		end
	end)
else
	Ext.RegisterNetListener("LLWEAPONEX_MasteryBonusManager_SyncCharacterDisabledBonuses", function (cmd, payload)
		local data = Common.JsonParse(payload)
		if data and data.NetID then
			_INTERNAL.CharacterDisabledBonuses[data.NetID] = data.Data
		end
	end)

	---@type ContextMenuAction
	local ToggleBonusesCM = nil

	ToggleBonusesCM = Classes.ContextMenuAction:Create({
		ID = "LLWEAPONEX_ToggleMasteryBonuses",
		DisplayName = "Toggle Mastery Bonuses",
		Children = {},
		ShouldOpen = function (contextMenu, x, y)
			local cursor = Ext.UI.GetPickingState()
			if cursor and GameHelpers.IsValidHandle(cursor.HoverCharacter) then
				local character = GameHelpers.GetCharacter(cursor.HoverCharacter)
				if character then
					if character.NetID == Client.Character.NetID then
						local bonuses,hasBonus = MasteryBonusManager.GetMasteryBonuses(character)
						if hasBonus then
							local orderedBonuses = {}
							for id,b in pairs(bonuses) do
								orderedBonuses[#orderedBonuses+1] = id
							end
							table.sort(orderedBonuses)
							local netid = character.NetID
							local toggleBonus = function (self, ui, id, actionID, handle, entry)
								local character = GameHelpers.GetCharacter(netid)
								local disabled = MasteryBonusManager.SetBonusDisabled(character, handle)
								Ext.Net.PostMessageToServer("LLWEAPONEX_MasteryBonusManager_DisableBonus", Common.JsonStringify({NetID=netid, Bonus=handle, Disabled=disabled}))
							end
							ToggleBonusesCM.Children = {
								Classes.ContextMenuAction:Create({
									ID = "LLWEAPONEX_ToggleBonus_EnableAll",
									DisplayName = "Enable All",
									ActionID = "LLWEAPONEX_ToggleBonus_EnableAll",
									Callback = function ()
										local character = GameHelpers.GetCharacter(netid)
										local updateData = {
											NetID = netid,
											Bonuses = {}
										}
										for _,id in pairs(orderedBonuses) do
											updateData.Bonuses[id] = false
											MasteryBonusManager.SetBonusDisabled(character, id, false)
										end
										Ext.Net.PostMessageToServer("LLWEAPONEX_MasteryBonusManager_DisableMultipleBonuses", Common.JsonStringify(updateData))
									end,
								}),
								Classes.ContextMenuAction:Create({
									ID = "LLWEAPONEX_ToggleBonus_DisableAll",
									DisplayName = "Disable All",
									ActionID = "LLWEAPONEX_ToggleBonus_DisableAll",
									Callback = function ()
										local character = GameHelpers.GetCharacter(netid)
										local updateData = {
											NetID = netid,
											Bonuses = {}
										}
										for _,id in pairs(orderedBonuses) do
											updateData.Bonuses[id] = true
											MasteryBonusManager.SetBonusDisabled(character, id, true)
										end
										Ext.Net.PostMessageToServer("LLWEAPONEX_MasteryBonusManager_DisableMultipleBonuses", Common.JsonStringify(updateData))
									end,
								})
							}
							for i=1,#orderedBonuses do
								local id = orderedBonuses[i]
								local displayName = GameHelpers.GetStringKeyText(id, id)
								local isDisabled = MasteryBonusManager.IsBonusDisabled(character, id)
								if isDisabled then
									displayName = string.format("<font color='#FF3333'>%s</font>", displayName)
								end
								local icon = nil
								local bonus = MasteryBonusManager.GetBonusByID(id)
								if bonus then
									if bonus.Skills and bonus.Skills[1] then
										local skill = bonus.Skills[1]
										if not GameHelpers.Skill.IsAction(skill) then
											local icon_check = GameHelpers.Stats.GetAttribute(skill, "Icon", "")
											if not StringHelpers.IsNullOrWhitespace(icon_check) then
												icon = icon_check
											end
										else
											if skill == "ActionAttackGround" then
												icon = "Action_AttackGround"
											else
												--TODO Replace with LLWEAPONEX_UI_PassiveBonus
												if isDisabled then
													icon = "Reputation Manager"
												else
													icon = "Reputation Manager_a"
												end
											end
										end
									elseif bonus.AllSkills then
										icon = "Talent_AllSkilledUp"
									end
									if not icon and bonus.Statuses then
										for _,v in pairs(bonus.Statuses) do
											local icon_check = GameHelpers.Stats.GetAttribute(v, "Icon", "")
											if not StringHelpers.IsNullOrWhitespace(icon_check) then
												icon = icon_check
												break
											end
										end
									end
								end
								ToggleBonusesCM.Children[#ToggleBonusesCM.Children+1] = Classes.ContextMenuAction:Create({
									ID = string.format("LLWEAPONEX_ToggleBonus_%s", id),
									DisplayName = displayName,
									ActionID = id,
									Callback = toggleBonus,
									Handle = id,
									Icon = icon
								})
							end
							return true
						end
					end
				end
			end
		end
	})

	UI.ContextMenu.Register.Action(ToggleBonusesCM)
end

Ext.RegisterConsoleCommand("weaponex_dumpbonuses", function (cmd, ...)
	local ids = {}
	for tag,tbl in pairs(_registeredBonuses) do
		for _,v in pairs(tbl) do
			ids[#ids+1] = v.ID
		end
	end
	table.sort(ids)
	local text = "Key\tContent\tHandle\n"
	for i=1,#ids do
		local v = ids[i]
		local name,handle = Ext.GetTranslatedString(v, v)
		text = text .. string.format("%s\t%s\t%s\n", v, name, handle or "")
	end
	Ext.Utils.Print("Saved bonus names to 'Dumps/WeaponExpansion_Bonuses.tsv'")
	GameHelpers.IO.SaveFile("Dumps/WeaponExpansion_Bonuses.tsv", text)
end)