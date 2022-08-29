Events.OnPrepareHit:Subscribe(function(e)
	if e.Data.TotalDamageDone > 0 and e.Data:Succeeded() then
		if ObjectGetFlag(e.TargetGUID, "LLWEAPONEX_MasteryBonus_RushProtection") == 1 and e.Data.HitType == "Surface" then
			e.Data.Blocked = true
			e.Data:ClearAllDamage()
			Timer.StartObjectTimer("LLWEAPONEX_ResetDualShieldsRushProtection", e.Target, 750)
			return
		end

		local hitTypeInt = Data.HitType[e.Data.HitType]

		if GameHelpers.Status.IsActive(e.Target, "LLWEAPONEX_MASTERYBONUS_SHIELD_BLOCK") and hitTypeInt < 4 then
			e.Data.Blocked = true
			e.Data:ClearAllDamage()
			GameHelpers.Status.Remove(e.Target, "LLWEAPONEX_MASTERYBONUS_SHIELD_BLOCK")
			if GameHelpers.Ext.ObjectIsCharacter(e.Target) then
				local blockedText = Ext.GetTranslatedString("h175f5a66g78d1g41a8g9530g004e19a5db8a", "Blocked!")
				CharacterStatusText(e.Target.MyGuid, string.format("<font color='#CCFF00'>%s</font>", blockedText))
			end
			return
		end
		if not StringHelpers.IsNullOrEmpty(e.SourceGUID) and GameHelpers.Ext.ObjectIsCharacter(e.Source) then
			local coverData = PersistentVars.SkillData.ShieldCover.Blocking[e.TargetGUID]
			if coverData ~= nil and coverData.CanCounterAttack == true then
				local blocker = coverData.Blocker
				if blocker ~= nil
				and CharacterIsDead(blocker) == 0
				and CharacterCanSee(blocker, e.SourceGUID) == 1
				and GameHelpers.Character.CanAttackTarget(e.Target, blocker, true)
				and hitTypeInt <= 3 then -- Everything but Surface,DoT,Reflected
					e.Data:ClearAllDamage()
					e.Data.SimulateHit = false
					e.Data.Dodged = false
					e.Data.Missed = false
					e.Data.Blocked = true
					e.Data.Hit = false
					e.Data.DontCreateBloodSurface = true
					PersistentVars.SkillData.ShieldCover.BlockedHit[e.TargetGUID] = {
						Blocker = blocker,
						Attacker = e.SourceGUID
					}
					coverData.CanCounterAttack = false
					return
				end
			end

			if not SkillConfiguration.TempData.RecalculatedUnarmedSkillDamage[e.SourceGUID] then
				if e.Data:IsFromWeapon(false, false) and UnarmedHelpers.HasUnarmedWeaponStats(e.Source.Stats) then
					UnarmedHelpers.ScaleUnarmedHitDamage(e.Source,e.Target,e.Data,true)
				end
			else
				SkillConfiguration.TempData.RecalculatedUnarmedSkillDamage[e.SourceGUID] = nil
			end

			if GameHelpers.Status.IsActive(e.Source, "LLWEAPONEX_MURAMASA_CURSE") then
				--Muramasa bonus of increasing crit damage with missing vitality percentage
				local isCrit = e.Data.Backstab or e.Data.CriticalHit
				if isCrit then
					local max = GameHelpers.GetExtraData("LLWEAPONEX_Muramasa_MaxCriticalDamageIncrease", 50)
					local damageBoost = (((100 - CharacterGetHitpointsPercentage(e.SourceGUID))/100) * max)/100
					if damageBoost > 0 then
						e.Data:MultiplyDamage(1+damageBoost)
						e.Damage = e.Data.TotalDamageDone
					end
				end
			end
		end
	end
end)

SkillConfiguration.ArmCannonSkills = {
	Zone_LLWEAPONEX_ArmCannon_Disperse = true,
	Projectile_LLWEAPONEX_ArmCannon_Shoot = true,
	Projectile_LLWEAPONEX_ArmCannon_Disperse_Explosion = true,
}

Events.OnHit:Subscribe(function(e)
	local skill = e.Data.Skill

	local blockedHit = PersistentVars.SkillData.ShieldCover.BlockedHit[e.TargetGUID]
	if blockedHit ~= nil then
		e.Data.HitStatus.AllowInterruptAction = false
		e.Data.HitStatus.ForceInterrupt = false
		e.Data.HitStatus.Interruption = false
		SkillConfiguration.DualShields.CoverCounter(e.TargetGUID, blockedHit.Blocker, blockedHit.Attacker)
		PersistentVars.SkillData.ShieldCover.BlockedHit[e.TargetGUID] = nil
	end
	local hitSucceeded = e.Data.Success
	if e.Data.SkillData and SkillConfiguration.ArmCannonSkills[skill] then
		e.Data:SetHitFlag("Hit", true)
		e.Data:SetHitFlag({"Dodged", "Missed"}, false)
		hitSucceeded = true
	end

	if hitSucceeded and e.Target then
		if GameHelpers.Ext.ObjectIsCharacter(e.Source) then
			SwordofVictory_OnHit(e.Target, e.Source, e.Data)
			local coverData = PersistentVars.SkillData.ShieldCover.Blocking[e.TargetGUID]
			if coverData ~= nil then
				SkillConfiguration.DualShields.CoverRedirectDamage(e.TargetGUID, coverData.Blocker, e.SourceGUID, e.Data.HitStatus.StatusHandle)
			end
			local canGrantMasteryXP = e.Data.Damage > 0 and MasterySystem.CanGainExperience(e.Source)
			if not e.Data.SkillData and e.Data:IsFromWeapon() then
				local xpMastery = nil
				-- if canGrantMasteryXP then
				-- 	Ext.PrintError("canGrantMasteryXP", source.DisplayName, e.SourceGUID, Lib.serpent.block(Osi.DB_IsPlayer:Get(nil)))
				-- end
				--local mainhand,offhand = GameHelpers.Character.GetEquippedWeapons(source)
				if UnarmedHelpers.HasUnarmedWeaponStats(e.Source.Stats) then
					local weapon,unarmedMasteryBoost,unarmedMasteryRank,highestAttribute,hasUnarmedWeapon = UnarmedHelpers.GetUnarmedWeapon(e.Source.Stats)
					if weapon and weapon.ExtraProperties then
						Ext.PropertyList.ExecuteExtraPropertiesOnTarget(weapon.Name, "ExtraProperties", e.Source, e.Target, e.Target.WorldPos, "Target", false, nil)
					end
					xpMastery = "LLWEAPONEX_Unarmed"
				end
				if canGrantMasteryXP then
					MasterySystem.GrantBasicAttackExperience(e.Source, e.Target, xpMastery)
				end
			elseif skill then
				if canGrantMasteryXP and IsWeaponSkill(e.Data.SkillData) then
					MasterySystem.GrantWeaponSkillExperience(e.Source, e.Target)
				end
			end
		end
		if GameHelpers.Status.IsActive(e.Target, "LLWEAPONEX_DUALSHIELDS_HUNKER_DOWN") then
			SkillConfiguration.DualShields.HunkerDownReduceDamage(e.Target, e.Source, e.Data)
		end
	end
	
	GameHelpers.Status.Remove(e.Target, "LLWEAPONEX_WARCHARGE_DAMAGEBOOST")
end)