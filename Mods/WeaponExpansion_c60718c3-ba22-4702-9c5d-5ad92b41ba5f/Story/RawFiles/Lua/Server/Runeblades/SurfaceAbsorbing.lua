local SurfaceToStatus = {
	Fire = "LLWEAPONEX_ACTIVATE_RUNEBLADE_FIRE",
	Frozen = "LLWEAPONEX_ACTIVATE_RUNEBLADE_ICE",
	Water = "LLWEAPONEX_ACTIVATE_RUNEBLADE_WATER",
	Electrified = "LLWEAPONEX_ACTIVATE_RUNEBLADE_AIR",
	Oil = "LLWEAPONEX_ACTIVATE_RUNEBLADE_EARTH",
	Poison = "LLWEAPONEX_ACTIVATE_RUNEBLADE_POISON",
	Blood = "LLWEAPONEX_ACTIVATE_RUNEBLADE_BLOOD",
	Explosion = "LLWEAPONEX_ACTIVATE_RUNEBLADE_EXPLOSIVE",
	Smoke = "LLWEAPONEX_ACTIVATE_RUNEBLADE_DUST",
	Lava = "LLWEAPONEX_ACTIVATE_RUNEBLADE_LAVA",
	Deathfog = "LLWEAPONEX_ACTIVATE_RUNEBLADE_DEATH",
}

local PreserveSurface = {
	Lava = true,
	Deathfog = true,
}

function RunebladeManager.AbsorbSurface(caster, position)
	local x,y,z = table.unpack(position)
	local grid = Ext.GetAiGrid()
	local surfaces = GameHelpers.Grid.GetSurfaces(x, z, grid, 3.0, 9)
end