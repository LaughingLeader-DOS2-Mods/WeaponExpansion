
local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryRankBonus

MasteryBonusManager.AddRankBonuses(MasteryID.Crossbow, 1, {
	-- rb:Create("CROSSBOW_MULTISHOT", {
	-- 	Skills = {"Projectile_Multishot", "Projectile_EnemyMultishot"},
	-- 	Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_", ""),
	-- }):RegisterSkillListener(function(bonuses, skill, char, state, data)
	-- 	if state == SKILL_STATE.HIT and data.Success then
			
	-- 	end
	-- end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Crossbow, 2, {
	rb:Create("CROSSBOW_SKYCRIT", {
		Skills = {"Projectile_SkyShot", "Projectile_EnemySkyShot"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Crossbow_SkyShotCrit", "<font color='#77FF33'>If the target is affected by [Key:KNOCKED_DOWN_DisplayName], deal a critical hit.</font>"),
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.HIT and data.Success then
			if GameHelpers.Status.HasStatusType(data.Target, "KNOCKED_DOWN") and not data:HasHitFlag("CriticalHit", true) then
				local attackerStats = GameHelpers.GetCharacter(char).Stats
				local critMultiplier = Game.Math.GetCriticalHitMultiplier(attackerStats.MainWeapon or attackerStats.OffHandWeapon)
				data:SetHitFlag("CriticalHit", true)
				data:MultiplyDamage(1 + critMultiplier)
			end
		end
	end),

	rb:Create("CROSSBOW_PINFANG", {
		Skills = {"Projectile_PiercingShot", "Projectile_EnemyPiercingShot"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Crossbow_MarksmansFang", "<font color='#77FF33'>If a target is in front of impassable terrain (like a wall), pin them for 1 turn and deal [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_Crossbow_PiercingShotPinDamage].</font>"),
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.HIT and data.Success then
			local attacker = Ext.GetCharacter(char)
			local startPos = data.TargetObject.WorldPos
			local directionalVector = GameHelpers.Math.GetDirectionalVectorBetweenObjects(data.TargetObject, attacker, false)
			local grid = Ext.GetAiGrid()

			local isNextToWall = false

			for i=1,2.5,0.5 do
				local x = (directionalVector[1] * i) + startPos[1]
				local z = (directionalVector[3] * i) + startPos[3]
				if not GameHelpers.Grid.IsValidPosition(x, z, grid) then
					isNextToWall = true
					break
				end
			end

			if isNextToWall then
				GameHelpers.Damage.ApplySkillDamage(attacker, data.TargetObject, "Projectile_LLWEAPONEX_MasteryBonus_Crossbow_PiercingShotPinDamage", HitFlagPresets.GuaranteedWeaponHit)
				GameHelpers.Status.Apply(data.TargetObject, "LLWEAPONEX_MB_CROSSOW_PINNED", 6.0, 0, attacker)
			end
		end
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Crossbow, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Crossbow, 4, {
	
})