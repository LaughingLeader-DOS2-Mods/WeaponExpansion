StatusManager.Subscribe.Applied("LLWEAPONEX_INTERRUPT", function (e)
	GameHelpers.Status.Apply(e.Target, {"MUTED", "DISARMED"}, 0, true, e.Source)
end)

StatusManager.Subscribe.Applied("LLWEAPONEX_DIZZY", function (e)
	if GameHelpers.Ext.ObjectIsCharacter(e.Target) and e.Target.AnimationOverride == "" then
		ObjectSetFlag(e.TargetGUID, "PlayAnim_Loop_stilldrunk", 0)
	end
end)

StatusManager.Subscribe.Removed("LLWEAPONEX_DIZZY", function (e)
	if GameHelpers.Ext.ObjectIsCharacter(e.Target) and e.Target.AnimationOverride == "stilldrunk" then
		CharacterSetAnimationOverride(e.TargetGUID, "")
	end
end)

StatusManager.Subscribe.Applied("LLWEAPONEX_WARCHARGE_BONUS", function (e)
	GameHelpers.Status.Apply(e.Target, "LLWEAPONEX_WARCHARGE_DAMAGEBOOST", 12, false, e.Source)
end)

StatusManager.Subscribe.BeforeAttempt("BURNING", function (e)
	if e.Status.CurrentLifeTime > 0 and e.Target:GetStatus("LLWEAPONEX_TARRED") then
		e.Status.CurrentLifeTime = e.Status.CurrentLifeTime + 6.0
		e.Status.LifeTime = e.Status.LifeTime + 6.0
		e.Status.ForceStatus = true
	end
end)

Config.Skill.RandomGroundSurfaces = {"Fire", "Water", "WaterFrozen", "WaterElectrified", "Blood", "BloodFrozen", "BloodElectrified", "Poison", "Oil"}

StatusManager.Subscribe.Applied("LLWEAPONEX_RANDOM_SURFACE_SMALL", function (e)
	local surface = Common.GetRandomTableEntry(Config.Skill.RandomGroundSurfaces)
	GameHelpers.Surface.CreateSurface(e.Target.WorldPos, surface, 1.0, e.Status.CurrentLifeTime, e.Source and e.Source.Handle or nil, true)
	if e.Status.CurrentLifeTime ~= 0 then
		GameHelpers.Status.Remove(e.Target, "LLWEAPONEX_RANDOM_SURFACE_SMALL")
	end
end)

Events.OnBasicAttackStart:Subscribe(function (e)
	local concussion = e.Attacker:GetStatus("LLWEAPONEX_CONCUSSION")
	if concussion then
		local chance = GameHelpers.GetExtraData("LLWEAPONEX_Concussion_FumbleChance", 10)
		if chance > 0 and GameHelpers.Math.Roll(chance) then
			local source = nil
			if GameHelpers.IsValidHandle(concussion.StatusSourceHandle) then
				source = GameHelpers.TryGetObject(concussion.StatusSourceHandle)
			end
			GameHelpers.Status.Apply(e.Target, "LLWEAPONEX_FUMBLE", 0, true, source)
		end
	end
end)

StatusManager.Subscribe.Applied("LLWEAPONEX_FUMBLE", function (e)
	if GameHelpers.Ext.ObjectIsCharacter(e.Target) then
		GameHelpers.ClearActionQueue(e.TargetGUID, false)
		GameHelpers.Action.PlayAnimation(e.Target, "hit")
	end
end)

StatusManager.Subscribe.Applied("LLWEAPONEX_DRAGONS_BANE", function (e)
	GameHelpers.Status.Apply(e.Target, "KNOCKED_DOWN", 6.0, true, e.Source)
end)

StatusManager.Subscribe.Applied("LLWEAPONEX_MAGIC_KNOCKDOWN_CHECK", function (e)
	GameHelpers.Status.Apply(e.Target, "KNOCKED_DOWN", e.Status.CurrentLifeTime, true, e.Source)
end)

StatusManager.Subscribe.Applied("LLWEAPONEX_MAGIC_BLEEDING_CHECK", function (e)
	GameHelpers.Status.Apply(e.Target, "BLEEDING", e.Status.CurrentLifeTime, true, e.Source)
end)

StatusManager.Subscribe.Applied("LLWEAPONEX_MAGIC_CRIPPLED_CHECK", function (e)
	GameHelpers.Status.Apply(e.Target, "CRIPPLED", e.Status.CurrentLifeTime, true, e.Source)
end)

StatusManager.Subscribe.Applied("LLWEAPONEX_PHYSICAL_BLIND_CHECK", function (e)
	GameHelpers.Status.Apply(e.Target, "BLIND", e.Status.CurrentLifeTime, true, e.Source)
end)

StatusManager.Subscribe.Applied("LLWEAPONEX_PHYSICAL_WEAK_CHECK", function (e)
	GameHelpers.Status.Apply(e.Target, "WEAK", e.Status.CurrentLifeTime, true, e.Source)
end)

--[[ StatusManager.Subscribe.Applied("LLWEAPONEX_BLOCK_HEALING", function (e)
	CharacterStatusText(e.Target, "LLWEAPONEX_StatusText_BlockedHealing")
	EffectManager.PlayEffect("LLWEAPONEX_FX_Status_BlockHealing_Hit_01", e.Target, {Bone="Dummy_FrontFX"})
end) ]]

--#region Unrelenting Rage

Events.CCH.GetHitResistanceBonus:Subscribe(function (e)
	if e.DamageType == "Physical" then
		local target = e.Target.Character --[[@as EsvCharacter]]
		if target then
			-- Unrelenting Rage grants up to a max of 20% Physical Resistance, but anything over that isn't increased.
			local maxResBonus = GameHelpers.GetExtraData("LLWEAPONEX_UnrelentingRage_MaxPhysicalResistanceBonus", 20)
			if e.CurrentResistanceAmount < maxResBonus and GameHelpers.Status.IsActive(target, "LLWEAPONEX_UNRELENTING_RAGE") then
				e.CurrentResistanceAmount = math.min(20, e.CurrentResistanceAmount + maxResBonus)
			end
		end
	end
end)

Ext.Osiris.RegisterListener("CharacterKilledBy", 3, "after", function (targetGUID, attackerOwnerGUID, attackerGUID)
	if HasActiveStatus(attackerGUID, "LLWEAPONEX_UNRELENTING_RAGE") == 1 and GameHelpers.Character.CanAttackTarget(targetGUID, attackerGUID, false) then
		GameHelpers.Status.Apply(attackerGUID, "LLWEAPONEX_UNRELENTING_RAGE_BONUS_APPLY", 0, false, attackerGUID)
	end
end)

Ext.Osiris.RegisterListener("ObjectTurnStarted", 1, "after", function (guid)
	if HasActiveStatus(guid, "LLWEAPONEX_UNRELENTING_RAGE") == 1 then
		ObjectSetFlag(guid, "LLWEAPONEX_UnrelentingRageAttackPending", 0)
	end
end)

Ext.Osiris.RegisterListener("ObjectTurnEnded", 1, "after", function (guid)
	if ObjectGetFlag(guid, "LLWEAPONEX_UnrelentingRageAttackPending") == 1 then
		ObjectClearFlag(guid, "LLWEAPONEX_UnrelentingRageAttackPending", 0)
		GameHelpers.Status.Remove(guid, "LLWEAPONEX_UNRELENTING_RAGE")
	end
end)

StatusManager.Subscribe.Removed("LLWEAPONEX_UNRELENTING_RAGE", function (e)
	if e.Target then
		for _,v in pairs(e.Target:GetStatuses()) do
			if string.find(v, "LLWEAPONEX_UNRELENTING_RAGE_BONUS") then
				GameHelpers.Status.Remove(e.Target, v)
			end
		end
	end
end)

StatusManager.Subscribe.AppliedType("DISABLE", function (e)
	GameHelpers.Status.Remove(e.Target, "LLWEAPONEX_UNRELENTING_RAGE")
end)

--#endregion

Events.CharacterDied:Subscribe(function (e)
	if e.Character:GetStatus("LLWEAPONEX_DEATH_SENTENCE") then
		local pos = e.Character.WorldPos
		EffectManager.PlayEffectAt("RS3_FX_GP_ScriptedEvent_SourceJar_Death_Impact_01", pos)
		EffectManager.PlayEffectAt("RS3_FX_GP_Impacts_Ghost_01", pos)
	end
end, {MatchArgs={State="BeforeDying"}})

---@param revenant EsvCharacter
---@param guid Guid
local function _KillRevenant(revenant, guid, source)
	PersistentVars.StatusData.Revenants[guid] = nil
	if revenant then
		EffectManager.PlayEffectAt("RS3_FX_GP_ScriptedEvent_GhostDissipate_01", revenant.WorldPos)
		local x,y,z = table.unpack(revenant.WorldPos)
		local sourceGUID = source and source.MyGuid or guid
		TransformSurfaceAtPosition(x, y, z, "Vaporize", "Ground", 1.0, 12.0, sourceGUID)
		if not GameHelpers.Character.IsDeadOrDying(revenant) then
			CharacterDieImmediate(revenant.MyGuid, 0, "LifeTime", revenant.MyGuid)
		end
	end
	RemoveTemporaryCharacter(guid)
end

Config.Skill.Revenants = {
	Templates = {
		Base = "bb15f97e-b6bf-4648-9190-71b42a7744c4",
	},
	KillRevenant = _KillRevenant,
	---@param source EsvCharacter
	---@param target CharacterParam|vec3
	---@param template FixedString|nil
	---@return EsvCharacter|nil revenant
	Create = function (source, target, template)
		if not template then
			template = Config.Skill.Revenants.Templates.Base
		end
		local name = Text.Misc.Revenant.Value
		local level = source.Stats.Level
		local x,y,z = GameHelpers.Math.GetPosition(target, true)
		local targetIsCharacter = false
		if type(target) ~= "table" then
			target = GameHelpers.GetCharacter(target, "EsvCharacter")
			if target then
				---@cast target EsvCharacter
				level = target.Stats.Level
				name = Text.Misc.Revenant_WithName:ReplacePlaceholders(GameHelpers.Character.GetDisplayName(target))
				targetIsCharacter = true
			end
		end
		--local revenant = GameHelpers.GetCharacter(NRD_Summon(source.MyGuid, template, x, y, z, -1, level, 0, 1), "EsvCharacter")
		local revenant = GameHelpers.GetCharacter(TemporaryCharacterCreateAtPosition(x, y, z, template, 0), "EsvCharacter")
		if targetIsCharacter then
			local targetGUID = target.MyGuid
			local revenantGUID = revenant.MyGuid
			--CharacterSetDetached(revenantGUID, 1)
			CharacterTransformAppearanceTo(revenantGUID, targetGUID, 1, 1)
			GameHelpers.Character.SetLevel(revenant, level)
			local faction = source.CurrentTemplate.CombatTemplate.Alignment
			SetFaction(revenantGUID, faction)
			revenant.Stats.CurrentVitality = revenant.Stats.MaxVitality
			revenant.CustomDisplayName = name
			TeleportToRandomPosition(revenantGUID, 4, "")
			Osi.LeaderLib_Helper_CopyAbilities(revenantGUID, targetGUID)
			Osi.LeaderLib_Helper_CopyAttributes(revenantGUID, targetGUID)
			CharacterCloneSkillsTo(targetGUID, revenantGUID, 1)
			EffectManager.PlayEffect("RS3_FX_Char_Ghosts_Teleport_in_01", revenant)
			GameHelpers.Status.Apply(revenant, "LLWEAPONEX_REVENANT", 12, true, source)
			if GameHelpers.Character.IsPlayer(source) then
				CharacterAddToPlayerCharacter(revenantGUID, source.MyGuid)
				Osi.SetRelationIndivFactionToPlayers(revenantGUID, 100)
			end

			if GameHelpers.Character.IsInCombat(source) then
				local combatid = GameHelpers.Combat.GetID(source)
				local enemies = GameHelpers.Combat.GetCharacters(combatid, "Enemy", source, true)
				if enemies[1] then
					EnterCombat(revenantGUID, enemies[1].MyGuid)
				else
					Osi.ProcCharacterFollowCharacter(revenantGUID, source.MyGuid)
				end
			else
				Osi.ProcCharacterFollowCharacter(revenantGUID, source.MyGuid)
			end

			return revenant
		end
	end
}

StatusManager.Subscribe.BeforeDelete("LLWEAPONEX_DEATH_SENTENCE", function (e)
	if e.Source and GameHelpers.Character.IsDeadOrDying(e.Target) then
		local revenant = Config.Skill.Revenants.Create(e.Source, e.Target)
		if revenant then
			PersistentVars.StatusData.Revenants[revenant.MyGuid] = e.SourceGUID
		end
	end
end)

local function _TryKillRevenant(guid)
	local revenant = GameHelpers.GetCharacter(guid, "EsvCharacter")
	if revenant then
		if not GameHelpers.Character.IsDeadOrDying(revenant) then
			CharacterDieImmediate(guid, 0, "LifeTime", guid)
			 -- Let the died event clear the table key
			return
		end
	end
	PersistentVars.StatusData.Revenants[guid] = nil
end

Events.CharacterDied:Subscribe(function (e)
	if PersistentVars.StatusData.Revenants[e.CharacterGUID] then
		local source = GameHelpers.Status.GetSourceByID(e.Character, "LLWEAPONEX_REVENANT")
		if source then
			_KillRevenant(e.Character, e.CharacterGUID, source)
		end
	end
end, {MatchArgs={State="StatusBeforeAttempt"}})

StatusManager.Subscribe.Removed("LLWEAPONEX_REVENANT", function (e)
	_TryKillRevenant(e.TargetGUID)
end)

Events.CharacterResurrected:Subscribe(function (e)
	for revenantGUID,sourceGUID in pairs(PersistentVars.StatusData.Revenants) do
		if sourceGUID == e.CharacterGUID then
			_TryKillRevenant(revenantGUID)
		end
	end
end)

--[[
Revenant Save Bug 2/4/2019
When a save with an attached revenant is loaded, that revenant no longer remains attached, despite still being a "player".
Not sure why this is happeneing, but unattaching them and re-attaching after the game is started works.
--]]

Events.Initialized:Subscribe(function (e)
	for revenantGUID,sourceGUID in pairs(PersistentVars.StatusData.Revenants) do
		if ObjectExists(revenantGUID) == 1 and GameHelpers.Character.IsPlayer(sourceGUID) then
			CharacterAddToPlayerCharacter(revenantGUID, sourceGUID)
		end
	end
end)

--[[ Ext.Osiris.RegisterListener("ObjectTurnEnded", 1, "after", function (guid)
	local object = GameHelpers.TryGetObject(guid)
	if object then
		for id,b in pairs(Config.Status.RemoveOnTurnEnding) do
			if b and object:GetStatus(id) then
				GameHelpers.Status.Remove(object, id)
			end
		end
		if object:HasTag("LLWEAPONEX_Pistol_MarkedForCrit") then
			GameHelpers.Status.Remove(object, "MARKED")
			ClearTag(object.MyGuid, "LLWEAPONEX_Pistol_MarkedForCrit")
		end
	end
end) ]]

--#region Soul Burn

--LLWEAPONEX_SOUL_BURN_PROC - Increase the stack
--LLWEAPONEX_SOUL_BURN_TICK - Lower the stack

Events.ObjectEvent:Subscribe(function (e)
	local target = e.Objects[1]
	if not GameHelpers.Status.IsActive(target, "LLWEAPONEX_SOUL_BURN1") then
		ObjectClearFlag(e.ObjectGUID1, "LLWEAPONEX_SkipSoulBurnTick", 0)
		GameHelpers.Status.Apply(target, "LLWEAPONEX_SOUL_BURN_TICK", 6.0, true, target)
	end
end, {MatchArgs={Event="LLWEAPONEX_Commands_StartSoulBurnTick"}})

Events.ObjectEvent:Subscribe(function (e)
	ObjectSetFlag(e.ObjectGUID1, "LLWEAPONEX_SkipSoulBurnTick", 0)
	GameHelpers.Status.Remove(e.ObjectGUID1, "LLWEAPONEX_SOUL_BURN_TICK")
end, {MatchArgs={Event="LLWEAPONEX_Commands_StopSoulBurnTick"}})

StatusManager.Subscribe.Removed("LLWEAPONEX_SOUL_BURN_TICK", function (e)
	if ObjectGetFlag(e.TargetGUID, "LLWEAPONEX_SkipSoulBurnTick") == 1 then
		Timer.StartObjectTimer("LLWEAPONEX_ResetSkipSoulBurnTickTimerFlag", e.Target, 250)
	end
end)

Timer.Subscribe("LLWEAPONEX_ResetSkipSoulBurnTickTimerFlag", function (e)
	ObjectClearFlag(e.Data.UUID, "LLWEAPONEX_SkipSoulBurnTick", 0)
end)

--#endregion