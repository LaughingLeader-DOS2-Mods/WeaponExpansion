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

---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param skillData SkillEventData|HitData
local function ShieldsUpBonus(skill, char, state, skillData)
	if state == SKILL_STATE.CAST then
		local bonuses = MasteryBonusManager.GetMasteryBonuses(char, skill)
		if bonuses["GUARANTEED_BLOCK"] == true then
			PlayEffect(char, "RS3_FX_GP_Impacts_Arena_PillarLight_01_Silver", "")
			ApplyStatus(char, "LLWEAPONEX_MASTERYBONUS_SHIELD_BLOCK", -1.0, 0, char)
		end
	end
end
LeaderLib.RegisterSkillListener("Shout_RecoverArmour", ShieldsUpBonus)

---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param skillData SkillEventData|HitData
local function BlitzAttackBonus(skill, char, state, skillData)
	if state == SKILL_STATE.HIT then
		local target = skillData.Target
		if target ~= nil then
			local bonuses = MasteryBonusManager.GetMasteryBonuses(char, skill)
			if bonuses["AXE_VULNERABLE"] == true then
				Mods.LeaderLib.StartTimer("LLWEAPONEX_MasteryBonus_ApplyVulnerable", 50, char, target)
				-- if CharacterIsInCombat(char) == 1 then
				-- 	ApplyStatus(target, "LLWEAPONEX_MASTERYBONUS_VULNERABLE", -1.0, 0, char)
				-- else
				-- 	ApplyStatus(target, "LLWEAPONEX_MASTERYBONUS_VULNERABLE", 6.0, 0, char)
				-- end
			end
		end
	end
end
LeaderLib.RegisterSkillListener("MultiStrike_BlinkStrike", BlitzAttackBonus)
LeaderLib.RegisterSkillListener("MultiStrike_EnemyBlinkStrike", BlitzAttackBonus)

local function BlinkStrike_ApplyVulnerable(timerData)
	local char = timerData[1]
	local target = timerData[2]
	if char ~= nil and target ~= nil and CharacterIsDead(target) == 0 then
		if CharacterIsInCombat(char) == 1 then
			ApplyStatus(target, "LLWEAPONEX_MASTERYBONUS_VULNERABLE", -1.0, 0, char)
		else
			ApplyStatus(target, "LLWEAPONEX_MASTERYBONUS_VULNERABLE", 6.0, 0, char)
		end
	end
end

OnTimerFinished["LLWEAPONEX_MasteryBonus_ApplyVulnerable"] = BlinkStrike_ApplyVulnerable

---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param skillData SkillEventData|HitData
local function SuckerPunchBonus(skill, char, state, skillData)
	if state == SKILL_STATE.CAST then
		local bonuses = MasteryBonusManager.GetMasteryBonuses(char, skill)
		if bonuses["SUCKER_PUNCH_COMBO"] == true then
			ApplyStatus(char, "LLWEAPONEX_WS_RAPIER_SUCKERCOMBO1", 12.0, 0, char)
		end
	elseif state == SKILL_STATE.HIT then
		local target = skillData.Target
		if target ~= nil then
			local bonuses = MasteryBonusManager.GetMasteryBonuses(char, skill)
			if bonuses["SUCKER_PUNCH_COMBO"] == true then
				if HasActiveStatus(target, "KNOCKED_DOWN") == 1 then
					local chance = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_PetrifyingTouch_KnockbackDistance", 4.0)
					if Ext.Random(0,100) <= chance then
						local handle = NRD_StatusGetHandle(target, "KNOCKED_DOWN")
						if handle ~= nil then
							local duration = NRD_StatusGetReal(target, handle, "CurrentLifeTime")
							local lastTurns = math.floor(duration / 6)
							duration = duration + 6.0
							local nextTurns = math.floor(duration / 6)
							NRD_StatusSetReal(target, handle, "CurrentLifeTime", duration)
							local text = Ext.GetTranslatedStringFromKey("LLWEAPONEX_StatusText_StatusExtended")
							if text == nil then
								text = "<font color='#99FF22' size='22'><p align='center'>[1] Extended!</p></font><p align='center'>[2] -> [3]</p>"
							end
							text = text:gsub("%[1%]", Ext.GetTranslatedStringFromKey(Ext.StatGetAttribute("KNOCKED_DOWN", "DisplayName")))
							text = text:gsub("%[2%]", lastTurns)
							text = text:gsub("%[3%]", nextTurns)
							if ObjectIsCharacter(target) == 1 then
								CharacterStatusText(target, text)
							else
								DisplayText(target, text)
							end
						end
					end
				end
			end
		end
	end
end
LeaderLib.RegisterSkillListener("Target_SingleHandedAttack", SuckerPunchBonus)

local function AdrenalineBonuses(skill, char, state, skillData)
	if state == SKILL_STATE.CAST then
		local bonuses = MasteryBonusManager.GetMasteryBonuses(char, skill)
		if bonuses["PISTOL_ADRENALINE"] == true then
			SetTag(char, "LLWEAPONEX_Pistol_Adrenaline_Active")
			CharacterStatusText(char, "LLWEAPONEX_Pistol_Adrenaline_Active")
		end
	end
end
LeaderLib.RegisterSkillListener("Shout_Adrenaline", AdrenalineBonuses)
LeaderLib.RegisterSkillListener("Shout_EnemyAdrenaline", AdrenalineBonuses)

local function TacticalRetreatBonuses(skill, char, state, skillData)
	if state == SKILL_STATE.CAST and CharacterIsInCombat(char) == 1 then
		local bonuses = MasteryBonusManager.GetMasteryBonuses(char, skill)
		if bonuses["JUMP_MARKED"] == true then
			local data = Osi.DB_CombatCharacters:Get(nil, CombatGetIDForCharacter(char))
			if data ~= nil then
				local totalEnemies = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_TacticalRetreat_MaxMarkedTargets", 2)
				local maxDistance = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_TacticalRetreat_MarkingRadius", 4.0)
				local combatEnemies = LeaderLib.Common.ShuffleTable(data)
				for i,v in pairs(combatEnemies) do
					local enemy = v[1]
					if (enemy ~= char and CharacterIsEnemy(char, enemy) == 1 and 
						not LeaderLib.IsSneakingOrInvisible(char) and GetDistanceTo(char,enemy) <= maxDistance) then
							totalEnemies = totalEnemies - 1
							ApplyStatus(enemy, "MARKED", 6.0, 0, char)
					end
					if totalEnemies <= 0 then
						break
					end
				end
			end
		end
	end
end
LeaderLib.RegisterSkillListener("Jump_TacticalRetreat", TacticalRetreatBonuses)
LeaderLib.RegisterSkillListener("Jump_EnemyTacticalRetreat", TacticalRetreatBonuses)

local function CloakAndDaggerBonuses(skill, char, state, skillData)
	if state == SKILL_STATE.CAST then
		local bonuses = MasteryBonusManager.GetMasteryBonuses(char, skill)
		if bonuses["PISTOL_CLOAKEDJUMP"] == true then
			if CharacterHasSkill(char, "Shout_LLWEAPONEX_Pistol_Reload") == 1 then
				LeaderLib.SwapSkill(char, "Shout_LLWEAPONEX_Pistol_Reload", "Target_LLWEAPONEX_Pistol_Shoot")
			end
			if CharacterIsInCombat(char) == 1 then
				Mods.LeaderLib.StartTimer("LLWEAPONEX_MasteryBonus_CloakAndDagger_Pistol_MarkEnemy", 1000, char)
			end
		end
	end
end
LeaderLib.RegisterSkillListener("Jump_CloakAndDagger", CloakAndDaggerBonuses)
LeaderLib.RegisterSkillListener("Jump_EnemyCloakAndDagger", CloakAndDaggerBonuses)

local function CloakAndDagger_Pistol_MarkEnemy(timerData)
	local char = timerData[1]
	if char ~= nil and CharacterIsInCombat(char) == 1 then
		local data = Osi.DB_CombatCharacters:Get(nil, CombatGetIDForCharacter(char))
		if data ~= nil then
			local totalEnemies = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_CloakAndDagger_MaxMarkedTargets", 1)
			local maxDistance = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_CloakAndDagger_MarkingRadius", 6.0)
			local combatEnemies = LeaderLib.Common.ShuffleTable(data)
			local lastDist = 999
			local targets = {}
			for i,v in pairs(combatEnemies) do
				local enemy = v[1]
				if enemy ~= char and
					CharacterIsEnemy(char, enemy) == 1 and 
					CharacterIsDead(enemy) == 0 and 
					not LeaderLib.IsSneakingOrInvisible(char) then
						local dist = GetDistanceTo(char,enemy)
						if dist <= maxDistance then
							if totalEnemies == 1 then
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
				table.sort(targets, function(a,b)
					return a.Dist < b.Dist
				end)
				for i,v in pairs(targets) do
					local target = v.UUID
					ApplyStatus(target, "MARKED", 6.0, 0, char)
					SetTag(target, "LLWEAPONEX_Pistol_MarkedForCrit")
					Osi.LLWEAPONEX_Statuses_ListenForTurnEnding(char, target, "MARKED")
					totalEnemies = totalEnemies - 1
					if totalEnemies <= 0 then
						break
					end
				end
			else
				local target = targets[1]
				ApplyStatus(target, "MARKED", 6.0, 0, char)
				SetTag(target, "LLWEAPONEX_Pistol_MarkedForCrit")
				Osi.LLWEAPONEX_Statuses_ListenForTurnEnding(char, target, "MARKED")
			end
		end
	else
		LeaderLib.PrintDebug("CloakAndDagger_Pistol_MarkEnemy params: "..LeaderLib.Common.Dump(skillData))
	end
end

OnTimerFinished["LLWEAPONEX_MasteryBonus_CloakAndDagger_Pistol_MarkEnemy"] = CloakAndDagger_Pistol_MarkEnemy

---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param skillData SkillEventData|HitData
local function PistolShootBonuses(skill, char, state, skillData)
	if state == SKILL_STATE.HIT then
		local target = skillData.Target
		local damageAmount = skillData.Damage
		if target ~= nil and damageAmount > 0 then
			local handle = skillData.Handle
			if IsTagged(target, "LLWEAPONEX_Pistol_MarkedForCrit") == 1 then
				local critMult = Ext.Round(CharacterGetAbility(char,"RogueLore") * Ext.ExtraData.SkillAbilityCritMultiplierPerPoint) * 0.01
				GameHelpers.IncreaseDamage(target, char, handle, critMult, 0)
				NRD_StatusSetInt(target, handle, "CriticalHit", 1)
				ClearTag(target, "LLWEAPONEX_Pistol_MarkedForCrit")
				--CharacterStatusText(target, string.format("<font color='#FF337F'>%s</font>", Ext.GetTranslatedString("h11065363gf07eg4764ga834g9eeab569ceec", "Critical Hit!")))
				CharacterStatusText(target, "LLWEAPONEX_StatusText_Pistol_MarkedCrit")
			end
			if IsTagged(char, "LLWEAPONEX_Pistol_Adrenaline_Active") == 1 then
				ClearTag(char, "LLWEAPONEX_Pistol_Adrenaline_Active")
				local damageBoost = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_Adrenaline_PistolDamageBoost", 50.0)
				if damageBoost > 0 then
					GameHelpers.IncreaseDamage(target, char, handle, damageBoost * 0.01, 0)
					CharacterStatusText(char, "LLWEAPONEX_StatusText_Pistol_AdrenalineBoost")
				end
			end
		end
	end
end
LeaderLib.RegisterSkillListener("Projectile_LLWEAPONEX_Pistol_Shoot_LeftHand", PistolShootBonuses)
LeaderLib.RegisterSkillListener("Projectile_LLWEAPONEX_Pistol_Shoot_RightHand", PistolShootBonuses)

---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param skillData SkillEventData|HitData
local function PinDownBonuses(skill, char, state, skillData)
	if state == SKILL_STATE.CAST then
		local bonuses = MasteryBonusManager.GetMasteryBonuses(char, skill)
		if bonuses["BOW_DOUBLE_SHOT"] == true then
			-- Support for a mod making Pin Down shoot multiple arrows through the use of iterating tables.
			local shotBonus = false
			local isInCombat = CharacterIsInCombat(char) == 1
			if skillData.TotalTargetObjects ~= nil and skillData.TotalTargetObjects > 0 then
				for i,v in ipairs(skillData.TargetObjects) do
					local target = nil
					if isInCombat then
						local maxDist = Ext.StatGetAttribute(skill, "TargetRadius")
						local targets = MasteryBonusManager.GetClosestCombatEnemies(char, maxDist, true, 3, v)
						if #targets > 0 then
							target = Common.GetRandomTableEntry(targets)
						else
							target = v
						end
					end

					if target ~= nil then
						GameHelpers.ShootProjectile(char, target.UUID, "Projectile_LLWEAPONEX_MasteryBonus_PinDown_BonusShot", true)
						shotBonus = true
					else
						local x,y,z = GetPosition(v)
						y = y + 1.0
						GameHelpers.ShootProjectileAtPosition(char, x,y,z, "Projectile_LLWEAPONEX_MasteryBonus_PinDown_BonusShot")
						shotBonus = true
					end
				end
			end

			if not shotBonus and skillData.TotalTargetPositions ~= nil and skillData.TotalTargetPositions > 0 then
				local character = Ext.GetCharacter(char)
				local rot = character.Stats.Rotation
				local forwardVector = {
					-rot[7] * 1.25,
					0,
					-rot[9] * 1.25,
				}

				for i,v in ipairs(skillData.TargetPositions) do
					local target = nil
					local x,y,z = table.unpack(v)
					if isInCombat then
						local maxDist = Ext.StatGetAttribute(skill, "TargetRadius")
						local targets = MasteryBonusManager.GetClosestCombatEnemies(char, maxDist, true, 3, v)
						if #targets > 0 then
							target = Common.GetRandomTableEntry(targets)
						end
					end

					if target ~= nil then
						GameHelpers.ShootProjectile(char, target.UUID, "Projectile_LLWEAPONEX_MasteryBonus_PinDown_BonusShot", true)
					else
						x = x + forwardVector[1]
						z = z + forwardVector[3]
						GameHelpers.ShootProjectileAtPosition(char, x,y,z, "Projectile_LLWEAPONEX_MasteryBonus_PinDown_BonusShot")
					end
				end
			end
		end
	end
end
LeaderLib.RegisterSkillListener("Projectile_PinDown", PinDownBonuses)
LeaderLib.RegisterSkillListener("Projectile_EnemyPinDown", PinDownBonuses)