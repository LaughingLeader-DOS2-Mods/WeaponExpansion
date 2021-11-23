local isClient = Ext.IsClient()

MasteryBonusManager = {
	Vars = {
		RushSkills = {"Rush_BatteringRam", "Rush_BullRush", "Rush_EnemyBatteringRam", "Rush_EnemyBullRush"}
	},
}
if Mastery.Bonuses == nil then
	Mastery.Bonuses = {}
end

---@param char string
---@param skill string|nil
---@return table<string, boolean>
function MasteryBonusManager.GetMasteryBonuses(char, skill)
	---@type EsvCharacter|EclCharacter
	local character = GameHelpers.GetCharacter(char)

	local bonuses = {}
	if character then
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
	end
	return bonuses
end

---@param uuid string
---@param bonus string|string[]
---@return boolean
function MasteryBonusManager.HasMasteryBonus(uuid, bonus)
	---@type EsvCharacter|EclCharacter
	local character = GameHelpers.GetCharacter(uuid)
	if character then
		local t = type(bonus)
		for tag,tbl in pairs(Mastery.Bonuses) do
			if Mastery.HasMasteryRequirement(character, tag) then
				for bonusName,_ in pairs(tbl) do
					if t == "table" then
						for i,v in pairs(bonus) do
							if v == bonusName then
								return true
							end
						end
					elseif bonusName == bonus then
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

---@alias WeaponExpansionMasterySkillListenerCallback fun(bonuses:string[], skill:string, char:string, state:SKILL_STATE, data:SkillEventData|HitData):void

local function OnSkillTypeCallback(callback, matchBonuses, uuid, ...)
	local bonuses = MasteryBonusManager.GetMasteryBonuses(uuid, nil)
	if HasMatchedBonuses(bonuses, matchBonuses) then
		callback(bonuses, uuid, ...)
	end
end

---@param skill string|string[]
---@param matchBonuses string|string[]
---@param callback WeaponExpansionMasterySkillListenerCallback
function MasteryBonusManager.RegisterSkillListener(skill, matchBonuses, callback)
	if Vars.IsClient then return end
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

---@param skillType string|string[]
---@param matchBonuses string|string[]
---@param callback WeaponExpansionMasterySkillListenerCallback
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

local function OnStatusCallback(callback, matchBonuses, target, status, source, statusType)
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
		callback(bonuses, target, status, source, statusType)
	end
end

---@alias MasteryBonusStatusCallback fun(bonuses:table<string,table<UUID,boolean>>, target:string, status:string, source:string, statusType:string)
---@alias MasteryBonusStatusBeforeAttemptCallback fun(bonuses:table<string,table<UUID,boolean>>, target:EsvCharacter|EsvItem, status:EsvStatus, source:EsvCharacter|EsvItem|nil, handle:integer, statusType:string):boolean

---@param event string
---@param status string|string[]
---@param matchBonuses string|string[]
---@param callback MasteryBonusStatusCallback
function MasteryBonusManager.RegisterStatusListener(event, status, matchBonuses, callback)
	if Vars.IsClient then return end
	if type(status) == "table" then
		for i,v in pairs(status) do
			MasteryBonusManager.RegisterStatusListener(event, v, matchBonuses, callback)
		end
	else
		local wrapperCallback = function(target, status, source, statusType)
			OnStatusCallback(callback, matchBonuses, target, status, source, statusType)
		end
		RegisterStatusListener(event, status, wrapperCallback)
	end
end


---@param target EsvCharacter
---@param source EsvCharacter|nil
local function OnStatusAttemptCallback(callback, matchBonuses, target, status, source, handle, statusType, skipBonusCheck)
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
function MasteryBonusManager.RegisterStatusAttemptListener(status, matchBonuses, callback, skipBonusCheck)
	if Vars.IsClient then return end
	if type(status) == "table" then
		for i,v in pairs(status) do
			MasteryBonusManager.RegisterStatusAttemptListener(v, matchBonuses, callback, skipBonusCheck)
		end
	else
		RegisterStatusListener("BeforeAttempt", status, function(target, status, source, handle, statusType)
			OnStatusAttemptCallback(callback, matchBonuses, target, status, source, handle, statusType, skipBonusCheck)
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
---@param bonuses MasteryRankBonus|MasteryRankBonus[]
function MasteryBonusManager.AddRankBonuses(mastery, rank, bonuses)
	local masteryRankID = string.format("%s_Mastery%s", mastery, rank)
	if not Mastery.Bonuses[masteryRankID] then
		Mastery.Bonuses[masteryRankID] = {}
	end
	local t = type(bonuses)
	if t == "table" then
		if bonuses.Type == "MasteryRankBonus" then
			table.insert(Mastery.Bonuses[masteryRankID], bonuses)
		else
			for k,v in pairs(bonuses) do
				table.insert(Mastery.Bonuses[masteryRankID], v)
			end
		end
	end
end

---@param character EsvCharacter|EclCharacter
---@param skillOrStatus string
---@param isStatus boolean
function MasteryBonusManager.GetBonusText(character, skillOrStatus, isStatus, ...)
	local textEntries = {}
	local params = {...}
	for tag,tbl in pairs(Mastery.Bonuses) do
		if Mastery.HasMasteryRequirement(character, tag) then
			for bonusName,entries in pairs(tbl) do
				if type(entries) == "table" then
					for i,data in pairs(entries) do
						if type(data) == "table" then
							if data.Type == "MasteryRankBonus" then
								local bonusText = data:GetTooltipText(character, skillOrStatus, ...)
								if not StringHelpers.IsNullOrWhitespace(bonusText) then
									textEntries[#textEntries+1] = bonusText
								end
							else
								--Old style
								local bonusIsActive = true
								if data.Active ~= nil then
									if data.Active.Type == "Tag" then
										if data.Active.Source == true and type(params[1]) == "userdata" then
											local status = params[1]
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
								end
								if bonusIsActive then
									local descriptionText = TooltipHandler.GetDescriptionText(character, data, params[1], true)
									if not StringHelpers.IsNullOrWhitespace(descriptionText) then
										textEntries[#textEntries+1] = descriptionText
									end
								end
							end
						end
					end
				end
			end
		end
	end
	if #textEntries > 0 then
		return StringHelpers.Join("<br>", textEntries)
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

function Mastery.InitBonusIdentifiers()
	
end