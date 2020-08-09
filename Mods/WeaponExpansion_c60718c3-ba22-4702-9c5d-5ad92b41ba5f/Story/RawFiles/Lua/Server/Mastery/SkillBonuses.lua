MasteryBonusManager = {}

HitData = LeaderLib.Classes.HitData

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

function MasteryBonusManager.GetMasteryBonuses(char, skill)
	local character = Ext.GetCharacter(char)
	local bonuses = {}
	local data = Mastery.Params.SkillData[skill]
	if data ~= nil and data.Tags ~= nil then
		for tagName,tagData in pairs(data.Tags) do
			if Mastery.HasMasteryRequirement(character, tagName) then
				bonuses[tagData.ID] = true
			end
		end
	end
	return bonuses
end

local function OnSkillCallback(callback, matchBonuses, skill, char, ...)
	local bonuses = MasteryBonusManager.GetMasteryBonuses(char, skill)
	if matchBonuses == nil then
		callback(bonuses, skill, char, ...)
	else
		for i,v in pairs(matchBonuses) do
			if bonuses[v] == true then
				callback(bonuses, skill, char, ...)
				break
			end
		end
	end
end

function MasteryBonusManager.RegisterSkillListener(skill, matchBonuses, callback)
	if type(skill) == "table" then
		for i,v in pairs(skill) do
			LeaderLib.RegisterSkillListener(v, function(inskill, char, ...)
				OnSkillCallback(callback, matchBonuses, inskill, char, ...)
			end)
		end
	else
		LeaderLib.RegisterSkillListener(skill, function(inskill, char, ...)
			OnSkillCallback(callback, matchBonuses, inskill, char, ...)
		end)
	end
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
				not LeaderLib.IsSneakingOrInvisible(char)) then
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

local warChargeStatuses = {
	"LLWEAPONEX_WARCHARGE_DAMAGEBOOST",
	"LLWEAPONEX_WARCHARGE_BONUS",
	"LLWEAPONEX_WARCHARGE01",
	"LLWEAPONEX_WARCHARGE02",
	"LLWEAPONEX_WARCHARGE03",
	"LLWEAPONEX_WARCHARGE04",
	"LLWEAPONEX_WARCHARGE05",
	"LLWEAPONEX_WARCHARGE06",
	"LLWEAPONEX_WARCHARGE07",
	"LLWEAPONEX_WARCHARGE08",
	"LLWEAPONEX_WARCHARGE09",
	"LLWEAPONEX_WARCHARGE10",
}

---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param skillData HitData
local function RushBonus(skill, char, state, skillData)
	if state == SKILL_STATE.CAST then
		local bonuses = MasteryBonusManager.GetMasteryBonuses(char, skill)
		if bonuses["WAR_CHARGE_RUSH"] == true then
			local hasStatus = false
			for i,status in pairs(warChargeStatuses) do
				if HasActiveStatus(char, status) == 1 then
					hasStatus = true
					break
				end
			end
			if hasStatus then
				Osi.LeaderLib_Timers_StartObjectTimer(char, 1000, "Timers_LLWEAPONEX_ApplyHasted", "LLWEAPONEX_ApplyHasted")
				--ApplyStatus(char, "HASTED", 6.0, 0, char)
			end
		end
	elseif state == SKILL_STATE.HIT and skillData.ID == HitData.ID then
		local target = skillData.Target
		local handle = skillData.Handle
		local damageAmount = skillData.Damage
		if target ~= nil and damageAmount ~= nil and damageAmount > 0 then
			local bonuses = MasteryBonusManager.GetMasteryBonuses(char, skill)
			if bonuses["WAR_CHARGE_RUSH"] == true then
				local hasStatus = false
				for i,status in pairs(warChargeStatuses) do
					if HasActiveStatus(char, status) == 1 then
						hasStatus = true
						break
					end
				end
				if hasStatus then
					local bonusPercent = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_WarChargeDamageBoost", 25.0)
					if bonusPercent > 0 then
						GameHelpers.IncreaseDamage(target, char, handle, bonusPercent/100, 0)
					end
				end
			end
			if bonuses["RUSH_DIZZY"] == true then
				local forceDist = Ext.Random(2,4)
				local forceProjectile = "Projectile_LeaderLib_Force"..tostring(math.floor(forceDist))
				CharacterStatusText(char, "Force! " .. forceProjectile)
				GameHelpers.ShootProjectile(char, target, forceProjectile, true)
				local dizzyChance = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_RushDizzyChance", 40.0)
				if dizzyChance > 0 then
					local dizzyDuration = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_RushDizzyTurns", 1.0) * 6.0
					if Ext.Random(0,100) <= dizzyChance then
						ApplyStatus(target, "LLWEAPONEX_DIZZY", dizzyDuration, 0, char)
					end
				end
			end
		end
	end
end
LeaderLib.RegisterSkillListener("Rush_BatteringRam", RushBonus)
LeaderLib.RegisterSkillListener("Rush_EnemyBatteringRam", RushBonus)
LeaderLib.RegisterSkillListener("Rush_BullRush", RushBonus)
LeaderLib.RegisterSkillListener("Rush_EnemyBullRush", RushBonus)

---@param char string
---@param skill string
---@param element string
function OnRushSkillCast(char, skill, element)

end
