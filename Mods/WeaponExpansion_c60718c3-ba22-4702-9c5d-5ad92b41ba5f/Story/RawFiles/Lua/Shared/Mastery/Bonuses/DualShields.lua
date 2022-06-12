local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

MasteryBonusManager.AddRankBonuses(MasteryID.DualShields, 1, {
	rb:Create("DUALSHIELDS_RUSHPROTECTION", {
		Skills = MasteryBonusManager.Vars.RushSkills,
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_DualShields_RushProtection", "<font color='#FFAA33'>You are immune to surface damage and harmful statuses while moving.</font>"),
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.USED then
			ObjectSetFlag(char, "LLWEAPONEX_MasteryBonus_RushProtection", 0)
		elseif state == SKILL_STATE.CAST then
			Timer.StartObjectTimer("LLWEAPONEX_ResetDualShieldsRushProtection", char, 1500)
		end
	end):RegisterStatusBeforeAttemptListener(function(bonuses, target, status, source, statusType)
		if bonuses.HasBonus("DUALSHIELDS_RUSHPROTECTION", target.MyGuid) and GameHelpers.Status.IsHarmful(status.StatusId) then
			--Aggregate blocked statuses, just in case it's spammy
			Timer.StartOneshot("", 250, function()
				PlaySound(target.MyGuid, "Skill_Warrior_BouncingShield_Impact")
			end)
			--Block status from surface
			return false
		end
	end, "All"),
})

if not Vars.IsClient then
	Timer.Subscribe("LLWEAPONEX_ResetDualShieldsRushProtection", function(e)
		if e.Data.UUID then
			ObjectClearFlag(e.Data.UUID, "LLWEAPONEX_MasteryBonus_RushProtection", 0)
		end
	end)
end

MasteryBonusManager.AddRankBonuses(MasteryID.DualShields, 2, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.DualShields, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.DualShields, 4, {
	
})

--Mastery skills / weapon skills

if not Vars.IsClient then
	SkillManager.Register.Hit("Target_LLWEAPONEX_ShieldBash", function(e)
		if e.Data.Success then
			GameHelpers.ForceMoveObject(e.Character, e.Data.Target, 1, e.Skill)
		end
	end)
	
	SkillManager.Register.Cast("Shout_LLWEAPONEX_DualShields_HunkerDown", function(e)
		-- Armor Overhaul Support
		-- Only restores armor if these statuses still do that.
		local healStat = Ext.StatGetAttribute("SHIELDED_PHYSICAL", "HealStat")
		local healType = Ext.StatGetAttribute("SHIELDED_PHYSICAL", "HealType")
		if healStat == "PhysicalArmor" and healType == "Shield" then
			GameHelpers.Status.Apply(e.Character, "SHIELDED_PHYSICAL", 0.0, 0, e.Character)
		end
		healStat = Ext.StatGetAttribute("SHIELDED_MAGIC", "HealStat")
		healType = Ext.StatGetAttribute("SHIELDED_MAGIC", "HealType")
		if healStat == "MagicArmor" and healType == "Shield" then
			GameHelpers.Status.Apply(e.Character, "SHIELDED_MAGIC", 0.0, 0, e.Character)
		end
		--Ext.IsModLoaded(MODID.DivinityUnleashed) or Ext.IsModLoaded(MODID.ArmorMitigation) then
	end)

	function DualShields_Cover_OnApplied(target, blocker)
		PersistentVars.SkillData.ShieldCover.Blocking[target] = {
			Blocker = blocker,
			CanCounterAttack = true
		}
		--GameHelpers.Status.Apply(target, "LLWEAPONEX_COVERED_SHELL", 6.0, 0, blocker)
	end

	local blockerTeleporting = {}

	function DualShields_Cover_OnCounter(target, blocker, attacker)
		if blockerTeleporting[blocker] ~= true then
			GameHelpers.Status.Apply(target, "LLWEAPONEX_COVERED_SHELL", 6.0, 0, blocker)
			local sx,sy,sz = GetPosition(blocker)
			local pos = GameHelpers.Math.GetForwardPosition(attacker, 2.0)
			local x,y,z = table.unpack(pos)
			PlayEffectAtPosition("LLWEAPONEX_FX_Skills_ShieldCover_Counter_Disappear_Root_01", sx, sy, sz)
			PlayEffectAtPosition("LLWEAPONEX_FX_Skills_ShieldCover_Counter_Disappear_Root_01", x, y, z)
			PlayEffect(blocker, "LLWEAPONEX_FX_Skills_ShieldCover_Counter_Disappear_Overlay_01")
			Osi.LeaderLib_Behavior_TeleportTo(blocker, x, y, z)
			blockerTeleporting[blocker] = true
			Timer.StartOneshot("Timers_LLWEAPONEX_CoverCounter_"..blocker, 50, function()
				TeleportToRandomPosition(blocker, 1.0, "")
				CharacterStatusText(attacker, "LLWEAPONEX_StatusText_Countered")
				GameHelpers.ClearActionQueue(blocker)
				CharacterUseSkill(blocker, "Target_LLWEAPONEX_ShieldCover_CounterAttack", attacker, 1, 1, 1)
				blockerTeleporting[blocker] = nil
			end)
		end
	end

	function DualShields_Cover_OnRemoved(target)
		--GameHelpers.Status.Remove(target, "LLWEAPONEX_COVERING")
		local coverData = PersistentVars.SkillData.ShieldCover.Blocking[target]
		if coverData ~= nil and coverData.Blocker ~= nil then
			local isBlocking = false
			for uuid,v in pairs(PersistentVars.SkillData.ShieldCover.Blocking) do
				if v.Blocker == coverData.Blocker then
					isBlocking = true
					break
				end
			end
			if not isBlocking then 
				GameHelpers.Status.Remove(coverData.Blocker, "LLWEAPONEX_COVERING")
			end
		end
		PersistentVars.SkillData.ShieldCover.Blocking[target] = nil
		PersistentVars.SkillData.ShieldCover.BlockedHit[target] = nil
	end

	function DualShields_Cover_RedirectDamage(target, blocker, attacker, handle)
		if CharacterIsDead(blocker) == 0 then
			local damageSourceType = NRD_StatusGetInt(target, handle, "DamageSourceType")
			-- Ignore surfaces/statuses/GM
			if damageSourceType == 0 or damageSourceType == 6 or damageSourceType == 7 then
				GameHelpers.RedirectDamage(target, blocker, attacker, handle, 0.5, false)
			end
		end
	end

	SkillManager.Register.All("Target_LLWEAPONEX_IronMaiden", function(e)
		if e.State == SKILL_STATE.USED then
			e.Data:ForEach(function(v, targetType, skillEventData)
				if GameHelpers.Status.IsActive(v, "LLWEAPONEX_SHIELD_PRISON") then
					GameHelpers.Status.Remove(v, "LLWEAPONEX_SHIELD_PRISON")
					GameHelpers.Status.Apply(v, "LLWEAPONEX_IRONMAIDEN_SHIELDPRISON_FX", 3.0, true, e.Character)
				end
			end, e.Data.TargetMode.Objects)
		elseif e.State == SKILL_STATE.HIT and e.Data.Success then
			if HasActiveStatus(e.Data.Target, "BLEEDING") == 1 then
				--LLWEAPONEX_RUPTURE_INSTANT
				GameHelpers.Damage.ApplySkillDamage(e.Character, e.Data.Target, "Projectile_LLWEAPONEX_Status_Rupture_Damage")
			else
				GameHelpers.Status.Apply(e.Data.Target, "BLEEDING", 6.0, false, e.Character)
			end
			if HasActiveStatus(e.Data.Target, "LLWEAPONEX_IRONMAIDEN_SHIELDPRISON_FX") == 1 then
				GameHelpers.Damage.ApplySkillDamage(e.Character, e.Data.Target, "Projectile_LLWEAPONEX_Status_IronMaiden_BonusHit", {ApplySkillProperties=true})
				EffectManager.PlayEffect("LLWEAPONEX_FX_Status_IronMaidenHit_01", e.Data.Target)
				GameHelpers.Status.Remove(e.Data.Target, "LLWEAPONEX_IRONMAIDEN_SHIELDPRISON_FX")
			end
			local surface = e.Data.TargetObject.Stats.TALENT_Zombie and "Poison" or "Blood"
			GameHelpers.Surface.CreateSurface(e.Data.TargetObject.WorldPos, surface, 1.0, 6.0, e.Character.Handle, true)
		end
	end)
end