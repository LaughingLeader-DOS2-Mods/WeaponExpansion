if not Vars.IsClient then
	EquipmentManager.Events.UnsheathedChanged:Subscribe(function (e)
		if e.Unsheathed then
			EffectManager.PlayEffect("LLWEAPONEX_FX_Overlay_Weapon_DarkEnergy_01", e.Character, {Loop=true, Bone="Dummy_Root"})
		else
			EffectManager.StopEffectsByNameForObject("LLWEAPONEX_FX_Overlay_Weapon_DarkEnergy_01", e.Character)
		end
	end, {MatchArgs={Tag="LLWEAPONEX_BeholderSword_Equipped"}})
end