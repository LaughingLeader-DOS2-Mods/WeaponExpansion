if not Vars.IsClient then
	StatusManager.Subscribe.Applied("LLWEAPONEX_BASILUS_HIT", function(e)
		local minTurns = GameHelpers.GetExtraData("LLWEAPONEX_BasilusDagger_MinTurns", 2, true)
		local maxTurns = GameHelpers.GetExtraData("LLWEAPONEX_BasilusDagger_MaxTurns", 3, true)
		local duration = Ext.Utils.Random(minTurns,maxTurns) * 6.0
		if not GameHelpers.Status.IsActive(e.Target, "LLWEAPONEX_BASILUS_HAUNTED") then
			GameHelpers.Status.Apply(e.Target, "LLWEAPONEX_BASILUS_HAUNTED", duration, false, e.Source)
		else
			local hauntedStatus = e.Target:GetStatus("LLWEAPONEX_BASILUS_HAUNTED")
			if hauntedStatus then
				if hauntedStatus.CurrentLifeTime < duration then
					hauntedStatus.CurrentLifeTime = duration
					hauntedStatus.RequestClientSync = true
				end
			end
		end
	end)

	---@param attacker EsvCharacter
	local function Basilus_OnTargetActionTaken(attacker)
		if not attacker then
			return
		end
		PersistentVars.BasilusHauntedTarget[attacker.MyGuid] = 0
		local hauntedStatus = attacker:GetStatus("LLWEAPONEX_BASILUS_HAUNTED")
		if hauntedStatus and GameHelpers.IsValidHandle(hauntedStatus.StatusSourceHandle) then
			local source = GameHelpers.TryGetObject(hauntedStatus.StatusSourceHandle, "EsvCharacter")
			if source then
				local backstab = false
				local chance = math.ceil(GameHelpers.GetExtraData("LLWEAPONEX_BasilusDagger_BackstabChance", 40))
				if chance >= 100 or (chance > 0 and GameHelpers.Math.Roll(chance)) then
					backstab = true
				end
				local text = Text.CombatLog.BasilusDaggerHauntedDamage:ReplacePlaceholders(GameHelpers.GetDisplayName(attacker), GameHelpers.GetDisplayName(source))
				CombatLog.AddCombatText(text)
				if backstab then
					CharacterStatusText(attacker.MyGuid, "LLWEAPONEX_StatusText_BasilusHauntedDamage_Backstab")
				else
					CharacterStatusText(attacker.MyGuid, "LLWEAPONEX_StatusText_BasilusHauntedDamage_Normal")
				end
				GameHelpers.Damage.ApplySkillDamage(source, attacker, "Projectile_LLWEAPONEX_BasilusDagger_HauntedDamage", {
					HitParams=HitFlagPresets.GuaranteedWeaponHit:Append({Backstab = backstab}),
					GetDamageFunction=Skills.Damage.Projectile_LLWEAPONEX_BasilusDagger_HauntedDamage
				})
				local pos = {table.unpack(attacker.WorldPos)}
				pos[2] = pos[2] + attacker.AI.AIBoundsHeight * 0.5
				EffectManager.PlayEffectAt("RS3_FX_GP_Impacts_Ghost_01", pos, {Rotation=attacker.Rotation})
				SignalTestComplete("LLWEAPONEX_BladeOfBasilus_DamageApplied")
			end
		end
	end

	local _registeredListeners = false

	local function _RegisterOsirisListeners()
		if not _registeredListeners then
			Ext.Osiris.RegisterListener("CharacterStartAttackObject", 3, "before", function (target, owner, attacker)
				if PersistentVars.BasilusHauntedTarget[StringHelpers.GetUUID(attacker)] == 1 then
					Basilus_OnTargetActionTaken(GameHelpers.TryGetObject(attacker, "EsvCharacter"))
				end
			end)
		
			Ext.Osiris.RegisterListener("CharacterUsedSkill", 4, "before", function (attacker)
				---@cast attacker GUID
				if PersistentVars.BasilusHauntedTarget[StringHelpers.GetUUID(attacker)] == 1 then
					Basilus_OnTargetActionTaken(GameHelpers.TryGetObject(attacker, "EsvCharacter"))
				end
			end)

			_registeredListeners = true
		end
	end

	StatusManager.Subscribe.Applied("LLWEAPONEX_BASILUS_TURN_TICK", function (e)
		PersistentVars.BasilusHauntedTarget[e.TargetGUID] = 1
		_RegisterOsirisListeners()
	end)

	StatusManager.Subscribe.Removed("LLWEAPONEX_BASILUS_HAUNTED", function (e)
		PersistentVars.BasilusHauntedTarget[e.TargetGUID] = nil
	end)

	Events.PersistentVarsLoaded:Subscribe(function (e)
		if Common.TableHasAnyEntry(PersistentVars.BasilusHauntedTarget) then
			_RegisterOsirisListeners()
		end
	end, {Priority=0})

	WeaponExTesting.RegisterUniqueTest("basilus", function (test)
		local characters,dummy,cleanup = Testing.Utils.CreateTestCharacters({EquipmentSet="Class_Rogue_Act2", TotalCharacters=2, TotalDummies=1})
		local char1 = characters[1]
		local char2 = characters[2]
		---@cast dummy string
		test.Cleanup = function (...)
			PersistentVars.StatusData.BasilusHauntedTarget[char2] = nil
			cleanup(...)
		end
		test:Wait(250)
		local weapon = GameHelpers.Item.CreateItemByStat("WPN_UNIQUE_LLWEAPONEX_Dagger_Basilus_A") --[[@as GUID]]
		test:Wait(250)
		SetTag(weapon, "LLWEAPONEX_Testing")
		NRD_CharacterEquipItem(char1, weapon, "Weapon", 0, 0, 1, 1)
		TeleportTo(char1, dummy, "", 0, 1, 1)
		test:Wait(250)
		TeleportTo(char2, dummy, "", 0, 1, 1)
		SetFaction(char1, "PVP_1")
		SetFaction(dummy, "PVP_1")
		SetFaction(char2, "PVP_2")
		test:Wait(250)
		CharacterSetTemporaryHostileRelation(char1, char2)
		CharacterSetTemporaryHostileRelation(dummy, char2)
		test:Wait(250)
		test:AssertEquals(GameHelpers.CharacterOrEquipmentHasTag(char1, "LLWEAPONEX_BasilusDagger_Equipped"), true, "Missing 'LLWEAPONEX_BasilusDagger_Equipped' tag on char1")
		test:AssertEquals(GameHelpers.Character.CanAttackTarget(char1, char2, false), true, "char2 is not an enemy of char1")
		test:Wait(250)
		CharacterAttack(char1, char2)
		test:Wait(500)
		test:AssertEquals(GameHelpers.Status.IsActive(char2, "LLWEAPONEX_BASILUS_HAUNTED"), true, "'LLWEAPONEX_BASILUS_HAUNTED' not applied to basic attack target.")
		GameHelpers.Status.ExtendTurns(char2, "LLWEAPONEX_BASILUS_HAUNTED", 10, true, false) -- Extend turns for testing
		test:Wait(6500) -- Wait for tick
		test:AssertEquals(PersistentVars.StatusData.BasilusHauntedTarget[char2], 1, "PersistentVars.StatusData.BasilusHauntedTarget[char2] does not equal 1.")
		CharacterAttack(char2, dummy)
		test:WaitForSignal("LLWEAPONEX_BladeOfBasilus_DamageApplied", 5000)
		test:AssertGotSignal("LLWEAPONEX_BladeOfBasilus_DamageApplied")
		test:Wait(6500) -- Wait for tick
		test:AssertEquals(PersistentVars.StatusData.BasilusHauntedTarget[char2], 1, "PersistentVars.StatusData.BasilusHauntedTarget[char2] does not equal 1.")
		CharacterUseSkill(char2, "Shout_InspireStart", char2, 1, 1, 1)
		test:WaitForSignal("LLWEAPONEX_BladeOfBasilus_DamageApplied", 5000)
		test:AssertGotSignal("LLWEAPONEX_BladeOfBasilus_DamageApplied")
		CharacterDieImmediate(char2, 0, "DoT", char2)
		test:AssertEquals(PersistentVars.StatusData.BasilusHauntedTarget[char2] == nil, true, "PersistentVars.StatusData.BasilusHauntedTarget[char2] was not cleared.")
		return true
	end)
end

--[[
//S_Ghost_LLWEAPONEX_Dagger_Basilus_A_e4fcee11-628c-42f2-9393-fb41d79a7ce5
IF
ItemDropped(S_WPN_UNIQUE_LLWEAPONEX_Dagger_Basilus_A_5b5c20e1-cef4-40a2-b367-a984c38c1f03)
THEN
LeaderLib_Timers_StartObjectTimer(S_WPN_UNIQUE_LLWEAPONEX_Dagger_Basilus_A_5b5c20e1-cef4-40a2-b367-a984c38c1f03, 500, "Timers_LLWEAPONEX_BasilusDagger_CheckCombat", "LLWEAPONEX_BasilusDagger_CheckCombat");

IF
StoryEvent((ITEMGUID)_Item, "LLWEAPONEX_BasilusDagger_CheckCombat")
AND
ItemIsInInventory(_Item, 0)
AND
//ItemGetOwner(S_WPN_UNIQUE_LLWEAPONEX_Dagger_Basilus_A_5b5c20e1-cef4-40a2-b367-a984c38c1f03, _Owner)
ItemGetOriginalOwner(S_WPN_UNIQUE_LLWEAPONEX_Dagger_Basilus_A_5b5c20e1-cef4-40a2-b367-a984c38c1f03, _Owner)
AND
CharacterIsInCombat(_Owner, 1)
AND
GetFaction(_Owner, _Faction)
AND
CharacterGetLevel(_Owner, _Level)
THEN
SetCanJoinCombat(S_Ghost_LLWEAPONEX_Dagger_Basilus_A_e4fcee11-628c-42f2-9393-fb41d79a7ce5, 0);
SetTag(S_Ghost_LLWEAPONEX_Dagger_Basilus_A_e4fcee11-628c-42f2-9393-fb41d79a7ce5, "AI_UNPREFERRED_TARGET");
//NRD_CharacterSetStatInt(S_Ghost_LLWEAPONEX_Dagger_Basilus_A_e4fcee11-628c-42f2-9393-fb41d79a7ce5, "Gain", 0);
CharacterAddAttitudeTowardsPlayer(S_Ghost_LLWEAPONEX_Dagger_Basilus_A_e4fcee11-628c-42f2-9393-fb41d79a7ce5, _Owner, 100);
CharacterAddAttitudeTowardsPlayer(_Owner, S_Ghost_LLWEAPONEX_Dagger_Basilus_A_e4fcee11-628c-42f2-9393-fb41d79a7ce5, 100);
SetFaction(S_Ghost_LLWEAPONEX_Dagger_Basilus_A_e4fcee11-628c-42f2-9393-fb41d79a7ce5, _Faction);
CharacterLevelUpTo(S_Ghost_LLWEAPONEX_Dagger_Basilus_A_e4fcee11-628c-42f2-9393-fb41d79a7ce5, _Level);
TeleportTo(S_Ghost_LLWEAPONEX_Dagger_Basilus_A_e4fcee11-628c-42f2-9393-fb41d79a7ce5, S_WPN_UNIQUE_LLWEAPONEX_Dagger_Basilus_A_5b5c20e1-cef4-40a2-b367-a984c38c1f03, "LLWEAPONEX_BasilusDagger_GhostEquip", 0, 1, 1);

IF
StoryEvent((CHARACTERGUID)_DaggerGhost, "LLWEAPONEX_BasilusDagger_GhostEquip")
THEN
Proc_CharacterFullRestore(_DaggerGhost);
SetOnStage(_DaggerGhost, 1);
CharacterEquipItem(_DaggerGhost, S_WPN_UNIQUE_LLWEAPONEX_Dagger_Basilus_A_5b5c20e1-cef4-40a2-b367-a984c38c1f03);
SetCanJoinCombat(_DaggerGhost, 1);

IF
ItemEquipped(S_WPN_UNIQUE_LLWEAPONEX_Dagger_Basilus_A_5b5c20e1-cef4-40a2-b367-a984c38c1f03, _Owner)
AND
_Owner != S_Ghost_LLWEAPONEX_Dagger_Basilus_A_e4fcee11-628c-42f2-9393-fb41d79a7ce5
THEN
ItemSetOriginalOwner(S_WPN_UNIQUE_LLWEAPONEX_Dagger_Basilus_A_5b5c20e1-cef4-40a2-b367-a984c38c1f03, _Owner);
SetOnStage(S_Ghost_LLWEAPONEX_Dagger_Basilus_A_e4fcee11-628c-42f2-9393-fb41d79a7ce5, 0);
LeaveCombat(S_Ghost_LLWEAPONEX_Dagger_Basilus_A_e4fcee11-628c-42f2-9393-fb41d79a7ce5);
//CharacterDieImmediate(S_Ghost_LLWEAPONEX_Dagger_Basilus_A_e4fcee11-628c-42f2-9393-fb41d79a7ce5, 0, "None", _Owner);

IF
CharacterDied(S_Ghost_LLWEAPONEX_Dagger_Basilus_A_e4fcee11-628c-42f2-9393-fb41d79a7ce5)
THEN
LLWEAPONEX_Basilus_DropDagger();

IF
ObjectLeftCombat(S_Ghost_LLWEAPONEX_Dagger_Basilus_A_e4fcee11-628c-42f2-9393-fb41d79a7ce5, _CombatID)
THEN
LLWEAPONEX_Basilus_DropDagger();

PROC
LLWEAPONEX_Basilus_DropDagger()
AND
GetPosition(S_Ghost_LLWEAPONEX_Dagger_Basilus_A_e4fcee11-628c-42f2-9393-fb41d79a7ce5, _x, _y, _z)
AND
GetRotation(S_Ghost_LLWEAPONEX_Dagger_Basilus_A_e4fcee11-628c-42f2-9393-fb41d79a7ce5, _rx, _ry, _rz)
AND
RealProduct(_rx, 0.0174533, _Pitch)
AND
RealProduct(_ry, 0.0174533, _Yaw)
AND
RealProduct(_rz, 0.0174533, _Roll)
AND
ItemGetOriginalOwner(S_WPN_UNIQUE_LLWEAPONEX_Dagger_Basilus_A_5b5c20e1-cef4-40a2-b367-a984c38c1f03, _Owner)
THEN
ItemToTransform(S_WPN_UNIQUE_LLWEAPONEX_Dagger_Basilus_A_5b5c20e1-cef4-40a2-b367-a984c38c1f03, _x, _y, _z, _Pitch, _Yaw, _Roll, 1, _Owner);

PROC
LLWEAPONEX_Basilus_DropDagger()
THEN
SetOnStage(S_Ghost_LLWEAPONEX_Dagger_Basilus_A_e4fcee11-628c-42f2-9393-fb41d79a7ce5, 0);
]]