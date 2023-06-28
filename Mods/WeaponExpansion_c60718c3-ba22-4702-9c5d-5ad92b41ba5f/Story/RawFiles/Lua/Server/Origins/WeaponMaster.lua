WeaponMaster = {}

function WeaponMaster.RegisterLeaderLibTraderSettings()
	--S_LLWEAPONEX_WeaponMaster_Trader_3cabc61d-6385-4ae3-b38f-c4f24a8d16b5
	--DB_Dialogs(S_LLWEAPONEX_WeaponMaster_Trader_3cabc61d-6385-4ae3-b38f-c4f24a8d16b5, "LLWEAPONEX_WeaponMaster_Trader")
	Osi.LeaderLib_Trader_Register_Dialog("LLWEAPONEX.WeaponMaster.Trader", "LLWEAPONEX_WeaponMaster_Trader") -- Default

	--S_LLWEAPONEX_WeaponMaster_Trader
	Osi.LeaderLib_Trader_Register_GlobalTrader("LLWEAPONEX.WeaponMaster.Trader", NPC.WeaponMaster)

	Osi.LeaderLib_Trader_Register_StartingGold("LLWEAPONEX.WeaponMaster.Trader", "TUT_Tutorial_A", 250)
	Osi.LeaderLib_Trader_Register_StartingGold("LLWEAPONEX.WeaponMaster.Trader", "FJ_FortJoy_Main", 3500)

	Osi.LeaderLib_Trader_Register_Seat("LLWEAPONEX.WeaponMaster.Trader", "FJ_FortJoy_Main", "f204c77a-6981-4362-9455-6f0f3d0ce99d")
	Osi.LeaderLib_Trader_Register_Seat("LLWEAPONEX.WeaponMaster.Trader", "LV_HoE_Main", "6bf9707b-cb27-40fb-943a-a0c9772e3ed9")
	Osi.LeaderLib_Trader_Register_Seat("LLWEAPONEX.WeaponMaster.Trader", "RC_Main", "a809eda1-9d42-4eb9-8233-3d0d6ffe2263")
	Osi.LeaderLib_Trader_Register_Seat("LLWEAPONEX.WeaponMaster.Trader", "CoS_Main", "1ee2031f-d46b-447e-a813-252d87a2ae29")
	Osi.LeaderLib_Trader_Register_Seat("LLWEAPONEX.WeaponMaster.Trader", "Arx_Main", "ef9141f1-531c-831f-2e8c-2e1174ff44a1")

	Osi.LeaderLib_Trader_Register_Position("LLWEAPONEX.WeaponMaster.Trader", "FJ_FortJoy_Main", 208.437, -6.144, 155.0)
	Osi.LeaderLib_Trader_Register_Position("LLWEAPONEX.WeaponMaster.Trader", "LV_HoE_Main", 29.807, 11.044, 3.221)
	Osi.LeaderLib_Trader_Register_Position("LLWEAPONEX.WeaponMaster.Trader", "RC_Main", 353.891, 0.378, 94.752)
	Osi.LeaderLib_Trader_Register_Position("LLWEAPONEX.WeaponMaster.Trader", "CoS_Main", -4.062, 14.418, 706.99)
	Osi.LeaderLib_Trader_Register_Position("LLWEAPONEX.WeaponMaster.Trader", "Arx_Main", 366.42, 16.621, 59.39)

	Osi.CharacterSetImmortal(NPC.WeaponMaster, 1)
end

Events.Osiris.CharacterAttitudeTowardsPlayerChanged:Subscribe(function (e)
	if e.Attitude <= -10 then
		if Osi.ObjectGetFlag(e.CharacterGUID, "LLWEAPONEX_WeaponMaster_AutoSaveBeforeWipe") == 0 then
			Osi.ObjectSetFlag(e.CharacterGUID, "LLWEAPONEX_WeaponMaster_AutoSaveBeforeWipe", 0)
			Osi.AutoSave()
		end
	elseif e.Attitude > 0 then
		Osi.ObjectClearFlag(e.CharacterGUID, "LLWEAPONEX_WeaponMaster_AutoSaveBeforeWipe", 0)
	end
end, {MatchArgs={CharacterGUID=NPC.WeaponMaster}})

Events.Osiris.ObjectEnteredCombat:Subscribe(function (e)
	Timer.StartObjectTimer("LLWEAPONEX_OmaeWaMouShindeiru_CheckForPlayers", e.Object, 50)
	Osi.JumpToTurn(e.ObjectGUID)
end, {MatchArgs={ObjectGUID=NPC.WeaponMaster}})

Timer.Subscribe("LLWEAPONEX_OmaeWaMouShindeiru_CheckForPlayers", function (e)
	local wm = e.Data.Object
	if wm then
		local id = GameHelpers.Combat.GetID(wm)
		if id > -1 then
			local players = GameHelpers.Combat.GetCharacters(id, "Player", wm, true)
			if #players > 0 then
				Osi.Proc_StartDialog(1, "AD_LLWEAPONEX_WeaponMaster_OmaeWaMouShindeiru_Start", wm.MyGuid)
				Osi.CharacterSetFightMode(wm.MyGuid, 1, 0)
				Timer.StartObjectTimer("LLWEAPONEX_OmaeWaMouShindeiru_Cast", wm, 250)
			end
		end
	end
end)

Timer.Subscribe("LLWEAPONEX_OmaeWaMouShindeiru_Cast", function (e)
	local wm = e.Data.Object
	if wm then
		local x,y,z = table.unpack(wm.WorldPos)
		Osi.SetVarFloat3(wm.MyGuid, "LLWEAPONEX_WM_StartingPosition", x, y, z)
		GameHelpers.Action.UseSkill(wm, "Shout_LLWEAPONEX_WeaponMaster_OmaeWaMouShindeiru", wm)
	end
end)

function WeaponMaster.KillNext()
	local wm = GameHelpers.GetCharacter(NPC.WeaponMaster)
	if wm and not GameHelpers.ObjectIsDead(wm) then
		local target = Common.PopRandomTableEntry(PersistentVars.SkillData.WeaponMasterTargets)
		if target then
			Osi.Proc_StartDialog(1, "AD_LLWEAPONEX_Player_OmaeWaMouShindeiru_Hit", target)
			EffectManager.PlayEffect("LLWEAPONEX_FX_Skills_InstantTransmission_Dissolve_Body_01", wm)
			EffectManager.PlayEffectAt("LLWEAPONEX_FX_Skills_InstantTransmission_Disappear_01", wm.WorldPos)
			Osi.LeaderLib_Behavior_TeleportTo(NPC.WeaponMaster, target)
			Timer.StartObjectTimer("LLWEAPONEX_OmaeWaMouShindeiru_OneShot", wm, 50, {Target=target})
		else
			PersistentVars.SkillData.WeaponMasterTargets = {}
			local x,y,z = Osi.GetVarFloat3(NPC.WeaponMaster, "LLWEAPONEX_WM_StartingPosition")
			if x then
				EffectManager.PlayEffect("LLWEAPONEX_FX_Skills_InstantTransmission_Appear_01", wm)
				Osi.TeleportToPosition(NPC.WeaponMaster, x, y, z, "LLWEAPONEX_OmaeWaMouShindeiru_Done", 0, 0)
				Timer.StartOneshot("", 100, function (_)
					GameHelpers.ClearActionQueue(NPC.WeaponMaster, true)
					Osi.Proc_StartDialog(1, "AD_LLWEAPONEX_WeaponMaster_OmaeWaMouShindeiru_End", NPC.WeaponMaster)
					Osi.CharacterSetFightMode(NPC.WeaponMaster, 0, 0)
					GameHelpers.Action.PlayAnimation(NPC.WeaponMaster, "Dust_Off_01")
				end)
			end
		end
	end
end

SkillManager.Subscribe.Cast("Shout_LLWEAPONEX_WeaponMaster_OmaeWaMouShindeiru", function (e)
	e.Data:ForEachTarget(function (self, target, isPosition)
		if target.MyGuid ~= NPC.WeaponMaster then
			table.insert(PersistentVars.SkillData.WeaponMasterTargets, target.MyGuid)
		end
	end)
	if #PersistentVars.SkillData.WeaponMasterTargets > 0 then
		WeaponMaster.KillNext()
	end
end)

Timer.Subscribe("LLWEAPONEX_OmaeWaMouShindeiru_OneShot", function (e)
	local wm = e.Data.Object
	local target = e.Data.Target
	if wm and target then
		EffectManager.PlayEffect("LLWEAPONEX_FX_Skills_InstantTransmission_Appear_01", wm)
		GameHelpers.ClearActionQueue(wm, true)
		GameHelpers.Action.PlayAnimation(wm, "skill_attack_round_01_cast", {NoBlend=true})
		GameHelpers.Status.Apply(target, "LLWEAPONEX_WEAPONMASTER_OMAEWAMOUSHINDEIRU", 0, true, wm)
		Timer.StartObjectTimer("LLWEAPONEX_OmaeWaMouShindeiru_KillNext", wm, 250)
	end
end)

Timer.Subscribe("LLWEAPONEX_OmaeWaMouShindeiru_KillNext", function (e)
	WeaponMaster.KillNext()
end)