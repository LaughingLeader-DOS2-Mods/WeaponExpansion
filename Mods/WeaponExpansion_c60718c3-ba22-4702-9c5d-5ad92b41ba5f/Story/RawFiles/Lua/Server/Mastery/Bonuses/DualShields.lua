
---@param bonuses table<string,bool>
---@param char string
---@param state SKILL_STATE
---@param skill string
---@param skillType string
---@param element string
MasteryBonusManager.RegisterSkillTypeListener("rush", {"DUALSHIELDS_RUSHPROTECTION"}, function(bonuses, char, state, skill, skillType, element)
	if state == SKILL_STATE.USED then
		ObjectSetFlag(char, "LLWEAPONEX_MasteryBonus_RushProtection", 0)
	elseif state == SKILL_STATE.CAST then
		Osi.LeaderLib_Timers_StartObjectTimer(char, 1500, "Timers_LLWEAPONEX_ResetDualShieldsRushProtection", "LLWEAPONEX_ResetDualShieldsRushProtection")
	end
end)

---@param skill string
---@param char string
---@param state SkillState
---@param data HitData
LeaderLib.RegisterSkillListener("Target_LLWEAPONEX_ShieldBash", function(skill, char, state, data)
	if state == SKILL_STATE.HIT and data.Success then
		Osi.LeaderLib_Force_Apply(char, data.Target, 1)
	end
end)

---@param skill string
---@param char string
---@param state SkillState
---@param data SkillEventData
LeaderLib.RegisterSkillListener("Shout_LLWEAPONEX_DualShields_HunkerDown", function(skill, char, state, data)
	if state == SKILL_STATE.CAST then
		-- Armor Overhaul Support
		-- Only restores armor if these statuses still do that.
		local healStat = Ext.StatGetAttribute("SHIELDED_PHYSICAL", "HealStat")
		local healType = Ext.StatGetAttribute("SHIELDED_PHYSICAL", "HealType")
		if healStat == "PhysicalArmor" and healType == "Shield" then
			ApplyStatus(char, "SHIELDED_PHYSICAL", 0.0, 0, char)
		end
		healStat = Ext.StatGetAttribute("SHIELDED_MAGIC", "HealStat")
		healType = Ext.StatGetAttribute("SHIELDED_MAGIC", "HealType")
		if healStat == "MagicArmor" and healType == "Shield" then
			ApplyStatus(char, "SHIELDED_MAGIC", 0.0, 0, char)
		end
		--Ext.IsModLoaded(MODID.DivinityUnleashed) or Ext.IsModLoaded(MODID.ArmorMitigation) then
	end
end)

function DualShields_Cover_OnApplied(target, blocker)
	PersistentVars.SkillData.ShieldCover.Blocking[target] = {
		Blocker = blocker,
		CanCounterAttack = true
	}
	--ApplyStatus(target, "LLWEAPONEX_COVERED_SHELL", 6.0, 0, blocker)
end

local blockerTeleporting = {}

function DualShields_Cover_OnCounter(target, blocker, attacker)
	if blockerTeleporting[blocker] ~= true then
		ApplyStatus(target, "LLWEAPONEX_COVERED_SHELL", 6.0, 0, blocker)
		local sx,sy,sz = GetPosition(blocker)
		local pos = GameHelpers.Math.GetForwardPosition(attacker, 2.0)
		local x,y,z = table.unpack(pos)
		PlayEffectAtPosition("LLWEAPONEX_FX_Skills_ShieldCover_Counter_Disappear_Root_01", sx, sy, sz)
		PlayEffectAtPosition("LLWEAPONEX_FX_Skills_ShieldCover_Counter_Disappear_Root_01", x, y, z)
		PlayEffect(blocker, "LLWEAPONEX_FX_Skills_ShieldCover_Counter_Disappear_Overlay_01")
		Osi.LeaderLib_Behavior_TeleportTo(blocker, x, y, z)
		blockerTeleporting[blocker] = true
		StartOneshotTimer("Timers_LLWEAPONEX_CoverCounter_"..blocker, 50, function()
			TeleportToRandomPosition(blocker, 1.0, "")
			CharacterStatusText(attacker, "LLWEAPONEX_StatusText_Countered")
			GameHelpers.ClearActionQueue(blocker)
			CharacterUseSkill(blocker, "Target_LLWEAPONEX_ShieldCover_CounterAttack", attacker, 1, 1, 1)
			blockerTeleporting[blocker] = nil
		end)
	end
end

function DualShields_Cover_OnRemoved(target)
	--RemoveStatus(target, "LLWEAPONEX_COVERING")
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
			RemoveStatus(coverData.Blocker, "LLWEAPONEX_COVERING")
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