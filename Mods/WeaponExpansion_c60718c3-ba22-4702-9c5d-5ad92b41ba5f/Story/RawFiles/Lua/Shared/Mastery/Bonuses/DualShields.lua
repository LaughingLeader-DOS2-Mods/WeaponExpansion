local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

local _unsubRushProtection = {}

Config.Skill.DualShields = {}

MasteryBonusManager.AddRankBonuses(MasteryID.DualShields, 1, {
	rb:Create("DUALSHIELDS_RUSHPROTECTION", {
		Skills = MasteryBonusManager.Vars.RushSkills,
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_DualShields_RushProtection", "<font color='#FFAA33'>You are immune to surface damage and harmful statuses while moving.</font>"),
	}).Register.SkillUsed(function(self, e, bonuses)
		ObjectSetFlag(e.Character.MyGuid, "LLWEAPONEX_MasteryBonus_RushProtection", 0)
	end).SkillCast(function(self, e, bonuses)
		--This listener won't persist between saves, but that's a fair trade-off for not listening for every status
		local index = Events.OnStatus:Subscribe(function (e)
			if ObjectGetFlag(e.TargetGUID, "LLWEAPONEX_MasteryBonus_RushProtection") == 1
			and e.SourceGUID ~= e.TargetGUID
			and GameHelpers.Status.IsHarmful(e.StatusId) then
				--Aggregate blocked statuses, just in case it's spammy
				Timer.StartObjectTimer("LLWEAPONEX_DualShields_PlayRushProtectionSound", e.TargetGUID, 250)
				e.PreventApply = true
			end
		end, {MatchArgs={StatusEvent="BeforeAttempt", StatusId="All", TargetGUID = e.Character.MyGuid}})
		_unsubRushProtection[e.Character.MyGuid] = index
		Timer.StartObjectTimer("LLWEAPONEX_ResetDualShieldsRushProtection", e.Character, 1500)
	end),
})

if not Vars.IsClient then
	Timer.Subscribe("LLWEAPONEX_ResetDualShieldsRushProtection", function(e)
		if e.Data.UUID then
			local index = _unsubRushProtection[e.Data.UUID]
			if index then
				Events.OnStatus:Unsubscribe(index)
			end
			ObjectClearFlag(e.Data.UUID, "LLWEAPONEX_MasteryBonus_RushProtection", 0)
		end
	end)

	Timer.Subscribe("LLWEAPONEX_DualShields_PlayRushProtectionSound", function(e)
		if e.Data.UUID then
			PlaySound(e.Data.UUID, "Skill_Warrior_BouncingShield_Impact")
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
		if e.Data.Success and e.Data.TargetObject then
			GameHelpers.ForceMoveObject(e.Character, e.Data.TargetObject, 1, e.Skill)
		end
	end)

	--#region Cover
	StatusManager.Subscribe.Applied("LLWEAPONEX_COVERED", function (e)
		if e.Source and e.TargetGUID ~= e.SourceGUID then
			PersistentVars.SkillData.ShieldCover.Blocking[e.TargetGUID] = {
				Blocker = e.SourceGUID,
				CanCounterAttack = true
			}
		end
	end)

	StatusManager.Subscribe.Removed("LLWEAPONEX_COVERED", function (e)
		--GameHelpers.Status.Remove(target, "LLWEAPONEX_COVERING")
		local coverData = PersistentVars.SkillData.ShieldCover.Blocking[e.TargetGUID]
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
		PersistentVars.SkillData.ShieldCover.Blocking[e.TargetGUID] = nil
		PersistentVars.SkillData.ShieldCover.BlockedHit[e.TargetGUID] = nil
	end)

	local blockerTeleporting = {}

	---@param target GUID
	---@param blocker GUID
	---@param attacker GUID
	local function _CoverCounter(target, blocker, attacker)
		--TODO add combat log text
		if blockerTeleporting[blocker] ~= true then
			GameHelpers.Status.Apply(target, "LLWEAPONEX_COVERED_SHELL", 6.0, 0, blocker)
			local sx,sy,sz = GetPosition(blocker)
			local pos = GameHelpers.Math.GetForwardPosition(attacker, 2.0)
			local x,y,z = table.unpack(pos)
			EffectManager.PlayEffectAt("LLWEAPONEX_FX_Skills_ShieldCover_Counter_Disappear_Root_01", {sx, sy, sz})
			EffectManager.PlayEffectAt("LLWEAPONEX_FX_Skills_ShieldCover_Counter_Disappear_Root_01", {x, y, z})
			EffectManager.PlayEffect("LLWEAPONEX_FX_Skills_ShieldCover_Counter_Disappear_Overlay_01", blocker)
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

	---@param target GUID
	---@param blocker GUID
	---@param attacker GUID
	---@param handle integer
	local function _CoverRedirectDamage(target, blocker, attacker, handle)
		--TODO add combat log text
		if CharacterIsDead(blocker) == 0 then
			local damageSourceType = NRD_StatusGetInt(target, handle, "DamageSourceType")
			-- Ignore surfaces/statuses/GM
			if damageSourceType == 0 or damageSourceType == 6 or damageSourceType == 7 then
				GameHelpers.Damage.RedirectDamage(target, blocker, attacker, handle, 0.5, false)
			end
		end
	end

	Config.Skill.DualShields.CoverCounter = _CoverCounter
	Config.Skill.DualShields.CoverRedirectDamage = _CoverRedirectDamage
	--#endregion

	--#region Hunker Down
	SkillManager.Register.Cast("Shout_LLWEAPONEX_DualShields_HunkerDown", function(e)
		local shieldedPhysical = Ext.Stats.Get("SHIELDED_PHYSICAL", nil, false)
		-- Armor Overhauls Support
		-- Only restores armor if these statuses still do that.
		if shieldedPhysical then
			if shieldedPhysical.HealStat == "PhysicalArmor" and shieldedPhysical.HealType == "Shield" then
				GameHelpers.Status.Apply(e.Character, "SHIELDED_PHYSICAL", 0, false, e.Character)
			end
		end
		local shieldedMagic = Ext.Stats.Get("SHIELDED_MAGIC", nil, false)
		if shieldedMagic then
			if shieldedMagic.HealStat == "MagicArmor" and shieldedMagic.HealType == "Shield" then
				GameHelpers.Status.Apply(e.Character, "SHIELDED_MAGIC", 0, false, e.Character)
			end
		end
	end)

	---@param target EsvCharacter
	---@param source EsvCharacter|EsvItem|nil
	---@param data HitData
	local function _HunkerDownReduceDamage(target, source, data)
		--TODO add combat log text
		if data.Damage > 0 and data:HasHitFlag("CriticalHit", true) then
			local damageReduction = GameHelpers.GetExtraData("LLWEAPONEX_DualShields_HunkerDownCriticalHitReduction", 50)
			if damageReduction > 0 then
				damageReduction = damageReduction * 0.01
				data:MultiplyDamage(damageReduction, true)
			end
		end
	end

	Config.Skill.DualShields.HunkerDownReduceDamage = _HunkerDownReduceDamage

	StatusManager.Subscribe.Applied("LLWEAPONEX_DUALSHIELDS_HUNKER_DOWN", function (e)
		if not e.Target:HasTag("AI_PREFERRED_TARGET") then
			SetTag(e.TargetGUID, "AI_PREFERRED_TARGET")
			ObjectSetFlag(e.TargetGUID, "LLWEAPONEX_DualShields_AddedTag_AI_PREFERRED_TARGET", 0)
		end
	end)

	StatusManager.Subscribe.Removed("LLWEAPONEX_DUALSHIELDS_HUNKER_DOWN", function (e)
		if ObjectGetFlag(e.TargetGUID, "LLWEAPONEX_DualShields_AddedTag_AI_PREFERRED_TARGET") == 1 then
			ClearTag(e.TargetGUID, "AI_PREFERRED_TARGET")
			ObjectClearFlag(e.TargetGUID, "LLWEAPONEX_DualShields_AddedTag_AI_PREFERRED_TARGET", 0)
		end
	end)
	--#endregion

	--#region Shield Prison
	StatusManager.Subscribe.Removed("LLWEAPONEX_SHIELD_PRISON", function (e)
		if e.Target:GetStatus("LLWEAPONEX_SHIELD_PRISON_FX") then
			Timer.StartObjectTimer("LLWEAPONEX_RemoveShieldPrisonFX", e.Target, 250)
		end
	end)
	
	Timer.Subscribe("LLWEAPONEX_RemoveShieldPrisonFX", function (e)
		if e.Data.UUID then
			GameHelpers.Status.Remove(e.Data.UUID, "LLWEAPONEX_SHIELD_PRISON_FX")
			Timer.StartObjectTimer("LLWEAPONEX_PlayShieldPrisonEndFX", e.Data.UUID, 250)
		end
	end)

	Timer.Subscribe("LLWEAPONEX_PlayShieldPrisonEndFX", function (e)
		if e.Data.UUID and not e.Data.Object:GetStatus("LLWEAPONEX_IRONMAIDEN_SHIELDPRISON_FX") then
			EffectManager.PlayEffect("LLWEAPONEX_FX_Status_ShieldPrison_End_01", e.Data.Object)
		end
	end)
	--#endregion

	--#region Iron Maiden
	SkillManager.Register.Used("Target_LLWEAPONEX_IronMaiden", function (e)
		e.Data:ForEach(function(v, targetType, skillEventData)
			if GameHelpers.Status.IsActive(v, "LLWEAPONEX_SHIELD_PRISON") then
				GameHelpers.Status.Remove(v, "LLWEAPONEX_SHIELD_PRISON")
				GameHelpers.Status.Apply(v, "LLWEAPONEX_IRONMAIDEN_SHIELDPRISON_FX", 3.0, true, e.Character)
			end
		end, e.Data.TargetMode.Objects)
	end)

	SkillManager.Register.Hit("Target_LLWEAPONEX_IronMaiden", function (e)
		--TODO add combat log text
		if e.Data.Success then
			if GameHelpers.Status.IsActive(e.Data.Target, "BLEEDING") then
				--LLWEAPONEX_RUPTURE_INSTANT
				GameHelpers.Damage.ApplySkillDamage(e.Character, e.Data.Target, "Projectile_LLWEAPONEX_Status_Rupture_Damage")
			else
				GameHelpers.Status.Apply(e.Data.Target, "BLEEDING", 6.0, false, e.Character)
			end
			if GameHelpers.Status.IsActive(e.Data.Target, "LLWEAPONEX_IRONMAIDEN_SHIELDPRISON_FX") then
				GameHelpers.Damage.ApplySkillDamage(e.Character, e.Data.Target, "Projectile_LLWEAPONEX_Status_IronMaiden_BonusHit", {ApplySkillProperties=true})
				EffectManager.PlayEffect("LLWEAPONEX_FX_Status_IronMaidenHit_01", e.Data.Target)
				GameHelpers.Status.Remove(e.Data.Target, "LLWEAPONEX_IRONMAIDEN_SHIELDPRISON_FX")
			end
			local surface = e.Data.TargetObject.Stats.TALENT_Zombie and "Poison" or "Blood"
			GameHelpers.Surface.CreateSurface(e.Data.TargetObject.WorldPos, surface, 1.0, 6.0, e.Character.Handle, true)
		end
	end)
	--#region
end