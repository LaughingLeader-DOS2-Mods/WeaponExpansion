local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

MasteryBonusManager.AddRankBonuses(MasteryID.Pistol, 1, {
	rb:Create("PISTOL_ADRENALINE", {
		Skills = {"Shout_Adrenaline", "Shout_EnemyAdrenaline"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Pistol_Adrenaline", "Gain hyper-focus, increasing the <font color='#33FF00'>damage of the next shot of your pistol by [ExtraData:LLWEAPONEX_MB_Pistol_Adrenaline_DamageBoost]%</font>."),
		Statuses = {"ADRENALINE"},
		StatusTooltip = ts:CreateFromKey("LLWEAPONEX_MB_Pistol_AdrenalineStatus", "<font color='#33FF00'>Your next pistol shot will deal [ExtraData:LLWEAPONEX_MB_Pistol_Adrenaline_DamageBoost]% more damage.</font>"),
		GetIsTooltipActive = rb.DefaultStatusTagCheck("LLWEAPONEX_Pistol_Adrenaline_Active", false)
	}).Register.SkillCast(function(self, e, bonuses)
		SetTag(e.Character.MyGuid, "LLWEAPONEX_Pistol_Adrenaline_Active")
		CharacterStatusText(e.Character.MyGuid, "LLWEAPONEX_Pistol_Adrenaline_Active")
	end),

	rb:Create("PISTOL_CLOAKEDJUMP", {
		Skills = {"Jump_CloakAndDagger", "Jump_EnemyCloakAndDagger"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Pistol_CloakAndDagger", "Automatically reload your pistol when jumping.<br>When landing, apply [Key:MARKED_DisplayName] to the closest enemy within [ExtraData:LLWEAPONEX_MB_Pistol_CloakAndDagger_MarkingRadius]m ([ExtraData:LLWEAPONEX_MB_Pistol_CloakAndDagger_MaxTargets] target(s) max).<br>Shooting targets [Key:MARKED_DisplayName] this way, with your pistol, guarantees one critical hit until you end your turn."),
	}).Register.SkillCast(function(self, e, bonuses)
		if GameHelpers.Character.HasSkill(e.Character, "Shout_LLWEAPONEX_Pistol_Reload") then
			GameHelpers.Skill.Swap(e.Character, "Shout_LLWEAPONEX_Pistol_Reload", "Projectile_LLWEAPONEX_Pistol_Shoot")
		end
		if GameHelpers.Character.IsInCombat(e.Character) then
			Timer.StartObjectTimer("LLWEAPONEX_MasteryBonus_CloakAndDagger_Pistol_MarkEnemy", e.Character, 1000)
		end
	end).TimerFinished("LLWEAPONEX_MasteryBonus_CloakAndDagger_Pistol_MarkEnemy", function (self, e, bonuses)
		if e.Data.UUID ~= nil and GameHelpers.Character.IsInCombat(e.Data.Object) then
			local radius = GameHelpers.GetExtraData("LLWEAPONEX_MB_Pistol_CloakAndDagger_MarkingRadius", 6)
			local maxTargets = GameHelpers.GetExtraData("LLWEAPONEX_MB_Pistol_CloakAndDagger_MaxTargets", 1, true)
			if radius > 0 and maxTargets > 0 then
				--TODO Replace with GameHelpers.Grid.GetObjects
				---@type MasteryBonusManagerClosestEnemyData[]
				local enemies = Common.ShuffleTable(MasteryBonusManager.GetClosestEnemiesToObject(e.Data.UUID, e.Data.UUID, radius, true, maxTargets))
				for i,v in pairs(enemies) do
					if CharacterIsDead(v.UUID) == 0 
					and not GameHelpers.Status.IsSneakingOrInvisible(v.UUID) 
					and HasActiveStatus(v.UUID, "MARKED") == 0
					then
						GameHelpers.Status.Apply(v.UUID, "MARKED", 6.0, false, e.Data.UUID)
						SetTag(v.UUID, "LLWEAPONEX_Pistol_MarkedForCrit")
						StatusTurnHandler.SaveTurnEndStatus(e.Data.UUID, "MARKED", e.Data.UUID, v.UUID)
					end
				end
			end
		end
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Pistol, 2, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Pistol, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Pistol, 4, {
	
})