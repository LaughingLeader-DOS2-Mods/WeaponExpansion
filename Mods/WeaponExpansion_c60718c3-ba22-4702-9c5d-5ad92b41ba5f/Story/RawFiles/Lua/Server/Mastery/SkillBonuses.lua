MasteryBonusManager = {}

HitData = LeaderLib.Classes.HitData

---@param char string
---@param skill string|nil
---@return table<string, boolean>
function MasteryBonusManager.GetMasteryBonuses(char, skill)
	---@type EsvCharacter
	local character = nil
	if type(char) ~= "userdata" then
		if ObjectExists(char) == 0 or ObjectIsCharacter(char) == 0 then
			return
		end
		character = Ext.GetCharacter(char)
	else
		character = char
	end

	local bonuses = {}
	for tag,tbl in pairs(Mastery.Bonuses) do
		if Mastery.HasMasteryRequirement(character, tag) then
			for bonusName,v in pairs(tbl) do
				if skill == nil then
					bonuses[bonusName] = true
				elseif v.Skills ~= nil then
					for _,bonusReqSkill in pairs(v.Skills) do
						if bonusReqSkill == skill then
							bonuses[bonusName] = true
						end
					end
				end
			end
		end
	end
	return bonuses
end

---@param uuid string
---@param bonus string|table<string,boolean>
---@return boolean
function MasteryBonusManager.HasMasteryBonuses(uuid, bonus)
	local character = uuid
	local t = type(uuid)
	if t == "string" or t == "number" then
		character = Ext.GetCharacter(uuid)
	end
	for tag,tbl in pairs(Mastery.Bonuses) do
		if Mastery.HasMasteryRequirement(character, tag) then
			for bonusName,_ in pairs(tbl) do
				if type(bonus) == "table" then
					for i,v in pairs(bonus) do
						if v == bonusName then
							return true
						end
					end
				else
					if bonusName == bonus then
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
		return bonuses[matchBonuses] == true
	else
		if #matchBonuses <= 0 then
			return true
		end
		for i,v in pairs(matchBonuses) do
			if bonuses[v] == true then
				return true
			end
		end
	end
	return false
end

local function OnSkillCallback(callback, matchBonuses, skill, char, ...)
	local bonuses = MasteryBonusManager.GetMasteryBonuses(char, skill)
	if HasMatchedBonuses(bonuses, matchBonuses) then
		callback(bonuses, skill, char, ...)
	end
end

---@alias WeaponExpansionMasterySkillListenerCallback fun(bonuses:string[], skill:string, char:string, state:SKILL_STATE, data:SkillEventData|HitData)

---@param skill string|string[]
---@param matchBonuses string|string[]
---@param callback WeaponExpansionMasterySkillListenerCallback
function MasteryBonusManager.RegisterSkillListener(skill, matchBonuses, callback)
	if type(skill) == "table" then
		for i,v in pairs(skill) do
			RegisterSkillListener(v, function(inskill, char, ...)
				OnSkillCallback(callback, matchBonuses, inskill, char, ...)
			end)
		end
	else
		RegisterSkillListener(skill, function(inskill, char, ...)
			OnSkillCallback(callback, matchBonuses, inskill, char, ...)
		end)
	end
end

local function OnSkillTypeCallback(callback, matchBonuses, uuid, ...)
	local bonuses = MasteryBonusManager.GetMasteryBonuses(uuid, nil)
	if HasMatchedBonuses(bonuses, matchBonuses) then
		callback(bonuses, uuid, ...)
	end
end

function MasteryBonusManager.RegisterSkillTypeListener(skillType, matchBonuses, callback)
	if type(skillType) == "table" then
		for i,v in pairs(skillType) do
			SkillManager.RegisterTypeListener(v, function(uuid, ...)
				OnSkillTypeCallback(callback, matchBonuses, uuid, ...)
			end)
		end
	else
		SkillManager.RegisterTypeListener(skillType, function(uuid, ...)
			OnSkillTypeCallback(callback, matchBonuses, uuid, ...)
		end)
	end
end

local function OnStatusCallback(callback, matchBonuses, target, status, source)
	local bonuses = {}
	if ObjectIsCharacter(source) == 1 then
		local b = MasteryBonusManager.GetMasteryBonuses(source)
		if #b > 0 then
			for i,v in pairs(b) do
				if bonuses[v] == nil then bonuses[v] = {} end
				bonuses[v][source] = true
			end
		end
	end
	if ObjectIsCharacter(target) == 1 then
		local b = MasteryBonusManager.GetMasteryBonuses(target)
		if #b > 0 then
			for i,v in pairs(b) do
				if bonuses[v] == nil then bonuses[v] = {} end
				bonuses[v][target] = true
			end
		end
	end
	if HasMatchedBonuses(bonuses, matchBonuses) then
		callback(target, status, source, bonuses)
	end
end

---@alias WeaponExpansionMasteryStatusListenerCallback fun(target:string, status:string, source:string, bonuses:table<string,table<string,boolean>>)

---@param event string
---@param status string|string[]
---@param matchBonuses string|string[]
---@param callback WeaponExpansionMasteryStatusListenerCallback
function MasteryBonusManager.RegisterStatusListener(event, status, matchBonuses, callback)
	if type(status) == "table" then
		for i,v in pairs(status) do
			local wrapperCallback = function(target,v,source) 
				OnStatusCallback(callback, matchBonuses, target, v, source)
			end
			RegisterStatusListener(event, v, wrapperCallback)
		end
	else
		local wrapperCallback = function(target,status,source)
			OnStatusCallback(callback, matchBonuses, target, status, source)
		end
		RegisterStatusListener(event, status, wrapperCallback)
	end
end


---@param target EsvCharacter
---@param source EsvCharacter|nil
local function OnStatusAttemptCallback(callback, matchBonuses, target, status, handle, source, skipBonusCheck)
	if skipBonusCheck ~= true then
		local bonuses = {}
		if source and ObjectIsCharacter(source.MyGuid) == 1 then
			local b = MasteryBonusManager.GetMasteryBonuses(source)
			if #b > 0 then
				for i,v in pairs(b) do
					if bonuses[v] == nil then bonuses[v] = {} end
					bonuses[v][source] = true
				end
			end
		end
		if target and ObjectIsCharacter(target.MyGuid) == 1 then
			local b = MasteryBonusManager.GetMasteryBonuses(target)
			if #b > 0 then
				for i,v in pairs(b) do
					if bonuses[v] == nil then bonuses[v] = {} end
					bonuses[v][target] = true
				end
			end
		end
		if HasMatchedBonuses(bonuses, matchBonuses) then
			callback(target, status, handle, source, bonuses)
		end
	else
		callback(target, status, handle, source)
	end
end

function MasteryBonusManager.RegisterStatusAttemptListener(status, matchBonuses, callback, skipBonusCheck)
	if type(status) == "table" then
		for i,v in pairs(status) do
			MasteryBonusManager.RegisterStatusAttemptListener(v, matchBonuses, callback, skipBonusCheck)
		end
	else
		RegisterStatusListener(StatusEvent.BeforeAttempt, status, function(target, status, source, handle, statusType)
			OnStatusAttemptCallback(callback, matchBonuses, target, status, handle, source, skipBonusCheck)
		end)
	end
end

---Get a table of enemies in combat, determined by distance to a source.
---@param char string
---@param target EsvCharacter|EsvItem
---@param radius number
---@param sortByClosest boolean
---@param limit integer
---@param ignoreTarget string
---@return string[]
function MasteryBonusManager.GetClosestEnemiesToObject(char, target, radius, sortByClosest, limit, ignoreTarget)
	if target == nil then
		return {}
	end
	if radius == nil then
		radius = 8
	end
	local lastDist = 999
	local targets = {}
	for _,enemy in pairs(target:GetNearbyCharacters(radius)) do
		if enemy ~= char 
		and enemy ~= ignoreTarget
		and (CharacterIsEnemy(char, enemy) == 1 or IsTagged(enemy, "LLDUMMY_TrainingDummy") == 1)
		and CharacterIsDead(enemy) == 0
		and not GameHelpers.Status.IsSneakingOrInvisible(char)
		then
			local dist = GetDistanceTo(char,enemy)
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
---@param char string
---@param maxDistance number
---@param sortByClosest boolean
---@param limit integer
---@param ignoreTarget string
---@return string[]
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

BonusHelperVars = {
	RushSkills = {"Rush_BatteringRam", "Rush_BullRush", "Rush_EnemyBatteringRam", "Rush_EnemyBullRush"}
}

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
	Ext.Require("Server/Mastery/Bonuses/"..v)
end