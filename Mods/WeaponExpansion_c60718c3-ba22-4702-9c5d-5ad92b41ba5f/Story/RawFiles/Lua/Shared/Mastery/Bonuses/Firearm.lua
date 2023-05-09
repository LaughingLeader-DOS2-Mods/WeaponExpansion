local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

local _ISCLIENT = Ext.IsClient()

local _eqSet = "Class_LLWEAPONEX_Rifleman_Preview"

MasteryBonusManager.AddRankBonuses(MasteryID.Firearm, 1, {
	rb:Create("FIREARM_TACTICAL_RETREAT", {
		Skills = {"Jump_TacticalRetreat", "Jump_EnemyTacticalRetreat"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Firearm_TacticalRetreat", "<font color='#00FF99'>After jumping, your next action's AP cost is reduced by [Stats:Stats_LLWEAPONEX_MasteryBonus_Firearm_Tactics:APCostBoost].</font>"),
	}).Register.SkillCast(function(self, e, bonuses)
		local GUID = e.Character.MyGuid
		GameHelpers.Status.Apply(e.Character, "LLWEAPONEX_MASTERYBONUS_FIREARM_TACTICS", -2.0, true, e.Character)

		Events.OnSkillState:Subscribe(function (se)
			GameHelpers.Status.Remove(se.Character, "LLWEAPONEX_MASTERYBONUS_FIREARM_TACTICS")
		end, {Once=true, MatchArgs=function(_e) return _e.State == SKILL_STATE.CAST and _e.Character.MyGuid == GUID end})

		Events.OnBasicAttackStart:Subscribe(function (ae)
			GameHelpers.Status.Remove(ae.Attacker, "LLWEAPONEX_MASTERYBONUS_FIREARM_TACTICS")
		end, {Once=true, MatchArgs=function(_e) return _e.Attacker.MyGuid == GUID end})
	end),

	rb:Create("FIREARM_RICOCHET", {
		Skills = {"Projectile_Ricochet", "Projectile_EnemyRicochet"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Firearm_Ricochet", "<font color='#00FF99'>On hit, shrapnel ricochets in a random direction, dealing [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_Firearm_RicochetShrapnel] with a chance to apply [Key:BLEEDING_DisplayName:Bleeding].</font>"),
	}).Register.SkillHit(function(self, e, bonuses)
		local sourcePos = e.Data.TargetObject.WorldPos
		local targetPos = GameHelpers.Math.GetPositionWithAngle(sourcePos, Ext.Utils.Random(0, 359), 4)
		GameHelpers.Skill.ShootProjectileAt(targetPos, "Projectile_LLWEAPONEX_MasteryBonus_Firearm_RicochetShrapnel", e.Character, {SourcePosition=sourcePos})
	end).Test(function (test, self)
		local characters,dummies,cleanup = Testing.Utils.CreateTestCharacters({EquipmentSet=_eqSet, TotalDummies=3, TotalCharacters=1,})
		local character = characters[1]
		test.Cleanup = function()
			cleanup()
		end
		test:Wait(250)
		TeleportTo(character, dummies[1], "", 0, 1, 1)
		test:Wait(1000)
		CharacterUseSkill(character, self.Skills[1], dummies[1], 1, 1, 1)
		test:WaitForSignal(self.ID, 10000)
		test:AssertGotSignal(self.ID)
		return true
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Firearm, 2, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Firearm, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Firearm, 4, {
	
})