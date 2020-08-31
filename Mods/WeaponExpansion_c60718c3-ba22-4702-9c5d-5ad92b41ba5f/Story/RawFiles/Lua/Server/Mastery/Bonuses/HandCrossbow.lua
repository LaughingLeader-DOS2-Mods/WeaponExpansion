
local whirlwindHandCrossbowTargets = {}

function OnWhirlwindHandCrossbowTargetFound(uuid, target)
	if whirlwindHandCrossbowTargets[uuid] ~= nil then
		table.insert(whirlwindHandCrossbowTargets[uuid].All, target)
	end
end

function LaunchWhirlwindHandCrossbowBolt(uuid, target)
	local data = whirlwindHandCrossbowTargets[uuid]
	if data ~= nil and #data.All > 0 and data.Remaining > 0 then
		data.Remaining = data.Remaining - 1
		local target = Common.PopRandomTableEntry(whirlwindHandCrossbowTargets[uuid].All)
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

MasteryBonusManager.RegisterSkillListener({"Shout_Whirlwind", "Shout_EnemyWhirlwind"}, {"WHIRLWIND_BOLTS"}, function(bonuses, skill, char, state, skillData)
	if state == SKILL_STATE.USED then
		local uuid = GetUUID(char)
		if whirlwindHandCrossbowTargets[uuid] == nil then
			local minTargets = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_Whirlwind_HandCrossbow_MinTargets", 1)
			local maxTargets = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_Whirlwind_HandCrossbow_MaxTargets", 3)
			local totalTargets = Ext.Random(minTargets, maxTargets)
			whirlwindHandCrossbowTargets[uuid] = { Remaining = totalTargets, All = {} }
		end
	elseif state == SKILL_STATE.CAST then
		local uuid = GetUUID(char)
		if whirlwindHandCrossbowTargets[uuid] ~= nil then
			GameHelpers.ExplodeProjectile(char, char, "Projectile_LLWEAPONEX_MasteryBonus_Whirlwind_HandCrossbow_FindTarget")
		end
	end
end)

---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param skillData SkillEventData|HitData
MasteryBonusManager.RegisterSkillListener({"Jump_TacticalRetreat", "Jump_EnemyTacticalRetreat"}, {"HANDCROSSBOW_JUMP_MARKING"}, function(bonuses, skill, char, state, skillData)
	if state == SKILL_STATE.CAST and CharacterIsInCombat(char) == 1 then
		local data = Osi.DB_CombatCharacters:Get(nil, CombatGetIDForCharacter(char))
		if data ~= nil then
			local totalEnemies = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_TacticalRetreat_MaxMarkedTargets", 2)
			local maxDistance = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_TacticalRetreat_MarkingRadius", 4.0)
			local combatEnemies = LeaderLib.Common.ShuffleTable(data)
			for i,v in pairs(combatEnemies) do
				local enemy = v[1]
				if (enemy ~= char and CharacterIsEnemy(char, enemy) == 1 and 
					not GameHelpers.Status.IsSneakingOrInvisible(char) and GetDistanceTo(char,enemy) <= maxDistance) then
						totalEnemies = totalEnemies - 1
						ApplyStatus(enemy, "MARKED", 6.0, 0, char)
				end
				if totalEnemies <= 0 then
					break
				end
			end
		end
	end
end)