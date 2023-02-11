if not Vars.IsClient then
	local function _EnableCharacterWorkarounds(targetGUID, sourceGUID)
		if targetGUID == "69b951dc-55a4-44b8-a2d5-5efedbd7d572" then -- Dallis
			SetTag(targetGUID, "MASKED_UNDEAD")
			--SetTag(targetGUID, "VEILED_UNDEAD")
			Osi.ProcCharacterDisableCrime(targetGUID, "ActiveUndead")
			Osi.ProcCharacterDisableCrime(targetGUID, "Resist_Arrest")
			-- CharacterDisableCrime(targetGUID, "ActiveUndead")
			-- Osi.DB_CharacterCrimeDisabled(targetGUID, "ActiveUndead")
		end
	end
	
	StatusManager.Subscribe.Applied("LLWEAPONEX_BODYSNATCH", function (e)
		local source = e.SourceGUID
		local target = e.TargetGUID

		local trot = e.Target.Rotation
		local tpos = e.Target.WorldPos
		tpos[2] = tpos[2] + 2

		local srot = e.Source.Rotation
		local spos = e.Source.WorldPos

		_EnableCharacterWorkarounds(target, source)
		Timer.StartOneshot("", 250, function (_)
			if GameHelpers.Character.MakePlayer(target, source, {SkipAssigningFaction=true, SkipPartyCheck=true}) then
				CharacterCloneSkillsTo(source, target, 1)
				Osi.PROC_GLO_PartyMembers_Remove(source, 1)
				CharacterDie(source, 0, "Physical", source)
				Timer.StartOneshot("", 250, function (_)
					Osi.ProcTryStopDialogFor(target)
					MakePlayerActive(target)
					GameHelpers.Utils.SetPlayerCameraPosition(target, {TargetLookAt=tpos, CurrentLookAt=tpos})
				end)
			end
		end)
	end)
end