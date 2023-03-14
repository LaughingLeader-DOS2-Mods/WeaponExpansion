local overrides = {
	-- Skills
	Target_SingleHandedAttack = {
		IgnoreSilence = "Yes",
		UseWeaponDamage = "Yes",
	},
	Target_TentacleLash = {
		UseWeaponDamage = "Yes",
		["Damage Multiplier"] = 90
	},
	Target_CorrosiveTouch = {
		Description = "LLWEAPONEX_Target_CorrosiveTouch_Description",
	},
	Cone_CorrosiveSpray = {
		Description = "LLWEAPONEX_Cone_CorrosiveSpray_Description",
	},
	Projectile_SilverArrow = {
		Description = "LLWEAPONEX_Projectile_SilverArrow_Description",
	},
	Target_DemonicStare = {
		Description = "LLWEAPONEX_Target_DemonicStare_Description",
	},
	-- Weapons
	NoWeapon = {
		ExtraProperties = {{
			Type = "Status",
			Action = "LLWEAPONEX_UNARMED_NOWEAPON_HIT",
			Context = {"AoE", "Target"},
			Duration = 0.0,
			StatusChance = 1.0,
			StatsId = "",
			Arg4 = -1,
			Arg5 = -1,
			SurfaceBoost = false
		}}
	},
}

return overrides