local isClient = Ext.IsClient()

---@alias MasteryBonusCheckTarget string|'"Any"'|'"Target"'|'"Source"'
---@alias WeaponExpansionMasterySkillListenerCallback fun(bonuses:string[], skill:string, char:string, state:SKILL_STATE, data:SkillEventData|HitData):void
---@alias MasteryBonusStatusCallback fun(bonuses:table<string,table<UUID,boolean>>, target:string, status:string, source:string, statusType:string)
---@alias MasteryBonusStatusBeforeAttemptCallback fun(bonuses:table<string,table<UUID,boolean>>, target:EsvCharacter|EsvItem, status:EsvStatus, source:EsvCharacter|EsvItem|nil, handle:integer, statusType:string):boolean

MasteryBonusManager = {
	Vars = {
		RushSkills = {"Rush_BatteringRam", "Rush_BullRush", "Rush_EnemyBatteringRam", "Rush_EnemyBullRush"}
	}
}

local _registeredBonuses = {}

local masteryRankBonusPattern = "(.-)_Mastery(%d+)"

---@deprecated
Mastery.Bonuses = {}
setmetatable(Mastery.Bonuses, {
	__index = _registeredBonuses,
	__newindex = function (tbl, k, v)
		Ext.PrintError("Please don't add to WeaponExpansion.Mastery.Bonuses directly. Use Mastery.Register.NewRankBonus or MasteryBonusManager.AddRankBonuses", k)
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
		Ext.PrintError("WeaponExpansion.MasteryDataClasses.BonusIDEntry is deprecated.")
		return {}
	end
}

---@param char string
---@param skill ?string Optional skilto filter with.
---@param checkBonusOn ?MasteryBonusCheckTarget
---@return table<string, boolean>
function MasteryBonusManager.GetMasteryBonuses(char, skill, checkBonusOn)
	---@type EsvCharacter|EclCharacter
	local character = GameHelpers.GetCharacter(char)
	local bonuses = {}
	if character then
		for tag,tbl in pairs(_registeredBonuses) do
			if Mastery.HasMasteryRequirement(character, tag) then
				for _,v in pairs(tbl) do
					if v.ID then
						if skill == nil or GameHelpers.Skill.IsAction(skill) then
							bonuses[v.ID] = true
						elseif v.Skills ~= nil and Common.TableHasEntry(v.Skills, skill) then
							bonuses[v.ID] = true
						end
					else
						fprint(LOGLEVEL.ERROR, "[LLWEAPONEX] Bonus is lacking an ID parameter:\n%s", Common.JsonStringify(v))
					end
				end
			end
		end
	end
	return bonuses
end

---@param character UUID|NETID|EsvCharacter|EclCharacter|StatCharacter
---@param bonus string|string[]
---@return boolean
function MasteryBonusManager.HasMasteryBonus(character, bonus)
	---@type EsvCharacter|EclCharacter
	local character = GameHelpers.GetCharacter(character)
	if character then
		for tag,tbl in pairs(_registeredBonuses) do
			if Mastery.HasMasteryRequirement(character, tag) then
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

local function HasMatchedBonuses(bonuses, matchBonuses)
	if matchBonuses == nil or matchBonuses == "" then
		return true
	end
	if type(matchBonuses) == "string" then
		return bonuses[matchBonuses] ~= nil
	else
		if #matchBonuses <= 0 then
			return true
		end
		for i,v in pairs(matchBonuses) do
			if bonuses[v] ~= nil then
				return true
			end
		end
	end
	return false
end

local function OnSkillCallback(callback, matchBonuses, skill, char, checkBonusOn, ...)
	local bonuses = MasteryBonusManager.GetMasteryBonuses(char, skill, checkBonusOn)
	if HasMatchedBonuses(bonuses, matchBonuses) then
		callback(bonuses, skill, char, ...)
	end
end

local function OnSkillTypeCallback(callback, matchBonuses, uuid, checkBonusOn, ...)
	local bonuses = MasteryBonusManager.GetMasteryBonuses(uuid, nil, checkBonusOn)
	if HasMatchedBonuses(bonuses, matchBonuses) then
		callback(bonuses, uuid, ...)
	end
end

---@param skill string|string[]
---@param matchBonuses string|string[]
---@param callback WeaponExpansionMasterySkillListenerCallback
---@param checkBonusOn MasteryBonusCheckTarget
function MasteryBonusManager.RegisterSkillListener(skill, matchBonuses,
	callback, checkBonusOn)
	if isClient then return end
	checkBonusOn = checkBonusOn or "Source"
	if type(skill) == "table" then
		for i,v in pairs(skill) do
			RegisterSkillListener(v, function(inskill, char, ...)
				OnSkillCallback(callback, matchBonuses, inskill, char, checkBonusOn, ...)
			end)
		end
	else
		RegisterSkillListener(skill, function(inskill, char, ...)
			OnSkillCallback(callback, matchBonuses, inskill, char, checkBonusOn, ...)
		end)
	end
end

local function OnSkillTypeCallback(callback, matchBonuses, uuid, checkBonusOn, ...)
	local bonuses = MasteryBonusManager.GetMasteryBonuses(uuid, nil, checkBonusOn)
	checkBonusOn = checkBonusOn or "Source"
	if HasMatchedBonuses(bonuses, matchBonuses) then
		callback(bonuses, uuid, ...)
	end
end

---@param skillType string|string[]
---@param matchBonuses string|string[]
---@param callback WeaponExpansionMasterySkillListenerCallback
---@param checkBonusOn MasteryBonusCheckTarget
function MasteryBonusManager.RegisterSkillTypeListener(skillType, matchBonuses,
	callback, checkBonusOn)
	checkBonusOn = checkBonusOn or "Source"
	if type(skillType) == "table" then
		for i,v in pairs(skillType) do
			SkillManager.RegisterTypeListener(v, function(uuid, ...)
				OnSkillTypeCallback(callback, matchBonuses, uuid, checkBonusOn, ...)
			end)
		end
	else
		SkillManager.RegisterTypeListener(skillType, function(uuid, ...)
			OnSkillTypeCallback(callback, matchBonuses, uuid, checkBonusOn, ...)
		end)
	end
end

local function GetStatusListenerMasteryBonuses(target, source, checkBonusOn)
	local bonuses = {}
	if (checkBonusOn == "Source" or checkBonusOn == "Any") and source ~= StringHelpers.NULL_UUID and GameHelpers.Ext.ObjectIsCharacter(source) then
		for bonus,_ in pairs(MasteryBonusManager.GetMasteryBonuses(source, nil, checkBonusOn)) do
			if bonuses[bonus] == nil then
				bonuses[bonus] = {}
			end
			bonuses[bonus][target] = true
		end
	end
	if target ~= StringHelpers.NULL_UUID
	and (checkBonusOn == "Target" or checkBonusOn == "Any" or StringHelpers.IsNullOrEmpty(source))
	and GameHelpers.Ext.ObjectIsCharacter(target)
	then
		for bonus,_ in pairs(MasteryBonusManager.GetMasteryBonuses(target, nil, checkBonusOn)) do
			if bonuses[bonus] == nil then
				bonuses[bonus] = {}
			end
			bonuses[bonus][source] = true
		end
	end
	return bonuses
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
	local bonuses = GetStatusListenerMasteryBonuses(target, source, checkBonusOn)
	if HasMatchedBonuses(bonuses, matchBonuses) then
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
	if isClient then return end
	checkBonusOn = checkBonusOn or "Any"
	if type(status) == "table" then
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
	if isClient then return end
	checkBonusOn = checkBonusOn or "Any"
	if type(statusType) == "table" then
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
---@param source ?EsvCharacter
---@param checkBonusOn MasteryBonusCheckTarget
local function OnStatusAttemptCallback(callback, matchBonuses, target, status, source, handle, statusType, skipBonusCheck, checkBonusOn)
	if skipBonusCheck ~= true then
		checkBonusOn = checkBonusOn or "Any"
		local bonuses = GetStatusListenerMasteryBonuses(target, source, checkBonusOn)
		if HasMatchedBonuses(bonuses, matchBonuses) then
			local b,result = xpcall(callback, debug.traceback, bonuses, target, status, source, handle, statusType)
			if b then
				if result == false then
					NRD_StatusPreventApply(target, handle, 1)
				elseif result == true then
					NRD_StatusPreventApply(target, handle, 0)
				end
			else
				Ext.PrintError(result)
			end
		end
	else
		local b,result = xpcall(callback, debug.traceback, nil, target, status, source, handle, statusType)
		if b then
			if result == false then
				NRD_StatusPreventApply(target, handle, 1)
			elseif result == true then
				NRD_StatusPreventApply(target, handle, 0)
			end
		else
			Ext.PrintError(result)
		end
	end
end

---@param status string|string[]
---@param matchBonuses string|string[]
---@param callback MasteryBonusStatusBeforeAttemptCallback
---@param skipBonusCheck boolean
---@param checkBonusOn MasteryBonusCheckTarget
function MasteryBonusManager.RegisterStatusAttemptListener(status, matchBonuses, callback,
	skipBonusCheck, checkBonusOn)
	if isClient then return end
	checkBonusOn = checkBonusOn or "Source"
	if type(status) == "table" then
		for i,v in pairs(status) do
			MasteryBonusManager.RegisterStatusAttemptListener(v, matchBonuses, callback, skipBonusCheck, checkBonusOn)
		end
	else
		RegisterStatusListener("BeforeAttempt", status, function(target, status, source, handle, statusType)
			OnStatusAttemptCallback(callback, matchBonuses, target, status, source, handle, statusType, skipBonusCheck, checkBonusOn)
		end)
	end
end

---@class MasteryBonusManagerClosestEnemyData
---@field UUID string
---@field Dist number

---Get a table of enemies in combat, determined by distance to a source.
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

	local t = type(target)
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

---@param mastery string
---@param rank integer
---@param bonuses MasteryBonusData|MasteryBonusData[]
function MasteryBonusManager.AddRankBonuses(mastery, rank, bonuses)
	local masteryRankID = string.format("%s_Mastery%s", mastery, rank)
	if not _registeredBonuses[masteryRankID] then
		_registeredBonuses[masteryRankID] = {}
	end
	---@type MasteryData
	local masteryData = Masteries[mastery]
	if masteryData and not masteryData.RankBonuses[rank] then
		masteryData.RankBonuses[rank] = MasteryDataClasses.MasteryRankData:Create(rank, masteryRankID)
		masteryData.RankBonuses[rank].Bonuses = _registeredBonuses[masteryRankID]
	end
	local t = type(bonuses)
	if t == "table" then
		if bonuses.Type == "MasteryBonusData" then
			table.insert(_registeredBonuses[masteryRankID], bonuses)
		else
			for k,v in pairs(bonuses) do
				table.insert(_registeredBonuses[masteryRankID], v)
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
		end
	else
		--Old style
		local bonusIsActive = true
		if data.Active ~= nil and data.Active.Type == "Tag" then
			if data.Active.Source == true and type(status) == "userdata" then
				if status.StatusSourceHandle ~= nil then
					local source = GameHelpers.GetCharacter(status.StatusSourceHandle)
					if source then
						bonusIsActive = GameHelpers.CharacterOrEquipmentHasTag(source, data.Active.Value)
					end
				end
				bonusIsActive = GameHelpers.CharacterOrEquipmentHasTag(character, data.Active.Value)
			else
				bonusIsActive = GameHelpers.CharacterOrEquipmentHasTag(character, data.Active.Value)
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

---@param character EsvCharacter|EclCharacter
---@param skillOrStatus string
---@param tooltipType MasteryBonusDataTooltipID
function MasteryBonusManager.GetBonusText(character, skillOrStatus, tooltipType, ...)
	local textEntries = {}
	for rankTag,tbl in MasteryBonusManager.GetOrderedMasteryRanks() do
		if Debug.MasteryTests or Mastery.HasMasteryRequirement(character, rankTag) then
			local addedRankName = false
			for _,v in pairs(tbl) do
				local text = EvaluateEntryForBonusText(v, character, skillOrStatus, tooltipType, ...)
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