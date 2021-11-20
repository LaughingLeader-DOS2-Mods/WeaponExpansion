local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryRankBonus

MasteryBonusManager.AddRankBonuses(MasteryID.HandCrossbow, 1, {
	rb:Create("HANDCROSSBOW_JUMP_MARKING", {
		Skills = {"Jump_TacticalRetreat", "Jump_EnemyTacticalRetreat"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_HandCrossbow_TacticalRetreat", "While in combat, automatically apply [Key:MARKED_DisplayName] to [ExtraData:LLWEAPONEX_MB_HandCrossbow_TacticalRetreat_MaxTargets] enemies in a [ExtraData:LLWEAPONEX_MB_HandCrossbow_TacticalRetreat_MarkingRadius]m radius when jumping away."),
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.CAST and CharacterIsInCombat(char) == 1 then
			local totalEnemies = GameHelpers.GetExtraData("LLWEAPONEX_MB_HandCrossbow_TacticalRetreat_MaxTargets", 2)
			local maxDistance = GameHelpers.GetExtraData("LLWEAPONEX_MB_HandCrossbow_TacticalRetreat_MarkingRadius", 4.0)
			local combatEnemies = Common.ShuffleTable(MasteryBonusManager.GetClosestEnemiesToObject(char, char, maxDistance, true, totalEnemies))
			for i,v in pairs(combatEnemies) do
				if not GameHelpers.Status.IsSneakingOrInvisible(char) then
					ApplyStatus(v, "MARKED", 6.0, 0, char)
				end
			end
		end
	end),
	rb:Create("WHIRLWIND_BOLTS", {
		Skills = {"Shout_Whirlwind", "Shout_EnemyWhirlwind"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_HandCrossbow_Whirlwind", "<font color='#F19824'>While spinning, shoot [ExtraData:LLWEAPONEX_MB_HandCrossbow_Whirlwind_MinTargets]-[ExtraData:LLWEAPONEX_MB_HandCrossbow_Whirlwind_MaxTargets] enemies in a [ExtraData:LLWEAPONEX_MB_HandCrossbow_Whirlwind_Radius]m radius, dealing [Skill:Projectile_LLWEAPONEX_MasteryBonus_Whirlwind_HandCrossbow_Shoot:LLWEAPONEX_HandCrossbow_ShootDamage].</font>"),
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.CAST then
			local radius = GameHelpers.GetExtraData("LLWEAPONEX_MB_HandCrossbow_Whirlwind_Radius", 6)
			local minTargets = GameHelpers.GetExtraData("LLWEAPONEX_MB_HandCrossbow_Whirlwind_MinTargets", 1)
			local maxTargets = GameHelpers.GetExtraData("LLWEAPONEX_MB_HandCrossbow_Whirlwind_MaxTargets", 3)
			local targets = Ext.Random(minTargets, maxTargets)
			if radius > 0 and targets > 0 then
				local enemies = Common.ShuffleTable(MasteryBonusManager.GetClosestEnemiesToObject(char, char, radius, true, targets))
				local delay = 250
				for i,v in pairs(enemies) do
					Timer.StartObjectTimer("LLWEAPONEX_HandCrossbow_Whirlwind_Shoot", v, delay, char)
					delay = delay + 100
				end
			end
		end
	end),
})

if not Vars.IsClient then
	Timer.RegisterListener("LLWEAPONEX_HandCrossbow_Whirlwind_Shoot", function(timerName, target, source)
		GameHelpers.Skill.ShootProjectileAt(target, "Projectile_LLWEAPONEX_MasteryBonus_Whirlwind_HandCrossbow_Shoot", source)
		PlayEffect(source, "LLWEAPONEX_FX_HandCrossbow_Shoot_01", "LowerArm_L_Twist_Bone")
	end)
end

MasteryBonusManager.AddRankBonuses(MasteryID.HandCrossbow, 2, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.HandCrossbow, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.HandCrossbow, 4, {
	
})