WeaponExpansion.TimerFinished = {}

local function OnTimerFinished(event, ...)
	local callback = WeaponExpansion.TimerFinished[event]
	if callback ~= nil then
		local status,err = xpcall(callback, debug.traceback, {...})
		if not status then
			Ext.PrintError("[LLWEAPONEX_TimerListener] Error invoking function:\n", err)
		end
	end
end

LeaderLib.RegisterListener("TimerFinished", OnTimerFinished)