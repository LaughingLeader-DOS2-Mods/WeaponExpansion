TimerFinished = {}

local function OnTimerFinished(event, ...)
	local callback = TimerFinished[event]
	if callback ~= nil then
		local status,err = xpcall(callback, debug.traceback, {...})
		if not status then
			Ext.PrintError("[LLWEAPONEX_TimerListener] Error invoking function:\n", err)
		end
	end
	if event == "LLWEAPONEX_Debug_Explode" then
		local x,y,z = GetPosition(CharacterGetHostCharacter())
		CreateExplosionAtPosition(x,y,z, "Projectile_TrapChainLightning", 1)
	end
end

LeaderLib.RegisterListener("TimerFinished", OnTimerFinished)