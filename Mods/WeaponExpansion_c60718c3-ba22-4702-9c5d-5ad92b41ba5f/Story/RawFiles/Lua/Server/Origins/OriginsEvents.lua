local function PlayFrostdyneLoopedEffect(x, y, z)
	local handle = PlayLoopEffectAtPosition("RS3_FX_UI_Exclamation_Mark_01", x, y, z)
	local removeEffectHandleFunc = nil
	removeEffectHandleFunc = function(item, character)
		if StringHelpers.GetUUID(item) == Uniques.Frostdyne.UUID then
			StopLoopEffect(handle)
			Uniques.Frostdyne:RemoveEventListener("ItemAddedToCharacter", removeEffectHandleFunc)
			CancelTimer("Timers_LLWEAPONEX_SlaneRewardExclamationEffect")
		end
	end
	Uniques.Frostdyne:AddEventListener("ItemAddedToCharacter", removeEffectHandleFunc)
	StartOneshotTimer("Timers_LLWEAPONEX_SlaneRewardExclamationEffect", 5000, function()
		StopLoopEffect(handle)
		Uniques.Frostdyne:RemoveEventListener("ItemAddedToCharacter", removeEffectHandleFunc)
	end)
end

function FortJoyEvent(event)
	fprint(LOGLEVEL.DEFAULT, "[WeaponExpansion:FortJoyEvent]", event)
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
		if StringHelpers.GetUUID(Uniques.Frostdyne:GetOwner()) == NPC.Slane or Vars.DebugMode then
			Uniques.Frostdyne:ReleaseFromOwner()
			if CharacterIsDead(NPC.Slane) == 0 then
				ItemToInventory(Uniques.Frostdyne.UUID, NPC.Slane, 1, 0, 1)
			else
				local x,y,z = GetPosition(NPC.Slane)
				ItemScatterAt(Uniques.Frostdyne.UUID, x, y, z)
				StartOneshotTimer("Timers_LLWEAPONEX_SlaneRewardEffect", 500, function()
					local x,y,z = GetPosition(Uniques.Frostdyne.UUID)
					y = GameHelpers.Grid.GetY(x, z)
					PlayEffectAtPosition("RS3_FX_Skills_Totem_Impact_Target_Root_Ice_01", x, y, z)
					PlayFrostdyneLoopedEffect(x, y+2, z)
				end)
			end
		end
	end
end

--Mods.WeaponExpansion.FortJoyEvent("SlaneReward")