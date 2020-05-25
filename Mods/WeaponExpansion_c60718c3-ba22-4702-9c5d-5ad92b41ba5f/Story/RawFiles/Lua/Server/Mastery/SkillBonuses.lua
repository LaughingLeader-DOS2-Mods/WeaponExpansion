SKILL_STATE = LeaderLib.SKILL_STATE
local Classes = LeaderLib.Classes

---@type SkillEventData
local SkillEventData = Classes.SkillEventData
---@type HitData
local HitData = Classes.HitData

local function GetMasteryBonuses(char, skill)
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

---Get a table of enemies in combat, determined by distance to a source.
---@param char string
---@param maxDistance number
---@param sortByClosest boolean
---@param limit integer
---@param ignoreTarget string
---@return string[]
local function GetClosestCombatEnemies(char, maxDistance, sortByClosest, limit, ignoreTarget)
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

local throwingKnifeBonuses = {
	"Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Poison",
	"Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Explosive",
}

---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param skillData SkillEventData|HitData
local function ThrowingKnifeBonus(skill, char, state, skillData)
	--LeaderLib.PrintDebug("[MasteryBonuses:ThrowingKnife] char(",char,") state(",state,") skillData("..Ext.JsonStringify(skillData)..")")
	if state ~= SKILL_STATE.PREPARE then
		local bonuses = GetMasteryBonuses(char, skill)
		if bonuses["BONUS_DAGGER"] == true then
			local procSet = ObjectGetFlag(char, "LLWEAPONEX_ThrowingKnife_ActivateBonus") == 1
			if state == SKILL_STATE.USED then
				if hasMastery and not procSet then 
					local roll = Ext.Random(1,100)
					local chance = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_ThrowingKnife_Chance", 25)
					if chance == nil or chance < 0 then chance = 25 end
					LeaderLib.PrintDebug("LLWEAPONEX_ThrowingKnife_ActivateBonus|",roll, "/", chance)
					if roll <= chance then
						if skillData.ID == SkillEventData.ID then
							if skillData.TotalTargetObjects > 0 then
								local x,y,z = GetPosition(skillData.TargetObjects[1])
								SetVarFloat3(char, "LLWEAPONEX_ThrowingKnife_ExplodePosition", x,y,z)
							elseif skillData.TotalTargetPositions > 0 then
								local x,y,z = table.unpack(skillData.TargetPositions[1])
								SetVarFloat3(char, "LLWEAPONEX_ThrowingKnife_ExplodePosition", x,y,z)
							end
							ObjectSetFlag(char, "LLWEAPONEX_ThrowingKnife_ActivateBonus", 0)
						end
					end
				end
			elseif state == SKILL_STATE.CAST then
				if procSet then
					Mods.LeaderLib.StartTimer("LLWEAPONEX_Daggers_ThrowingKnife_ProcBonus", 250, char)
				end
			elseif state == SKILL_STATE.HIT then
				if procSet and skillData.ID == HitData.ID then
					Mods.LeaderLib.CancelTimer("LLWEAPONEX_Daggers_ThrowingKnife_ProcBonus", char)
					local explodeSkill = throwingKnifeBonuses[Ext.Random(1,2)]
					GameHelpers.ExplodeProjectile(char, target, explodeSkill)
					ObjectClearFlag(char, "LLWEAPONEX_ThrowingKnife_ActivateBonus", 0)
				end
			end
		end
	end
end

LeaderLib.RegisterSkillListener("Projectile_ThrowingKnife", ThrowingKnifeBonus)
LeaderLib.RegisterSkillListener("Projectile_EnemyThrowingKnife", ThrowingKnifeBonus)

local function ThrowingKnifeDelayedProc(funcParams)
	local char = funcParams[1]
	if char ~= nil and ObjectGetFlag(char, "LLWEAPONEX_ThrowingKnife_ActivateBonus") == 1 then
		local x,y,z = GetVarFloat3(char, "LLWEAPONEX_ThrowingKnife_ExplodePosition")
		local explodeSkill = throwingKnifeBonuses[Ext.Random(1,2)]
		local level = CharacterGetLevel(char)
		NRD_ProjectilePrepareLaunch()
		NRD_ProjectileSetString("SkillId", explodeSkill)
		NRD_ProjectileSetInt("CasterLevel", level)
		NRD_ProjectileSetGuidString("Caster", char)
		NRD_ProjectileSetGuidString("Source", char)
		NRD_ProjectileSetVector3("SourcePosition", x,y,z)
		NRD_ProjectileSetVector3("HitObjectPosition", x,y,z)
		NRD_ProjectileSetVector3("TargetPosition", x,y,z)
		NRD_ProjectileLaunch()
		ObjectClearFlag(char, "LLWEAPONEX_ThrowingKnife_ActivateBonus", 0)
	else
		LeaderLib.PrintDebug("ThrowingKnifeDelayedProc params: "..LeaderLib.Common.Dump(funcParams))
	end
end

OnTimerFinished["LLWEAPONEX_Daggers_ThrowingKnife_ProcBonus"] = ThrowingKnifeDelayedProc

---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param skillData HitData
local function CripplingBlowBonus(skill, char, state, skillData)
	LeaderLib.PrintDebug("[MasteryBonuses:CripplingBlow] char(",char,") state(",state,") skillData("..Ext.JsonStringify(skillData)..")")
	if state == SKILL_STATE.HIT then
		if skillData.Target ~= nil then
			local bonuses = GetMasteryBonuses(char, skill)
			if bonuses["SUNDER"] == true then
				local duration = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_CripplingBlow_SunderTurns", 2) * 6.0
				if HasActiveStatus(skillData.Target, "LLWEAPONEX_MASTERYBONUS_SUNDER") == 1 then
					local handle = NRD_StatusGetHandle(skillData.Target, "LLWEAPONEX_MASTERYBONUS_SUNDER")
					NRD_StatusSetReal(skillData.Target, handle, "CurrentLifeTime", duration)
				else
					ApplyStatus(skillData.Target, "LLWEAPONEX_MASTERYBONUS_SUNDER", duration, 0, char)
				end
			end
			if bonuses["BONUSDAMAGE"] == true then
				if LeaderLib.HasStatusType(skillData.Target, {"INCAPACITATED", "KNOCKED_DOWN"}) then
					local level = CharacterGetLevel(char)
					GameHelpers.ExplodeProjectile(char, skillData.Target, "Projectile_LLWEAPONEX_MasteryBonus_CripplingBlowPiercingDamage")
					
					-- local skillData.TargetPos = {[1] = x, [2] = y, [3] = z}
					--local x,y,z = GetPosition(skillData.Target)					-- local skill = Skills.CreateSkillTable("Projectile_LLWEAPONEX_MasteryBonus_CripplingBlowPiercingDamage")
					-- local damageList = Game.Math.GetSkillDamage(skill, character.Stats, false, false, character.Stats.Position, skillData.TargetPos, character.Stats.Level, 0)
					-- damageList:ConvertDamageType("Piercing")
					-- for i,damage in pairs(damageList:ToTable()) do
					-- 	ApplyDamage(skillData.Target, damage.Amount, "Piercing", char)
					-- end
				else
					LeaderLib.PrintDebug("[WeaponExpansion:MasteryBonuses:CripplingBlowBonus] Target is not disabled.")
				end
			end
		end
	end
end

LeaderLib.RegisterSkillListener("Target_CripplingBlow", CripplingBlowBonus)
LeaderLib.RegisterSkillListener("Target_EnemyCripplingBlow", CripplingBlowBonus)

local elementalWeakness = {
	Air = "LLWEAPONEX_WEAKNESS_AIR",
	Chaos = "LLWEAPONEX_WEAKNESS_CHAOS",
	Earth = "LLWEAPONEX_WEAKNESS_EARTH",
	Fire = "LLWEAPONEX_WEAKNESS_FIRE",
	Poison = "LLWEAPONEX_WEAKNESS_POISON",
	Water = "LLWEAPONEX_WEAKNESS_WATER",
	Piercing = "LLWEAPONEX_WEAKNESS_PIERCING",
	--Shadow = "LLWEAPONEX_WEAKNESS_SHADOW",
	--Physical = "LLWEAPONEX_WEAKNESS_Physical",
}

local whirlwindHandCrossbowTargets = {}

function OnWhirlwindHandCrossbowTargetFound(uuid, target)
	if whirlwindHandCrossbowTargets[uuid] ~= nil then
		table.insert(whirlwindHandCrossbowTargets[uuid].All, target)
		CharacterStatusText(target, "Found Target")
	end
end

function LaunchWhirlwindHandCrossbowBolt(uuid, target)
	local data = whirlwindHandCrossbowTargets[uuid]
	if data ~= nil and #data.All > 0 and data.Remaining > 0 then
		data.Remaining = data.Remaining - 1
		local target = LeaderLib.Common.PopRandomTableEntry(whirlwindHandCrossbowTargets[uuid].All)
		if target ~= nil then
			CharacterStatusText(uuid, "Shooting Bolt")
			local level = CharacterGetLevel(uuid)
			NRD_ProjectilePrepareLaunch()
			NRD_ProjectileSetString("SkillId", "Projectile_LLWEAPONEX_MasteryBonus_Whirlwind_HandCrossbow_Shoot")
			NRD_ProjectileSetInt("CasterLevel", level)
			--NRD_ProjectileSetGuidString("SourcePosition", target)
			local x,y,z = GetPosition(uuid)
			NRD_ProjectileSetVector3("SourcePosition", x, y + 2.0, z)
			NRD_ProjectileSetGuidString("Caster", uuid)
			NRD_ProjectileSetGuidString("Source", uuid)
			--NRD_ProjectileSetGuidString("HitObject", target)
			NRD_ProjectileSetGuidString("HitObjectPosition", target)
			NRD_ProjectileSetGuidString("TargetPosition", target)
			NRD_ProjectileLaunch()
			PlayEffect(uuid, "LLWEAPONEX_FX_HandCrossbow_Shoot_01", "LowerArm_L_Twist_Bone")
		end
		if data.Remaining > 0 and #data.All > 0 then
			Osi.LeaderLib_Timers_StartObjectTimer(uuid, 50, "Timers_LLWEAPONEX_HandCrossbow_Whirlwind_Shoot", "LLWEAPONEX_HandCrossbow_Whirlwind_Shoot")
		else
			whirlwindHandCrossbowTargets[uuid] = nil
		end
	end
end

---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param skillData SkillEventData|HitData
local function WhirlwindBonus(skill, char, state, skillData)
	LeaderLib.PrintDebug("[MasteryBonuses:Whirlwind] char(",char,") state(",state,") skillData("..Ext.JsonStringify(skillData)..")")
	if state == SKILL_STATE.USED then
		local bonuses = GetMasteryBonuses(char, skill)
		if bonuses["WHIRLWIND_BOLTS"] == true then
			local uuid = GetUUID(char)
			if whirlwindHandCrossbowTargets[uuid] == nil then
				local minTargets = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_Whirlwind_HandCrossbow_MinTargets", 1)
				local maxTargets = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_Whirlwind_HandCrossbow_MaxTargets", 3)
				local totalTargets = Ext.Random(minTargets, maxTargets)
				whirlwindHandCrossbowTargets[uuid] = { Remaining = totalTargets, All = {} }
				CharacterStatusText(char, string.format("Total targets: %i", totalTargets))
			end
		end
	elseif state == SKILL_STATE.CAST then
		local uuid = GetUUID(char)
		if whirlwindHandCrossbowTargets[uuid] ~= nil then
			GameHelpers.ExplodeProjectileAtPosition(char, "Projectile_LLWEAPONEX_MasteryBonus_Whirlwind_HandCrossbow_FindTarget", GetPosition(char))
			CharacterStatusText(char, "Shooting")
		end
	elseif state == SKILL_STATE.HIT then
		local target = skillData.Target
		if target ~= nil then
			local bonuses = GetMasteryBonuses(char, skill)
			if bonuses["RUPTURE"] == true then
				local bleedingTurns = GetStatusTurns(target, "BLEEDING")
				if bleedingTurns ~= nil and bleedingTurns > 0 then
					local level = CharacterGetLevel(char)
					for i=bleedingTurns,1,-1 do
						GameHelpers.ExplodeProjectile(char, target, "Projectile_LLWEAPONEX_MasteryBonus_WhirlwindRuptureBleeding")
					end
					if ObjectIsCharacter(target) then
						local text = Text.RupteredWound.Value
						if bleedingTurns > 1 then
							text = text:gsub("%[1%]", "x"..tostring(bleedingTurns))
						else
							text = text:gsub("%[1%]", "")
						end
						CharacterStatusText(target, text)
					end
					LeaderLib.PrintDebug("[MasteryBonuses:WhirlwindBonus] Exploded (",bleedingTurns,") rupture projectiles on ("..target..").")
				end
			end
			if bonuses["ELEMENTAL_DEBUFF"] == true then
				local duration = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_ElementalWeaknessTurns", 1) * 6.0
				local weaponuuid = CharacterGetEquippedWeapon(char)
				--local damageType = Ext.StatGetAttribute(NRD_ItemGetStatsId(weapon), "Damage Type")
				local weapon = Ext.GetItem(weaponuuid).Stats
				if weapon ~= nil then
					local stats = weapon.DynamicStats
					if stats ~= nil then
						for i, stat in pairs(stats) do
							if stat.StatsType == "Weapon" and stat.DamageType ~= "None" then
								local status = elementalWeakness[stat.DamageType]
								if status ~= nil then
									ApplyStatus(target, status, duration, 0, char)
								end
							end
						end
					end
				end
			end
		end
	end
end
LeaderLib.RegisterSkillListener("Shout_Whirlwind", WhirlwindBonus)
LeaderLib.RegisterSkillListener("Shout_EnemyWhirlwind", WhirlwindBonus)

local function FleshSacrificeBonus(skill, char, state, skillData)
	if state == SKILL_STATE.CAST then
		local bonuses = GetMasteryBonuses(char, skill)
		if bonuses["BLOOD_EMPOWER"] == true then
			---@return string[]
			local party = GameHelpers.GetParty(char, true, true, false, false)
			if #party > 0 then
				for i,partyMember in pairs(party) do
					local surfaceGround = GetSurfaceGroundAt(partyMember)
					local surfaceCloud = GetSurfaceCloudAt(partyMember)
					if string.find(surfaceCloud, "Blood") or string.find(surfaceCloud, "Blood") then
						ApplyStatus(partyMember, "LLWEAPONEX_BLOOD_EMPOWERED", 6.0, 0, char)
					end
				end
			end
		end
	end
end
LeaderLib.RegisterSkillListener("Shout_FleshSacrifice", FleshSacrificeBonus)
LeaderLib.RegisterSkillListener("Shout_EnemyFleshSacrifice", FleshSacrificeBonus)

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
		local bonuses = GetMasteryBonuses(char, skill)
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
			local bonuses = GetMasteryBonuses(char, skill)
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
local function PetrifyingTouchBonus(skill, char, state, skillData)
	if state == SKILL_STATE.CAST then
		local bonuses = GetMasteryBonuses(char, skill)
		if bonuses["PETRIFYING_SLAM"] == true then
			PlayEffect(char, "RS3_FX_Char_Creatures_Condor_Cast_Warrior_01", "Dummy_R_HandFX")
			PlayEffect(char, "RS3_FX_Char_Creatures_Condor_Cast_Warrior_01", "Dummy_L_HandFX")
		end
	elseif state == SKILL_STATE.HIT then
		local target = skillData.Target
		if target ~= nil then
			local bonuses = GetMasteryBonuses(char, skill)
			if bonuses["PETRIFYING_SLAM"] == true then
				GameHelpers.ExplodeProjectile(char, target, "Projectile_LLWEAPONEX_MasteryBonus_PetrifyingTouchBonusDamage")
				local forceDistance = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_PetrifyingTouch_KnockbackDistance", 4.0)
				if forceDistance > 0 then
					local character = Ext.GetCharacter(char)
					local x,y,z = GetPosition(target)
					PlayEffectAtPosition("RS3_FX_Skills_Void_Power_Attack_Impact_01",x,y,z)
					PlayEffect(target, "RS3_FX_Skills_Warrior_Impact_Weapon_01", "Dummy_BodyFX")
					local pos = character.Stats.Position
					local rot = character.Stats.Rotation
					local forwardVector = {
						-rot[7] * forceDistance,
						0,---rot[8] * distanceMult, -- Rot Y is never used since objects can't look "up"
						-rot[9] * forceDistance,
					}
					x = pos[1] + forwardVector[1]
					--y = pos[2] + forwardVector[2]
					z = pos[3] + forwardVector[3]
					local tx,ty,tz = FindValidPosition(x,y,z, 2.0, target)
					local actionHandle = NRD_CreateGameObjectMove(target, tx,ty,tz, "", char)
				end
			end
		end
	end
end
LeaderLib.RegisterSkillListener("Target_PetrifyingTouch", PetrifyingTouchBonus)
LeaderLib.RegisterSkillListener("Target_EnemyPetrifyingTouch", PetrifyingTouchBonus)

---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param skillData SkillEventData|HitData
local function ShieldsUpBonus(skill, char, state, skillData)
	if state == SKILL_STATE.CAST then
		local bonuses = GetMasteryBonuses(char, skill)
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
			local bonuses = GetMasteryBonuses(char, skill)
			if bonuses["VULNERABLE"] == true then
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
		local bonuses = GetMasteryBonuses(char, skill)
		if bonuses["SUCKER_PUNCH_COMBO"] == true then
			ApplyStatus(char, "LLWEAPONEX_WS_RAPIER_SUCKERCOMBO1", 12.0, 0, char)
		end
	elseif state == SKILL_STATE.HIT then
		local target = skillData.Target
		if target ~= nil then
			local bonuses = GetMasteryBonuses(char, skill)
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
		local bonuses = GetMasteryBonuses(char, skill)
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
		local bonuses = GetMasteryBonuses(char, skill)
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
		local bonuses = GetMasteryBonuses(char, skill)
		if bonuses["PISTOL_CLOAKEDJUMP"] == true then
			--NRD_SkillSetCooldown(char, "Target_LLWEAPONEX_Pistol_Shoot", 0.0)
			Osi.CharacterUsedSkill(char, "Shout_LLWEAPONEX_Pistol_Reload", "shout", "")
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
		local bonuses = GetMasteryBonuses(char, skill)
		if bonuses["BOW_DOUBLE_SHOT"] == true then
			-- Support for a mod making Pin Down shoot multiple arrows through the use of iterating tables.
			local shotBonus = false
			local isInCombat = CharacterIsInCombat(char) == 1
			if skillData.TotalTargetObjects ~= nil and skillData.TotalTargetObjects > 0 then
				for i,v in ipairs(skillData.TargetObjects) do
					local target = nil
					if isInCombat then
						local maxDist = Ext.StatGetAttribute(skill, "TargetRadius")
						local targets = GetClosestCombatEnemies(char, maxDist, true, 3, v)
						if #targets > 0 then
							target = Common.GetRandomTableEntry(targets)
						else
							target = v
						end
					end

					if target ~= nil then
						GameHelpers.ShootProjectile(char, target, "Projectile_LLWEAPONEX_MasteryBonus_PinDown_BonusShot")
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
						local targets = GetClosestCombatEnemies(char, maxDist, true, 3, v)
						if #targets > 0 then
							target = Common.GetRandomTableEntry(targets)
						end
					end

					if target ~= nil then
						GameHelpers.ShootProjectile(char, target, "Projectile_LLWEAPONEX_MasteryBonus_PinDown_BonusShot")
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