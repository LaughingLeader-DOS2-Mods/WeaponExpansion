local SurfaceToStatus = {
	Blood = "LLWEAPONEX_ACTIVATE_RUNEBLADE_BLOOD",
	Deathfog = "LLWEAPONEX_ACTIVATE_RUNEBLADE_DEATH",
	Electrified = "LLWEAPONEX_ACTIVATE_RUNEBLADE_AIR",
	Explosion = "LLWEAPONEX_ACTIVATE_RUNEBLADE_EXPLOSIVE",
	Sulfur = "LLWEAPONEX_ACTIVATE_RUNEBLADE_EXPLOSIVE",
	Fire = "LLWEAPONEX_ACTIVATE_RUNEBLADE_FIRE",
	Frozen = "LLWEAPONEX_ACTIVATE_RUNEBLADE_ICE",
	Lava = "LLWEAPONEX_ACTIVATE_RUNEBLADE_LAVA",
	Oil = "LLWEAPONEX_ACTIVATE_RUNEBLADE_EARTH",
	Poison = "LLWEAPONEX_ACTIVATE_RUNEBLADE_POISON",
	Smoke = "LLWEAPONEX_ACTIVATE_RUNEBLADE_DUST",
	Water = "LLWEAPONEX_ACTIVATE_RUNEBLADE_WATER",
}

local PreserveSurface = {
	Lava = true,
	Deathfog = true,
}

---@param caster EsvCharacter
---@param position number[]
---@param radius number
---@param duration number
function RunebladeManager.AbsorbSurface(caster, position, radius, duration)
	local x,y,z = table.unpack(position)
	local grid = Ext.GetAiGrid()
	---@type LeaderLibSurfaceRadiusData
	local data = GameHelpers.Grid.GetSurfaces(x, z, grid, radius, 9)
	local applyStatuses = {}
	local absorbedSurface = false
	for name,status in pairs(SurfaceToStatus) do
		if data:HasSurface(name, true) then
			applyStatuses[status] = true
			absorbedSurface = true
		end
	end
	for status,b in pairs(applyStatuses) do
		GameHelpers.Status.Apply(caster, status, duration, 0, caster)
	end
	if absorbedSurface then
		PlayEffect(caster.MyGuid, "LLWEAPONEX_FX_Rune_Chaos_01", "Dummy_OverheadFX")
		--Skip replacing surfaces if it's lava or deathfog
		if not data:HasSurface("Lava", true, 0) and not data:HasSurface("Deathfog", true, 1) then
			GameHelpers.Surface.CreateSurface(position, "None", radius, 0.0, caster.Handle, true)
		end
	else
		CharacterStatusText(caster.MyGuid, "LLWEAPONEX_NoElementFoundForChaosRune")
	end
end