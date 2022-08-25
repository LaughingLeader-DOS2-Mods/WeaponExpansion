local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

MasteryBonusManager.AddRankBonuses(MasteryID.HandCrossbow, 1, {
	rb:Create("HANDCROSSBOW_JUMP_MARKING", {
		Skills = {"Jump_TacticalRetreat", "Jump_EnemyTacticalRetreat"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_HandCrossbow_TacticalRetreat", "While in combat, automatically apply [Key:MARKED_DisplayName] to [ExtraData:LLWEAPONEX_MB_HandCrossbow_TacticalRetreat_MaxTargets] enemies in a [ExtraData:LLWEAPONEX_MB_HandCrossbow_TacticalRetreat_MarkingRadius]m radius when jumping away."),
	}).Register.SkillCast(function(self, e, bonuses)
		if GameHelpers.Character.IsInCombat(e.Character) or e.Character:HasTag("LLWEAPONEX_MasteryTestCharacter") then
			local totalEnemies = GameHelpers.GetExtraData("LLWEAPONEX_MB_HandCrossbow_TacticalRetreat_MaxTargets", 2)
			local maxDistance = GameHelpers.GetExtraData("LLWEAPONEX_MB_HandCrossbow_TacticalRetreat_MarkingRadius", 4.0)
			local combatEnemies = Common.ShuffleTable(MasteryBonusManager.GetClosestEnemiesToObject(e.Character, e.Character, maxDistance, true, totalEnemies))
			for i,v in pairs(combatEnemies) do
				if not GameHelpers.Status.IsSneakingOrInvisible(e.Character) then
					GameHelpers.Status.Apply(v, "MARKED", 6.0, 0, e.Character)
				end
			end
		end
	end),
	rb:Create("HANDCROSSBOW_WHIRLWIND_BOLTS", {
		Skills = {"Shout_Whirlwind", "Shout_EnemyWhirlwind"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_HandCrossbow_Whirlwind", "<font color='#F19824'>While spinning, shoot [ExtraData:LLWEAPONEX_MB_HandCrossbow_Whirlwind_MinTargets]-[ExtraData:LLWEAPONEX_MB_HandCrossbow_Whirlwind_MaxTargets] enemies in a [ExtraData:LLWEAPONEX_MB_HandCrossbow_Whirlwind_Radius]m radius, dealing [Skill:Projectile_LLWEAPONEX_MasteryBonus_Whirlwind_HandCrossbow_Shoot:LLWEAPONEX_HandCrossbow_ShootDamage].</font>"),
	}).Register.SkillCast(function(self, e, bonuses)
		local radius = GameHelpers.GetExtraData("LLWEAPONEX_MB_HandCrossbow_Whirlwind_Radius", 6)
		local minTargets = GameHelpers.GetExtraData("LLWEAPONEX_MB_HandCrossbow_Whirlwind_MinTargets", 1)
		local maxTargets = GameHelpers.GetExtraData("LLWEAPONEX_MB_HandCrossbow_Whirlwind_MaxTargets", 3)
		local targets = Ext.Random(minTargets, maxTargets)
		if radius > 0 and targets > 0 then
			---@type EsvCharacter[]
			local enemies = GameHelpers.Grid.GetNearbyObjects(e.Character, {Radius = radius, Relation={Enemy=true}, Type="Character", AsTable=true, Sort="Random"})
			local delay = 250
			for _,v in pairs(enemies) do
				Timer.StartObjectTimer("LLWEAPONEX_HandCrossbow_Whirlwind_Shoot", v, delay, e.Character, {Target=v.MyGuid})
				delay = delay + 100
			end
		end
	end).TimerFinished("LLWEAPONEX_HandCrossbow_Whirlwind_Shoot", function (self, e, bonuses)
		if e.Data.UUID and e.Data.Target then
			GameHelpers.Skill.ShootProjectileAt(e.Data.Target, "Projectile_LLWEAPONEX_MasteryBonus_Whirlwind_HandCrossbow_Shoot", e.Data.UUID)
			PlayEffect(e.Data.UUID, "LLWEAPONEX_FX_HandCrossbow_Shoot_01", "LowerArm_L_Twist_Bone")
		end
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.HandCrossbow, 2, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.HandCrossbow, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.HandCrossbow, 4, {
	
})