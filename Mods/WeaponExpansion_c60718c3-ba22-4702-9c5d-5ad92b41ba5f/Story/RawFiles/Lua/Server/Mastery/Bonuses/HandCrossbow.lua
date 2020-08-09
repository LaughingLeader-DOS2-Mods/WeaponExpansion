
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
			GameHelpers.ExplodeProjectileAtPosition(char, "Projectile_LLWEAPONEX_MasteryBonus_Whirlwind_HandCrossbow_FindTarget", GetPosition(char))
		end
	end
end)