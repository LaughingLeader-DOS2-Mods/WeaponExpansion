local _ISCLIENT = Ext.IsClient()

---@type table<string,LuaTest>
local _Tests = {}
MasteryTesting = {}

---@alias MasteryTestingTaskCallback fun(test:LuaTest, bonus:MasteryBonusData)

---@param bonusId string
---@param operation MasteryTestingTaskCallback|MasteryTestingTaskCallback[]
---@param params LuaTestParams
function MasteryTesting.RegisterTest(bonusId, operation, params)
	if _Tests[bonusId] == nil then
		_Tests[bonusId] = {}
	end
	Ext.PrintError("MasteryTesting.RegisterTest", bonusId, operation)
	local test = nil
	if type(operation) == "table" then
		test = Classes.LuaTest.Create(bonusId, operation, params)
	else
		test = Classes.LuaTest.Create(bonusId, {operation}, params)
	end
	table.insert(_Tests[bonusId], test)
end

function SignalTestComplete(id)
	Testing.EmitSignal(id)
end

local toggledTest = false

local function SetMasteryTests(cmd, enabledArg)
	if not _ISCLIENT or Client.IsHost then
		local enabled = Debug.MasteryTests
		if enabledArg == "true" or enabledArg == "1" or enabledArg == true then
			enabled = true
		elseif enabledArg == "false" or enabledArg == "0" or enabledArg == false then
			enabled = false
		else
			enabled = not enabled
		end
		if Debug.MasteryTests ~= enabled then
			Debug.MasteryTests = enabled
			fprint(LOGLEVEL.DEFAULT, "[weaponex_debugtesting] Testing is now (%s)", enabled and "enabled" or "disabled")
			if _ISCLIENT then
				Ext.PostMessageToServer("LLWEAPONEX_SetMasteryTests", "true")
			else
				GameHelpers.Net.Broadcast("LLWEAPONEX_SetMasteryTests", "true")
			end
		end
	else
		Ext.PrintError("[weaponex_debugtesting] Only the host can enable testing.")
	end
end

Ext.RegisterConsoleCommand("weaponex_debugtesting", function (...)
	SetMasteryTests(...)
	toggledTest = true
end)

Ext.RegisterNetListener("LLWEAPONEX_SetMasteryTests", function (cmd, payload)
	Debug.MasteryTests = payload == "true"
end)

Events.BeforeLuaReset:Subscribe(function (e)
	if Debug.MasteryTests then
		GameHelpers.IO.SaveFile("Debug/MasteryTestsEnabled.txt", "true")
	elseif toggledTest then
		GameHelpers.IO.SaveFile("Debug/MasteryTestsEnabled.txt", "false")
	end
end)

Events.LuaReset:Subscribe(function (e)
	if not _ISCLIENT then
		Timer.StartOneshot("LLWEAPONEX_SetMasteryTests", 250, function ()
			if not Debug.MasteryTests then
				local f = GameHelpers.IO.LoadFile("Debug/MasteryTestsEnabled.txt")
				if f then
					SetMasteryTests("", f)
				end
			end
		end)
	end
end)

Ext.RegisterConsoleCommand("test", function (cmd, id, subid)
	if id == "bonus" then
		local test = _Tests[subid]
		if test then
			SetMasteryTests("", "true")
			fprint(LOGLEVEL.DEFAULT, "[test] Running test (%s)", subid)
			Testing.RunTests(test, subid)
		else
			fprint(LOGLEVEL.WARNING, "[test] No test for ID (%s)", subid)
		end
	elseif id == "mastery" then
		local mastery = Masteries[subid]
		if mastery then
			local tests = {}
			for _,v in pairs(mastery.RankBonuses) do
				for _,v2 in ipairs(v.Bonuses) do
					if _Tests[v2.ID] then
						if _Tests[v2.ID].Type == "LuaTest" then
							tests[#tests+1] = _Tests[v2.ID]
						else
							for _,v3 in ipairs(_Tests[v2.ID]) do
								tests[#tests+1] = v3
							end
						end
					end
				end
			end
			if #tests > 0 then
				SetMasteryTests("", "true")
				fprint(LOGLEVEL.DEFAULT, "[test] Running tests for mastery (%s)", subid)
				Testing.RunTests(tests, subid)
			else
				fprint(LOGLEVEL.WARNING, "[test] No registered tests for mastery (%s)", subid)
			end
		else
			fprint(LOGLEVEL.ERROR, "[test] No mastery with ID (%s)", subid)
		end
	else
		fprint(LOGLEVEL.WARNING, "[test] No tests for type (%s)", id)
	end
end)

if not _ISCLIENT then
	---@param pos number[]|nil
	---@param equipmentSet string|nil
	---@return EsvCharacter
	function MasteryTesting.CreateTemporaryCharacter(pos, equipmentSet)
		local host = Ext.GetCharacter(CharacterGetHostCharacter())
		local pos = pos or GameHelpers.Math.ExtendPositionWithForwardDirection(host, 10)
		local character = TemporaryCharacterCreateAtPosition(pos[1], pos[2], pos[3], host.RootTemplate.Id, 0)
		CharacterTransformFromCharacter(character, host.MyGuid, 1, 1, 1, 1, 1, 1, 1)
		if equipmentSet then
			CharacterTransformAppearanceToWithEquipmentSet(character, host.MyGuid, equipmentSet, false)
		end
		SetTag(character, "LeaderLib_TemporaryCharacter")
		return Ext.GetCharacter(character)
	end

	local function SetupCharacter(character, transformTarget, equipmentSet)
		if equipmentSet then
			CharacterTransformAppearanceToWithEquipmentSet(character, transformTarget, equipmentSet, false)
		else
			CharacterTransformAppearanceTo(character, transformTarget, 1, 1)
		end
		SetStoryEvent(character, "ClearPeaceReturn")
		CharacterSetReactionPriority(character, "StateManager", 0)
		CharacterSetReactionPriority(character, "ResetInternalState", 0)
		CharacterSetReactionPriority(character, "ReturnToPeacePosition", 0)
		CharacterSetReactionPriority(character, "CowerIfNeutralSeeCombat", 0)
		SetTag(character, "LeaderLib_TemporaryCharacter")
		SetTag(character, "LLWEAPONEX_MasteryTestCharacter")
	end

	---@param test LuaTest
	---@param pos number[]|nil
	---@param equipmentSet string|nil
	---@param targetTemplate string|nil
	---@return UUID character
	---@return UUID dummy
	function MasteryTesting.CreateTemporaryCharacterAndDummy(test, pos, equipmentSet, targetTemplate, setEnemy)
		local host = Ext.GetCharacter(CharacterGetHostCharacter())
		local pos = pos or {GameHelpers.Grid.GetValidPositionInRadius(GameHelpers.Math.ExtendPositionWithForwardDirection(host, 6), 6.0)}
		local pos2 = {GameHelpers.Grid.GetValidPositionInRadius(pos, 6.0)}
		local character = TemporaryCharacterCreateAtPosition(pos[1], pos[2], pos[3], "13ee7ec6-70c3-4f2c-9145-9a5e85feb7d3", 0)

		--CharacterTransformFromCharacter(character, host.MyGuid, 0, 1, 1, 1, 1, 1, 1)
		SetupCharacter(character, host.MyGuid, equipmentSet)

		local dummy = TemporaryCharacterCreateAtPosition(pos2[1], pos2[2], pos2[3], targetTemplate or "985acfab-b221-4221-8263-fa00797e8883", 0)

		PlayEffect(dummy, "RS3_FX_GP_ScriptedEvent_Teleport_GenericSmoke_01")
		SetTag(dummy, "LeaderLib_TemporaryCharacter")
		SetVarObject(dummy, "LLDUMMY_Owner", character)
		Osi.LLDUMMY_LevelUpTrainingDummy(dummy)
		if setEnemy then
			--CharacterSetTemporaryHostileRelation(dummy, character)
			SetFaction(dummy, "Evil NPC")
		end

		local cleanup = function ()
			if ObjectExists(character) == 1 then
				RemoveTemporaryCharacter(character)
			end
			if ObjectExists(dummy) == 1 then
				SetStoryEvent(dummy, "LLDUMMY_TrainingDummy_DieNow")
			end
		end
		Timer.StartOneshot("", 30000, cleanup)
		return character,dummy,cleanup
	end

	---@param test LuaTest
	---@param pos number[]|nil
	---@param equipmentSet string|nil
	---@param targetTemplate string|nil
	---@return UUID character1
	---@return UUID character2
	---@return UUID dummy
	function MasteryTesting.CreateTwoTemporaryCharactersAndDummy(test, pos, equipmentSet, targetTemplate, setEnemy)
		local host = Ext.GetCharacter(CharacterGetHostCharacter())
		local pos = pos or {GameHelpers.Grid.GetValidPositionInRadius(GameHelpers.Math.ExtendPositionWithForwardDirection(host, 6), 6.0)}
		local pos2 = {GameHelpers.Grid.GetValidPositionInRadius(GameHelpers.Math.ExtendPositionWithForwardDirection(host, 6), 7.0)}
		local pos3 = {GameHelpers.Grid.GetValidPositionInRadius(pos, 6.0)}
		local character = TemporaryCharacterCreateAtPosition(pos[1], pos[2], pos[3], "13ee7ec6-70c3-4f2c-9145-9a5e85feb7d3", 0)
		local character2 = TemporaryCharacterCreateAtPosition(pos2[1], pos2[2], pos2[3], "13ee7ec6-70c3-4f2c-9145-9a5e85feb7d3", 0)

		--CharacterTransformFromCharacter(character, host.MyGuid, 0, 1, 1, 1, 1, 1, 1)
		SetupCharacter(character, host.MyGuid, equipmentSet)
		SetupCharacter(character2, host.MyGuid, equipmentSet)

		local dummy = TemporaryCharacterCreateAtPosition(pos3[1], pos3[2], pos3[3], targetTemplate or "985acfab-b221-4221-8263-fa00797e8883", 0)

		PlayEffect(dummy, "RS3_FX_GP_ScriptedEvent_Teleport_GenericSmoke_01")
		SetTag(dummy, "LeaderLib_TemporaryCharacter")
		SetVarObject(dummy, "LLDUMMY_Owner", character)
		Osi.LLDUMMY_LevelUpTrainingDummy(dummy)
		if setEnemy then
			-- CharacterSetTemporaryHostileRelation(dummy, character)
			-- CharacterSetTemporaryHostileRelation(dummy, character2)
			SetFaction(dummy, "Evil NPC")
		end

		local cleanup = function ()
			if ObjectExists(character) == 1 then
				RemoveTemporaryCharacter(character)
			end
			if ObjectExists(character2) == 1 then
				RemoveTemporaryCharacter(character2)
			end
			if ObjectExists(dummy) == 1 then
				SetStoryEvent(dummy, "LLDUMMY_TrainingDummy_DieNow")
			end
		end
		Timer.StartOneshot("", 60000, cleanup)
		return character,character2,dummy,cleanup
	end
end