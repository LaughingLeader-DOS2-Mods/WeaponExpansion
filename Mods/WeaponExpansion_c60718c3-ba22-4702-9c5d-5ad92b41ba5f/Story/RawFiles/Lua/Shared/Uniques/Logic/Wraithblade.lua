if not Vars.IsClient then
	--#region Slay Hidden Skill

	---@param sourceGUID GUID
	---@param targetGUID GUID
	local function _StoreSlayHiddenTarget(sourceGUID, targetGUID)
		local data = PersistentVars.SkillData.WraithbladeSlayHiddenData[sourceGUID]
		if data then
			data.Targets[targetGUID] = true
		end
	end

	---@param sourceGUID GUID
	local function _HasSlayHiddenTargets(sourceGUID)
		local data = PersistentVars.SkillData.WraithbladeSlayHiddenData[sourceGUID]
		if data then
			return Common.TableHasAnyEntry(data.Targets)
		end
		return false
	end

	StatusManager.Subscribe.Applied("LLWEAPONEX_WRAITHBLADE_MARK", function (e)
		if e.Source then
			_StoreSlayHiddenTarget(e.SourceGUID, e.TargetGUID)
			EffectManager.PlayEffect("LLWEAPONEX_FX_Status_Wraithblade_Mark_Apply_01", e.Target, {Loop=true}, true)
			Timer.StartObjectTimer("LLWEAPONEX_Wraithblade_SlayHidden_StopEffect", e.Target, 5000)
		end
	end)

	Timer.Subscribe("LLWEAPONEX_Wraithblade_SlayHidden_StopEffect", function (e)
		EffectManager.StopEffectsByNameForObject("LLWEAPONEX_FX_Status_Wraithblade_Mark_Apply_01", e.Data.UUID)
	end)

	StatusManager.Subscribe.Applied("LLWEAPONEX_WRAITHBLADE_STEAL_INVISIBILITY", function (e)
		EffectManager.StopEffectsByNameForObject("LLWEAPONEX_FX_Status_Wraithblade_Mark_Apply_01", e.Target)
		if e.Source then
			local turns = GameHelpers.GetExtraData("LLWEAPONEX_Wraithblade_StealInvisibilityTurns", 3)
			if turns ~= 0 then
				if _HasSlayHiddenTargets(e.SourceGUID) then
					Timer.StartObjectTimer("LLWEAPONEX_Wraithblade_ApplyInvisible", e.Source, 2000)
				else
					Timer.StartObjectTimer("LLWEAPONEX_Wraithblade_ApplyInvisible", e.Source, 250)
				end
			end
		end
	end)

	Timer.Subscribe("LLWEAPONEX_Wraithblade_ApplyInvisible", function (e)
		local target = e.Data.Object
		if target then
			local turns = GameHelpers.GetExtraData("LLWEAPONEX_Wraithblade_StealInvisibilityTurns", 3)
			if turns ~= 0 then
				GameHelpers.Status.ExtendTurns(target, "INVISIBLE", turns, true, true, target)
			end
		end
	end)

	SkillManager.Register.Used("Shout_LLWEAPONEX_Wraithblade_SlayHidden", function (e)
		PersistentVars.SkillData.WraithbladeSlayHiddenData[e.CharacterGUID] = {
			StartingPosition = e.Character.WorldPos,
			Targets = {},
		}
	end)

	SkillManager.Register.Cast({"Shout_LLWEAPONEX_Wraithblade_SlayHidden", "Target_LLWEAPONEX_Wraithblade_SlayHidden_Attack"}, function (e)
		Timer.StartObjectTimer("LLWEAPONEX_Wraithblade_TryNextAttack", e.Character, 750)
	end)

	---@param source EsvCharacter
	local function _SlayHiddenAttackNextTarget(source)
		local sourceGUID = source.MyGuid
		local data = PersistentVars.SkillData.WraithbladeSlayHiddenData[sourceGUID]
		local target = next(data.Targets)
		if target then
			data.Targets[target] = nil
			EffectManager.PlayEffect("LLWEAPONEX_FX_Skills_InstantTransmission_Dissolve_Body_01", source)
			EffectManager.PlayEffectAt("LLWEAPONEX_FX_Skills_InstantTransmission_Disappear_01", source.WorldPos)
			CharacterSetFightMode(sourceGUID, 1, 1)
			CharacterLookAt(sourceGUID, target, 1)
			Osi.LeaderLib_Behavior_TeleportTo(sourceGUID, target)
			Timer.StartOneshot("", 100, function (e)
				EffectManager.PlayEffect("LLWEAPONEX_FX_Skills_InstantTransmission_Appear_01", sourceGUID)
				CharacterLookAt(sourceGUID, target, 1)
				Timer.StartObjectTimer("LLWEAPONEX_SlayHidden_DoAttack", sourceGUID, 150, {Target=target})
			end)
		end
	end

	Timer.Subscribe("LLWEAPONEX_SlayHidden_DoAttack", function (e)
		local sourceGUID = e.Data.UUID
		local targetGUID = e.Data.Target
		if sourceGUID and targetGUID then
			if GameHelpers.Character.IsDeadOrDying(targetGUID) then
				Timer.StartObjectTimer("LLWEAPONEX_Wraithblade_TryNextAttack", sourceGUID, 250)
				return
			end
			local source = GameHelpers.GetCharacter(sourceGUID, "EsvCharacter")
			if not GameHelpers.Character.IsDeadOrDying(source) then
				GameHelpers.ClearActionQueue(sourceGUID)
				GameHelpers.Action.UseSkill(source, targetGUID, "Target_LLWEAPONEX_Wraithblade_SlayHidden_Attack")
				Timer.StartObjectTimer("LLWEAPONEX_Wraithblade_SlayHidden_StopEffect", targetGUID, 5000)
			end
		end
	end)

	Timer.Subscribe("LLWEAPONEX_Wraithblade_TryNextAttack", function (e)
		local data = PersistentVars.SkillData.WraithbladeSlayHiddenData[e.Data.UUID]
		if data then
			if Common.TableHasAnyEntry(data.Targets) then
				_SlayHiddenAttackNextTarget(e.Data.Object)
			else
				PersistentVars.SkillData.WraithbladeSlayHiddenData[e.Data.UUID] = nil
			end
		end
	end)

	--#endregion
	
end

--375ff3ff-13c3-4498-b4b8-2c183df7751b