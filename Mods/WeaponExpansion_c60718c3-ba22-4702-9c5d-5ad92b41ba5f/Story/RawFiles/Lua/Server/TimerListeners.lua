if Vars.DebugMode then
	Timer.RegisterListener("LLWEAPONEX_Debug_Explode", function(timerName)
		local x,y,z = GetPosition(CharacterGetHostCharacter())
		CreateExplosionAtPosition(x,y,z, "Projectile_TrapChainLightning", 1)
	end)
end