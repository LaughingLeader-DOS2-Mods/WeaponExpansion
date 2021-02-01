if PersistentVars.OnDeath == nil then
	PersistentVars.OnDeath = {}
end

DeathManager = {
	Listeners = {},
	ActiveTimers = 0
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

function DeathManager.ListenForDeath(id, target, attacker, listenDelay)
	if PersistentVars.OnDeath[target] == nil then
		PersistentVars.OnDeath[target] = {
			Total = 0,
			Attackers = {}
		}
	end
	local data = PersistentVars.OnDeath[target]
	local timerName = ""
	if listenDelay > 0 then
		timerName = string.format("Timers_LLWEAPONEX_ClearOnDeath_%s%s%s", id, target, attacker)
		TimerCancel(timerName)
		TimerLaunch(timerName, listenDelay)
	end
	if data.Attackers[attacker] == nil then
		data.Attackers[attacker] = {}
	end
	if data.Attackers[attacker][id] == nil or data.Total == 0 then
		data.Total = data.Total + 1
		if listenDelay > 0 then
			DeathManager.ActiveTimers = DeathManager.ActiveTimers + 1
		end
	end
	data.Attackers[attacker][id] = timerName
	if Vars.DebugMode and IsTagged(target, "LLDUMMY_TrainingDummy") == 1 then
		local tDebugName = string.format("Timers_LLWEAPONEX_Debug_FakeDeathEvent_%s_%s", id, Ext.Random(0,999))
		StartOneshotTimer(tDebugName, listenDelay/2, function()
			printd("[LLWEAPONEX:DeathMechanics:OnDeath] Target Dummy death simulation firing for timer", tDebugName)
			DeathManager.OnDeath(target)
		end)
	end
end

RegisterProtectedOsirisListener("TimerFinished", 1, "after", function(timerName)
	if DeathManager.ActiveTimers > 0 then
		for uuid,data in pairs(PersistentVars.OnDeath) do
			for attacker,attackerData in pairs(data.Attackers) do
				for id,tName in pairs(attackerData) do
					if tName ~= "" and tName == timerName then
						printd("[LLWEAPONEX:DeathMechanics:TimerFinished] OnDeath timer finished", timerName, id, uuid, attacker)
						FireCallbacks(id, uuid, attacker, false)
						data.Total = math.max(0, data.Total - 1)
						data.Attackers[attacker][id] = nil
						break
					end
				end
			end
			if data.Total <= 0 then
				PersistentVars.OnDeath[uuid] = nil
				printd("[LLWEAPONEX:DeathMechanics:TimerFinished] Cleared OnDeath listeners for", uuid)
			end
		end
	end
end)

LeaderLib.RegisterListener("Initialized", function(region)
	DeathManager.ActiveTimers = 0
	for uuid,data in pairs(PersistentVars.OnDeath) do
		local total = 0
		for attacker,attackerData in pairs(data.Attackers) do
			for id,timerName in pairs(attackerData) do
				total = total + 1
				if timerName ~= "" then
					data.Attackers[attacker][id] = nil
					total = math.max(0, total - 1)
				end
			end
		end
		data.Total = total
		if total == 0 then
			PersistentVars.OnDeath[uuid] = nil
		end
	end
end)

function DeathManager.OnDeath(uuid)
	local data = PersistentVars.OnDeath[uuid]
	if data ~= nil then
		printd("[LLWEAPONEX:DeathMechanics:OnDeath]", uuid, "died. Firing callbacks.")
		for attacker,attackerData in pairs(data.Attackers) do
			for id,tName in pairs(attackerData) do
				FireCallbacks(id, uuid, attacker, true)
				if tName ~= "" then
					TimerCancel(tName)
				end
			end
		end
		PersistentVars.OnDeath[uuid] = nil
	end
end

RegisterProtectedOsirisListener("CharacterDying", 1, "after", function(char)
	DeathManager.OnDeath(StringHelpers.GetUUID(char))
end)