if not Vars.IsClient then
	--1 Damage Max
	Events.OnWeaponTagHit:Subscribe(function (e)
		if e.Data.Damage > 0 then
			e.Data:ClearAllDamage()
			--No killing if at 1 hp
			if GameHelpers.Ext.ObjectIsCharacter(e.Data.TargetObject) and e.Data.TargetObject.Stats.CurrentVitality == 1 then
				return
			end
			e.Data:AddDamage("Physical", 1)
		end
	end, {MatchArgs={Tag="LLWEAPONEX_PacifistsWrath_Equipped"}})

	SkillManager.Register.Cast("Shout_LLWEAPONEX_Bokken_ChangeStance_ToOneHanded", function (e)
		SaveSkillSlot(e.CharacterGUID, "Shout_LLWEAPONEX_Bokken_ChangeStance_ToOneHanded")
		Timer.StartObjectTimer("LLWEAPONEX_PacifistsWrath_ChangeStance", e.Character, 900)
	end)

	SkillManager.Register.Cast("Shout_LLWEAPONEX_Bokken_ChangeStance_ToTwoHanded", function (e)
		SaveSkillSlot(e.CharacterGUID, "Shout_LLWEAPONEX_Bokken_ChangeStance_ToTwoHanded")
		Timer.StartObjectTimer("LLWEAPONEX_PacifistsWrath_ChangeStance", e.Character, 900)
	end)

	Timer.Subscribe("LLWEAPONEX_PacifistsWrath_ChangeStance", function (e)
		if e.Data.UUID then
			SwapUnique(e.Data.UUID, "Bokken")
		end
	end)

	SkillManager.Register.Learned("Shout_LLWEAPONEX_Bokken_ChangeStance_ToOneHanded", function (e)
		if e.Data then
			RestoreSkillSlot(e.CharacterGUID, "Shout_LLWEAPONEX_Bokken_ChangeStance_ToTwoHanded", "Shout_LLWEAPONEX_Bokken_ChangeStance_ToOneHanded")
		end
	end)

	SkillManager.Register.Learned("Shout_LLWEAPONEX_Bokken_ChangeStance_ToTwoHanded", function (e)
		if e.Data then
			RestoreSkillSlot(e.CharacterGUID, "Shout_LLWEAPONEX_Bokken_ChangeStance_ToOneHanded", "Shout_LLWEAPONEX_Bokken_ChangeStance_ToTwoHanded")
		end
	end)
end