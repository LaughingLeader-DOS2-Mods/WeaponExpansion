function FortJoyEvent(event)
	if event == "AlexanderDefeated" then
		--Ext.Print(string.format("[FJ_AlexanderDefeated] Owner(%s) Alex(%s) Pos(%s)", Uniques.DivineBanner.Owner, NPC.BishopAlexander, Common.Dump(Ext.GetCharacter(NPC.BishopAlexander).WorldPos)))
		if Uniques.DivineBanner.Owner == NPC.BishopAlexander then
			local x,y,z = GetPosition(NPC.BishopAlexander)
			if x == nil then
				x,y,z = GetPosition(NPC.Dallis)
			end
			Uniques.DivineBanner:ReleaseFromOwner(true)
			ItemScatterAt(Uniques.DivineBanner.UUID, x, y, z)
			PlayEffectAtPosition("RS3_FX_Skills_Divine_Barrage_Impact_01", x, y, z)
		end
	elseif event == "SlaneReward" then
		if Uniques.Frostdyne.Owner == NPC.Slane then
			local x,y,z = GetPosition(NPC.Slane)
			ItemScatterAt(Uniques.Frostdyne.UUID, x, y, z)
			Uniques.Frostdyne:ReleaseFromOwner()
		end
	end
end