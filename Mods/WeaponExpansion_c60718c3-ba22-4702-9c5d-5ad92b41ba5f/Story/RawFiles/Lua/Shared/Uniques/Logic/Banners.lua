if not Vars.IsClient then
	EquipmentManager.Events.EquipmentChanged:Subscribe(function (e)
		GameHelpers.Status.Remove(e.Character, "LLWEAPONEX_BANNER_RALLY_DIVINEORDER")
	end, {MatchArgs={Tag="LLWEAPONEX_Banner_DivineOrder_Equipped", Equipped=false}})

	EquipmentManager.Events.EquipmentChanged:Subscribe(function (e)
		GameHelpers.Status.Remove(e.Character, "LLWEAPONEX_BANNER_RALLY_DWARVES")
	end, {MatchArgs={Tag="LLWEAPONEX_Banner_LoneWolves_Equipped", Equipped=false}})
end