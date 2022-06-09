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
					Ext.PrintError("[LLWEAPONEX:DeathManager] Error invoking callback:")
					Ext.PrintError(result)
				end
			else
				Ext.PrintError("FireCallbacks", i, id, target, attacker, success)
			end
		end
	end
end

---@param id string
---@param target UUID|EsvCharacter|EsvItem
---@param attacker UUID|EsvCharacter|EsvItem
---@param listenDelay integer
function DeathManager.ListenForDeath(id, target, attacker, listenDelay)
	local target = GameHelpers.GetUUID(target)
	local attacker = GameHelpers.GetUUID(attacker)

	if ObjectIsCharacter(target) == 0 then
		return
	end

	if CharacterIsDead(target) == 1 then
		--Skip waiting
		FireCallbacks(id, target, attacker, true)
		return
	end

	if PersistentVars.OnDeath[target] == nil then
		PersistentVars.OnDeath[target] = {
			Total = 0,
			Attackers = {}
		}
	end
	local data = PersistentVars.OnDeath[target]
	if listenDelay > 0 then
		Timer.StartUniqueTimer("LLWEAPONEX_DeathManager_ClearListener", string.format("%s%s", target, attacker), listenDelay,
		{ID=id, Target=target, Attacker=attacker})
	end
	if data.Attackers[attacker] == nil then
		data.Attackers[attacker] = {}
	end
	if data.Attackers[attacker][id] == nil or data.Total == 0 then
		data.Total = data.Total + 1
	end
	data.Attackers[attacker][id] = true
	if Vars.DebugMode and IsTagged(target, "LLDUMMY_TrainingDummy") == 1 then
		if listenDelay > 0 then
			local tDebugName = string.format("Timers_LLWEAPONEX_Debug_FakeDeathEvent_%s_%s", id, Ext.Random(0,999))
			Timer.StartOneshot(tDebugName, listenDelay/2, function()
				fprint(LOGLEVEL.TRACE, "[LLWEAPONEX:DeathMechanics:OnDeath] Target Dummy death simulation firing for timer %s", tDebugName)
				DeathManager.OnDeath(target)
			end)
		else
			fprint(LOGLEVEL.TRACE, "[LLWEAPONEX:DeathMechanics:OnDeath] Target Dummy death simulation firing.")
			DeathManager.OnDeath(target)
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
		fprint(LOGLEVEL.TRACE, "[LLWEAPONEX:DeathMechanics:OnDeath] %s died. Firing callbacks.", uuid)
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