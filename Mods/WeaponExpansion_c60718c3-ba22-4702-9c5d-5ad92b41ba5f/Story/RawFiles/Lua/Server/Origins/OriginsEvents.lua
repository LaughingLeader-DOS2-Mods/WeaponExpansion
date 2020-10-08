Ext.RegisterOsirisListener("Proc_DallisLootInstantiate", 0, "before", function()
	if SharedData.RegionData.Current == "FJ_FortJoy_Main" then
		if Uniques.DivineBanner.Owner == NPC.BishopAlexander then
			local x,y,z = GetPosition(NPC.BishopAlexander)
			ItemScatterAt(Uniques.DivineBanner.UUID, x, y, z)
			Uniques.DivineBanner:ReleaseFromOwner()
		end
	end
end)

RegisterProtectedOsirisListener("GlobalFlagSet", 1, "before", function(flag)
	if flag == "FTJ_SW_PurgedDragonSaved" then
		if Uniques.Frostdyne.Owner == NPC.Slane then
			local x,y,z = GetPosition(NPC.Slane)
			ItemScatterAt(Uniques.Frostdyne.UUID, x, y, z)
			Uniques.Frostdyne:ReleaseFromOwner()
		end
	end
end)