if not Vars.IsClient then
	--LLWEAPONEX_WarchiefHalberd_Equipped

	--#region Swapping / Preserving Skill Slots
	SkillManager.Register.Cast("Shout_LLWEAPONEX_Warchief_SwitchMode", function (e)
		SaveSkillSlot(e.CharacterGUID, "Zone_LLWEAPONEX_Warchief_CripplingBlow")
		SaveSkillSlot(e.CharacterGUID, "Rush_LLWEAPONEX_Warchief_Whirlwind")
		Timer.StartObjectTimer("LLWEAPONEX_Warchief_StartModeToggle", e.Character, 900)
	end)

	Timer.Subscribe("LLWEAPONEX_Warchief_StartModeToggle", function (e)
		if e.Data.UUID then
			SwapUnique(e.Data.UUID, Uniques.WarchiefHalberd.ID)
		end
	end)

	SkillManager.Register.Learned("Zone_LLWEAPONEX_Warchief_CripplingBlow", function (e)
		RestoreSkillSlot(e.CharacterGUID, "Rush_LLWEAPONEX_Warchief_Whirlwind", "Zone_LLWEAPONEX_Warchief_CripplingBlow")
	end)

	SkillManager.Register.Learned("Rush_LLWEAPONEX_Warchief_Whirlwind", function (e)
		RestoreSkillSlot(e.CharacterGUID, "Zone_LLWEAPONEX_Warchief_CripplingBlow", "Rush_LLWEAPONEX_Warchief_Whirlwind")
	end)
	--#endregion

	--#region Whirlwind Damage
	
	--Rush damage applies immediately, so we delay it a little bit until the whirlwind animation should be done spinning

	local function _WhirlwindApplyDamage(source)
		source = GameHelpers.GetCharacter(source, "EsvCharacter")
		assert(source ~= nil, string.format("Failed to get character from (%s)", source))
		local data = PersistentVars.SkillData.WarchiefWhirlwindTargets[source.MyGuid]
		if data then
			for guid,b in pairs(data.Targets) do
				if b then
					GameHelpers.Damage.ApplySkillDamage(source, guid, "Projectile_LLWEAPONEX_Status_Warchief_Whirlwind_Damage")
					data.Targets[guid] = false
				end
			end
		end
	end

	SkillManager.Register.Used("Rush_LLWEAPONEX_Warchief_Whirlwind", function (e)
		PersistentVars.SkillData.WarchiefWhirlwindTargets[e.CharacterGUID] = {
			Ready = false,
			Targets = {}
		}
	end)

	SkillManager.Register.Cast("Rush_LLWEAPONEX_Warchief_Whirlwind", function (e)
		PersistentVars.SkillData.WarchiefWhirlwindTargets[e.CharacterGUID].Ready = true
		_WhirlwindApplyDamage(e.Character)
		Timer.StartObjectTimer("LLWEAPONEX_WarchiefWhirlwind_Done", e.Character, 1200)
	end)

	StatusManager.Subscribe.Applied("LLWEAPONEX_WARCHIEF_WHIRLWIND_HIT", function (e)
		local data = PersistentVars.SkillData.WarchiefWhirlwindTargets[e.SourceGUID]
		if data and data.Targets[e.TargetGUID] == nil then
			data.Targets[e.TargetGUID] = true
			if data.Ready then
				--Apply damage immediately since the spinning animation is active
				_WhirlwindApplyDamage(e.Source)
			end
		end
	end)

	Timer.Subscribe("LLWEAPONEX_WarchiefWhirlwind_Done", function (e)
		_WhirlwindApplyDamage(e.Data.Object)
		PersistentVars.SkillData.WarchiefWhirlwindTargets[e.Data.UUID] = nil
	end)
	--#endregion
end