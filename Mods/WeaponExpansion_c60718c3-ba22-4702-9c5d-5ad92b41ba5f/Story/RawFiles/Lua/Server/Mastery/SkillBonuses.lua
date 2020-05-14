SKILL_STATE = LeaderLib.SKILL_STATE

local function GetMasteryBonuses(char, skill)
	local character = Ext.GetCharacter(char)
	local bonuses = {}
	local data = Mastery.Params.SkillData[skill]
	if data ~= nil and data.Tags ~= nil then
		for tagName,tagData in pairs(data.Tags) do
			if HasMasteryRequirement(character, tagName) then
				bonuses[tagData.ID] = true
			end
		end
	end
	return bonuses
end

local throwingKnifeBonuses = {
	"Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Poison",
	"Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Explosive",
}

local function ThrowingKnifeBonus(skill, char, state, funcParams)
	--LeaderLib.PrintDebug("[MasteryBonuses:ThrowingKnife] char(",char,") state(",state,") funcParams("..Ext.JsonStringify(funcParams)..")")
	if state ~= SKILL_STATE.PREPARE then
		local bonuses = GetMasteryBonuses(char, skill)
		if bonuses["BONUS_DAGGER"] == true then
			local procSet = ObjectGetFlag(char, "LLWEAPONEX_ThrowingKnife_ActivateBonus") == 1
			if state == SKILL_STATE.USED then
				if hasMastery and not procSet then 
					local roll = Ext.Random(1,100)
					local chance = LeaderLib.Game.GetExtraData("LLWEAPONEX_MasteryBonus_ThrowingKnife_Chance", 25)
					if chance == nil or chance < 0 then chance = 25 end
					LeaderLib.PrintDebug("LLWEAPONEX_ThrowingKnife_ActivateBonus|",roll, "/", chance)
					if roll <= chance then
						-- Position
						if #funcParams == 3 then
							local x = funcParams[1]
							local y = funcParams[2]
							local z = funcParams[3]
							SetVarFloat3(char, "LLWEAPONEX_ThrowingKnife_ExplodePosition", x,y,z)
						elseif funcParams[1] ~= nil then
							local x,y,z = GetPosition(funcParams[1])
							SetVarFloat3(char, "LLWEAPONEX_ThrowingKnife_ExplodePosition", x,y,z)
						end
						ObjectSetFlag(char, "LLWEAPONEX_ThrowingKnife_ActivateBonus", 0)
					end
				end
			elseif state == SKILL_STATE.CAST then
				if procSet then
					Mods.LeaderLib.StartTimer("LLWEAPONEX_Daggers_ThrowingKnife_ProcBonus", 250, char)
				end
			elseif state == SKILL_STATE.HIT then
				if procSet then
					local target = funcParams[1]
					if target ~= nil then
						Mods.LeaderLib.CancelTimer("LLWEAPONEX_Daggers_ThrowingKnife_ProcBonus", char)
						local explodeSkill = throwingKnifeBonuses[Ext.Random(1,2)]
						LeaderLib.Game.ExplodeProjectile(char, target, explodeSkill)
					end
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

local function CripplingBlowBonus(skill, char, state, funcParams)
	LeaderLib.PrintDebug("[MasteryBonuses:CripplingBlow] char(",char,") state(",state,") funcParams("..Ext.JsonStringify(funcParams)..")")
	if state == SKILL_STATE.HIT then
		local target = funcParams[1]
		if target ~= nil then
			local bonuses = GetMasteryBonuses(char, skill)
			if bonuses["SUNDER"] == true then
				local duration = LeaderLib.Game.GetExtraData("LLWEAPONEX_MasteryBonus_CripplingBlow_SunderTurns", 2) * 6.0
				if HasActiveStatus(target, "LLWEAPONEX_MASTERYBONUS_SUNDER") == 1 then
					local handle = NRD_StatusGetHandle(target, "LLWEAPONEX_MASTERYBONUS_SUNDER")
					NRD_StatusSetReal(target, handle, "CurrentLifeTime", duration)
				else
					ApplyStatus(target, "LLWEAPONEX_MASTERYBONUS_SUNDER", duration, 0, char)
				end
			end
			if bonuses["BONUSDAMAGE"] == true then
				if LeaderLib.HasStatusType(target, {"INCAPACITATED", "KNOCKED_DOWN"}) then
					local level = CharacterGetLevel(char)
					LeaderLib.Game.ExplodeProjectile(char, target, "Projectile_LLWEAPONEX_MasteryBonus_CripplingBlowPiercingDamage")
					
					-- local targetPos = {[1] = x, [2] = y, [3] = z}
					--local x,y,z = GetPosition(target)					-- local skill = Skills.PrepareSkillProperties("Projectile_LLWEAPONEX_MasteryBonus_CripplingBlowPiercingDamage")
					-- local damageList = Game.Math.GetSkillDamage(skill, character.Stats, false, false, character.Stats.Position, targetPos, character.Stats.Level, 0)
					-- damageList:ConvertDamageType("Piercing")
					-- for i,damage in pairs(damageList:ToTable()) do
					-- 	ApplyDamage(target, damage.Amount, "Piercing", char)
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
		end
		if data.Remaining > 0 and #data.All > 0 then
			Osi.LeaderLib_Timers_StartObjectTimer(uuid, 50, "Timers_LLWEAPONEX_HandCrossbow_Whirlwind_Shoot", "LLWEAPONEX_HandCrossbow_Whirlwind_Shoot")
		else
			whirlwindHandCrossbowTargets[uuid] = nil
		end
	end
end

local function WhirlwindBonus(skill, char, state, funcParams)
	LeaderLib.PrintDebug("[MasteryBonuses:Whirlwind] char(",char,") state(",state,") funcParams("..Ext.JsonStringify(funcParams)..")")
	if state == SKILL_STATE.USED then
		local bonuses = GetMasteryBonuses(char, skill)
		if bonuses["WHIRLWIND_BOLTS"] == true then
			local uuid = GetUUID(char)
			if whirlwindHandCrossbowTargets[uuid] == nil then
				local minTargets = LeaderLib.Game.GetExtraData("LLWEAPONEX_MasteryBonus_Whirlwind_HandCrossbow_MinTargets", 1)
				local maxTargets = LeaderLib.Game.GetExtraData("LLWEAPONEX_MasteryBonus_Whirlwind_HandCrossbow_MaxTargets", 3)
				local totalTargets = Ext.Random(minTargets, maxTargets)
				whirlwindHandCrossbowTargets[uuid] = { Remaining = totalTargets, All = {} }
				CharacterStatusText(char, string.format("Total targets: %i", totalTargets))
			end
		end
	elseif state == SKILL_STATE.CAST then
		local uuid = GetUUID(char)
		if whirlwindHandCrossbowTargets[uuid] ~= nil then
			LeaderLib.Game.ExplodeProjectileAtPosition(char, "Projectile_LLWEAPONEX_MasteryBonus_Whirlwind_HandCrossbow_FindTarget", GetPosition(char))
			CharacterStatusText(char, "Shooting")
		end
	elseif state == SKILL_STATE.HIT then
		local target = funcParams[1]
		if target ~= nil then
			local bonuses = GetMasteryBonuses(char, skill)
			if bonuses["RUPTURE"] == true then
				local bleedingTurns = GetStatusTurns(target, "BLEEDING")
				if bleedingTurns ~= nil and bleedingTurns > 0 then
					local level = CharacterGetLevel(char)
					for i=bleedingTurns,1,-1 do
						LeaderLib.Game.ExplodeProjectile(char, target, "Projectile_LLWEAPONEX_MasteryBonus_WhirlwindRuptureBleeding")
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
				local duration = LeaderLib.Game.GetExtraData("LLWEAPONEX_MasteryBonus_ElementalWeaknessTurns", 1) * 6.0
				local weaponuuid = CharacterGetEquippedWeapon(char)
				--local damageType = Ext.StatGetAttribute(NRD_ItemGetStatsId(weapon), "Damage Type")
				local weapon = Ext.GetItem(weaponuuid).Stats
				if weapon ~= nil then
					print(weapon)
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

local function FleshSacrificeBonus(skill, char, state, funcParams)
	if state == SKILL_STATE.CAST then
		local bonuses = GetMasteryBonuses(char, skill)
		if bonuses["BLOOD_EMPOWER"] == true then
			---@return string[]
			local party = LeaderLib.Game.GetParty(char, true, true, false, false)
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

local function RushBonus(skill, char, state, funcParams)
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
	elseif state == SKILL_STATE.HIT then
		local target = funcParams[1]
		local handle = funcParams[2]
		local damageAmount = funcParams[3]
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
					local bonusPercent = LeaderLib.Game.GetExtraData("LLWEAPONEX_MasteryBonus_WarChargeDamageBoost", 25.0)
					if bonusPercent > 0 then
						LeaderLib.Game.IncreaseDamage(target, char, handle, bonusPercent/100, 0)
					end
				end
			end
			if bonuses["RUSH_DIZZY"] == true then
				local forceDist = Ext.Random(2,4)
				local forceProjectile = "Projectile_LeaderLib_Force"..tostring(math.floor(forceDist))
				CharacterStatusText(char, "Force! " .. forceProjectile)
				LeaderLib.Game.ShootProjectile(char, target, forceProjectile, true)
				local dizzyChance = LeaderLib.Game.GetExtraData("LLWEAPONEX_MasteryBonus_RushDizzyChance", 40.0)
				local dizzyDuration = LeaderLib.Game.GetExtraData("LLWEAPONEX_MasteryBonus_RushDizzyTurns", 1.0) * 6.0
				if Ext.Random(0,100) <= dizzyChance then
					ApplyStatus(target, "LLWEAPONEX_DIZZY", dizzyDuration, 0, char)
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