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
		local source = e.Data.Object --[[@as EsvCharacter]]
		if source ~= nil and (GameHelpers.Character.IsInCombat(source) or source:HasTag("LLWEAPONEX_MasteryTestCharacter")) then
			local radius = GameHelpers.GetExtraData("LLWEAPONEX_MB_Pistol_CloakAndDagger_MarkingRadius", 6)
			local maxTargets = GameHelpers.GetExtraData("LLWEAPONEX_MB_Pistol_CloakAndDagger_MaxTargets", 1, true)
			if radius > 0 and maxTargets > 0 then
				if GameHelpers.Character.IsDeadOrDying(source) then
					return
				end
				local enemies = GameHelpers.Grid.GetNearbyObjects(e.Data.UUID, {Relation={Enemy=true}, Type="Character", Sort="Random", Radius=radius, AsTable=true})
				---@cast enemies EsvCharacter[]
				local len = math.min(#enemies, maxTargets)
				if len > 0 then
					for i=1,len do
						local enemy = enemies[i]
						if not GameHelpers.Status.IsSneakingOrInvisible(enemy) and not GameHelpers.Status.IsActive(enemy, "MARKED") then
							GameHelpers.Status.Apply(enemy, "MARKED", 6.0, false, e.Data.UUID)
							SetTag(enemy.MyGuid, "LLWEAPONEX_Pistol_MarkedForCrit")
							StatusTurnHandler.SaveTurnEndStatus(source, "MARKED", source, enemy)
						end
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