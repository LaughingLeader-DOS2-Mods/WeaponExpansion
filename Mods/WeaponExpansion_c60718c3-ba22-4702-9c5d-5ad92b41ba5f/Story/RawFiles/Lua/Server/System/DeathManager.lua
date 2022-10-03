DeathManager = {
	Listeners = {}
}

---@param id string The ID for the death event, specified in ListenForDeath.
---@param callback fun(target:string, attacker:string, success:boolean):void
function DeathManager.RegisterListener(id, callback)
	if DeathManager.Listeners[id] == nil then
		DeathManager.Listeners[id] = {}
	end
	table.insert(DeathManager.Listeners[id], callback)
end

local function FireCallbacks(id, target, attacker, success)
	local callbacks = DeathManager.Listeners[id]
	if callbacks ~= nil then
		for i=1,#callbacks do
			local callback = callbacks[i]
			if callback ~= nil then
				local b,result = xpcall(callback, debug.traceback, target, attacker, success)
				if not b then
					Ext.Utils.PrintError("[LLWEAPONEX:DeathManager] Error invoking callback:")
					Ext.Utils.PrintError(result)
				end
			else
				Ext.Utils.PrintError("FireCallbacks", i, id, target, attacker, success)
			end
		end
	end
end

function DeathManager.RemoveAllDataForTarget(target)
	local targetGUID = GameHelpers.GetUUID(target)
	if targetGUID then
		PersistentVars.OnDeath[targetGUID] = nil
	end
end

---@param id string
---@param target CharacterParam
---@param attacker CharacterParam
---@param listenDelay integer
function DeathManager.ListenForDeath(id, target, attacker, listenDelay)
	local targetGUID = GameHelpers.GetUUID(target)
	local attackerGUID = GameHelpers.GetUUID(attacker)

	if ObjectIsCharacter(targetGUID) == 0 then
		return
	end

	if CharacterIsDead(targetGUID) == 1 then
		--Skip waiting
		FireCallbacks(id, targetGUID, attackerGUID, true)
		return
	end

	if PersistentVars.OnDeath[targetGUID] == nil then
		PersistentVars.OnDeath[targetGUID] = {
			Total = 0,
			Attackers = {}
		}
	end
	local data = PersistentVars.OnDeath[targetGUID]
	if listenDelay > 0 then
		Timer.StartUniqueTimer("LLWEAPONEX_DeathManager_ClearListener", string.format("%s%s", targetGUID, attackerGUID), listenDelay,
		{ID=id, Target=targetGUID, Attacker=attackerGUID})
	end
	if data.Attackers[attackerGUID] == nil then
		data.Attackers[attackerGUID] = {}
	end
	if data.Attackers[attackerGUID][id] == nil or data.Total == 0 then
		data.Total = data.Total + 1
	end
	data.Attackers[attackerGUID][id] = true
	if Vars.DebugMode and IsTagged(targetGUID, "LLDUMMY_TrainingDummy") == 1 then
		if listenDelay > 0 then
			local tDebugName = string.format("Timers_LLWEAPONEX_Debug_FakeDeathEvent_%s_%s", id, Ext.Random(0,999))
			Timer.StartOneshot(tDebugName, listenDelay/2, function()
				fprint(LOGLEVEL.TRACE, "[LLWEAPONEX:DeathMechanics:OnDeath] Target Dummy death simulation firing for timer %s", tDebugName)
				DeathManager.OnDeath(targetGUID)
			end)
		else
			fprint(LOGLEVEL.TRACE, "[LLWEAPONEX:DeathMechanics:OnDeath] Target Dummy death simulation firing.")
			DeathManager.OnDeath(targetGUID)
		end
	end
end

Timer.Subscribe("LLWEAPONEX_DeathManager_ClearListener", function (e)
	if e.Data.Target then
		FireCallbacks(e.Data.ID, e.Data.Target, e.Data.Attacker, false)
		PersistentVars.OnDeath[e.Data.Target] = nil
	end
end)

function DeathManager.OnDeath(uuid)
	local data = PersistentVars.OnDeath[uuid]
	if data ~= nil then
		--fprint(LOGLEVEL.TRACE, "[LLWEAPONEX:DeathMechanics:OnDeath] %s died. Firing callbacks.", uuid)
		for attacker,attackerData in pairs(data.Attackers) do
			for id,b in pairs(attackerData) do
				FireCallbacks(id, uuid, attacker, true)
			end
		end
		PersistentVars.OnDeath[uuid] = nil
	end
end

RegisterProtectedOsirisListener("CharacterDying", 1, "after", function(char)
	DeathManager.OnDeath(StringHelpers.GetUUID(char))
end)

RegisterListener("Initialized", function(region)
	for uuid,data in pairs(PersistentVars.OnDeath) do
		if ObjectExists(uuid) == 0 then
			PersistentVars.OnDeath[uuid] = nil
		else
			local total = 0
			for attacker,attackerData in pairs(data.Attackers) do
				if ObjectExists(attacker) == 0 then
					data.Attackers[attacker] = nil
				else
					total = total + 1
				end
			end
			if total == 0 then
				PersistentVars.OnDeath[uuid] = nil
			else
				data.Total = total
			end
		end
	end
end)